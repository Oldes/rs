Rebol [
	title: "SWF Importer"
	Author: "oldes"
	Date:   18-10-2005
	version: 0.0.2
    File:    %import-swf.r
    Email:   oliva.david@seznam.cz
	Purpose: {
       Basic SWF importer. To import swf graphic into the rswf-dialect scripts.
       If I'm importing SWF file into existing one, I must rename all used character ids so they
       will not collide with the existing ones.
    }
    Comment: {It's possible that some of the tags will not be converted correctly yet. I did only what I needed}
    Category: [file util 3]
	History: [
		0.0.2 [18-10-2005 "oldes" "review - all used variables closed in context or used as local"]
		0.0.1 [09-04-2005 "oldes" "Initial version"]
	]
]

swf-importer: make object! [
 	;some local variables used between functions:
	tag-bin: tagid: swf-buff: swf: swf-stream: skip-val: none
	
	replaced-ids: []
	
	new-char-id: func[ /local id new-id idbin newbin][
		id: to-integer reverse copy idbin: copy/part tag-bin 2
		;print ["new-char-id:" id mold rswf/used-ids]
		tag-bin: either find rswf/used-ids id [
			;character id already exists
			new-id: 1 + (last rswf/used-ids)
			insert tail rswf/used-ids new-id
			newbin: rswf/int-to-ui16 new-id
			append replaced-ids copy/deep reduce [idbin newbin]
			print [" ### replacing:" id "=>" new-id]
			change tag-bin newbin
			
		][
			insert tail rswf/used-ids id
			skip tag-bin 2
		]
	]
	get-replaced-id: func[id][
		print ["looking for " id mold replaced-ids]
		foreach [oid nid] replaced-ids [
			if id = oid [return nid]
		]
		id
	]
	replaced-id: func[/ui /local id i][
		id: copy/part tag-bin 2
		tag-bin: either none? i: get-replaced-id id [
			skip tag-bin 2
		][
			print [" ### replaced-id:" mold id "=>" mold i]
			either ui [
				change tag-bin reverse copy i
			][	change tag-bin i ]
			
		]
		copy i
	]
	
	skip-tags: [9 24 58 69]
	
	swf-tags: make block! [
		0  ["end"        ] ;I don't want to import END tag
		1  ["showFrame"  ]
		2  ["DefineShape"     [parse-DefineShape ]]
		4  ["PlaceObject"     [parse-PlaceObject ]]
		5  ["RemoveObject"    [parse-RemoveObject]] 
		6  ["DefineBits"      [parse-defineBits  ]]
		22 ["DefineShape2"    [parse-DefineShape ]]
		24 ["Protected file!" [clear tag-bin     ]] 
		32 ["DefineShape3"    [parse-DefineShape ]]
		9  ["setBackgroundColor" [clear tag-bin  ]]
		10 ["DefineFont"      [parse-defineFont  ]]
		11 ["DefineText"      [parse-defineText  ]]
		12 ["DoAction Tag"  ]
		13 ["DefineFontInfo"]
		
		14 ["DefineSound"     [parse-defineSound ]]
		15 ["StartSound"      [parse-startSound  ]]
		18 ["SoundStreamHead" ]
		19 ["SoundStreamBlock"]
		20 ["DefineBitsLossless" [parse-DefineBitsLossless]]
		21 ["DefineBitsJPEG2" [parse-DefineBitsJPEG2]]
		26 ["PlaceObject2"    [parse-PlaceObject2]]
		28 ["RemoveObject2"] ;;;;;;;;;;;;;;;;;;;;;;nutno dopsat!!!!!!!!!!!!!!!!!!!
		
		34 ["DefineButton2"   [parse-DefineButton2]]
		35 ["DefineBitsJPEG3" [parse-DefineBitsJPEG3]]
		36 ["DefineBitsLossless2" [parse-DefineBitsLossless]]
		37 ["DefineEditText"  [parse-DefineEditText]]
		
		
		39 ["DefineSprite"    [parse-sprite        ]]
		40 ["SWT-CharacterName" [
			print ["ID:" tag-bin-part/rev 2 "="	mold as-string copy/part tag-bin find tag-bin #{00}] 
		]]
		43 ["FrameLabel" []] ;print mold as-string head remove back tail tag-bin]]
		45 ["SoundStreamHead2" ]
		46 ["DefineMorphShape" [parse-DefineMorphShape]]
		48 ["DefineFont2" [parse-DefineFont2]]
		;swf 5
		56 ["ExportAssets" [parse-Assets]]
		57 ["ImportAssets" [parse-Assets/import]]
		58 ["EnableDebugger" [clear tag-bin]]	
		;swf 6
		59 ["DoInitAction" [parse-ActionRecord/init]]
		60 ["DefineVideoStream" [new-char-id]]
		61 ["VideoFrame" [replaced-id]]
		62 ["DefineFontInfo2" [parse-DefineFontInfo/mx]]
		66 ["SetTabIndex" [replaced-id]]
		69 ["FileAttributes" [clear tag-bin]]
		
		;swf8
		73 ["DefineAlignZones" [replaced-id ]]
		74 ["CSMTextSettings" [replaced-id]]
		75 ["DefineFont3" [parse-DefineFont3 ]]
		;77 ["MetaData" [clear tag-bin]]
		78 ["DefineScalingGrid" [replaced-id]]
		
		83 ["DefineShape4" [parse-DefineShape ]]
		84 ["DefineMorphShape2" [new-char-id]]

		
	]
	tag: length: data: none
	indent: 0
	
	;help functions:
	getpart: func[bytes /rev /local tmp][
		tmp: copy/part swf-bin bytes 
		swf-bin: skip swf-bin bytes
		either rev [reverse tmp][tmp]
	]
	
	roundTo: func[val digits /local i d][
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
		if (i: num // 8) > 0 [num: num + 8 - i]
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
	
	SI16-to-int: func[i [binary!]][
		i: reverse i
		i: either #{8000} = and i #{8000} [
			negate (32768 - to-integer (and i #{7FFF}))
		][to integer! i]
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
		/local s p x y i
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
	
	read-rectangle: func[/local rect][
		rect: get-rect/integers enbase/base copy/part tag-bin 16 2
		tag-bin: skip tag-bin (extend-int skip-val) / 8
		rect
	]

	tabs: has [t][t: make string! indent insert/dup t tab indent t] 

	
	tag-bin-part: func[bytes /rev /twips "Converts the result to number in twips" /local tmp][
		tmp: copy/part tag-bin bytes
		tag-bin: skip tag-bin bytes
		either rev [
			reverse tmp
		][	either twips [(to-integer reverse tmp) / 20][tmp]]
	]
	
	get-count: func["Gets the count value from tag-bin (used in some tags)" /local c][
		c: tag-bin-part 1
		to-integer either c = #{FF} [tag-bin-part/rev 2][c]
	]
	
	
	parse-Assets: func[ /import /local assets file id name new-id bin oi i][
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
			print ["ImportingAssets" mold assets/2 "from" assets/1]
		][
			tag-bin: skip tag-bin 2
			bin: copy tag-bin
			while [not tail? tag-bin][
				new-id: copy replaced-id
				;probe tag-bin
				;probe oi: index? tag-bin
				bin: copy (skip bin 2)
				;probe bin
				name: join "imp_" copy/part bin (i: (index? find bin #{00}) - 1)
				;probe i
				tag-bin: skip tag-bin (i + 1)
				bin: copy tag-bin
				;probe tag-bin
				;tag-bin: find/tail tag-bin #{00}
				insert rswf/names-ids-table reduce [to-word name to-integer reverse copy new-id]
				probe reduce ["EXPORT:" to-string name new-id]
			]
		]
	
		assets
	]
	
	parse-defineSound:        func[][new-char-id]
	parse-startSound:         func[][new-char-id]
	parse-DefineBitsJPEG2:    func[][new-char-id]
	parse-DefineBitsJPEG3:    func[][new-char-id]
	parse-DefineBitsLossless: func[][new-char-id]
	parse-DefineMorphShape:   func[][new-char-id]
	
	parse-MORPHFILLSTYLE: func[/local type][
		type: tag-bin-part 1
		if type = #{00} [tag-bin-part 8]
		if type = #{10} [
			parse-matrix
			parse-matrix
			tag-bin-part (10 * to-integer tag-bin-part 1)
		]
		if find #{4041} type [
			replaced-id ;BitmapId
			parse-matrix
			parse-matrix
		]
	
	]
	parse-DefineButton2: func[/local ofs][
		new-char-id ;Button ID
		tag-bin-part 1
		;Offset to the first Button2ActionCondition 
		ofs: to-integer tag-bin-part/rev 2
		ofs: either ofs = 0 [(length? tag-bin) - 1][ofs - 3]
		parse-BUTTONRECORD ofs
	]
	parse-BUTTONRECORD: func[ofs /local i][
		i: index? tag-bin
		while [((index? tag-bin) - i) < ofs][
			tag-bin-part 1
			replaced-id ;ButtonCharacter
			tag-bin-part 2
			parse-matrix
			parse-CXFORMWITHALPHA
			;print ["btnofs: " ((index? tag-bin) - i)]
		]
	]
	
	parse-DefineFont:     func[][new-char-id]
	parse-defineFont2:    func[][new-char-id]
	parse-defineFont3:    func[][new-char-id]
	parse-DefineFontInfo: func[][new-char-id]
	
	parse-defineText: func[/local flags NglyphBits NadvanceBits nGlyphs bytes bits][
		;probe copy/part tag-bin 15
		new-char-id
		;probe copy/part tag-bin 15
		get-rect/integers enbase/base copy/part tag-bin 5 2
		;print [tabs "Rect:" mold get-rect/integers enbase/base copy/part tag-bin 5 2]
		tag-bin: skip tag-bin (extend-int skip-val) / 8
		;probe copy/part tag-bin 10
		parse-matrix
		;probe copy/part tag-bin 10
		;tag-bin-part 2
		NglyphBits: to-integer tag-bin-part 1
		NadvanceBits: to-integer tag-bin-part 1
		;print [tabs "TextRecords:" tag-bin]
		while [
			;all [
				#{00} <> flags: tag-bin-part 1
			;	not empty? flags
			;]
		][
			flags: enbase/base flags 2
			either flags/1 = #"1" [
				;Text Style Change Record
				if flags/5 = #"1" [
					replaced-id ;TextFontID
				]
				if flags/6 = #"1" [tag-bin-part either tagid = 11 [3][4]]
				if flags/7 = #"1" [tag-bin-part 2]
				if flags/8 = #"1" [tag-bin-part 2]
				if flags/5 = #"1" [tag-bin-part 2]
			][
				;Glyph Record
				nGlyphs: ub-to-int copy next flags
				bytes: (extend-int (nGlyphs * (NglyphBits + NadvanceBits))) / 8
				bits: enbase/base tag-bin-part bytes 2
			]
		]
	]

	parse-DefineEditText: func[][new-char-id]
	parse-PlaceObject:    func[][replaced-id]
	parse-RemoveObject:   func[][replaced-id]
	parse-defineBits:     func[][new-char-id]

	parse-PlaceObject2: func[/local flags depth ][
		set [flags depth] slice-bin tag-bin-part 3 [1 2]
		flags: enbase/base flags 2
		if flags/7 = #"1" [	replaced-id	]
	]

	parse-sprite: func[][
		new-char-id
		tag-bin-part 2
		;print "=====>"
		foreach-tag tag-bin show-info
		;print "<-----"
	]

	parse-DefineShape: func [/local MoveBits NumBits bits b][
		new-char-id
		read-rectangle
		if tagid >= 67 [
			read-rectangle ;EdgeRect
			tag-bin-part 1 ;flags
		]
		probe checksum head tag-bin
		parse-SHAPE/WITHSTYLE
		probe checksum head tag-bin
	]
		
parse-SHAPE: func[/withstyle /local fills bits NumBits points b][
	if withstyle [
		parse-FILLSTYLEARRAY
		parse-LINESTYLEARRAY
	]
	NumBits: slice-bin/integers (enbase/base tag-bin-part 1 2) [4 4]
	print [tabs "NumFillBits:" NumBits/1]
	print [tabs "NumLineBits:" NumBits/2]
	bits: enbase/base tag-bin 2
	
	while ["000000" <> copy/part bits 6 ][
		either bits/1 = #"0" [
			;STYLECHANGERECORD
			states: next copy/part bits 6 ;I skip the first bit (TypeFlag)
			print [tabs "States:" states]
			bits: skip bits 6
			if states/5 = #"1" [
				;Move bit count
				MoveBits: UB-to-int copy/part bits 5
				bits: skip bits 5
				;print [tabs "MoveBits:" MoveBits]
				MoveDeltaX: SB-to-int copy/part bits MoveBits
				bits: skip bits MoveBits
				MoveDeltaY: SB-to-int copy/part bits MoveBits
				;print [tabs "MoveX:" MoveDeltaX / 20]
				;print [tabs "MoveY:" MoveDeltaY / 20]
				bits: skip bits MoveBits
				;insert points d-pos: to-pair reduce [MoveDeltaX MoveDeltaY]
			]
			if states/4 = #"1" [
				;Fill style 0 change flag
				FillStyle0: UB-to-int copy/part bits NumBits/1
				bits: skip bits NumBits/1
				;print [tabs "FillStyle0:" FillStyle0]
			]
			if states/3 = #"1" [
				;Fill style 1 change flag
				FillStyle1: UB-to-int copy/part bits NumBits/1
				bits: skip bits NumBits/1
				;print [tabs "FillStyle1:" FillStyle1]
			]
			if states/2 = #"1" [
				;Line style change flag
				LineStyle: UB-to-int copy/part bits NumBits/2
				bits: skip bits NumBits/2
				;print [tabs "LineStyle:" LineStyle]
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
			
			NBits: 2 + UB-to-int copy/part bits 4
			bits: skip bits 4
			;print [tabs "NBits:" NBits]
				
			either Straight? [
				;StraightFlag
				;print [tabs "StraightFlag"]
				LineFlag: bits/1
				bits: next bits
				either LineFlag = #"1" [
					;DeltaX: SB-to-int copy/part bits NBits
					bits: skip bits NBits
					;DeltaY: SB-to-int copy/part bits NBits
					bits: skip bits NBits
				][
					;vertFlag?: #"1" = bits/1
					bits: next bits
					;either vertFlag? [
					;	DeltaY: SB-to-int copy/part bits NBits
					;	DeltaX: 0
					;][
					;	DeltaX: SB-to-int copy/part bits NBits
					;	DeltaY: 0
					;]
					bits: skip bits NBits
				]
				;print [tabs "X-Y:" DeltaX / 20 DeltaY / 20]
			][
			
				bits: skip bits (4 * NBits)

				
				
			]
			;probe points
					
		]
	]
]
parse-FILLSTYLEARRAY: func[/local fills type color i][
	print [tabs "FillStyleCount:" fills: get-count ]
	if fills > 0 [
		
		loop fills [
			print [tabs "FillStyleType:" type: tag-bin-part 1]
			if type = #{00} [
				color: tag-bin-part either tagid >= 32 [4][3]
				print [tabs "Color:" color]
			]
			if found? find #{1012} type [
				print [tabs "Gradient matrix:" ] parse-matrix
				print [tabs "NumGradients:" i: to-integer tag-bin-part 1]
				loop i [
					print [tabs "Ratio:" to-integer tag-bin-part 1]
					print [tabs "Color:" to-tuple tag-bin-part either tagid >= 32 [4][3]]
				]
			]
			if found? find #{40414243} type [
				replaced-id
				print [tabs "Bitmap matrix:" ] parse-matrix
			]
		]
		
	]
]
parse-LINESTYLEARRAY: func[][
	print [tabs "LineStyleCount:" lines: get-count ]
	if tag-bin/1 > 0 [
		
		loop lines [parse-LINESTYLE]
		
	]
]
parse-LINESTYLE: func[/local width rgb flags][
	width: bin-to-int tag-bin-part 2
	if tagid >= 67 [
		flags: enbase/base tag-bin-part 2 2
		print [tabs "Flags:" mold flags]
	]
	rgb: tag-bin-part either tagid >= 32 [4][3]
	print [tabs "width:" width "RGB:" rgb]
]

	parse-CXFORM: func[/local bits flags nBits used-bits v1 v2 v3][
	
		bits: enbase/base copy tag-bin 2
		flags: copy/part bits 2
		bits: skip bits 2
		nBits: UB-to-int copy/part bits 4
		bits: skip bits 4
		used-bits: 6
		if flags/2 = #"1" [
			parse bits [copy v1 nBits skip copy v2 nBits skip copy v3 nBits skip copy bits to end]
			;print [tabs "Multiply:" SB-to-int v1 SB-to-int v2 SB-to-int v3]
			used-bits: used-bits + (3 * nBits)
		]
		if flags/1 = #"1" [
			parse bits [copy v1 nBits skip copy v2 nBits skip copy v3 nBits skip copy bits to end]
			;print [tabs "Addition:" SB-to-int v1 SB-to-int v2 SB-to-int v3]
			used-bits: used-bits + (3 * nBits)
		]
		tag-bin: skip tag-bin (extend-int used-bits) / 8
	
	]
	parse-CXFORMWITHALPHA: func[/local bits flags nBits used-bits v1 v2 v3 v4][
		bits: enbase/base copy tag-bin 2
		flags: copy/part bits 2
		bits: skip bits 2
		nBits: UB-to-int copy/part bits 4
		bits: skip bits 4
		used-bits: 6
		if flags/2 = #"1" [
			parse bits [copy v1 nBits skip copy v2 nBits skip copy v3 nBits skip copy v4 nBits skip copy bits to end]
			;print [tabs "Multiply:" SB-to-int v1 SB-to-int v2 SB-to-int v3 SB-to-int v4]
			used-bits: used-bits + (4 * nBits)
		]
		if flags/1 = #"1" [
			parse bits [copy v1 nBits skip copy v2 nBits skip copy v3 nBits skip copy v4 nBits skip copy bits to end]
			;print [tabs "Addition:" SB-to-int v1 SB-to-int v2 SB-to-int v3 Sb-to-int v4]
			used-bits: used-bits + (4 * nBits)
		]
		tag-bin: skip tag-bin (extend-int used-bits) / 8
	
	]
	parse-matrix: func[
		/local bits used-bits val
		 ScaleX ScaleY RotateSkew0 RotateSkew1 TranslateX TranslateY
	][
	
		bits: enbase/base copy tag-bin 2
		used-bits: 7
		parse bits [
			[
				#"0" ;(tabs print "Has no scale")
				|
				#"1" ;(prin [tabs "Scale:"])
				copy val 5 skip (val: UB-to-int val)
				copy ScaleX val skip
				copy ScaleY val skip
				(;print [(FB-to-int ScaleX) "x" (FB-to-int ScaleY)]
					used-bits: used-bits + 5 + (2 * val)
					; b: b + 5
				)
			]
			[
				#"0" ;(print "Has no rotation")
				|
				#"1" ;(prin [tabs "Rotation: "])
				copy val 5 skip (val: UB-to-int val)
				copy RotateSkew0 val skip
				copy RotateSkew1 val skip
				(	;print [FB-to-int RotateSkew0 FB-to-int RotateSkew1]
					used-bits: used-bits + 5 + (2 * val)
				)
			]
			copy val 5 skip (val: UB-to-int val)
			copy TranslateX val skip
			copy TranslateY val skip
			(
				if val = 0 [TranslateX: TranslateY: "0"]
				;print [tabs "Translate:" (SB-to-int TranslateX) / 20 (SB-to-int TranslateY) / 20]
				used-bits: used-bits + (2 * val)
			)
			to end
		]
		tag-bin: skip tag-bin (extend-int used-bits) / 8
	
	]	
	
	parse-ActionRecord: func[/init][
		if init [
			replaced-id
		]
	]
	
	;#################################################################	
	
	parse-swf-header: func[/local sig nbits rect tmp][
		sig: stream-part 3
		either sig <> #{465753} [
			either sig = #{435753} [
				;print ["This file is compressed Flash MX file!"]
				swf/header/version: to-integer stream-part 1
				swf/header/length: to-integer stream-part/rev 4
				tmp: copy swf-stream
				error? try [close swf-stream]
				if all [
					error? try [swf-stream: copy to-binary decompress tmp]
					error? try [swf-stream: copy to-binary zlib/decompress/l tmp (swf/header/length + 100)]
				][
					print "Cannot decompress the data:("
					halt
				]
			][
				print "Illegal swf header!"
				close swf-stream
				halt
			]
			
		][
			swf/header/version: to-integer stream-part 1
			swf/header/length: to-integer stream-part/rev 4
		]
		swf-buff: stream-part 1
		nbits: to-integer debase/base (refill-bits copy/part (enbase/base swf-buff 2) 5) 2
		insert tail swf-buff stream-part (((extend-int (5 + (4 * nbits))) / 8) - 1)
		rect: slice-bin (skip enbase/base swf-buff 2 5) reduce [nbits nbits nbits nbits]
		forall rect [rect/1: SB-to-int rect/1]
		swf/header/frame-size: head rect
		swf/header/frame-rate: to-integer stream-part 2
		swf/header/frame-count: to-integer stream-part/rev 2
	]
	
	foreach-tag: func[bin action /local t i][
		bind action 'tag
		while [not tail? bin][
			t: copy/part bin 2
			bin: skip bin 2
			set [tag length] slice-bin (enbase/base (reverse t) 2) [10 6]
			tag:    to-integer debase/base refill-bits tag 2
			length: to-integer debase/base refill-bits length 2
			;print [tag length]
			if length = 63 [length: to-integer reverse copy/part bin 4 bin: skip bin 4]
			data: copy/part bin length
			do action
			bin: change bin data
		]
	]
	
	stream-part: func[bytes /rev /twips "Converts the result to number in twips" /local tmp][
		tmp: copy/part swf-stream bytes
		if binary? swf-stream [swf-stream: skip swf-stream bytes]
		either rev [
			reverse tmp
		][	either twips [(to-integer reverse tmp) / 20][tmp]]
	]
	
	foreach-stream-tag: func[ action /local t rh-length][
		bind action 'rh-length
		while [all [not none? t: stream-part 2 not empty? t]][
			rh-length: 2
			set [tag length] slice-bin (enbase/base (reverse t) 2) [10 6]
			tag:    to-integer debase/base refill-bits tag 2
			length: to-integer debase/base refill-bits length 2
			if length = 63 [rh-length: 6 length: to-integer stream-part/rev 4]
			data: either length > 0 [copy stream-part length][make binary! 0 ]
			if not find skip-tags tag [	do action ]
		]
	]
	
	show-info: make block! [
		tagid: tag
		use [ta][
			ta: select swf-tags tag
			print rejoin [tabs ta/1 "(" tagid "): "]
			either found? ta [
				
				either none? ta/2 [
					;print [tag length data]
				][
					tag-bin: data
					;print ["##ST:" length? tag-bin]
					do ta/2
					;print ["##EN:" length? head tag-bin]
				]
			][
				print ["^/^/!!!!!!!!!!!!!!!!!! UNKNOWN TAG" tabs tag length data]
			]
		]
		;if tag = 12 [parse-ActionRecord data]
	]
	
	set 'import-swf func[
		"Imports SWF file structure"
		swf-file [file! url!] "the SWF source file"
		/quiet "No visible output"
		/local f info err
	][
		print ["Importing SWF file... " swf-file]
		;used-char-ids: sort head rswf/used-ids ;character ids which already exists in the wile I'm importing to
		replaced-ids: make block! 50
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
		indent: 0
		skip-val: none ;how many bits i'll have to skip

		if not exists? swf-file [
			f: join swf-file ".swf"
			either exists? f [swf-file: f][print ["Cannot found the file" swf-file "!"]]
		]
		swf-stream: open/direct/read/binary swf-file

		if error? err: try [
			
			parse-swf-header
			;print "-------------------------"
			;probe swf/header
			info: make block! [repend/only swf/data [tag length data]]
			foreach-stream-tag append info show-info
			print "------------------------------------"
			true
		][
			if port? swf-stream [close swf-stream]
			throw err
		]
		if port? swf-stream [close swf-stream]
		swf
	]
]




