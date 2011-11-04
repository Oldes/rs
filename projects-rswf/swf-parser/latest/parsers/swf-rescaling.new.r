rebol [
	title: "SWF sprites and movie clip related parse functions"
	purpose: "Functions for parsing sprites and movie clip related tags in SWF files"
]

[
rs/run 'imagick rs/run 'jpg-size
rs/run/fresh 'rswf rs/go 'robotek
rescale-swf %ovladac_olejak.swf run %xxx.swf
]

round2: func[m][make 1 (m: m + .5) - mod m 1.0]

force-image-update?: true

unless value? 'scale-x [scale-x: 1]
unless value? 'scale-y [scale-y: 1]

rswf-rescale-index:      ;;0.8 ;0.75 ;0.25 ;0.5 ;0.75
rswf-rescale-index-x:    scale-x ;0.592  ; == 740 / 1250
rswf-rescale-index-y:    scale-y ;rswf-rescale-index-x * .9 ;0.5328 ; == rswf-rescale-index-x * .9        

rsci: func[m][
	to integer! 20 * (
		(m: 0.025 + (
			(max rswf-rescale-index-x rswf-rescale-index-y) * m / 20
		)) - mod m .05
	)
]
rsci-x: func[m][
	to integer! 20 * ((m: 0.025 + (rswf-rescale-index-x * m / 20)) - mod m .05 )
]
rsci-y: func[m][
	to integer! 20 * ((m: 0.025 + (rswf-rescale-index-y * m / 20)) - mod m .05 )
]

