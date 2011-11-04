rebol [
	title: "SWF shape parse functions"
	purpose: "Functions for parsing shape tags in SWF files"
]

	readFILLSTYLEARRAY: has[FillStyles][
		;print ["FSA:" mold copy/part inBuffer 10]
		byteAlign
		FillStyles: copy []
		loop readCount [ ;FillStyleCount
			append/only FillStyles readFILLSTYLE
	
		]
		;print ["readFILLSTYLEARRAY" mold FillStyles]
		FillStyles
	]
	readFILLSTYLE: has[type][
		;print ["fillstyle" mold copy/part inBuffer 10]
		byteAlign
		reduce [
			type: readUI8 ;FillStyleType
			case [
				type = 0 [
					;solid fill
					case [
						find [46 84] tagId [
							;morph
							reduce [readRGBA readRGBA]
						]
						tagId >= 32 [readRGBA]
						true [readRGB]
					]
				]
				any [
					type = 16 ;linear gradient fill
					type = 18 ;radial gradient fill
					type = 19 ;focal gradient fill (swf8)
				][
					;gradient
					reduce either find [46 84] tagId [
						;morph
						[readMATRIX readMATRIX readGRADIENT type ]
					][	;shape
						[readMATRIX readGRADIENT type]
					]
				]
				type >= 64 [
					;bitmap
					reduce either find [46 84] tagId [
						;morph
						[readUsedID readMATRIX readMATRIX]
					][	;shape
						[readUsedID readMATRIX]
					]
				]
			]
		]
	]
	readLINESTYLEARRAY: has[LineStyles][
		LineStyles: copy []
		byteAlign
		;print ["LSA:" mold copy/part inBuffer 10]
		loop readCount [ ;LineStyleCount
			append/only LineStyles readLINESTYLE
		]
	;	print ["readLINESTYLEARRAY" mold LineStyles]
		LineStyles
	]
	readLINESTYLE: has[flags][
		byteAlign
		
		reduce case [
			;DefineMorphShape
			tagId = 46 [
				[
					readUI16 ;StartWidth
					readUI16 ;EndWidth
					readRGBA
					readRGBA
				]
			]
			;DefineShape4
			any [tagId = 67 tagId = 83][
				[
					readUI16 ;Width
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
					either hasFill? [print "HASFILL" readFILLSTYLE][readRGBA]
				]
			]
			;DefineMorphShape2
			tagId = 84 [
				[
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
			true [
				[
					readUI16 ;Width
					either tagId = 32 [readRGBA][readRGB]
				]
			]
			
		]

	]
	readGRADIENT: func[type /local gradients][
		byteAlign
	;	print ["gradient:" to-hex type]
		reduce [
			readUB 2 ;SpreadMode
			readUB 2 ;InterpolationMode
			(
				gradients: copy []
				loop readUB 4 [
					insert tail gradients readGRADRECORD
				]
				gradients
			)
			either all [type = 19 tagId = 83] [readSShortFixed][none] ;FocalPoint
		]
	]
	readGRADRECORD: has[][
		reduce [
			readUI8 ;ratio
			either tagId >= 32 [readRGBA][readRGB] ;color
		]
	]
	readSHAPERECORD: func[numFillBits numLineBits /local nBits lineType states records][
		;print ["readSHAPERECORD" numFillBits numLineBits "availableBits:" availableBits mold copy/part inBuffer 10] 
		;probe inBuffer
		records: copy []
		lineType: none
		byteAlign		
		until [
			either readBitLogic [ ;edge?
				;print "edge"
				either readBitLogic [;straightEdge?
					;print "line - "
					if lineType <> 'line [insert tail records lineType: 'line]
					nBits: 2 + readUB 4
					insert tail records reduce either readBitLogic [
						;GeneralLine
						[
							readSB nBits ;deltaX
							readSB nBits ;deltaY
						]
					][
						either readBitLogic [
							;Vertical
							[0 readSB nBits]
						][	;Horizontal
							[readSB nBits 0]
						]
					]
				][
					;print "curve - "
					if lineType <> 'curve [insert tail records lineType: 'curve]
					nBits: 2 + readUB 4
					insert tail records reduce [
						readSB nBits ;controlDeltaX
						readSB nBits ;Y
						readSB nBits ;anchorDeltaX
						readSB nBits ;Y
					]
				]
				false
			][
				states: readUB 5
				;print ["STATES:" states]
				either states = 0 [
					;EndShapeRecord
					true ;end
				][
					lineType: none
					;StyleChangeRecord
					;print ["SCR:" mold copy/part inBuffer 5 (enbase/base to-binary to-char states 2)]
					insert tail records 'style
					insert/only tail records reduce [
						either 0 < (states and 1 ) [ readSBPair ][none] ;move
						either 0 < (states and 2 ) [ readUB numFillBits][none] ;fillStyle0
						either 0 < (states and 4 ) [ readUB numFillBits][none] ;fillStyle1
						either 0 < (states and 8 ) [ readUB numLineBits][none] ;lineStyle
						either 0 < (states and 16) [
							reduce [
								readFILLSTYLEARRAY
								readLINESTYLEARRAY
								numFillBits: readUB 4 ;Number of fill index bits for new styles
								numLineBits: readUB 4 ;...line...
							]
						][none] ;NewStyles
					]
					false ;continue
				]		
			]
		]
		records	
	]
	
	readSHAPE: does[
		readSHAPERECORD (byteAlign readUB 4) readUB 4
	]
	readSHAPEWITHSTYLES: does [
		byteAlign
		;print "readSHAPEWITHSTYLES"
		;probe copy/part inBuffer 10
		reduce [
			readFILLSTYLEARRAY
			readLINESTYLEARRAY
			readSHAPERECORD (byteAlign readUB 4) readUB 4
		]
	]
	
	parse-DefineShape: does[
		;probe copy/part inBuffer 10
		;probe inBuffer
		reduce [
			readID   ;shapeID
			probe readRect ;shape bounds
			either tagId >= 67 [
				;probe copy/part inBuffer 10
				reduce [
					readRect ;edgeBounds
					(
					 readUB 6     ;reserved
					 readBitLogic ;usesNonScalingStrokes
					)
					readBitLogic ;usesScalingStrokes
				]
			][	none ]
			readSHAPEWITHSTYLES
		]
	]
	