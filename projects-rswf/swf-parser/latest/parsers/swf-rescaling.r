rebol [
	title: "SWF sprites and movie clip related parse functions"
	purpose: "Functions for parsing sprites and movie clip related tags in SWF files"
]

[
rs/run 'imagick rs/run 'jpg-size
rs/run/fresh 'rswf rs/go 'robotek
rescale-swf %ovladac_olejak.swf run %xxx.swf
]

rswf-rescale-index:   .56; 0.8 ;0.75 ;0.25 ;0.5 ;0.75
rsc: func[val][
	switch/default type?/word val [
		integer! [round rswf-rescale-index * val]
		pair!    [as-pair round rswf-rescale-index * val/x rswf-rescale-index * val/y]
		block!   [forall val [change val rsc val/1] val: head val]
	][
 		to (type? val) val * rswf-rescale-index
 	]
]



set 'rescale-swf-tag func[tagId tagData /local err action st st2][
	reduce either none? action: select parseActions tagId [
		;tagData
		form-tag tagId tagData
	][
		setStreamBuffer tagData
		clearOutBuffer
		
		;print ["IMP>" index? inBuffer length? inBuffer]
		;print [tagId select swfTagNames tagId]
		
		if error? set/any 'err try [
			set/any 'result do bind/copy action 'self
		][
			print ajoin ["!!! ERROR while rescaling tag:" select swfTagNames tagId "(" tagId ")"]
			throw err
		]
	
		;head inBuffer
		;print ["IMP<" index? inBuffer length? head inBuffer]
		if tagId = 6 [tagId: 21]
		if tagId = 43 [print as-string tagData]
		;print ["rescale tagId:" tagId]
		either result [
			form-tag tagId result ;head inBuffer
		][	copy #{} ]
	]
	
]




rescale-PlaceObject2: has[flags] [
	;print "rescale-PlaceObject2"
	writeUI8 flags: readUI8
	carryBytes 2 ;depth
	if isSetBit? flags 2 [carryBytes 2]   ;HasCharacter
	if isSetBit? flags 3 [rescaleMATRIX]  ;HasMatrix
	if isSetBit? flags 4 [carryCXFORMa]   ;HasCxform

	if isSetBit? flags 5 [carryBytes 2]   ;HasRatio
	if isSetBit? flags 6 [carryString ]   ;HasName
	if isSetBit? flags 7 [carryBytes 2]   ;HasClipDepth
	;if isSetBit? flags 8 [readCLIPACTIONS][none]
	;print ["len:" length? inBuffer index? inBuffer length? head inBuffer]
	carryBytes length? inBuffer ;<------------------------------------------------------asi blbe
	head outBuffer
]
rescale-PlaceObject3: has [flags1][
	;probe inbuffer
	f: context [
		HasClipActions?: carryBitLogic
		HasClipDepth?:   carryBitLogic
		HasName?:        carryBitLogic
		HasRatio?:       carryBitLogic
		HasColorTransform?: carryBitLogic
		HasMatrix?:        carryBitLogic
		HasCharacter?:     carryBitLogic
		Move?:             carryBitLogic
		carryBits 3 ;reserved
		HasImage?:         carryBitLogic
		HasClassName?:     carryBitLogic
		HasCacheAsBitmap?: carryBitLogic
		HasBlendMode?:     carryBitLogic
		HasFilterList?:    carryBitLogic
	]
	;alignBuffers
	carryBytes 2 ;Depth
	;probe inbuffer
	if any [
		f/HasClassName? 
		all [f/HasImage? f/HasCharacter?]
	][writeString readString] ;ClassName
	if f/HasCharacter? [carryBytes 2] ;ID
	;print "?"
	if f/HasMatrix? [rescaleMATRIX]
	;print "?"
	carryBytes length? inBuffer
	comment {
	if f/HasColorTransform? [carryCXFORMa]
	if f/HasRatio? [carryBytes 2]
	if f/HasName?  [writeString readString]
	if f/HasClipDepth?  [carryBytes 2]
	carryBytes length? inBuffer

	if f/HasFilterList? [rescaleFILTERLIST]
	if f/BlendMode?     [carryBytes 1]
	
	}
	head outBuffer
]

