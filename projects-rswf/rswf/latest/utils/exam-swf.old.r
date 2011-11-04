Rebol [
	title: "SWF Examiner"
	Author: "oldes"
	Date:   17-12-2001
	version: 0.0.12
    File:    %exam-swf.r
    Email:   oliva.david@seznam.cz
	Purpose: {
       Basic SWF  parser which can
	   show all standard informations from the file. 
    }
    Category: [file util 3]
	History: [
		0.0.12 [17-12-2001 {Support for new tags} "oldes"]
		0.0.7 [30-11-2001 {
		Fixed converting numbers from binary.
		Added support for some other tags as morping and so on} "oldes"]
		0.0.2 [6-11-2001 "New start..." "oldes"]
		0.0.1 [3-Sep-2000 "Initial version" "oldes"]
	]
	comment: {}
]

details?: true
system/options/binary-base: 16



;--------------------------------------




swf-tags: [
	0 ["end" [print ""]]
	1 ["showFrame" [print ""]]
	2 ["DefineShape" [either details? [parse-DefineShape][probe tag-bin]]]
	4 ["PlaceObject2" [parse-PlaceObject]]
	22 ["DefineShape2" [either details? [parse-DefineShape][probe tag-bin]]] ;Extends the capabilities of DefineShape with the ability to support more than 255 styles in the style list and multiple style lists in a single shape. (SWF 2.0)
	24 ["Protected file!"]
	32 ["DefineShape3" [either details? [parse-DefineShape][probe tag-bin]]]	;Extends the capabilities of DefineShape2 by extending all of the RGB color fields to support RGBA with alpha transparency. (SWF 3.0)
	9 ["setBackgroundColor" [print to-tuple tag-bin]]
	10 ["DefineFont" [parse-defineFont]]
	11 ["DefineText" [parse-defineText]]
	13 ["DefineFontInfo" [parse-DefineFontInfo]]
	12 ["DoAction Tag" [print "" parse-ActionRecord tag-bin]]
	20 ["DefineBitsLossless" [parse-DefineBitsLossless]]
	21 ["DefineBitsJPEG2" [parse-DefineBitsJPEG2]]
	26 ["PlaceObject2" [parse-PlaceObject2]]
	28 ["RemoveObject2" ]
	34 ["DefineButton2" [parse-DefineButton2]]
	36 ["DefineBitsLossless2" [parse-DefineBitsLossless]]
	37 ["DefineEditText" [parse-DefineEditText]]
	39 ["DefineSprite" [parse-sprite]]
	40 ["SWT-CharacterName" [
		print ["ID:" tag-bin-part/rev 2 "="	mold to-string copy/part tag-bin find tag-bin #{00}] 
	]]
	43 ["FrameLabel" [print mold to-string head remove back tail tag-bin]]
	46 ["DefineMorphShape" [parse-DefineMorphShape]]
	48 ["DefineFont2" [parse-DefineFont2]]
	;swf 5
	56 ["ExportAssets" [parse-Assets]]
	57 ["ImportAssets" [parse-Assets/import]]
	58 ["EnableDebugger" [prin "Password:" probe tag-bin]]	
	;swf6
	59 ["DoInitAction" [print "" parse-ActionRecord/init tag-bin]]
	62 ["DefineFontInfo2" [parse-DefineFontInfo/mx]]
]
	
;help functions:
getpart: func[bytes /rev /local tmp][
	tmp: copy/part swf-bin bytes 
	swf-bin: skip swf-bin bytes
	either rev [reverse tmp][tmp]
]

round: func[val digits /local i d][
	either parse mold val [copy i to "." 1 skip copy d to end][
		load rejoin [i #"." copy/part d digits]
	][ val ]
]

slice-bin: func [
	"Slices the binary data to parts which length is specified in the bytes block"
	bin [string! binary!]
	bytes [block!]
	/integers "Returns data as block of integers"
	/local tmp b
][
	tmp: make block! length? bytes
	forall bytes [
		b: copy/part bin bytes/1
		append tmp either integers [to-integer debase/base refill-bits b 2][b]
		bin: skip bin bytes/1
	]
	tmp
]
extract-data: func[type][
	swf/chunk/data: slice-bin/integers swf/chunk/data select swf/chunk-bytes type
]

extend-int: func[num /local i][
	i: num // 8
	if i > 0 [num: num + 8 - i]
	num
]

refill-bits: func[
	"When an unsigned bit value is expanded into a larger word size the leftmost bits are filled with zeros."
	bits
	/local n
][
	bits
	n: (length? bits) // 8
	if n > 0 [
		n: 8 - n
		insert/dup head bits #"0" n
	]
	bits		 
]
;end of help functions

bin-to-decimal: func [
    {convert a binary native into a decimal value - also accepts a binary
    string representation in the format returned by REAL/SHOW}
    in      [binary!]
    /local sign exponent fraction
][
    in: copy in
    insert tail in copy/part in 4
	in: reverse remove/part in 4

    sign: either zero? to integer! (first in) / 128 [1][-1]
    exponent: (first in) // 128 * 16 + to integer! (second in) / 16
    fraction: to decimal! (second in) // 16
    in: skip in 2
    loop 6 [
        fraction: fraction * 256 + first in
        in: next in
    ]
    sign * either zero? exponent [
        2 ** -1074 * fraction
    ][
        2 ** (exponent - 1023) * (2 ** -52 * fraction + 1)
    ]
]


UB-to-int: func[
	"converts unsigned bits to integer"
	bits [string! none!]
][
	if none? bits [return 0]
	to-integer debase/base refill-bits bits 2
]
SB-to-int: func[
	"converts signed bits to integer"
	bits [string! binary!]
][
	if binary? bits [bits: enbase/base reverse bits 2]
	to-integer debase/base head insert/dup bits bits/1 (32 - length? bits) 2
]
FB-to-int: func [
	"converts signed fixed-point bit value to integer"
	bits [string!]
	/local s p x y
][
	s: either bits/1 = #"1" [-1][1]
	bits: copy next bits
	p: (length? bits) - 16
	parse bits [copy x p skip copy y to end]
	if none? x [x: ""]
	if none? y [y: "0"]
	d: to-integer (UB-to-int y) / .65535
	i: load rejoin [UB-to-int x "." d]
	if s = -1 [
		i: -1 * either (i // 1) = 0 [i][((to-integer i) + (1 - (i // 1)))]
	]
	i
]
bin-to-int: func[bin][to-integer reverse bin]
str-to-int: func[str][bin-to-int to-binary str]
get-rect: func[
	"Parses Rectangle Record => returns block: [xmin xmax ymin ymax]"
	bin [string! binary!]
	/integers "returns values converted to integers"
	/local nbits rect
][
	nbits: to-integer debase/base (refill-bits copy/part bin 5) 2
	skip-val: 5 + (4 * nbits)
	rect: slice-bin (skip bin 5) reduce [nbits nbits nbits nbits]
	if integers [forall rect [rect/1: SB-to-int rect/1] rect: head rect]
	rect
]

tabs: has [t][t: make string! indent insert/dup t tab indent t] 
ind-: does [indent: indent - 1]
ind+: does [indent: indent + 1]

tag-bin-part: func[bytes /rev /twips "Converts the result to number in twips" /local tmp][
	tmp: copy/part tag-bin bytes
	tag-bin: copy skip tag-bin bytes
	either rev [
		reverse tmp
	][	either twips [(to-integer reverse tmp) / 20][tmp]]
]

get-count: func["Gets the count value from tag-bin (used in some tags)" /local c][
	c: tag-bin-part 1
	to-integer either c = #{FF} [tag-bin-part/rev 2][c]
]


parse-Assets: func[ /import /local assets file id name][
	assets: make block! 6
	either import [
		parse/all tag-bin [
			copy file to #"^@" 3 skip
			some [
				copy id 2 skip copy name to #"^@" 1 skip
				(append assets reduce [bin-to-int to-binary id name])
			]
		]
		assets: reduce [file assets]
	][
		parse/all tag-bin [
			2 skip
			some [
				copy id 2 skip copy name to #"^@" 1 skip
				(append assets reduce [bin-to-int to-binary id name])
			]
		]
	]
	probe assets
]
parse-DefineBitsJPEG2: func[][
	ind+
	print ""
	print [tabs "Bitmap ID:" tag-bin-part/rev 2]
	write/binary %/e/jpg.test tag-bin
	ind-
]
parse-DefineBitsLossless: func[][
	ind+
	print ""
	;probe tag-bin
	print [tabs "Bitmap ID:" tag-bin-part/rev 2]
	print [tabs "BitmapFormat:" select [3 8 4 16 5 32] to-integer tag-bin-part 1 "bits"]
	print [tabs "Size:" to-pair reduce [
		to-integer tag-bin-part/rev 2
		to-integer tag-bin-part/rev 2]
	]
	print [tabs "BitmapColorTableSize:" tag-bin-part 1]
	;probe ( zlib/decompress tag-bin)
	ind-
]

parse-DefineMorphShape: func[/local i end-bin][
	ind+
	print "" ;tag-bin
	print [tabs "Char ID:" tag-bin-part/rev 2]
	print [tabs "Rect start:" mold get-rect/integers enbase/base tag-bin 2]
	tag-bin: skip tag-bin (extend-int skip-val) / 8
	print [tabs "Rect end  :" mold get-rect/integers enbase/base tag-bin 2]
	tag-bin: skip tag-bin (extend-int skip-val) / 8
	print [tabs "Offset:" i: to-integer tag-bin-part/rev 4]
	end-bin: copy skip tag-bin i
	print [tabs "MorphFillStyles:" i: get-count]
	loop i [parse-MORPHFILLSTYLE]
	print [tabs "MorphLineStyles:" i: get-count]
	ind+
	loop i [
		print [tabs "StartWidth:" to-integer tag-bin-part/rev 2]
		print [tabs "EndWidth  :" to-integer tag-bin-part/rev 2]
		print [tabs "StartColor:" to-tuple tag-bin-part 4]
		print [tabs "EndColor  :" to-tuple tag-bin-part 4]
	]
	ind-
	print [tabs "StartEdges:"]
	ind+ parse-SHAPE ind-
	print [tabs "EndEdges:"]
	tag-bin: end-bin
	ind+ parse-SHAPE ind-
	ind-
]

parse-MORPHFILLSTYLE: func[/local type i][
	ind+
	print [tabs "Type:" type: tag-bin-part 1]
	if type = #{00} [
		print [tabs "StartColor:" to-tuple tag-bin-part 4]
		print [tabs "EndColor  :" to-tuple tag-bin-part 4]
	]
	if type = #{10} [
		print [tabs "StartGradientMatrix:" parse-matrix]
		print [tabs "EndGradientMatrix  :" parse-matrix]
		print [tabs "Gradients:" i: tag-bin-part 1]
		ind+
		loop i [
			print [tabs "StartRatio:" tag-bin-part 1]
			print [tabs "StartColor:" to-tuple tag-bin-part 4]
			print [tabs "EndRatio  :" tag-bin-part 1]
			print [tabs "EndColor  :" to-tuple tag-bin-part 4]
		]
		ind- 
	]
	if find #{4041} type [
		print [tabs "BitmapId:" tag-bin-part/rev 2]
		print [tabs "StartBitmapMatrix:" parse-matrix]
		print [tabs "EndBitmapMatrix  :" parse-matrix]
	]
	ind-
]
parse-DefineButton2: func[/local tmp ofs key menu?][
	ind+
	print "" ;tag-bin
	print [tabs "Button ID:" tag-bin-part/rev 2]
	print [tabs "Menu:" menu?: #{01} = tag-bin-part 1]
	;Offset to the first Button2ActionCondition 
	ofs: to-integer tag-bin-part/rev 2
	;print [tabs "Offset:" ofs]
	ofs: either ofs = 0 [(length? tag-bin) - 1][ofs - 3]
	parse-BUTTONRECORD tag-bin-part ofs
	tag-bin-part 1 ;ButtonEndFlag = #{00}
	if not empty? tag-bin [
		print [tabs "Actions:"]
		ind+
		while [not tail? tag-bin][
			ofs: to-integer tag-bin-part/rev 2
			;print [tabs "ActionsOffset:" ofs]
			parse (enbase/base tag-bin-part/rev 2 2) [
				copy key 7 skip copy tmp to end
			]
			st: make block! []
			either menu? [
				if tmp/1 = #"1" [insert st 'DragOut]
				if tmp/2 = #"1" [insert st 'DragOver]
			][
				if tmp/3 = #"1" [insert st 'ReleaseOutside]
				if tmp/4 = #"1" [insert st 'DragOver]
			]
			if tmp/5 = #"1" [insert st 'DragOut]
			if tmp/6 = #"1" [insert st 'Release]
			if tmp/7 = #"1" [insert st 'Press]
			if tmp/8 = #"1" [insert st 'RollOut]
			if tmp/9 = #"1" [insert st 'RollOver]
			print [tabs "Condition:" mold st "Key:" mold to-char ub-to-int key]
			tmp: tag-bin-part either ofs = 0 [length? tag-bin][ofs - 4]
			;first 7bits are reserved
			parse-ActionRecord tmp
		]
		ind-
	]
	ind-
]

parse-BUTTONRECORD: func[bin /local buff tmp st][
	buff: copy tag-bin tag-bin: copy bin
	print [tabs "Buttons:" tag-bin ]
	ind+
		while [not tail? tag-bin][
		tmp: copy skip (enbase/base tag-bin-part 1 2) 4
		st: make block! 4
		repeat i 4 [
			if tmp/:i = #"1" [insert st pick [hit down over up] i]
		]
		print [tabs "States:" mold st]
		ind+
		print [tabs "ButtonCharacter:" tag-bin-part/rev 2]
		print [tabs "ButtonLayer:" tag-bin-part/rev 2]
		ind-
		parse-matrix
		parse-CXFORMWITHALPHA
		]
	ind-
	tag-bin: buff
]

parse-DefineFontInfo: func[/mx /local nameLen flags CodeTable][
	ind+
	print ""
	print [tabs "Font ID:" tag-bin-part 2]
	NameLen: to-integer tag-bin-part 1
	print [tabs "Name:" to-string tag-bin-part NameLen]
	print [tabs "Flags:" flags: enbase/base tag-bin-part 1 2]
	if mx [
		print [tabs "LanguageCode:"  to-integer tag-bin-part 1]
	]
	CodeTable: tag-bin
	print [tabs "Glyphs in CodeTable:" (length? CodeTable) / 2]
	ind-
]

parse-DefineFont2: func[/local flags NameLen glyphs ofsTable wideOfs ofsFST
	FontShapeTable
][
	ind+
	print ""
	;print tag-bin
	print [tabs "Font ID:" tag-bin-part/rev 2]
	flags: enbase/base tag-bin-part 2 2
	print [tabs "Flags:" flags]
	NameLen: to-integer tag-bin-part 1
	print [tabs "Name:" to-string tag-bin-part NameLen]
	print [tabs "Glyphs:" glyphs: to-integer tag-bin-part/rev 2]
	wideOfs: either flags/5 = #"1" [4][2]
	print [tabs "OffsetTable:" ofsTable: tag-bin-part (glyphs * wideOfs)]
	print [tabs "CodeOffset:" codeOffset: to-integer tag-bin-part/rev wideOfs]
	ofsFST: codeOffset - (length? ofsTable) - wideOfs
	;parse-SHAPE
	FontShapeTable: tag-bin-part ofsFST
	print [tabs "FontShapeTable:" length? FontShapeTable]
	FontCodeTable: tag-bin-part (glyphs * (wideOfs / 2))
	print [tabs "FontCodeTable:" length? FontCodeTable]
	if flags/1 = #"1" [
		print [tabs "FontAscent:" SB-to-int tag-bin-part 2]
		print [tabs "FontDescent:" SB-to-int tag-bin-part 2]
		print [tabs "FontLeading:" SB-to-int tag-bin-part 2]
		FontAdvanceTable: tag-bin-part glyphs * 2
		;FontBoundsTable: tag-bin-part glyphs * 
	]
	if not empty? tag-bin [
		print [tabs "..." tag-bin]
	]
	ind-
]

