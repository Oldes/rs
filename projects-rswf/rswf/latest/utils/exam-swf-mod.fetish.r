rebol [
	purpose: "Modifies the %exam-swf.r script"
]

parse-DefineBitsLossless: func[/local tmp][
	tmp: make block! 5
	insert tmp tag-bin-part/rev 2 ;id
	insert tail tmp tag-bin-part 1 ;BitmapFormat
	insert tail tmp to-pair reduce [
		to-integer tag-bin-part/rev 2
		to-integer tag-bin-part/rev 2
	]	;size
	insert tail tmp tag-bin-part 1 ;BitmapColorTableSize
	;probe ( zlib/decompress tag-bin)
	tmp
]

parse-sprite: func[/local id frames tags][
	tags: make block! 100
	id: bin-to-int tag-bin-part 2 ;sprite ID
	frames: bin-to-int tag-bin-part 2 ;FrameCount
	foreach-tag tag-bin  [insert tail tags reduce [tag data]]
	foreach [id bin] tags [
		tag-bin: copy bin
		;probe reduce [id tag-bin]
		;if id = 26 [probe parse-placeObject2]
	]
	return reduce [id frames tags]
]

parse-DefineButton2: func[/local tmp ofs key menu? bshapes bactions][
	ind+
	obj-id: to-integer tag-bin-part/rev 2
	menu?: #{01} = tag-bin-part 1
	;Offset to the first Button2ActionCondition 
	ofs: to-integer tag-bin-part/rev 2
	;print [tabs "Offset:" ofs]
	ofs: either ofs = 0 [(length? tag-bin) - 1][ofs - 3]
	bshapes: parse-BUTTONRECORD tag-bin-part ofs
	tag-bin-part 1 ;ButtonEndFlag = #{00}
	bactions: make block! []
	if not empty? tag-bin [
		while [not tail? tag-bin][
			ofs: to-integer tag-bin-part/rev 2
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
			k: to-char ub-to-int key
			if k <> #"^@" [insert st compose [key (k)]]
			append/only bactions st
			tmp: tag-bin-part either ofs = 0 [length? tag-bin][ofs - 4]
			;first 7bits are reserved
			append/only bactions parse-ActionRecord tmp
		]
		ind-
	]
	ind-
	compose/deep [shapes [(bshapes)] actions [(bactions)]]
]
parse-BUTTONRECORD: func[bin /local buff tmp states][
	buff: copy tag-bin tag-bin: copy bin
	brecords: make block! 8
	while [not tail? tag-bin][
		tmp: copy skip (enbase/base tag-bin-part 1 2) 4
		states: make block! 4
		repeat i 4 [
			if tmp/:i = #"1" [insert states pick [hit down over up] i]
		]
		append/only brecords states
		ButtonCharacter: to-integer tag-bin-part/rev 2
		ButtonLayer: to-integer tag-bin-part/rev 2
		matrix: parse-matrix
		parse-CXFORMWITHALPHA
		repend/only brecords [ButtonCharacter ButtonLayer matrix]
	]
	tag-bin: buff
	brecords
]
parse-ActionRecord: func[bin-data /local vals cp str pstr word dec reg logic i32][
	ind+
	;probe bin-data
	actions: make block! []
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
		repend actions [actionid data]
	]
	ind-
	actions
]
parse-matrix: func[
	/local bits used-bits val
	 ScaleX ScaleY RotateSkew0 RotateSkew1 TranslateX TranslateY matrix
][
	bits: enbase/base copy tag-bin 2
	used-bits: 7
	matrix: make block! []
	parse bits [
		[
			#"0" ;(tabs print "Has no scale")
			|
			#"1"
			copy val 5 skip (val: UB-to-int val)
			copy ScaleX val skip
			copy ScaleY val skip
			(
				append matrix compose/deep [scale [(FB-to-int ScaleX) (FB-to-int ScaleY)]]
				used-bits: used-bits + 5 + (2 * val)
			)
		]
		[
			#"0" ;(print "Has no rotation")
			|
			#"1"
			copy val 5 skip (val: UB-to-int val)
			copy RotateSkew0 val skip
			copy RotateSkew1 val skip
			(
				append matrix compose/deep [rotate [(FB-to-int RotateSkew0) (FB-to-int RotateSkew1)]]
				used-bits: used-bits + 5 + (2 * val)
			)
		]
		copy val 5 skip (val: UB-to-int val)
		copy TranslateX val skip
		copy TranslateY val skip
		(
			if val = 0 [TranslateX: TranslateY: "0"]
			append matrix compose/deep [at (to-pair reduce [SB-to-int TranslateX SB-to-int TranslateY])]
			used-bits: used-bits + (2 * val)
		)
		to end
	]
	tag-bin: skip tag-bin (extend-int used-bits) / 8
	matrix
]