rescale-Shape: has[data tmp][

	carryBytes 2 ;shapeID
	writeRect tmp:  rsc readRect ;shape bounds
	;print ["originalBaounds:" mold tmp]
	;writeRect tmp ;reduce [tmp/1 - 600 tmp/2 + 600 tmp/3 - 600 tmp/4 + 600]
	if tagId >= 67 [
		writeRect rsc readRect ;edgeBounds
		carryBytes 1    ;flags: 6*reserved,usesNonScalingStrokes,usesScalingStrokes
	]
	rescaleFILLSTYLEARRAY
	rescaleLINESTYLEARRAY
	rescaleSHAPERECORD (alignBuffers carryUB 4) carryUB 4
	head outBuffer
]

rescale-DefineMorphShape: has [tmp][
	;print ["rescale-DefineMorphShape"]
	carryBytes 2 ;shapeID
	;probe inBuffer
	writeRect rsc readRect ;shape StartBounds
	writeRect rsc readRect ;shape EndBounds
	if tagId = 84 [
		writeRect rsc readRect ;shape StartEdgeBounds
		writeRect rsc readRect ;shape EndEdgeBounds
		;probe inBuffer
		carryBytes 1 ;flags: 6*reserved,usesNonScalingStrokes,usesScalingStrokes
	
	]
	;do not write offset yet!
	tmp: outBuffer
	readBytes 4 ;offset
	
	;probe inBuffer
	rescaleMORPHFILLSTYLEARRAY
	;probe inBuffer
	rescaleLINESTYLEARRAY
	rescaleSHAPERECORD (alignBuffers carryUB 4) carryUB 4
	alignBuffers
	
	;write correct offset to start of the end edges
	offs: (index? outBuffer) - (index? tmp)
	outBuffer: tmp
	writeUI32 offs
	outBuffer: tail outBuffer
	
	rescaleSHAPERECORD (carryUB 4) carryUB 4
	head outBuffer
]