parse-defineFont: func[][
	ind+
	print ""
	print [tabs "Font ID:" tag-bin-part 2]
	print [tabs "...:" tag-bin]
	ind-
]
parse-defineText: func[/local flags][
	ind+
	print ""
	print [tabs "Text ID:" tag-bin-part/rev 2]
	print [tabs "Rect:" mold get-rect/integers enbase/base tag-bin 2]
	tag-bin: skip tag-bin (extend-int skip-val) / 8
	print [tabs "Matrix:" tag-bin] parse-matrix
	print [tabs "NglyphBits:" NglyphBits: to-integer tag-bin-part 1]
	print [tabs "NadvanceBits:" NadvanceBits: to-integer tag-bin-part 1]
	print [tabs "TextRecords:" tag-bin]
	ind+
	while [#{00} <> flags: tag-bin-part 1][
		flags: enbase/base flags 2
		either flags/1 = #"1" [
			;Text Style Change Record
			if flags/5 = #"1" [
				print [tabs "TextFontID:" tag-bin-part/rev 2 ]
			]
			if flags/6 = #"1" [
				print [tabs "TextColor:" to-tuple tag-bin-part either tagid = 11 [3][4]]
			]
			if flags/7 = #"1" [
				print [tabs "TextXOffset:" to-integer tag-bin-part/rev 2 ]
			]
			if flags/8 = #"1" [
				print [tabs "TextYOffset:" to-integer tag-bin-part/rev 2 ]
			]
			if flags/5 = #"1" [
				print [tabs "TextHeight:" (to-integer tag-bin-part/rev 2) / 20 ]
			]
		][
			;Glyph Record
			print [tabs "TextGlyphCount:" nGlyphs: ub-to-int copy next flags]
			probe bytes: (extend-int (nGlyphs * (NglyphBits + NadvanceBits))) / 8
			probe bits: enbase/base tag-bin-part bytes 2
			parse bits [any [
				copy i NglyphBits skip
				copy j NadvanceBits skip
				(print [tabs "GlyphEntry:" ub-to-int i sb-to-int j])
			]]
		]
	]
	ind-
	ind-
]
parse-DefineEditText: func[/local flags bits rect InitialText var][
	ind+
	print ""
	probe tag-bin
	print [tabs "TextID:" tag-bin-part/rev 2]
	bits: enbase/base tag-bin 2
	rect: get-rect bits
	bits: skip bits extend-int (5 + (4 * length? rect/1))
	forall rect [rect/1: SB-to-int rect/1] rect: head rect
	print [tabs "Bounds:" rect]
	flags: copy/part bits 16
	tag-bin: load rejoin ["2#{" skip bits 16 "}"]
	print [tabs "Flags:" flags]
	ind+
	if flags/8 = #"1" [
		print [tabs "HasFont:" tag-bin-part/rev 2]
		print [tabs "FontHeight:" tag-bin-part/twips 2]
	]
	if flags/6 = #"1" [print [tabs "TextColor:" tag-bin-part 4]]
	if flags/7 = #"1" [print [tabs "MaxLength:" to-integer tag-bin-part/rev 2]]
	if flags/11 = #"1" [
		;HasLayout
		print [tabs "Align:" pick ['left 'right 'center 'justify] 1 + to-integer tag-bin-part 1]
		print [tabs "LeftMargin:" tag-bin-part/twips 2]
		print [tabs "RightMargin:" tag-bin-part/twips 2]
		print [tabs "Indent:" tag-bin-part/twips 2]
		print [tabs "Leading:" tag-bin-part/twips 2]
	]
	ind-
	parse/all tag-bin [copy var to #"^@" 1 skip InitialText: [to #"^@" | to end]]
	print [tabs "VariableName:" var]
	if flags/1 = #"1" [print [tabs "InitialText:" InitialText]]
	
	probe debase/base bits 2
	
	ind-
]
parse-PlaceObject: func[/local flags depth CharacterID][
	ind+
	print tag-bin
	print [tabs "CharID:" tag-bin-part 2]
	print [tabs "Depth:" tag-bin-part 2]
	parse-matrix

	ind-
]
parse-PlaceObject2: func[/local flags depth CharacterID r MXflags][
	ind+
	print "";tag-bin
	set [flags depth] slice-bin tag-bin-part 3 [1 2]
	flags: enbase/base flags 2
	print [tabs "Flags:" flags]
	print [tabs "Depth:" to-integer reverse depth]
	print [tabs  either flags/8 = #"1" ["Character is already in the list"]["Placing new character"]]
	if flags/7 = #"1" [
		print [tabs "CharacterID:" to-integer tag-bin-part/rev 2]
	]
	if flags/6 = #"1" [
		print [tabs "Matrix:" ]
		parse-matrix
	]
	if flags/5 = #"1" [
		print [tabs "ColorTransform:" tag-bin]
		parse-CXFORM
	]
	if flags/4 = #"1" [
		print [tabs "Ratio:" r: to-integer tag-bin-part/rev 2 rejoin ["( " round (r / 65535 * 100) 2 "% )"]]
	]
	if flags/2 = #"1" [
		print [tabs "ClipDepth:" to-integer tag-bin-part/rev 2]
	]
	if flags/3 = #"1" [
		print [tabs "Name:" mold to-string tmp: copy/part tag-bin find tag-bin #{00}]
		tag-bin: skip tag-bin 1 + length? tmp
	]
	if flags/1 = #"1" [
		print [tabs "ClipActions:" tag-bin]
		something: tag-bin-part 2
		print [tabs "Flags:" flags: enbase/base tag-bin-part 2 2]
		either swf/header/version > 5 [
			something: tag-bin-part 2
			while [#{00000000} <> type: tag-bin-part 4][
				print [tabs "On" select [
					#{01000000} "Load"
					#{02000000} "EnterFrame"
					#{04000000} "Unload"
					#{10000000} "MouseDown"
					#{20000000} "MouseUp"
					#{08000000} "MouseMove"
					#{40000000} "KeyDown"
					#{80000000} "KeyUp"
					#{00010000} "Data"
					] type
				]
				ofs: to-integer tag-bin-part/rev 4
				parse-ActionRecord tag-bin-part ofs
			]
		][
			while [#{0000} <> type: tag-bin-part 2][
				print [tabs "On" select [
					#{0100} "Load"
					#{0200} "EnterFrame"
					#{0400} "Unload"
					#{1000} "MouseDown"
					#{2000} "MouseUp"
					#{0800} "MouseMove"
					#{4000} "KeyDown"
					#{8000} "KeyUp"
					#{0001} "Data"
					] type
				]
				ofs: to-integer tag-bin-part/rev 4
				parse-ActionRecord tag-bin-part ofs
			]
		]
	]
	ind-
]