parse-DefineShape: func [/local shapes][
	ind+
	obj-id: to-integer tag-bin-part/rev 2
	obj-rect: get-rect/integers enbase/base tag-bin 2
	tag-bin: skip tag-bin (extend-int skip-val) / 8
	shapes: parse-SHAPE/WITHSTYLE
	ind-
	shapes
]
parse-SHAPE: func[/withstyle /local fills bits NumBits points b shapes linestyles][
	linestyles: make block! 10
	shapes: make block! 10
	if withstyle [
		parse-FILLSTYLEARRAY
		linestyles: parse-LINESTYLEARRAY
	]
	NumBits: slice-bin/integers (enbase/base tag-bin-part 1 2) [4 4]
	;print [tabs "NumFillBits:" NumBits/1]
	;print [tabs "NumLineBits:" NumBits/2]
	bits: enbase/base copy tag-bin 2
	
	d-pos: 0x0	;drawing position
	d-type: none
	points: make block! []
	add-point: func[x y /curve /move /local type][
		either move [
			d-type: none type: none
			d-pos: to-pair reduce [x y]
		][
			type: either curve ['curve]['line]
			d-pos: to-pair reduce [
				d-pos/1 + x
				d-pos/2 + y
			]
		]
		if all [d-type <> type not none? type][
			if not none? d-type [
				insert tail points last points
			]
			insert back tail points type
			d-type: type
		]
		append points d-pos
		d-pos
	]
	next-shape: func[][
		append/only shapes copy points
		clear points
		d-type: none
	]
	while ["000000" <> copy/part bits 6 ][
		either bits/1 = #"0" [
			;STYLECHANGERECORD
			states: next copy/part bits 6
			bits: skip bits 6
			;print [tabs "States:" states]
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
				if states/1 <> #"1" [
					append points either LineStyle = 0 [
						[no edge]
					][
						st: linestyles/:LineStyle
						compose/deep [edge [width (st/1) color (to-tuple st/2)]]
					]
				]
			]
			either states/1 <> #"1" [
				add-point/move MoveDeltaX MoveDeltaY
			][
				;New styles flag
				next-shape
				print "NEW STYLES"
				b: length? bits
				bits: refill-bits copy bits
				b: (length? bits) - b
				tag-bin: debase/base bits 2
				if b > 0 [tag-bin-part 1]
				parse-FILLSTYLEARRAY
				linestyles: parse-LINESTYLEARRAY
				NumBits: slice-bin/integers (enbase/base tag-bin-part 1 2) [4 4]
				;print [tabs "NumFillBits:" NumBits/1]
				;print [tabs "NumLineBits:" NumBits/2]
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
				;print [tabs "StraightFlag"]
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
				;print [tabs "X-Y:" DeltaX / 20 DeltaY / 20]
				add-point DeltaX DeltaY
			][
				;print [tabs "CurvedFlag"]
				CDeltaX: SB-to-int copy/part bits NBits
				bits: skip bits NBits
				CDeltaY: SB-to-int copy/part bits NBits
				bits: skip bits NBits
				add-point/curve CDeltaX CDeltaY
				;print [tabs "Control X-Y:" CDeltaX / 20 CDeltaY / 20 ]
				ADeltaX: SB-to-int copy/part bits NBits
				bits: skip bits NBits
				ADeltaY: SB-to-int copy/part bits NBits
				bits: skip bits NBits
				add-point/curve ADeltaX ADeltaY
				;print [tabs "Anchor  X-Y:" ADeltaX / 20 ADeltaY / 20 ]
			]
			ind-		
		]
	]
	next-shape
	shapes
]


parse-FILLSTYLEARRAY: func[/local fills type color][
	fills: get-count
	;print [tabs "FillStyleCount:" fills ]
	if fills > 0 [
		ind+
		loop fills [
			type: tag-bin-part 1
			;print [tabs "FillStyleType:" type]
			if type = #{00} [
				color: tag-bin-part either tagid = 32 [4][3]
				;print [tabs "Color:" color]
			]
			if found? find #{1012} type [
				;print [tabs "Gradient matrix:" ]
				parse-matrix
				i: to-integer tag-bin-part 1
				;print [tabs "NumGradients:" i]
				loop i [
					print [tabs "Ratio:" to-integer tag-bin-part 1]
					print [tabs "Color:" to-tuple tag-bin-part either tagid = 32 [4][3]]
				]
			]
			if found? find #{4041} type [
				print [tabs either type = #{40} ["tiled"]["clipped"] "bitmap" tag-bin-part/rev 2]
				print [tabs "Bitmap matrix:" ] parse-matrix
			]
		]
		ind-
	]
]

parse-PlaceObject2: func[/local flags depth CharacterID r][
	ind+
	set [flags depth] slice-bin tag-bin-part 3 [1 2]
	flags: enbase/base flags 2
	;print [tabs "Flags:" flags]
	depth: to-integer reverse depth
	pobj: make block! []
	if flags/8 = #"1" [
		append pobj compose [move depth (depth)]
	] 
	if flags/7 = #"1" [
		append pobj compose [id (to-integer tag-bin-part/rev 2)]
	]
	if flags/6 = #"1" [
		append pobj parse-matrix
	]
	if flags/5 = #"1" [
		;print [tabs "ColorTransform:" tag-bin]
		parse-CXFORM
	]
	if flags/4 = #"1" [
		append pobj compose [ratio (to-integer tag-bin-part/rev 2 )]
	]
	if flags/2 = #"1" [
		;print [tabs "ClipDepth:" to-integer tag-bin-part/rev 2]
		append pobj compose [clipDepth (to-integer tag-bin-part/rev 2 )]
	]
	if flags/3 = #"1" [
		append pobj compose [name (to-string tmp: copy/part tag-bin find tag-bin #{00})]
		tag-bin: skip tag-bin 1 + length? tmp
	]
	if flags/1 = #"1" [
		;print [tabs "ClipActions:" tag-bin]
		something: tag-bin-part 2
		print [tabs "Flags:" flags: enbase/base tag-bin-part 2 2]
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
	ind-
	pobj
]
parse-LINESTYLEARRAY: func[][
	lines: get-count
	linestyles: make block! lines
	if tag-bin/1 > 0 [
		ind+
		loop lines [
			append/only linestyles parse-LINESTYLE
		]
		ind-
	]
	linestyles
]
parse-LINESTYLE: func[/local width rgb][
	width: bin-to-int tag-bin-part 2
	either tagid = 32 [
		rgb: tag-bin-part 4
	][	rgb: tag-bin-part 3	]
	;print [tabs "width:" width "RGB:" rgb]
	reduce [width rgb]
]