rescale-DefineBits: has[md5 tmp file file-sc][
	md5: enbase/base checksum/method skip inBuffer 2 'md5 16
	tmp: parse-DefineBits
	file:    rejoin [swfDir %tag6_ md5 %.jpg]
	file-sc: rejoin [swfDir %_sc rswf-rescale-index-percent: to-integer (rswf-rescale-index * 100) #"/" %tag6_ md5 %.jpg]
	print ["JPEGTables:" mold JPEGTables]
	if not exists? file-sc [
		unless exists? file [
			;write/binary file  (join JPEGTables skip tmp/2 2)
			write/binary file  JPG-repair either JPEGTables [join JPEGTables tmp/2][tmp/2]
		]
		imagick/resize-jpg file file-sc join form to-string rswf-rescale-index-percent "%"
	]
	writeUI16 tmp/1
	;swf-parser/tagId: 21
	writeBytes read/binary file-sc
	head outBuffer
]
rescale-DefineBitsJPEG2: has[md5 tmp file file-sc][
	md5: enbase/base checksum/method skip inBuffer 2 'md5 16
	tmp: parse-DefineBitsJPEG2
	file:    rejoin [swfDir %tag21_ md5 %.jpg]
	file-sc: rejoin [swfDir %_sc rswf-rescale-index-percent: to-integer (rswf-rescale-index * 100) #"/" %tag21_ md5 %.jpg]
	if not exists? file-sc [
		unless exists? file [
			write/binary file   JPG-repair tmp/2
		]
		imagick/resize-jpg file file-sc join form to-string rswf-rescale-index-percent "%"
	]
	writeUI16 tmp/1
	writeBytes read/binary file-sc
	head outBuffer
]
rescale-DefineBitsJPEG3: has[md5 tmp img file file-sc alphaimg][
	md5: enbase/base checksum/method skip inBuffer 2 'md5 16
	tmp: parse-DefineBitsJPEG3
	file:    rejoin [swfDir %tag35_ md5 %.jpg]
	file-sc: rejoin [swfDir %_sc rswf-rescale-index-percent: to-integer (rswf-rescale-index * 100) #"/" %tag35_ md5 %.jpg]
	if not exists? file-sc [
		unless exists? file [
			;replace tmp/2 #{FFD9FFD8} #{}
			write/binary file  JPG-repair tmp/2
		]
		imagick/resize-jpg file file-sc join form to-string rswf-rescale-index-percent "%"
	]
	writeUI16 tmp/1
	img: read/binary file-sc
	writeUI32 length? img
	writeBytes img
	
	file:    rejoin [swfDir %tag35_ md5 %.png]
	file-sc: rejoin [swfDir %_sc rswf-rescale-index-percent #"/" %tag35_ md5 %.png]
	if not exists? file-sc [
		unless exists? file [
			img: make image! jpg-size rejoin [swfDir %tag35_ md5 %.jpg]
			img/alpha:	as-binary zlib-decompress tmp/3 (img/size/1 * img/size/2)
			save/png file img
		]
		imagick/resize-jpg file file-sc join form to-string rswf-rescale-index-percent "%"
	]
	img: load file-sc
	;probe img/alpha
	writeBytes head head remove/part tail compress img/alpha -4
	head outBuffer
]
rescale-DefineBitsLossless: has [md5 tmp file file-sc][
	md5: enbase/base checksum/method skip inBuffer 2 'md5 16
	tmp: parse-DefineBitsLossless
	
	file:    rejoin [swfDir %tag20_ md5 %.png]
	file-sc: rejoin [swfDir %_sc rswf-rescale-index-percent: to-integer (rswf-rescale-index * 100) #"/" %tag20_ md5 %.png]
	if not exists? file-sc [
		unless exists? file [
			write/binary file ImageCore/PIX24-to-PNG context [
				bARGB:  as-binary zlib-decompress tmp/6 (4 * tmp/3 * tmp/4) 
				size: as-pair tmp/3 tmp/4
			]
		]
		imagick/resize-jpg file file-sc join form to-string rswf-rescale-index-percent "%"
	]
	writeUI16 tmp/1
	writeBytes ImageCore/ARGB2BLL xxx: ImageCore/load file-sc
	head outBuffer
]

rescale-DefineBitsLossless2: has [md5 tmp file file-sc][
	md5: enbase/base checksum/method skip inBuffer 2 'md5 16
	tmp: parse-DefineBitsLossless
	;print ["BitmapFormat:" tmp/2]
	probe file:    rejoin [swfDir %tag36_ md5 %.png]
	probe file-sc: rejoin [swfDir %_sc rswf-rescale-index-percent: to-integer (rswf-rescale-index * 100) #"/" %tag36_ md5 %.png]
	if not exists? file-sc [
		unless exists? file [
			write/binary file ImageCore/ARGB2PNG context [
				bARGB: as-binary zlib-decompress tmp/6 (4 * tmp/3 * tmp/4) 
				size:  as-pair tmp/3 tmp/4
			]
		]
		imagick/resize-jpg file file-sc join form to-string rswf-rescale-index-percent "%"
	]
	writeUI16 tmp/1
	writeBytes probe ImageCore/ARGB2BLL probe ImageCore/load file-sc
	head outBuffer
]

rescale-DefineSprite: has[][
	carryBytes 4 ;ID + FrameCount
	writeBytes rescaleSWFTags inBuffer
	head outBuffer
]


rescaleSHAPERECORD: func[numFillBits numLineBits /local states nBits cx cy dx dy posx posy rposx rposy mainPoints mp][
		;print ["readSHAPERECORD" numFillBits numLineBits "availableBits:" availableBits mold copy/part inBuffer 10] 
		alignBuffers		
		;numFillBits: carryUB 4 ;Number of fill index bits for new styles
		;numLineBits: carryUB 4 ;...line...
		posx: 0
		posy: 0
		rposx: 0
		rposy: 0
		moveX: moveY: none
		mainPoints: copy [] ;move positions and style changes
		;minX: minY: 1000000
	;	maxX: maxY: -1000000
		until [
			either readBitLogic [ ;edge?
				print "edge"
				either readBitLogic [;straightEdge?
					;print "line - "
					nBits: 2 + readUB 4 ;original nBits - result may be different!
					;comment {
					either readBitLogic [
						;GeneralLine
						dx:	readSB nBits ;deltaX
						dy:	readSB nBits ;deltaY
					][
						either readBitLogic [
							;Vertical
							dx: 0
							dy: readSB nBits
						][	;Horizontal
							dx: readSB nBits
							dy: 0
						]
					]
					
					;rescaling position, not delta to eliminate rounding errors
					newx: posx + dx
					newy: posy + dy
					
					odx: dx
					ody: dy
					
					dx: (negate rposx) + rposx: (rsc newx)
					dy: (negate rposy) + rposy: (rsc newy)
					
					posx: newx
					posy: newy
					
					;either rposx > maxX [maxX: rposx][ if rposx < minX [minX: rposx]]
					;either rposy > maxY [maxY: rposy][ if rposy < minY [minY: rposy]]
					
					;print ["line:" posx posy]
					print [posx newx posy newy]
					;print ">>>>>>>"
					case [
						all [dx <> 0 dy <> 0][
							;print "xy"
							writeBit true
							writeBit true
							writeUB (-2 + nBits: getSBnBits reduce [dx dy]) 4 ;new nBits
							writeBit true
							writeSB dx nBits
							writeSB dy nBits
						]
						dx <> 0 [
							;print "x"
							writeBit true
							writeBit true
							nBits: getSBitsLength dx
							writeUB (-2 + nBits) 4
							writeBit false
							writeBit false
							writeSB dx nBits
						]
						dy <> 0 [
							;print "y"
							writeBit true
							writeBit true
							nBits: getSBitsLength dy
							writeUB (-2 + nBits) 4
							writeBit false
							writeBit true
							writeSB dy nBits
						]
						true [
							;print ["!!!!!!!!!!!!!!!!!!L" ]
							if find [46 84] tagId [ 
								;there MUST be same number of points in Morph shapes!!!
								writeBit true
								writeBit true
								writeUB 0 4
								writeBit false
								writeBit false
								writeSB 0 2
							]
							
						]
					]
					;}
					comment {
					either readBitLogic [
						;GeneralLine
						dx:	rsc readSB nBits ;deltaX
						dy:	rsc readSB nBits ;deltaY
						writeUB (-2 + nBits: getSBnBits reduce [dx dy]) 4 ;new nBits
						writeBit true
						writeSB dx nBits
						writeSB dy nBits
						
					][
						either readBitLogic [
							;Vertical
							nBits: getSBitsLength dy: rsc readSB nBits
							writeUB (-2 + nBits) 4
							writeBit false
							writeBit true
							writeSB dy nBits
						][	;Horizontal
							nBits: getSBitsLength dx: rsc readSB nBits
							writeUB (-2 + nBits) 4
							writeBit false
							writeBit false
							writeSB dx nBits
						]
					]
					}
					
				][
					
					;print "curve - "
					nBits: 2 + readUB 4
					cx: readSB nBits ;controlDeltaX
					cy: readSB nBits ;Y
					dx:	readSB nBits ;anchorDeltaX
					dy:	readSB nBits ;Y
					
					;print ["p:" cx cy dx dy rposx rposy]
					;rescaling control position, not delta to eliminate rounding errors
					newx: posx + cx
					newy: posy + cy
					cx: (negate rposx) + rposx: (rsc newx)
					cy: (negate rposy) + rposy: (rsc newy)
					posx: newx
					posy: newy
					
					;rescaling delta position, not delta to eliminate rounding errors
					newx: posx + dx
					newy: posy + dy
					
					dx: (negate rposx) + rposx: (rsc newx)
					dy: (negate rposy) + rposy: (rsc newy)
					
					posx: newx
					posy: newy

					;print ["n:" cx cy dx dy]
					;print ["curve:" posx posy "   (" cx cy  dx dy]
					either any [
					;	true
						;all [(abs cx) < 20 (abs cy) < 20]
						;all [(abs dx) < 20 (abs dy) < 20]
						false
					][
						;print ".."
						dx: dx + cx
						dy: dy + cy
						;if any [(abs dx) > 20 (abs dy > 20)][
							case [
								all [dx <> 0 dy <> 0][
									;print "xy"
									writeBit true
									writeBit true
									writeUB (-2 + nBits: getSBnBits reduce [dx dy]) 4 ;new nBits
									writeBit true
									writeSB dx nBits
									writeSB dy nBits
								]
								dx <> 0 [
									;print "x"
									writeBit true
									writeBit true
									nBits: getSBitsLength dx
									writeUB (-2 + nBits) 4
									writeBit false
									writeBit false
									writeSB dx nBits
								]
								dy <> 0 [
									;print "y"
									writeBit true
									writeBit true
									nBits: getSBitsLength dy
									writeUB (-2 + nBits) 4
									writeBit false
									writeBit true
									writeSB dy nBits
								]
								;true [print "!!!!!!!!!!!!!!!!!!"]
							]
							;posx: posx + dx
							;posy: posy + dy
						;]
					][
						either any [dx <> 0 dy <> 0] [ 
							writeBit true
							writeBit false
							writeUB (-2 + nBits: getSBnBits reduce [cx cy dx dy]) 4 ;new nBits
							writeSB cx nBits
							writeSB cy nBits
							writeSB dx nBits
							writeSB dy nBits
							
							;posx: posx + cx + dx
							;posy: posy + cy + dy
						][	
							;print ["!!!!!!!!!!!!!!!!!!C" cx cy dx dy]
						]
					]
					
					
					;either rposx > maxX [maxX: rposx][ if rposx < minX [minX: rposx]]
					;either rposy > maxY [maxY: rposy][ if rposy < minY [minY: rposy]]
				]
				false
			][
				
				states: readUB 5
				;print ["STATES:" states "POS:" posx posy "MOV:" moveX moveY mold mainPoints]
				comment {
				if all [
					not none? moveX
					any [
						moveX <> posX
						moveY <> posY
					]
					;all [
					;	5 > abs (dx: moveX - posx)
					;	5 > abs (dy: moveY - posy)
					;]
				][
					mindiffx: mindiffy: 10000
					newPos: none
					forall mainPoints [
						
						;print [abs (mainPoints/1  - (as-pair posx posy))]
						if all [
							mindiffx > tmpx: abs (mainPoints/1/x  - posx)
							mindiffy > tmpy: abs (mainPoints/1/y  - posy)
						][
							mindiffx: tmpx
							mindiffy: tmpy
							newPos: mainPoints/1
						]
					]
					mainPoints: head mainPoints
					print ["midiff:" mindiffx mindiffy "newPos:" newPos "oldPos:" as-pair posX posY]
					if all [
						mindiffx < 20
						mindiffy < 20
					][
						dx: newPos/x - posx
						dy: newPos/y - posy
						posX: newPos/x
						posY: newPos/y
					
					
						;print ["AAAAAAAAAAAA:" moveX posX MoveY posY dx dy]
						;dx: moveX - posx
						;dy: moveY - posy
						case [
							all [dx <> 0 dy <> 0][
								;print "xy"
								writeBit true
								writeBit true
								writeUB (-2 + nBits: getSBnBits reduce [dx dy]) 4 ;new nBits
								writeBit true
								writeSB dx nBits
								writeSB dy nBits
							]
							dx <> 0 [
								;print "x"
								writeBit true
								writeBit true
								nBits: getSBitsLength dx
								writeUB (-2 + nBits) 4
								writeBit false
								writeBit false
								writeSB dx nBits
							]
							dy <> 0 [
								;print "y"
								writeBit true
								writeBit true
								nBits: getSBitsLength dy
								writeUB (-2 + nBits) 4
								writeBit false
								writeBit true
								writeSB dy nBits
							]
							;true [print "!!!!!!!!!!!!!!!!!!"]
						]
					]
				]
				}
				either states = 0 [
					;EndShapeRecord
					writeBit false
					writeUB 0 5
				;	print [
				;		"bounds:" minX maxX minY  maxY
				;	]
					
					alignBuffers
					;outBuffer: skip head outBuffer 2
					;writeRect reduce [minX - 100 maxX + 100 minY - 100 maxY + 100]
					;outByteAlign
					;probe head outBuffer
					true ;end
				][
					;StyleChangeRecord
					writeBit false
					writeUB states 5
					if 0 < (states and 1 ) [
				;		prin "Move "
						
						set [newx newy] readSBPair	
						if all [posx = newx newy = posy][print "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"]
						moveX: posx: newx
						moveY: posy: newy
						
						rposx: rsc posx
						rposy: rsc posy
						;print ["MOVE:" rposx rposy "puvodni:" posx posy]
						
						
						;either rposx > maxX [maxX: rposx][ if rposx < minX [minX: rposx]]
						;either rposy > maxY [maxY: rposy][ if rposy < minY [minY: rposy]]
						writeSBPair reduce [rposx rposy]
						;rescaleSBPair
					]      ;move
					if 0 < (states and 2 ) [ carryUB numFillBits] ;fillStyle0
					if 0 < (states and 4 ) [ carryUB numFillBits] ;fillStyle1
					if 0 < (states and 8 ) [ carryUB numLineBits] ;lineStyle
					if 0 < (states and 16) [
					;print "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
						rescaleFILLSTYLEARRAY
						rescaleLINESTYLEARRAY
						numFillBits: carryUB 4 ;Number of fill index bits for new styles
						numLineBits: carryUB 4 ;...line...
					] ;NewStyles
					;mp: as-pair posX posY
					;unless find mainPoints mp [append mainPoints mp]
	
					false ;continue
				]		
			]
		]
]

rescaleSBPair: has[nBits x y][
	nBits: readUB 5
	x: rsc readSB nBits
	y: rsc readSB nBits
	writeSBPair reduce [x y]
	;writeUB (nBits: getSBnBits probe reduce [x y]) 5 ;new nBits
	;writeSB x nBits
	;writeSB y nBits
]

rescaleMATRIX: does [
	alignBuffers
	if carryBitLogic [;scale
		;carryPair
		writePair  readPair 
		;writePair rsc probe readPair 
	]
	if carryBitLogic [;rotate
		writePair  readPair 
		;carryPair
		;writePair probe readPair 
	]
	rescaleSBPair 
	alignBuffers
]
rescaleMATRIXall: does[
	alignBuffers
	if carryBitLogic [;scale
		;carryPair
		;writePair  readPair 
		writePair rsc readPair 
	]
	if carryBitLogic [;rotate
		writePair  readPair 
		;carryPair
		;writePair probe readPair 
	]
	rescaleSBPair 
	alignBuffers
]

rescaleGRADIENT: func[type] [
	alignBuffers
	;print ["gradient:" to-hex type]
	carryBits 4 ;SpreadMode + InterpolationMode
	loop carryUB 4 [
		;GRADRECORD
		carryBytes either tagId >= 32 [5][4] ;ratio + color
	]
	if all [type = 19 tagId = 83] [carryBytes 2] ;FocalPoint
]

rescaleMORPHGRADIENT: func[type][
	alignBuffers
	;print ["rescaleMORPHGRADIENT" mold copy/part inBuffer 30 ]
	loop carryUI8[
		carryBytes 10 ;Start ratio,Start color,End ratio,End color
	]
]

rescaleFILLSTYLEARRAY: does [
	;print ["FSA:" mold copy/part inBuffer 10]
	alignBuffers
	loop carryCount [
		rescaleFILLSTYLE 
	]
]
rescaleMORPHFILLSTYLEARRAY: does[
	;print ["MFSA:" mold copy/part inBuffer 10]
	alignBuffers
	loop carryCount [ ;FillStyleCount
		rescaleMORPHFILLSTYLE
	]
]

rescaleFILLSTYLE: has[type][
	;print ["fillstyle" mold copy/part inBuffer 10]
	alignBuffers
	type: readUI8 ;FillStyleType
	
	case [
		type = 66 [type: 64 print "66 000000000000000000000000"]
		type = 67 [type: 65 print "67 000000000000000000000000"]
	]
	
	writeUI8 type
	
	case [
		type = 0 [
			;solid fill
			case [
				find [46 84] tagId [
					carryBytes 8 ;morph RGBAs
				]
				tagId >= 32 [carryBytes 4] ;RGBA
				true [carryBytes 3] ;RGB
			]
		]
		any [
			type = 16 ;linear gradient fill
			type = 18 ;radial gradient fill
			type = 19 ;focal gradient fill (swf8)
		][
			;gradient
			either find [46 84] tagId [
				;morph
				rescaleMATRIX
				rescaleMATRIX
				rescaleMORPHGRADIENT type
			][	;shape
				;print "./......................."
				rescaleMATRIXall
				rescaleGRADIENT type
			]
		]
		type >= 64 [
			;bitmap
			reduce either find [46 84] tagId [
				;morph
				carryBytes 2 ;id
				rescaleMATRIX
				rescaleMATRIX
			][	;shape
				carryBytes 2 ;id
				rescaleMATRIX
			]
		]
	]
]

rescaleMORPHFILLSTYLE: does [
	;print ["Mfillstyle" mold copy/part inBuffer 10]
	alignBuffers
	type: readUI8 ;FillStyleType
	
	case [
		type = 66 [type: 64 print "66 000000000000000000000000"]
		type = 67 [type: 65 print "67 000000000000000000000000"]
	]
	
	writeUI8 type
	case [
		type = 0 [
			;solid fill
			carryBytes 8 ;morph RGBAs
		]
		any [
			type = 16 ;linear gradient fill
			type = 18 ;radial gradient fill
			type = 19 ;focal gradient fill (swf8)
		][
			;gradient
			rescaleMATRIXall
			rescaleMATRIXall
			rescaleMORPHGRADIENT type
		]
		type >= 64 [
			;bitmap
			carryBytes 2 ;id
			rescaleMATRIX
			rescaleMATRIX
		]
	]
]

rescaleLINESTYLEARRAY: has[LineStyles joinStyle hasFill?][
	;print "linestylearray"
	alignBuffers
	loop carryCount [ ;LineStyleCount
		alignBuffers
		;print ["linestyle" tagId]
		case [
			;DefineMorphShape
			tagId = 46 [
				writeUI16 rsc readUI16 ;StartWidth
				writeUI16 rsc readUI16 ;EndWidth
				carryBytes 8 ;RGBA + RGBA
			]
			;DefineShape4
			any [tagId = 67 tagId = 83][
				writeUI16 rsc readUI16   ;Width
				carryBits 2              ;f_start_cap_style
				joinStyle: carryUB 2     ;f_join_style
				hasFill?:  carryBitLogic ;f_has_fill
				carryBits 11 ;f_no_hscale,f_no_vscale,f_pixel_hinting,5*reserved,f_no_close,2*f_end_cap_style

				if joinStyle = 2 [carryBytes 2] ;miterLimit
				either hasFill? [rescaleFILLSTYLE][carryBytes 4]
			]
			;DefineMorphShape2
			tagId = 84 [
				writeUI16 rsc readUI16 ;StartWidth
				writeUI16 rsc readUI16 ;EndWidth
				
				carryBits 2              ;f_start_cap_style
				joinStyle: carryUB 2     ;f_join_style
				hasFill?:  carryBitLogic ;f_has_fill
				carryBits 11 ;f_no_hscale,f_no_vscale,f_pixel_hinting,5*reserved,f_no_close,2*f_end_cap_style
				
				if joinStyle = 2 [carryBytes 2] ;miterLimit
				either hasFill? [rescaleFILLSTYLE][carryBytes 8]
			]
			true [
				writeUI16 rsc readUI16 ;Width
				carryBytes either tagId = 32 [4][3]
			]
		];case
	]
]

rescaleMORPHLINESTYLEARRAY: has[LineStyles][
	;print "linestylearray"
	alignBuffers
	loop carryCount [ ;LineStyleCount
		alignBuffers
		writeUI16 rsc readUI16 ;StartWidth
		writeUI16 rsc readUI16 ;EndWidth
		
		
		
		;print ["linestyle" tagId]
		case [
			;DefineMorphShape
			tagId = 46 [
				writeUI16 rsc readUI16 ;StartWidth
				writeUI16 rsc readUI16 ;EndWidth
				carryBytes 8 ;RGBA + RGBA
			]
			;DefineShape4
			any [tagId = 67 tagId = 83][
				writeUI16 rsc readUI16   ;Width
				carryBits 2              ;f_start_cap_style
				joinStyle: carryUB 2     ;f_join_style
				hasFill?:  carryBitLogic ;f_has_fill
				carryBits 11 ;f_no_hscale,f_no_vscale,f_pixel_hinting,5*reserved,f_no_close,2*f_end_cap_style

				if joinStyle = 2 [carryBytes 2] ;miterLimit
				either hasFill? [rescaleFILLSTYLE][carryBytes 4]
			]
			;DefineMorphShape2
			tagId = 84 [
				writeUI16 rsc readUI16 ;StartWidth
				writeUI16 rsc readUI16 ;EndWidth
				
				carryBits 2              ;f_start_cap_style
				joinStyle: carryUB 2     ;f_join_style
				hasFill?:  carryBitLogic ;f_has_fill
				carryBits 11 ;f_no_hscale,f_no_vscale,f_pixel_hinting,5*reserved,f_no_close,2*f_end_cap_style
				
				if joinStyle = 2 [carryBytes 2] ;miterLimit
				either hasFill? [rescaleFILLSTYLE][carryBytes 8]
			]
			true [
				writeUI16 rsc readUI16 ;Width
				carryBytes either tagId = 32 [4][3]
			]
		];case
	]
]





;--------------------------------------------------------------------


carryCXFORM: has [HasAddTerms? HasMultTerms? nbits][
	HasAddTerms?:  carryBitLogic
	HasMultTerms?: carryBitLogic
	nbits: carryUB 4
	if HasMultTerms? [
		carrySB nbits ;R
		carrySB nbits ;G
		carrySB nbits ;B
	]
	if HasAddTerms? [
		carrySB nbits ;R
		carrySB nbits ;G
		carrySB nbits ;B
	]
	alignBuffers
]
carryCXFORMa: has [HasAddTerms? HasMultTerms? nbits][
	HasAddTerms?:  carryBitLogic
	HasMultTerms?: carryBitLogic
	nbits: carryUB 4
	if HasMultTerms? [
		carrySB nbits ;R
		carrySB nbits ;G
		carrySB nbits ;B
		carrySB nbits ;A
	]
	if HasAddTerms? [
		carrySB nbits ;R
		carrySB nbits ;G
		carrySB nbits ;B
		carrySB nbits ;A
	]
	alignBuffers
]