parse-CXFORM: func[/local bits flags nBits v1 v2 v3][
	ind+
	bits: enbase/base copy tag-bin 2
	flags: copy/part bits 2
	bits: skip bits 2
	nBits: UB-to-int copy/part bits 4
	bits: skip bits 4
	used-bits: 6
	if flags/2 = #"1" [
		parse bits [copy v1 nBits skip copy v2 nBits skip copy v3 nBits skip copy bits to end]
		print [tabs "Multiply:" SB-to-int v1 SB-to-int v2 SB-to-int v3]
		used-bits: used-bits + (3 * nBits)
	]
	if flags/1 = #"1" [
		parse bits [copy v1 nBits skip copy v2 nBits skip copy v3 nBits skip copy bits to end]
		print [tabs "Addition:" SB-to-int v1 SB-to-int v2 SB-to-int v3]
		used-bits: used-bits + (3 * nBits)
	]
	tag-bin: skip tag-bin (extend-int used-bits) / 8
	ind-
]
parse-CXFORMWITHALPHA: func[/local bits flags nBits v1 v2 v3 v4][
	ind+
	bits: enbase/base copy tag-bin 2
	flags: copy/part bits 2
	bits: skip bits 2
	nBits: UB-to-int copy/part bits 4
	bits: skip bits 4
	used-bits: 6
	if flags/2 = #"1" [
		parse bits [copy v1 nBits skip copy v2 nBits skip copy v3 nBits skip copy v4 nBits skip copy bits to end]
		print [tabs "Multiply:" SB-to-int v1 SB-to-int v2 SB-to-int v3 SB-to-int v4]
		used-bits: used-bits + (4 * nBits)
	]
	if flags/1 = #"1" [
		parse bits [copy v1 nBits skip copy v2 nBits skip copy v3 nBits skip copy v4 nBits skip copy bits to end]
		print [tabs "Addition:" SB-to-int v1 SB-to-int v2 SB-to-int v3 Sb-to-int v4]
		used-bits: used-bits + (4 * nBits)
	]
	tag-bin: skip tag-bin (extend-int used-bits) / 8
	ind-
]
parse-matrix: func[
	/local bits used-bits val
	 ScaleX ScaleY RotateSkew0 RotateSkew1 TranslateX TranslateY
][
	ind+
	bits: enbase/base copy tag-bin 2
	used-bits: 7
	parse bits [
		[
			#"0" ;(tabs print "Has no scale")
			|
			#"1" (prin [tabs "Scale:"])
			copy val 5 skip (val: UB-to-int val)
			copy ScaleX val skip
			copy ScaleY val skip
			(print [(FB-to-int ScaleX) "x" (FB-to-int ScaleY)]
				used-bits: used-bits + 5 + (2 * val)
			)
		]
		[
			#"0" ;(print "Has no rotation")
			|
			#"1" (prin [tabs "Rotation: "])
			copy val 5 skip (val: UB-to-int val)
			copy RotateSkew0 val skip
			copy RotateSkew1 val skip
			(	print [FB-to-int RotateSkew0 FB-to-int RotateSkew1]
				used-bits: used-bits + 5 + (2 * val)
			)
		]
		copy val 5 skip (val: UB-to-int val)
		copy TranslateX val skip
		copy TranslateY val skip
		(
			if val = 0 [TranslateX: TranslateY: "0"]
			print [tabs "Translate:" (SB-to-int TranslateX) / 20 (SB-to-int TranslateY) / 20]
			used-bits: used-bits + (2 * val)
		)
		to end
	]
	tag-bin: skip tag-bin (extend-int used-bits) / 8
	ind-
]

