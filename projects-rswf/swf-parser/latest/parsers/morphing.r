rebol [
	title: "SWF morphing shapes related parse functions"
	purpose: "Functions for parsing morphing shape tags in SWF files"
]

	readMORPHFILLSTYLEARRAY: has[FillStyles][
		;print ["FSA:" mold copy/part inBuffer 10]
		byteAlign
		FillStyles: copy []
		loop readCount [ ;FillStyleCount
			append/only FillStyles readMORHFILLSTYLE
	
		]
		;print ["readMFILLSTYLEARRAY" mold FillStyles]
		FillStyles
	]
	readMORPHLINESTYLEARRAY: has[LineStyles][
		LineStyles: copy []
		;byteAlign
		loop readCount [ ;LineStyleCount
			append/only LineStyles either tagId = 46 [
				reduce [
					readUI16 ;StartWidth
					readUI16 ;EndWidth
					readRGBA
					readRGBA
				] ;<= readMORPHLINESTYLE
			][ readMORPHLINESTYLE2 ]
		]
		;print ["readMLINESTYLEARRAY" mold LineStyles]
		LineStyles
	]
	readMORPHLINESTYLE2: has [joinStyle hasFill?][
		reduce [
			readUI16 ;StartWidth
			readUI16 ;EndWidth
			reduce [
				readUB 2 ;f_start_cap_style
				joinStyle: readUB 2 ;f_join_style
				hasFill?:  readBitLogic ;f_has_fill
				readBitLogic ;f_no_hscale
				readBitLogic ;f_no_vscale
				readBitLogic ;f_pixel_hinting
				(
					skipBits 5   ;f_reserved
					readBitLogic ;f_no_close
				)
				readUB 2 ;f_end_cap_style
			]
			either joinStyle = 2 [readUI16][none] ;miterLimit
			either hasFill? [readFILLSTYLE][reduce [readRGBA readRGBA]]
		]
	]
	
	readMORHFILLSTYLE: has[type][
		;print ["fillstyle" mold copy/part inBuffer 10]
		byteAlign
		reduce [
			type: readUI8 ;FillStyleType
			reduce case [
				type = 0 [;solid fill
					[readRGBA readRGBA]
				]
				any [
					type = 16 ;linear gradient fill
					type = 18 ;radial gradient fill
					type = 19 ;focal gradient fill (swf8)
				][;gradient
					[readMATRIX readMATRIX readMORPHGRADIENT type ]
				]
				type >= 64 [;bitmap
					[readUsedID readMATRIX readMATRIX]
				]
			]
		]
	]

	readMORPHGRADIENT: func[type /local gradients][
		byteAlign
		;print ["readMORPHGRADIENT" mold copy/part inBuffer 30 ]
		gradients: copy []
		loop readUI8 [
			insert/only tail gradients reduce [;readMORPHGRADRECORD
				readUI8  ;Start ratio
				readRGBA ;Start color
				readUI8  ;End ratio
				readRGBA ;End color
			]
		]
		gradients
	]
	
	parse-DefineMorphShape:  does [
		reduce [
			readID
			readRECT ;StartBounds
			readRECT ;EndBounds
			readUI32 ;Offset
			readMORPHFILLSTYLEARRAY
			readMORPHLINESTYLEARRAY
			readSHAPE ;StartEdges
			readSHAPE ;EndEdges
		]
	]
	parse-DefineMorphShape2:  does [
		reduce [
			readID
			readRECT ;StartBounds
			readRECT ;EndBounds
			readRECT ;StartEdgeBounds
			readRECT ;EndEdgeBounds
			(
				readUB 6     ;reserved
				readBitLogic ;usesNonScalingStrokes
			)
			readBitLogic ;usesScalingStrokes
			readUI32 ;Offset
			readMORPHFILLSTYLEARRAY
			readMORPHLINESTYLEARRAY
			readSHAPE ;StartEdges
			readSHAPE ;EndEdges
		]
	]

	