rscr: func[m [block!]][
	reduce [
		rsci-x m/1
		rsci-x m/2
		rsci-y m/3
		rsci-y m/4
		;to integer! 20 * (add -.5 (rswf-rescale-index * m/1 / 20))
		;to integer! 20 * (add 0.5 (rswf-rescale-index * m/2 / 20))
		;to integer! 20 * (add -.5 (rswf-rescale-index * m/3 / 20))
		;to integer! 20 * (add 0.5 (rswf-rescale-index * m/4 / 20))
	]
]
rsc: func[val][
	switch/default type?/word val [
		integer! [rsci-x val]
		pair!    [as-pair rsci-x val/x rsci-y val/y]
		block!   [forall val [change val rsc val/1] val: head val]
	][
 		to (type? val) val * rswf-rescale-index-x
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
	writeRect tmp:  rscr readRect ;shape bounds
	;set [bMinX bMaxX bMinY bMaxY] tmp
	;print ["originalBaounds:" mold tmp]
	;writeRect tmp ;reduce [tmp/1 - 600 tmp/2 + 600 tmp/3 - 600 tmp/4 + 600]
	if tagId >= 67 [
		writeRect rscr readRect ;edgeBounds
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
	writeRect rscr readRect ;shape StartBounds
	writeRect rscr readRect ;shape EndBounds
	
	if tagId = 84 [
		writeRect rscr readRect ;shape StartEdgeBounds
		writeRect rscr readRect ;shape EndEdgeBounds
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

	get-image-size-from-tagData: func[data /local tagId md5 file][
		tagId: first data
		md5:  last data
		either exists? probe file: rejoin [
			swfDir %tag tagId %_ md5
			either find [20 36] tagId [%.png][%.jpg]
		][
			get-image-size file
		][	none ]
	]
	combine-files: func[files size into /local tmp png? *wand2 *pixel][
		print ["COMBINE to size:" size into]
		with ctx-imagick [
			start
					*pixel: NewPixelWand
					;PixelSetAlpha *pixel 0
					not zero? MagickNewImage *wand size/x size/y *pixel
					
					*wand2: NewMagickWand
					png?: find into %.png
					foreach [pos size file] files [
						if block? file [parse file [to file! set file 1 skip]]
					
						if png? [file: replace copy file %.jpg %.png]
						unless all [
							not zero? MagickReadImage *wand2 utf8/encode to-local-file file
							tmp:  make image! size
					 		not zero? MagickExportImagePixels *wand2 0 0 size/x size/y "RGBO" 1 address? tmp
					 		not zero? MagickImportImagePixels *wand pos/x pos/y size/x size/y "RGBO" 1 address? tmp
				 		][
				 			errmsg: reform [
								Exception/Severity "="
								ptr-to-string tmp:  MagickGetException *wand2 Exception
							]
							MagickRelinquishMemory tmp
							ClearMagickWand   *wand2
							DestroyMagickWand *wand2	
							ClearPixelWand    *pixel
							DestroyPixelWand  *pixel
							end
							make error! errmsg
			 			]
				 		ClearMagickWand   *wand2
			 		]
				not zero? MagickWriteImages *wand to-local-file into
				ClearMagickWand   *wand2
				DestroyMagickWand *wand2	
				ClearPixelWand    *pixel
				DestroyPixelWand  *pixel
			end
		]
	]
	export-image-tag: func[tagId md5 data /alpha /rescale /local px py file file-sc img ext][
		;print ["export-image-tag:" tagId md5]
		ext: either any [find [20 36] tagId alpha] [%.png][%.jpg]
		unless exists? probe file: rejoin [swfDir %tag tagId %_ md5 ext][
			switch tagId [
				6  [write/binary file  JPG-repair either JPEGTables [join JPEGTables data/2][data/2]]
				20 [
					write/binary file ImageCore/PIX24-to-PNG context [
						bARGB:  as-binary zlib-decompress data/6 (4 * data/3 * data/4) 
						size: as-pair data/3 data/4
					]
				]
				21 [write/binary file  JPG-repair data/2]
				35 [
					either alpha [
						unless data/4 [
							append data get-image-size replace copy file %.png %.jpg
						]
						img: make image! data/4
						img/alpha:	as-binary zlib-decompress data/3 (img/size/1 * img/size/2)
						save/png file img
					][
						write/binary file  JPG-repair data/2
						append data get-image-size file
					]
				]
				36 [
					write/binary file ImageCore/ARGB2PNG context [
						bARGB: as-binary zlib-decompress data/6 (4 * data/3 * data/4) 
						size:  as-pair data/3 data/4
					]
				]
			]
		]
		either rescale [
			if any [not exists? file-sc: rejoin [scDir %tag tagId %_ md5 ext] force-image-update? ] [
				resize-image file file-sc reduce [rswf-rescale-index-x rswf-rescale-index-y]
			]
			read/binary file-sc
		][	file ]
	]

rescale-DefineBits: has[md5 tmp][
	md5: enbase/base checksum/method skip inBuffer 2 'md5 16
	tmp: parse-DefineBits
	writeUI16 tmp/1
	writeBytes export-image-tag/rescale 6 md5 tmp
	head outBuffer
]
rescale-DefineBitsJPEG2: has[md5 tmp][
	md5: enbase/base checksum/method skip inBuffer 2 'md5 16
	tmp: parse-DefineBitsJPEG2
	writeUI16 tmp/1
	writeBytes export-image-tag/rescale 21 md5 tmp
	head outBuffer
]
rescale-DefineBitsJPEG3: has[md5 tmp img alphaimg][
	md5: enbase/base checksum/method skip inBuffer 2 'md5 16
	tmp: parse-DefineBitsJPEG3
	writeUI16 tmp/1
	img: export-image-tag/rescale 35 md5 tmp
	writeUI32 length? img
	writeBytes img
	
	img: load export-image-tag/rescale/alpha 35 md5 tmp
	;probe img/alpha
	writeBytes head head remove/part tail compress img/alpha -4
	head outBuffer
]
rescale-DefineBitsLossless: has [md5 tmp img][
	md5: enbase/base checksum/method skip inBuffer 2 'md5 16
	tmp: parse-DefineBitsLossless
	
	writeUI16 tmp/1
	img: export-image-tag/rescale 20 md5 tmp
	writeBytes ImageCore/ARGB2BLL ImageCore/load img
;	writeBytes rejoin [
;		#{05}
;		int-to-ui16 round/ceiling(rswf-rescale-index * tmp/3)
;		int-to-ui16 round/ceiling(rswf-rescale-index * tmp/4)
;		head remove/part tail compress image-get-pixels img "ARGB" -4 ;ZLIBBITMAPDATA
;	]
	head outBuffer
]

rescale-DefineBitsLossless2: has [md5 tmp file file-sc][
	md5: enbase/base checksum/method skip inBuffer 2 'md5 16
	tmp: parse-DefineBitsLossless
	
	writeUI16 tmp/1
	img: export-image-tag/rescale 36 md5 tmp
	;img: read/binary %/f/rs/projects-mm/robotek/_export/ocasek.swf_export/_sc56/tag36_93E90EAE27663D15E7BC5041F6CF2DE7.png
	writeBytes ImageCore/ARGB2BLL ImageCore/load img
;	writeBytes rejoin [
;		#{05}
;		int-to-ui16 probe round/ceiling(rswf-rescale-index * tmp/3)
;		int-to-ui16 probe round/ceiling(rswf-rescale-index * tmp/4)
;		head remove/part tail compress probe image-get-pixels img "ARGB" -4 ;ZLIBBITMAPDATA
;	]
	head outBuffer
]

rescale-DefineSprite: has[][
	carryBytes 4 ;ID + FrameCount
	writeBytes rescaleSWFTags inBuffer
	head outBuffer
]


rescaleSHAPERECORD: func[numFillBits numLineBits /local states nBits cx cy dx dy posx posy rposx rposy mainPoints mp newx newy odx ody][
		;print ["readSHAPERECORD" numFillBits numLineBits "availableBits:" availableBits mold copy/part inBuffer 10] 
		alignBuffers		
		;numFillBits: carryUB 4 ;Number of fill index bits for new styles
		;numLineBits: carryUB 4 ;...line...
		posx: 0
		posy: 0
		rposx: 0
		rposy: 0
		oposx: 0
		oposy: 0
		moveX: moveY: none
		mainPoints: copy [] ;move positions and style changes
		minX: minY: 1000000
		maxX: maxY: -1000000
		until [
			;wasx: posx
			;wasy: posy
			either readBitLogic [ ;edge?
				;print "edge"
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
					;print ["?? dx:" dx "dy:" dy]
					oposx: oposx + dx
					oposy: oposy + dy
				;	print ["### OPOS:" oposx oposy]
				;	repend mainPoints ['l oposx oposy]

					dx: - rposx + rposx: (rsci-x oposx)
					dy: - rposy + rposy: (rsci-y oposy)
					
				
					either rposx > maxX [maxX: rposx][ if rposx < minX [minX: rposx]]
					either rposy > maxY [maxY: rposy][ if rposy < minY [minY: rposy]]
					
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
				][
					;print "curve - "
					nBits: 2 + readUB 4
					cx: readSB nBits ;controlDeltaX
					cy: readSB nBits ;Y
					
					oposx: oposx + cx
					oposy: oposy + cy
					
					cx: - rposx + rposx: (rsci-x oposx)
					cy: - rposy + rposy: (rsci-y oposy)
					
					dx:	readSB nBits ;anchorDeltaX
					dy:	readSB nBits ;Y
					
					oposx: oposx + dx
					oposy: oposy + dy
					
					dx: - rposx + rposx: (rsci-x oposx)
					dy: - rposy + rposy: (rsci-y oposy)
					
				;	print ["CURVE" cx cy dx dy]
					
					either any [
					;	true
						;all [(abs cx) < 20 (abs cy) < 20]
						;all [(abs dx) < 20 (abs dy) < 20]
						false
					][
						;print ".."

						;if any [(abs dx) > 20 (abs dy > 20)][
							case [
								all [dx <> 0 dy <> 0][
									print ["xy" dx dy]
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
						;]
					][
						either all [(abs cx) < 60 (abs cy) < 60][
							;print ["CURVE-TO-LINE" dx dy]
							dx: cx + dx
							dy: cy + dy
							case [
								all [dx <> 0 dy <> 0][
									;print ["xy" dx dy]
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
								
							]
							
						][
							writeBit true
							writeBit false
							writeUB (-2 + nBits: getSBnBits reduce [cx cy dx dy]) 4 ;new nBits
							writeSB cx nBits
							writeSB cy nBits
							writeSB dx nBits
							writeSB dy nBits
						]
					]
					
					
					either rposx > maxX [maxX: rposx][ if rposx < minX [minX: rposx]]
					either rposy > maxY [maxY: rposy][ if rposy < minY [minY: rposy]]
				]
				false
			][
				
				states: readUB 5
				;print ["STATES:" states "POS:" oposx oposy "MOV:" moveX moveY]
			;	if any [oposx <> moveX oposy <> moveY][
			;		if moveX [
			;			print ["!!!! unclosed shape !!!! POS:" oposx oposy "MOV:" moveX moveY]
			;		]
			;	]
			;	print ["MAINPoints:" mold mainPoints]
				;parse mainPoints [
				;	any [
				;		'm 
				;	]
				;]
			;	clear mainPoints
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
				;	print ["END SHAPE" movex posx movey posy]
					writeBit false
					writeUB 0 5
					;print [
					;	"bounds:" minX maxX minY  maxY
					;	"^/       " bMinX bMaxX bMinY bMaxY
					;]
				;	if any [
				;		minX < bMinX
				;		maxX > bMaxX
				;		minY < bMinY
				;		maxY > bMaxY
				;	][
				;		print ["!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! out of bounds" bMinX bMaxX bMinY bMaxY]
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
						
						set [oposx oposy] readSBPair

						moveX: oposx
						moveY: oposy
						;print ["MOVE:" moveX moveY]
						
				;		print ["### OPOS:" oposx oposy]
				;		repend mainPoints ['m oposx oposy]
						
					
					;	if all [posx = newx newy = posy][print "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"]
					;	moveX: posx: oposx
					;	moveY: posy: oposy
						
						rposx: rsci-x oposx
						rposy: rsci-y oposy
					;	print ["MOVE:" rposx rposy "puvodni:" posx posy]
						
						
						;either rposx > maxX [maxX: rposx][ if rposx < minX [minX: rposx]]
						;either rposy > maxY [maxY: rposy][ if rposy < minY [minY: rposy]]
						writeSBPair reduce [
							;to integer! 0.5 + (rposx / 20)
							;to integer! 0.5 + (rposy / 20)
							rposx
							rposy
						]
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
	x: rsci-x readSB nBits
	y: rsci-y readSB nBits
	;print ["rescaleSBPair:" nbits x y]
	writeSBPair reduce [x y]
	;writeUB (nBits: getSBnBits probe reduce [x y]) 5 ;new nBits
	;writeSB x nBits
	;writeSB y nBits
]

rescaleMATRIX: does [
	alignBuffers
{nsx: (scx * sx)
nry: (scx * ry)
ntx: (scx * tx)
nrx: (scy * rx)
nsy: (scy * sy)
nty: (scy * ty)

[(scx * sx) (scx * ry) (scx * tx)]
[(scy * rx) (scy * sy) (scy * ty)]
[ 0         0          1         ]





sx: 0.789321899414063
sy: 1.05244445800781
rx: 0.287307739257813
ry: -0.383087158203125
tx: 1939
ty: 434
x: 0
y: 0
mm: func[x y sx sy rx ry tx ty][
	x: x / 20
	y: y / 20
	a: sx / 20
	c: ry / 20
	b: rx / 20
	d: sy / 20
	tx: tx / 20
	ty: ty / 20
	
	
	tmp: (a * d) - (b * c)
	ai:   d / tmp
	bi: - b / tmp
	ci: - c / tmp
	di:   a / tmp
	txi: ((c * ty) - (d * tx)) / tmp
	tyi: -((a * ty) - (b * tx)) / tmp

	reduce [
		20 * (xA: (x * ai) + (y * ci) + txi)
		20 * (yA: (x * bi) + (y * di) + tyi)
	]
]

;sx ry tx
;rx sy ty
;0  0  1

I have a placeObject with some transformation:
Scale: [0.707107543945313 0.707107543945313]
Rotate: [0.70709228515625 -0.707107543945313]
Translate: [5000 1000]

which can be writen in matrix as:
[ 0.707107543945313  -0.707107543945313 5000 ]
[ 0.70709228515625    0.707107543945313 1000 ]
[ 0                   0                 1    ]

I was scaling it proportionaly, which was easy, I just scaled the transform part.
But now I need to scale unproportionaly, which leads to distortion:/

Don't you have any idea how to solve it? If you understand me?

      
;.5 0 0
; 0 1 0
; 0 0 1

nsx: (sx * scx)

[scx 0 0] [sx ry tx
[0 scy 0] [rx sy ty
[0   0 1] [0  0  1 ]

nsx: (scx * sx)
nry: (scx * ry)
ntx: (scx * tx)
nrx: (scy * rx)
nsy: (scy * sy)
nty: (scy * ty)

[
(a1 * a2)  + (b1 * c2)		(a1 * b1) + (b1 * d2)
(c1 * a2)  + (d1 * c2)		(c1 * b2) + (d1 * d2)
(tx1 * a2) + (ty1 * c2) + tx2	(tx1 * b2) + (ty1 * d2) + ty2
]		

n: probe mm 0 0 sx sy rx ry tx ty
n/1: n/1 / 2
;ask ""
probe reduce [
	round ((0 + ((n/1 * sx) + (n/2 * ry))) / -20)
	round ((0 + ((n/2 * sy) + (n/1 * rx))) / -20)
]
a: 
xx: (x * a) + (y * c) + tx
yy: (x * b) + (y * d) + ty		
			
;probe mm n/1 n/2  sx sy rx ry tx ty


}
	if carryBitLogic [;scale
		;carryPair
		;probe tmp: readPair 
		;writePair  reduce [] ;[tmp/1 * rswf-rescale-index-x  tmp/2 * rswf-rescale-index-x] 
		writePair readPair 
	]
	if carryBitLogic [;rotate
		tmp: readPair 
		writePair reduce [(rswf-rescale-index-y * tmp/1 * power rswf-rescale-index-x -1) (rswf-rescale-index-x * tmp/2 * power rswf-rescale-index-y -1)] ;reduce [rswf-rescale-index-y * tmp/1 tmp/2 / rswf-rescale-index-y ]  
		;carryPair
		;writePair probe readPair 
	]
	;probe aaa: readSBPair
	;writeSBPair probe reduce [rsci-x aaa/1 rsci-y aaa/2] 
	rescaleSBPair 
	alignBuffers
]
rescaleMATRIXall: does[
	alignBuffers
	if carryBitLogic [;scale
		;writePair rsc readPair 
		tmp: readPair 
		writePair reduce [rswf-rescale-index-x * tmp/1 rswf-rescale-index-y * tmp/2]
	]
	if carryBitLogic [;rotate
		;writePair  readPair 
		tmp: readPair 
		writePair reduce [rswf-rescale-index-y * tmp/1 rswf-rescale-index-x * tmp/2]
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

rescaleMORPHGRADIENT: func[type /local gradients][
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
	
	;smooth all images:
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
				writeUI16 rsci readUI16 ;StartWidth
				writeUI16 rsci readUI16 ;EndWidth
				carryBytes 8 ;RGBA + RGBA
			]
			;DefineShape4
			any [tagId = 67 tagId = 83][
				writeUI16 rsci readUI16   ;Width
				carryBits 2              ;f_start_cap_style
				joinStyle: carryUB 2     ;f_join_style
				hasFill?:  carryBitLogic ;f_has_fill
				carryBits 11 ;f_no_hscale,f_no_vscale,f_pixel_hinting,5*reserved,f_no_close,2*f_end_cap_style

				if joinStyle = 2 [carryBytes 2] ;miterLimit
				either hasFill? [rescaleFILLSTYLE][carryBytes 4]
			]
			;DefineMorphShape2
			tagId = 84 [
				writeUI16 rsci readUI16 ;StartWidth
				writeUI16 rsci readUI16 ;EndWidth
				
				carryBits 2              ;f_start_cap_style
				joinStyle: carryUB 2     ;f_join_style
				hasFill?:  carryBitLogic ;f_has_fill
				carryBits 11 ;f_no_hscale,f_no_vscale,f_pixel_hinting,5*reserved,f_no_close,2*f_end_cap_style
				
				if joinStyle = 2 [carryBytes 2] ;miterLimit
				either hasFill? [rescaleFILLSTYLE][carryBytes 8]
			]
			true [
				writeUI16 rsci readUI16 ;Width
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
		writeUI16 rsci readUI16 ;StartWidth
		writeUI16 rsci readUI16 ;EndWidth
		
		
		
		;print ["linestyle" tagId]
		case [
			;DefineMorphShape
			tagId = 46 [
				writeUI16 rsci readUI16 ;StartWidth
				writeUI16 rsci readUI16 ;EndWidth
				carryBytes 8 ;RGBA + RGBA
			]
			;DefineShape4
			any [tagId = 67 tagId = 83][
				writeUI16 rsci readUI16   ;Width
				carryBits 2              ;f_start_cap_style
				joinStyle: carryUB 2     ;f_join_style
				hasFill?:  carryBitLogic ;f_has_fill
				carryBits 11 ;f_no_hscale,f_no_vscale,f_pixel_hinting,5*reserved,f_no_close,2*f_end_cap_style

				if joinStyle = 2 [carryBytes 2] ;miterLimit
				either hasFill? [rescaleFILLSTYLE][carryBytes 4]
			]
			;DefineMorphShape2
			tagId = 84 [
				writeUI16 rsci readUI16 ;StartWidth
				writeUI16 rsci readUI16 ;EndWidth
				
				carryBits 2              ;f_start_cap_style
				joinStyle: carryUB 2     ;f_join_style
				hasFill?:  carryBitLogic ;f_has_fill
				carryBits 11 ;f_no_hscale,f_no_vscale,f_pixel_hinting,5*reserved,f_no_close,2*f_end_cap_style
				
				if joinStyle = 2 [carryBytes 2] ;miterLimit
				either hasFill? [rescaleFILLSTYLE][carryBytes 8]
			]
			true [
				writeUI16 rsci readUI16 ;Width
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