parse-sprite: func[][
	ind+
	print ""
	;print tag-bin
	print [tabs "Sprite ID:" tag-bin-part 2]
	print [tabs "FrameCount:" tag-bin-part 2]
		ind+
		probe tag-bin
		foreach-tag tag-bin  show-info
		ind-
	ind-
]
parse-DefineShape: func [][
	ind+
	print "";tag-bin
	print [tabs "ShapeId:" tag-bin-part 2]
	print [tabs "Rect:" mold get-rect/integers enbase/base tag-bin 2]
	tag-bin: skip tag-bin (extend-int skip-val) / 8
	parse-SHAPE/WITHSTYLE
	ind-
]

parse-SHAPE: func[/withstyle /local fills bits NumBits points b][
	if withstyle [
		parse-FILLSTYLEARRAY
		parse-LINESTYLEARRAY
	]
	NumBits: slice-bin/integers (enbase/base tag-bin-part 1 2) [4 4]
	print [tabs "NumFillBits:" NumBits/1]
	print [tabs "NumLineBits:" NumBits/2]
	bits: enbase/base copy tag-bin 2
	
	d-pos: 0x0	;drawing position
	points: make block! []
	add-point: func[x y][
		np: to-pair reduce [
			d-pos/1 + x
			d-pos/2 + y
		]
		append points np
		d-pos: np
	]
	while ["000000" <> copy/part bits 6 ][
		either bits/1 = #"0" [
			;STYLECHANGERECORD
			states: next copy/part bits 6
			bits: skip bits 6
			print [tabs "States:" states]
			if states/5 = #"1" [
				;Move bit count
				MoveBits: UB-to-int copy/part bits 5
				bits: skip bits 5
				;print [tabs "MoveBits:" MoveBits]
				MoveDeltaX: SB-to-int copy/part bits MoveBits
				bits: skip bits MoveBits
				MoveDeltaY: SB-to-int copy/part bits MoveBits
				print [tabs "MoveX:" MoveDeltaX / 20]
				print [tabs "MoveY:" MoveDeltaY / 20]
				bits: skip bits MoveBits
				insert points d-pos: to-pair reduce [MoveDeltaX MoveDeltaY]
			]
			if states/4 = #"1" [
				;Fill style 0 change flag
				FillStyle0: UB-to-int copy/part bits NumBits/1
				bits: skip bits NumBits/1
				print [tabs "FillStyle0:" FillStyle0]
			]
			if states/3 = #"1" [
				;Fill style 1 change flag
				FillStyle1: UB-to-int copy/part bits NumBits/1
				bits: skip bits NumBits/1
				print [tabs "FillStyle1:" FillStyle1]
			]
			if states/2 = #"1" [
				;Line style change flag
				LineStyle: UB-to-int copy/part bits NumBits/2
				bits: skip bits NumBits/2
				print [tabs "LineStyle:" LineStyle]
			]
			if states/1 = #"1" [
				;New styles flag
				print "NEW STYLES"
				b: length? bits
				bits: refill-bits copy bits
				b: (length? bits) - b
				tag-bin: debase/base bits 2
				if b > 0 [tag-bin-part 1]
				parse-FILLSTYLEARRAY
				parse-LINESTYLEARRAY
				NumBits: slice-bin/integers (enbase/base tag-bin-part 1 2) [4 4]
				print [tabs "NumFillBits:" NumBits/1]
				print [tabs "NumLineBits:" NumBits/2]
				bits: enbase/base copy tag-bin 2
			]
		][
			;Edge Records
			bits: next bits
			Straight?: bits/1 = #"1"
			bits: next bits
			ind+
			NBits: 2 + UB-to-int copy/part bits 4
			bits: skip bits 4
			;print [tabs "NBits:" NBits]
				
			either Straight? [
				;StraightFlag
				print [tabs "StraightFlag"]
				LineFlag: bits/1
				bits: next bits
				either LineFlag = #"1" [
					DeltaX: SB-to-int copy/part bits NBits
					bits: skip bits NBits
					DeltaY: SB-to-int copy/part bits NBits
					bits: skip bits NBits
				][
					vertFlag?: #"1" = bits/1
					bits: next bits
					either vertFlag? [
						DeltaY: SB-to-int copy/part bits NBits
						DeltaX: 0
					][
						DeltaX: SB-to-int copy/part bits NBits
						DeltaY: 0
					]
					bits: skip bits NBits
				]
				print [tabs "X-Y:" DeltaX / 20 DeltaY / 20]
			][
				print [tabs "CurvedFlag"]
				CDeltaX: SB-to-int copy/part bits NBits
				bits: skip bits NBits
				CDeltaY: SB-to-int copy/part bits NBits
				bits: skip bits NBits
				add-point CDeltaX CDeltaY
				print [tabs "Control X-Y:" CDeltaX / 20 CDeltaY / 20 ]
				ADeltaX: SB-to-int copy/part bits NBits
				bits: skip bits NBits
				ADeltaY: SB-to-int copy/part bits NBits
				bits: skip bits NBits
				add-point ADeltaX ADeltaY
				print [tabs "Anchor  X-Y:" ADeltaX / 20 ADeltaY / 20 ]
			]
			;probe points
			ind-		
		]
	]
]
parse-FILLSTYLEARRAY: func[/local fills type color][
	print [tabs "FillStyleCount:" fills: get-count ]
	if fills > 0 [
		ind+
		loop fills [
			print [tabs "FillStyleType:" type: tag-bin-part 1]
			if type = #{00} [
				color: tag-bin-part either tagid = 32 [4][3]
				print [tabs "Color:" color]
			]
			if found? find #{1012} type [
				print [tabs "Gradient matrix:" ] parse-matrix
				print [tabs "NumGradients:" i: to-integer tag-bin-part 1]
				loop i [
					print [tabs "Ratio:" to-integer tag-bin-part 1]
					print [tabs "Color:" to-tuple tag-bin-part either tagid = 32 [4][3]]
				]
			]
			if found? find #{40414243} type [
				print [tabs switch type [
					#{40} ["tiled"]
					#{41} ["clipped"]
					#{42} ["no sm. tiled"]
					#{43} ["no sm. clipped"]
				] "bitmap" tag-bin-part/rev 2]
				print [tabs "Bitmap matrix:" ] parse-matrix
			]
		]
		ind-
	]
]
parse-LINESTYLEARRAY: func[][
	print [tabs "LineStyleCount:" lines: get-count ]
	if tag-bin/1 > 0 [
		ind+
		loop lines [parse-LINESTYLE]
		ind-
	]
]
parse-LINESTYLE: func[/local width rgb][
	width: bin-to-int tag-bin-part 2
	either tagid = 32 [
		rgb: tag-bin-part 4
	][	rgb: tag-bin-part 3	]
	print [tabs "width:" width "RGB:" rgb]
]

ConstantPool: make block! []

parse-ActionRecord: func[bin-data /init /local vals cp str pstr word dec reg logic i32 ofs][
	ind+
	probe bin-data
	if init [
		print [tabs "For sprite:" copy/part bin-data 2]
		bin-data: skip bin-data 2
	]
	actions: make block! []
aparsers: [
	"ActionGetURL" [
		print [tabs aname mold parse/all data "^@"]
	]
	"ActionConstantPool" [
		ConstantPool: next parse/all data "^@"
		print [tabs aname data mold ConstantPool]
	]
	"ActionIf" [
		ofs: sb-to-int data
		either ofs < 0 [
			print [tabs aname data "(" ofs ")"]
		][ 
			print [tabs aname]
			parse-ActionRecord bin-part ofs
		]
	]
	"ActionDefineFunction" [
		vals: make block! []
		set [data codeSize] slice-bin data reduce [(length? data) - 2 2]
		parse/all data [str word any [str]]
		print [tabs aname rejoin [vals/1 mold skip vals 2]]
		parse-ActionRecord bin-part bin-to-int codeSize
	]
	"ActionPush" [
		vals: make block! []
		parse/all data [some [cp | i32 | dec | pstr | logic | reg | null]]
		print [tabs aname data mold vals]
	]
]
	cp: ["^H" copy v 1 skip
		(append vals pick ConstantPool v: 1 + str-to-int v)
	]
	i32: ["^G" copy v 4 skip
		(append vals v: str-to-int v)
	]
	pstr: ["^@" copy v to "^@" 1 skip
		(append vals v)
	]
	logic: ["^E" copy v 1 skip
		(append vals pick [false true] 1 + str-to-int v)
	]
	null: ["^B" ( append vals 'null )]
	dec: ["^F" copy v 8 skip
		(append vals bin-to-decimal to-binary v)
	]
	reg: ["^D" copy v 1 skip
		(append vals to-path join "register/" 1 + str-to-int v)
	]
	str: [copy v to "^@" 1 skip (append vals v) ]
	word: [copy v 2 skip (append vals str-to-int v)	]
	actionid: none
	bin-part: func[bytes][b: copy/part bin-data bytes bin-data: skip bin-data bytes b]
	while [all [actionid <> #{00} not empty? bin-data] ][
		actionid: bin-part 1
		length: to-integer either actionid > #{80} [reverse bin-part 2][0]
		data: bin-part length
		aname: select actionids actionid
		switch/default aname aparsers [
			print [tabs aname actionid data]
		]
	]
	ind-
]
	actionids: [
		#{00} "END of ActionRecord"
		;SWF3 Actions
		#{04} "ActionNextFrame"
		#{05} "ActionPrevFrame"
		#{06} "ActionPlay"
		#{07} "ActionStop"
		#{08} "ActionToggleQuality"
		#{09} "ActionStopSounds"	
		#{81} "ActionGotoFrame"
		#{83} "ActionGetURL"
		#{8A} "ActionWaitForFrame"
		#{8B} "ActionSetTarget"
		#{8C} "ActionGoToLabel"
		;Stack Operations
		#{96} "ActionPush"
		#{17} "ActionPop"
		;Arithmetic Operators
		#{0A} "ActionAdd"
		#{0B} "ActionSubtract"
		#{0C} "ActionMultiply"
		#{0D} "ActionDivide"
		;Numerical Comparison
		#{0E} "ActionEquals"
		#{0F} "ActionLess"
		;Logical Operators
		#{10} "ActionAnd"
		#{11} "ActionOr"
		#{12} "ActionNot"
		;String Manipulation
		#{13} "ActionStringEquals"
		#{14} "ActionStringLength"
		#{21} "ActionStringAdd"
		#{15} "ActionStringExtract"
		#{29} "ActionStringLess"
		#{31} "ActionMBStringLength"
		#{35} "ActionMBStringExtract"
		;Type Conversion
		#{18} "ActionToInteger"
		#{32} "ActionCharToAscii"
		#{33} "ActionAsciiToChar"
		#{36} "ActionMBCharToAscii"
		#{37} "ActionMBAsciiToChar"
		;Control Flow
		#{99} "ActionJump"
		#{9D} "ActionIf"
		#{9E} "ActionCall"
		;Variables
		#{1C} "ActionGetVariable"
		#{1D} "ActionSetVariable"
		;Movie Control
		#{9A} "ActionGetURL2"
		#{9F} "ActionGotoFrame2"
		#{20} "ActionSetTarget2"
		#{22} "ActionGetProperty"
		#{23} "ActionSetProperty"
		#{24} "ActionCloneSprite"
		#{25} "ActionRemoveSprite"
		#{27} "ActionStartDrag"
		#{28} "ActionEndDrag"
		#{8D} "ActionWaitForFrame2"
		;Utilities
		#{26} "ActionTrace"
		#{34} "ActionGetTime"
		#{30} "ActionRandomNumber"
		;SWF 5
		;ScriptObject Actions
		#{3D} "ActionCallFunction"
		#{52} "ActionCallMethod"
		#{88} "ActionConstantPool"
		#{9B} "ActionDefineFunction"
		#{3C} "ActionDefineLocal"
		#{41} "ActionDefineLocal2"
		#{43} "ActionDefineObject" ;this was not in the specification!
		#{3A} "ActionDelete"
		#{3B} "ActionDelete2"
		#{46} "ActionEnumerate"
		#{49} "ActionEquals2"
		#{4E} "ActionGetMember"
		#{42} "ActionInitArray/Object"
		#{53} "ActionNewMethod"
		#{40} "ActionNewObject"
		#{4F} "ActionSetMember"
		#{45} "ActionTargetPath"
		#{94} "ActionWith"
		;Type Actions
		#{4A} "ActionToNumber"
		#{4B} "ActionToString"
		#{44} "ActionTypeOf"
		;Math Actions
		#{47} "ActionAdd2"
		#{48} "ActionLess2"
		#{3F} "ActionModulo"
		;Stack Operator Actions
		#{60} "ActionBitAnd"
		#{63} "ActionBitLShift"
		#{61} "ActionBitOr"
		#{64} "ActionBitRShift"
		#{65} "ActionBitURShift"
		#{62} "ActionBitXor"
		#{51} "ActionDecrement"
		#{50} "ActionIncrement"
		#{4C} "ActionPushDuplicate"
		#{3E} "ActionReturn"
		#{4D} "ActionStackSwap"
		#{87} "ActionStoreRegister"
		
		;flashMX Actions
		#{66} "ActionStrictEqual"
	]



parse-swf-header: func[/local sig][
	tag-bin: copy swf-bin
	sig: tag-bin-part 3
	if sig <> #{465753} [
		either sig = #{435753} [
			print "This file is compressed Flash MX file!"
		][	print "Illegal swf header!" halt ]
	]
	swf/header/version: to-integer tag-bin-part 1
	swf/header/length: to-integer tag-bin-part/rev 4
	swf/header/frame-size: get-rect/integers enbase/base tag-bin 2
	tag-bin: skip tag-bin (extend-int skip-val) / 8
	swf/header/frame-rate: to-integer tag-bin-part 2
	swf/header/frame-count: to-integer tag-bin-part/rev 2
	swf-bin: copy tag-bin
]


foreach-tag: func[bin action /local tag length data getpart][
	getpart: func[bytes /rev /local tmp][
		tmp: copy/part bin bytes 
		bin: skip bin bytes
		either rev [reverse tmp][tmp]
	]
	tag: none
	bind action 'tag
	while [not tail? bin][
		t: getpart 2
		set [tag length] slice-bin (enbase/base (reverse t) 2) [10 6]
		tag:    to-integer debase/base refill-bits tag 2
		length: to-integer debase/base refill-bits length 2
		;print [tag length]
		if length = 63 [length: to-integer getpart/rev 4]
		probe data: getpart length
		do action
	]
]
show-info: [
	tagid: tag
	t: select swf-tags tag
	either found? t [
		prin rejoin [tabs t/1 "(" tagid "): "]
		either none? t/2 [
			print [tag length data]
		][
			tag-bin: data
			do t/2
		]
	][print [tabs tag length data]]
]

sysprint: get in system/words 'print
sysprin: get in system/words 'prin
exam-swf: func[ /file swf-file [file! url!] /quiet /local f info err][
	;--------[ global variables ]----------
	swf: make object! [
		header: make object! [
			version: none
			length: none
			frame-size: make block! []
			frame-rate: none
			frame-count: none
		]
		rect: none
		data: make block! 10
	]
	obj-id: 0
	indent: 0
	used-bits: 0
	skip-val: none ;how many bits i'll have to skip
	
	if none? swf-file [
		if empty? swf-file: to-file ask "SWF file:" [swf-file: %new.swf]
	]
	if not exists? swf-file [
		f: join swf-file ".swf"
		either exists? f [swf-file: f][print ["Cannot found the file" swf-file "!"]]
	]
	swf-bin: read/binary swf-file
	if quiet [
		prin: print: func[str][reduce str]
	]
	if error? err: try [
		prin "Searching the binary file... "
		print reform ["swf size:" length? swf-bin "bytes"]
		parse-swf-header
		print "-------------------------"
		probe swf/header
		info: make block! [repend/only swf/data [tag length data]]
		foreach-tag swf-bin append info show-info
		print: :sysprint
		prin: :sysprin
	][
		print: :sysprint
		prin: :sysprin
		throw err
	]
	
	swf
]





