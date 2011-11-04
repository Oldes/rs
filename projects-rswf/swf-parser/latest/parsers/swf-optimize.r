rebol [
	title: "SWF sprites and movie clip related parse functions"
	purpose: "Functions for parsing sprites and movie clip related tags in SWF files"
]

;tagId: none
use-BB-optimization?: false;true
set 'swf-tag-optimize func[tagId tagData /local err action st st2][
	;tagId: tag
	reduce either none? action: select parseActions tagId [
		;tagData
		;print ["importing tag:"  tagId]
		form-tag tagId tagData
	][
		setStreamBuffer tagData
		clearOutBuffer
		;print ["IMP>" index? inBuffer length? inBuffer]
		if error? set/any 'err try [
			set/any 'result do bind/copy action 'self
			;probe bind?
		][
			print ajoin ["!!! ERROR while optimizing tag:" select swfTagNames tagId "(" tagId ")"]
			throw err
		]
		result
		;head inBuffer
		;print ["IMP<" index? inBuffer length? head inBuffer]
		;form-tag tagId head inBuffer
	]

]



optimize-detectBmpFillBounds: has[
	shape result fillStyles lineStyles pos st dx dy tmp lineStyle fillStyle0 fillStyle1 p fill
	posX posY t0x t0y s0x s0y r0x r0y t1x t1y s1x s1y r1x r1y bmpFills noCropBitmaps usedFills usedLines allUsedLines allUsedFills
	lastBmpFill
] [
	;print ["optimize-detectBmpFillBounds" tagId]
	bmpFills: copy []
	noCropBitmaps: copy []
	
	
	id:     readUI16 ;shapeID
	bounds: readRect ;shape bounds
	;print ["BOUNDS:" mold bounds]
	if tagId >= 67 [
		readRect      ;edgeBounds
		skipBytes 1   ;flags: 6*reserved,usesNonScalingStrokes,usesScalingStrokes
	]
	
	fillStyles: readFILLSTYLEARRAY
	lineStyles: readLINESTYLEARRAY
	byteAlign
	lineStyle: fillStyle0: fillStyle1: none
	pos: 0x0
	posX: posY: 0
	fill: fill0posX: fill1posX: fill0posY: fill1posY: fill0: fill1: none
	minX: fill0minX: fill1minX:
	minY: fill0minY: fill1minY:  100000000
	maxX: fill0maxX: fill1maxX:
	maxY: fill0maxY: fill1maxY: -100000000
	
	usedFills:    copy []
	usedLines:    copy []
	allUsedFills: copy []
	allUsedLines: copy []
	allBounds:    copy []

	add-BmpFill: func[id minx miny maxx maxy sx sy rx ry tx ty /local lastBmpFill][
		lastBmpFill: skip tail bmpFills -11
		either all [
			id = lastBmpFill/1
			sx = lastBmpFill/6
			sy = lastBmpFill/7
			rx = lastBmpFill/8
			ry = lastBmpFill/9
			tx = lastBmpFill/10
			ty = lastBmpFill/11
		][
			change/part next lastBmpFill reduce [
				min minX lastBmpFill/2
				min minY lastBmpFill/3
				max maxX lastBmpFill/4
				max maxY lastBmpFill/5
			] 4
		][
			repend bmpFills [id minx miny maxx maxy sx sy rx ry tx ty]
		]
	]
	
	numFillBits: readUB 4 ;Number of fill index bits for new styles
	numLineBits: readUB 4 ;...line...
					
	until [
		either readBitLogic [ ;edge?
			;print "edge"
			either readBitLogic [;straightEdge?
				;print "line - "
				nBits: 2 + readUB 4 ;original nBits - result may be different!
				;comment {
				either readBitLogic [
					;GeneralLine
					posX: posX + readSB nBits ;deltaX
					posY: posY + readSB nBits ;deltaY
				][
					either readBitLogic [
						posY: posY + readSB nBits  ;deltaY
					][	posX: posX + readSB nBits ];deltaX
				]
				if fill0posX [
					fill0posX: posX
					fill0posY: posY
					;print ["FILL0 pos:" fill0posX fill0posY]
					fill0minX: min fill0minX fill0posX
					fill0maxX: max fill0maxX fill0posX
					fill0minY: min fill0minY fill0posY
					fill0maxY: max fill0maxY fill0posY
				]
				if fill1posX [
					fill1posX: posX
					fill1posY: posY
					fill1minX: min fill1minX fill1posX
					fill1maxX: max fill1maxX fill1posX
					fill1minY: min fill1minY fill1posY
					fill1maxY: max fill1maxY fill1posY
				]
				minX: min minX posX
				maxX: max maxX posX
				minY: min minY posY
				maxY: max maxY posY
			][
				;print "curve - "
				nBits: 2 + readUB 4
				x0: posX
				y0: posY
				
				x1: x0 + readSB nBits ;deltaX
				y1: y0 + readSB nBits ;deltaY
				posX: x1 + readSB nBits ;deltaX
				posY: y1 + readSB nBits ;deltaY
				
				minY: min minY yMin: either y0 > posY [
					either y1 > posY [posY][
						t: -( y1 - y0 ) / ( posY - (2 * y1) + y0 )
						(t1: 1 - t) * t1 * y0 + (2 * t * t1 * y1) + (t * t * posY)
					]
				][
					either y1 > y0 [y0][
						t: -( y1 - y0 ) / ( posY - (2 * y1) + y0 )
						(t1: 1 - t) * t1 * y0 + (2 * t * t1 * y1) + (t * t * posY)
					]
				]
				maxY: max maxY yMax: either y0 > posY [
					either y1 < y0 [y0][
						t: -( y1 - y0 ) / ( posY - (2 * y1) + y0 )
						(t1: 1 - t) * t1 * y0 + (2 * t * t1 * y1) + (t * t * posY)
					]
				][
					either posY > y1 [posY][
						t: -( y1 - y0 ) / ( posY - (2 * y1) + y0 )
						(t1: 1 - t) * t1 * y0 + (2 * t * t1 * y1) + (t * t * posY)
					]
				]
				minX: min minX xMin: either x0 > posX [
					either x1 > posX [posX][
						t: -( x1 - x0 ) / ( posX - (2 * x1) + x0 )
						(t1: 1 - t) * t1 * x0 + (2 * t * t1 * x1) + (t * t * posX)
					]
				][
					either x1 > x0 [x0][
						t: -( x1 - x0 ) / ( posX - (2 * x1) + x0 )
						(t1: 1 - t) * t1 * x0 + (2 * t * t1 * x1) + (t * t * posX)
					]
				]
				maxX: max maxX xMax: either x0 > posX [
					either x1 < x0 [x0][
						t: -( x1 - x0 ) / ( posX - (2 * x1) + x0 )
						(t1: 1 - t) * t1 * x0 + (2 * t * t1 * x1) + (t * t * posX)
					]
				][
					either x1 < posX [posX][
						t: -( x1 - x0 ) / ( posX - (2 * x1) + x0 )
						(t1: 1 - t) * t1 * x0 + (2 * t * t1 * x1) + (t * t * posX)
					]
				]
	
				;print ["-" x0 y0 x1 y1 posX posY xMin yMin xMax yMax]
				 
	
				if fill0posX [
					fill0posX: posX
					fill0posY: posY
					;print ["FILL0 pos:" fill0posX fill0posY]
					fill0minX: min fill0minX xMin
					fill0maxX: max fill0maxX xMax
					fill0minY: min fill0minY yMin
					fill0maxY: max fill0maxY yMax
				]
				if fill1posX [
					fill1posX: posX
					fill1posY: posY
					fill1minX: min fill1minX xMin
					fill1maxX: max fill1maxX xMax
					fill1minY: min fill1minY yMin
					fill1maxY: max fill1maxY yMax
				]

			]

					
			false
		][
			states: readUB 5
			;print ["STATES" mold states fill0posX]
			either states = 0 [;EndShapeRecord
				byteAlign
				true ;end
			][	;StyleChangeRecord
				if 0 < (states and 1 ) [;move
					set [posX posY] readSBPair
					if 0 = (states and 16) [
						minX: min minX posX
						maxX: max maxX posX
						minY: min minY posY
						maxY: max maxY posY
					]
				]
				prevFill0: fillStyle0
				prevFill1: fillStyle1
				fill0: fill1: none
				if 0 < (states and 2 ) [ ;fillStyle0
					fillStyle0: either fill0: readUB numFillBits [
						either fill0 > 0 [
							append usedFills fill0
							pick fillStyles fill0
						][	none ]
					][ none ]
				]
				if 0 < (states and 4 ) [ ;fillStyle1
					fillStyle1: either fill1: readUB numFillBits [
						either fill1 > 0 [
							append usedFills fill1
							pick fillStyles fill1
						][	none ]
					][ none ]
				]
				if 0 < (states and 8 ) [ ;lineStyle
					lineStyle: either tmp: readUB numLineBits [
						either tmp > 0 [
							append usedLines tmp
							pick lineStyles tmp
						][	none ]
					][ none ]
				]
				
				if fillStyle0 <> prevFill0 [
					if all [prevFill0 find [64 65 66 67] prevFill0/1 not none? fill0][
						;print ["end fill0-" fill0posX fill0posY]
						add-BmpFill prevFill0/2/1 fill0minX fill0minY fill0maxX fill0maxY s0x s0y r0x r0y t0x t0y
					]
					either all [
						fillStyle0
						find [64 65 66 67] fillStyle0/1
					][
						tmp: fillStyle0/2/2
						t0x: tmp/3/1
						t0y: tmp/3/2
						either tmp/2 [
							r0x: tmp/2/1
							r0y: tmp/2/2
						][
							r0x: r0y: 0	
						]
						either tmp/1 [
							s0x: tmp/1/1
							s0y: tmp/1/2
						][
							s0x: s0y: 0	
						]
						fill0posX: posX
						fill0posY: posY
						fill0minX: fill0minY:  100000000
						fill0maxX: fill0maxY: -100000000
					][
						t0x: t0y: r0x: r0y: s0x: s0y:
						fill0posX: fill0posY: none
					]
				]
				if fillStyle1 <> prevFill1 [
					if all [prevFill1 find [64 65 66 67] prevFill1/1 not none? fill1][
						;print ["end fill1-" fill1posX fill1posY]
						add-BmpFill prevFill1/2/1 fill1minX fill1minY fill1maxX fill1maxY s1x s1y r1x r1y t1x t1y
					]
					either all [
						fillStyle1
						find [64 65 66 67] fillStyle1/1
					][
						tmp: fillStyle1/2/2
						t1x: tmp/3/1
						t1y: tmp/3/2
						either tmp/2 [
							r1x: tmp/2/1
							r1y: tmp/2/2
						][
							r1x: r1y: 0	
						]
						either tmp/1 [
							s1x: tmp/1/1
							s1y: tmp/1/2
						][
							s1x: s1y: 0	
						]
						fill1posX: posX
						fill1posY: posY
						fill1minX: fill1minY:  100000000
						fill1maxX: fill1maxY: -100000000
					][
						t1x: t1y: r1x: r1y: s1x: s1y:
						fill1posX: fill1posY: none
					]
				]
				
				if fill0posX [
					fill0minX: min fill0minX fill0posX
					fill0maxX: max fill0maxX fill0posX
					fill0minY: min fill0minY fill0posY
					fill0maxY: max fill0maxY fill0posY
				]
				if fill1posX [
					fill1minX: min fill1minX fill1posX
					fill1maxX: max fill1maxX fill1posX
					fill1minY: min fill1minY fill1posY
					fill1maxY: max fill1maxY fill1posY
				]
	
				;print ["fillStyle0:" mold fillStyle0]
				;print ["fillStyle1:" mold fillStyle1]
				;probe fillStyle0
				;ask "aaa"
				
				if 0 < (states and 16) [
					;print "2XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
					
					repend/only allUsedFills [
						copy/deep fillStyles
						copy sort unique usedFills
					] 
					repend/only allUsedLines [
						copy/deep lineStyles
						copy sort unique usedLines
					]
					append/only allBounds reduce [to-integer minX round maxX to-integer minY round maxY]
					
					clear head usedFills
					clear head usedLines
					
					byteAlign
					fillStyles: readFILLSTYLEARRAY
					lineStyles: readLINESTYLEARRAY
					
					prevFill0: prevFill1: lineStyle: fillStyle0: fillStyle1: none
					pos: 0x0
					posX: posY: 0
					fill: fill0posX: fill1posX: fill0posY: fill1posY: fill0: fill1: none
					minX: fill0minX: fill1minX:
					minY: fill0minY: fill1minY:  100000000
					maxX: fill0maxX: fill1maxX:
					maxY: fill0maxY: fill1maxY: -100000000
					
					
					
					
					
					numFillBits: readUB 4 ;Number of fill index bits for new styles
					numLineBits: readUB 4 ;...line...
				] ;NewStyles

				false ;continue
			]		
		]
	]
	
	if all [fill0posX fillStyle0 find [64 65 66 67] fillStyle0/1][
		;print ["end fill0-" fill0posX fill0posY]
		add-BmpFill fillStyle0/2/1 fill0minX fill0minY fill0maxX fill0maxY s0x s0y r0x r0y t0x t0y
	]
	if all [fill1posX fillStyle1 find [64 65 66 67] fillStyle1/1] [
		;print ["end fill1-" fill1posX fill1posY]
		add-BmpFill fillStyle1/2/1 fill1minX fill1minY fill1maxX fill1maxY s1x s1y r1x r1y t1x t1y
	]	
	
	;print ["bmpFills" mold bmpFills]


;	bmpFills: copy []
;	foreach fill fillStyles [
;		if find [64 65 66 67] fill/1 [
;			repend bmpFills probe reduce [fill/2/1 fill/2/2/3  fill/3 fill/4 fill/5 fill/6]
;		]
;	]


	repend/only allUsedFills [
		copy/deep fillStyles
		copy sort unique usedFills
	]
	repend/only allUsedLines [
		copy/deep lineStyles
		copy sort unique usedLines
	]
	append/only allBounds reduce [to-integer minX round maxX to-integer minY round maxY]

	clear usedLines
	clear usedFills
	

	
;===============================================================================	
comment {
	shape: parse-DefineShape
	;print length? shape
	;ask ""
	;print "-=-=-=-"
	fillStyles: shape/4/1


	lineStyles: shape/4/2
	lineStyle: fillStyle0: fillStyle1: none
	pos: 0x0
	posX: posY: 0
	fill: fill0posX: fill1posX: fill0posY: fill1posY: none
	minX: fill0minX: fill1minX:
	minY: fill0minY: fill1minY:  100000000
	maxX: fill0maxX: fill1maxX:
	maxY: fill0maxY: fill1maxY: -100000000
	
	
	allUsedFills: copy []
	usedFills: copy []
	usedLines: copy []
	allUsedLines: copy []
	allBounds: copy []
	
	parse shape/4/3 [
		any [
			'style set st block! p: (
				;print ["style:" mold st]
				if all [st/2 st/2 > 0] [append usedFills st/2]
				if all [st/3 st/3 > 0] [append usedFills st/3]
				if all [st/4 st/4 > 0] [append usedLines st/4]
				;ask ""
				if all [fill0posX fill0bmp find [64 65 66 67] fill0bmp/1 not none? st/2] [
					;print ["end fill0-" fill0posX fill0posY]
					repend bmpFills reduce [fill0bmp/2/1 fill0minX fill0minY fill0maxX fill0maxY s0x s0y r0x r0y t0x t0y]
					fill0bmp: none
				]
				if all [fill1posX fill1bmp find [64 65 66 67] fill1bmp/1 not none? st/3] [
					;print ["end fill1-" fill1posX fill1posY]
					repend bmpFills reduce [fill1bmp/2/1 fill1minX fill1minY fill1maxX fill1maxY s1x s1y r1x r1y t1x t1y]
					fill1bmp: none
				]
				;smazat?-> if fill1pos [fill1pos: fill1pos + as-pair dx dy]
				fill0bmp: either fill0: st/2 [fillStyles/(fill0)][none]
				fill1bmp: either fill1: st/3 [fillStyles/(fill1)][none]
				if st/1 [
					posX: st/1/1
					posY: st/1/2
					minX: min minX posX
					maxX: max maxX posX
					minY: min minY posY
					maxY: max maxY posY
				]
				;print ["POS:" posX posY]
				either any [
					all [fill0bmp find [64 65 66 67] fill0bmp/1]
					all [fill1bmp find [64 65 66 67] fill1bmp/1]
				][
				;	print ["bmpfill" mold fill0bmp mold fill1bmp]
					;if fill0bmp [print ["????????????????????????" fill0bmp/2/1 fill0bmp/1]]
					;if fill1bmp [print ["????????????????????????" fill1bmp/2/1 fill1bmp/1]]
					either all [
						fill0bmp
						find [64 65 66 67] fill0bmp/1
					][
					;	probe fillStyles
						tmp: fill0bmp/2/2

						t0x: tmp/3/1
						t0y: tmp/3/2
						either tmp/2 [
							r0x: tmp/2/1
							r0y: tmp/2/2
						][
							r0x: r0y: 0	
						]
						either tmp/1 [
							s0x: tmp/1/1
							s0y: tmp/1/2
						][
							s0x: s0y: 0	
						]
						fill0posX: posX ;(posX * s0x) + (posY * r0y) + t0x
						fill0posY: posY ;(posY * s0y) + (posX * r0x) + t0y 
						fill0minX: fill0minY:  100000000
						fill0maxX: fill0maxY: -100000000
					][
						t0x: t0y: r0x: r0y: s0x: s0y:
						fill0posX: fill0posY: none
					]
					either all [fill1bmp find [64 65 66 67] fill1bmp/1] [
						tmp: fill1bmp/2/2

						t1x: tmp/3/1
						t1y: tmp/3/2
						either tmp/2 [
							r1x: tmp/2/1
							r1y: tmp/2/2
						][
							r1x: r1y: 0	
						]
						either tmp/1 [
							s1x: tmp/1/1
							s1y: tmp/1/2
						][
							s1x: s1y: 1	
						]
						fill1posX: posX ;(posX * s1x) + (posY * r1y) + t1x
						fill1posY: posY ;(posY * s1y) + (posX * r1x) + t1y 
						fill1minX: fill1minY:  100000000
						fill1maxX: fill1maxY: -100000000
					][
						t1x: t1y: r1x: r1y: s1x: s1y:
						fill1posX: fill1posY: none
					]

					;print ["FILL0:" fill0posX fill0posY t0x t0y s0x s0y r0x r0y]
					;print ["FILL1:" fill1posX fill1posY t1x t1y s1x s1y r1x r1y]
					
					if fill0posX [
						;print ["fill0pos" fill0posX fill0posY]
						fill0minX: min fill0minX fill0posX
						fill0maxX: max fill0maxX fill0posX
						fill0minY: min fill0minY fill0posY
						fill0maxY: max fill0maxY fill0posY
						print ["??" fill0minX fill0minY ]
					]
					if fill1posX [
						fill1minX: min fill1minX fill1posX
						fill1maxX: max fill1maxX fill1posX
						fill1minY: min fill1minY fill1posY
						fill1maxY: max fill1maxY fill1posY
					]
				][
					;print "nobmpfill"
					either tmp: find p 'style [p: tmp][p: tail p]
				]
				
				
				if st/5 [
					repend/only allUsedFills [
						copy/deep fillStyles
						copy sort unique usedFills
					] 
					repend/only allUsedLines [
						copy/deep lineStyles
						copy sort unique usedLines
					]
					append/only allBounds reduce [minX maxX minY maxY]
					
					clear head usedFills
					clear head usedLines
					
					;print ["new fillStyles:" mold st/5/1]
					;ask ""
					;new-style
					fillStyles: st/5/1
					lineStyles: st/5/2
					lineStyle: fillStyle0: fillStyle1: none
					pos: 0x0
					posX: posY: 0
					fill: fill0posX: fill1posX: fill0posY: fill1posY: none
					minX: fill0minX: fill1minX:
					minY: fill0minY: fill1minY:  100000000
					maxX: fill0maxX: fill1maxX:
					maxY: fill0maxY: fill1maxY: -100000000
				]
			) :p
			| 'line some [
				set dx integer! set dy integer! (
					posX: posX + dx
					posY: posY + dy
					if fill0posX [
						fill0posX: posX ;(posX * s0x) + (posY * r0y) + t0x
						fill0posY: posY ;(posY * s0y) + (posX * r0x) + t0y 
						;print ["FILL0 pos:" fill0posX fill0posY]
						fill0minX: min fill0minX fill0posX
						fill0maxX: max fill0maxX fill0posX
						fill0minY: min fill0minY fill0posY
						fill0maxY: max fill0maxY fill0posY
					]
					if fill1posX [
						fill1posX: posX ;(posX * s1x) + (posY * r1y) + t1x
						fill1posY: posY ;(posY * s1y) + (posX * r1x) + t1y 
						fill1minX: min fill1minX fill1posX
						fill1maxX: max fill1maxX fill1posX
						fill1minY: min fill1minY fill1posY
						fill1maxY: max fill1maxY fill1posY
					]
					minX: min minX posX
					maxX: max maxX posX
					minY: min minY posY
					maxY: max maxY posY
				)]
			|
			'curve some [
				;set cx integer! set cy integer!
				set dx integer! set dy integer! (
					posX: posX + dx
					posY: posY + dy
					if fill0posX [
						fill0posX: posX ;(posX * s0x) + (posY * r0y) + t0x
						fill0posY: posY ;(posY * s0y) + (posX * r0x) + t0y 
						fill0minX: min fill0minX fill0posX
						fill0maxX: max fill0maxX fill0posX
						fill0minY: min fill0minY fill0posY
						fill0maxY: max fill0maxY fill0posY
					]
					if fill1posX [
						fill1posX: posX ;(posX * s1x) + (posY * r1y) + t1x
						fill1posY: posY ;(posY * s1y) + (posX * r1x) + t1y 
						fill1minX: min fill1minX fill1posX
						fill1maxX: max fill1maxX fill1posX
						fill1minY: min fill1minY fill1posY
						fill1maxY: max fill1maxY fill1posY
					]
					minX: min minX posX
					maxX: max maxX posX
					minY: min minY posY
					maxY: max maxY posY
				)
			]
		]
	]
	if all [fill0posX fill0bmp] [
		;print ["end fill0" fill0posX fill0posY]
		repend bmpFills reduce [fill0bmp/2/1 fill0minX fill0minY fill0maxX fill0maxY s0x s0y r0x r0y t0x t0y]
		
	]
	if all [fill1posX fill1bmp] [
		;print ["end fill1" fill1posX fill1posY]
		repend bmpFills reduce [fill1bmp/2/1 fill1minX fill1minY fill1maxX fill1maxY s1x s1y r1x r1y t1x t1y]
		
	]


	;probe fill0bmp
print ["bmpFills" mold bmpFills]


;	bmpFills: copy []
;	foreach fill fillStyles [
;		if find [64 65 66 67] fill/1 [
;			repend bmpFills probe reduce [fill/2/1 fill/2/2/3  fill/3 fill/4 fill/5 fill/6]
;		]
;	]


	repend/only allUsedFills [
		copy/deep fillStyles
		copy sort unique usedFills
	]
	repend/only allUsedLines [
		copy/deep lineStyles
		copy sort unique usedLines
	]
	append/only allBounds reduce [minX maxX minY maxY]

	clear usedLines
	clear usedFills

	;print "======"
	;probe allUsedFills
	;probe allUsedLines
	;ask ""
					
	;print ["usedFills:" length? allUsedFills tab mold allUsedFills]
	;ask ""
	}
	;===============================================================================	
	reduce [
		bmpFills
		id
		context compose/only [
			fills: (new-line allUsedFills true)
			lines: (new-line allUsedLines true)
			bounds: (allBounds)
		]
	]
]


optimize-updateShape: has [id bounds styles fillsMap linesMap end?][
	id: carryUI16 ;shapeID
	;	print ["SH" id tagId "\"]
	
	writeRect bounds: readRect ;shape bounds
	;print ["BOUNDS:" mold bounds]
	if tagId >= 67 [
		writeRect readRect ;edgeBounds
		carryBytes 1    ;flags: 6*reserved,usesNonScalingStrokes,usesScalingStrokes
	]
	alignBuffers
	
	styles: select data/shapeStyles id
	fillsMap: optimize-processFills styles/fills/1/2
	linesMap: optimize-processLines styles/lines/1/2

	;ask ""
	
	numFillBits: carryUB 4
	numLineBits: carryUB 4
	end?: false
	

	until [
		;test if can use BBShape
		;ask "TESTING IF BB"
		either all [
			false
			use-BB-optimization?
			empty? linesMap
			1 = length? fillsMap ;= only one fill used
			tmp: pick styles/fills/1/1 fillsMap/1
			find [64 65 66] tmp/1 ;= optimize only bitmaps with transparency
			find [35 36] first select swfBitmaps tmp/2/1
			none? find data/noBBids tmp/2/1
		][
			
			;can simplify shape..skip source and write BB shape at the end
			;ask "simplify BB.."
			until [
				either readBitLogic [ ;edge?	
					either readBitLogic [;straightEdge?
						nBits: 2 + readUB 4 ;original nBits - result may be different!
						either readBitLogic [
							skipBits (2 * nBits) ;GeneralLine
						][	skipBits (1 + nBits)]
					][
						skipBits (4 * (2 + readUB 4))
					]
					false
				][
					states: readUB 5
					;ask reform ["states:" states]
					either states = 0 [
						;EndShapeRecord
						optimize-writeBBshape styles/bounds/1
						writeBit false
						writeUB 0 5
						alignBuffers
						end?:
						true ;end
					][
						;StyleChangeRecord
						;print ["STYLE CHANGE1:"]
						either 0 < (states and 16) [ ;NewStyles
							optimize-writeBBshape styles/bounds/1
							writeBit false
							writeUB states 5
							if 0 < (states and 1 ) [carrySBPair];move
							if 0 < (states and 2 ) [
								writeUB either 0 < tmp: readUB numFillBits [index? find fillsMap tmp][0] numFillBits
							] ;fillStyle0
							if 0 < (states and 4 ) [
								writeUB either 0 < tmp: readUB numFillBits [index? find fillsMap tmp][0] numFillBits
							] ;fillStyle1
							if 0 < (states and 8 ) [
								writeUB either 0 < tmp: readUB numLineBits [index? find linesMap tmp][0] numLineBits
							];lineStyle
						
							;print "1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
							;probe states
							;ask ""
							
							alignBuffers
							styles/fills:  next styles/fills
							styles/lines:  next styles/lines
							styles/bounds: next styles/bounds
							
							fillsMap: optimize-processFills styles/fills/1/2
							linesMap: optimize-processLines styles/lines/1/2
							
							numFillBits: carryUB 4 ;Number of fill index bits for new styles
							numLineBits: carryUB 4 ;...line...
							break ;continue in main loop
						][
							if 0 < (states and 1 ) [
								skipSBPair
							];move
							if 0 < (states and 2 ) [ skipBits numFillBits] ;fillStyle0
							if 0 < (states and 4 ) [ skipBits numFillBits] ;fillStyle1
							if 0 < (states and 8 ) [ skipBits numLineBits] ;lineStyle	
						
						]
						false ;continue
					]		
				]
			]
		][
			;cannot simplify this shape..so just reuse it
			until [
				either carryBitLogic [ ;edge?
			;		print "edge"
					either carryBitLogic [;straightEdge?
						;print "line - "
						nBits: 2 + carryUB 4 ;original nBits - result may be different!
						;comment {
						either carryBitLogic [
							;GeneralLine
							carrySB nBits ;deltaX
							carrySB nBits ;deltaY
						][
							carryBitLogic
							carrySB nBits
						]
					][
						;print "curve - "
						nBits: 2 + carryUB 4
						carrySB nBits ;controlDeltaX
						carrySB nBits ;Y
						carrySB nBits ;anchorDeltaX
						carrySB nBits ;Y
					]
					false
				][
					states: carryUB 5
					;print ["STATES" mold states]
					either states = 0 [
						;EndShapeRecord
						alignBuffers
						end?:
						true ;end
					][
						;StyleChangeRecord
						;print ["STYLE CHANGE2:" ]
						if 0 < (states and 1 ) [
					;		prin "Move "
							carrySBPair
						]      ;move
						if 0 < (states and 2 ) [
							writeUB either 0 < tmp: readUB numFillBits [index? find fillsMap tmp][0] numFillBits
						] ;fillStyle0
						if 0 < (states and 4 ) [
							writeUB either 0 < tmp: readUB numFillBits [index? find fillsMap tmp][0] numFillBits
						] ;fillStyle1
						if 0 < (states and 8 ) [
							writeUB either 0 < tmp: readUB numLineBits [index? find linesMap tmp][0] numLineBits
						];lineStyle
						if 0 < (states and 16) [
							;print "2XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
							;probe states
							;ask ""
							
							alignBuffers
							styles/fills:  next styles/fills
							styles/lines:  next styles/lines
							styles/bounds: next styles/bounds
							
							fillsMap: optimize-processFills styles/fills/1/2
							linesMap: optimize-processLines styles/lines/1/2
							
							numFillBits: carryUB 4 ;Number of fill index bits for new styles
							numLineBits: carryUB 4 ;...line...
							break ;continue in main loop
						] ;NewStyles
	
						false ;continue
					]		
				]
			]
		]
		
		end?
	]
	;ask "end"
	
	
	comment {
	foreach fill usedFills [
		print "+++++++++++++++++++"
		probe fill
		writeUI8 type: fill/1
		case  [
			type = 0 [
				;solid fill
				case [
					find [46 84] tagId [
						;morph
						writeRGBA fill/2/1
						writeRGBA fill/2/2
					]
					tagId >= 32 [writeRGBA fill/2]
					true [writeRGB fill/2]
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
					writeMATRIX   fill/2/1
					writeMATRIX   fill/2/2
					writeGRADIENT fill/2/3 type
				][	;shape
					writeMATRIX   fill/2/1
					writeGRADIENT fill/2/2 type
				]
			]
			type >= 64 [
				;bitmap
				reduce either find [46 84] tagId [
					;morph
					writeUI16 fill/2/1
					writeMATRIX   fill/2/2
					writeMATRIX   fill/2/3
				][	;shape
					writeUI16 fill/2/1
					writeMATRIX   fill/2/2
				]
			]
		] 
	]
	;zapsal jsem pouze pouzite fills
	}
	

	;alignBuffers
	;optimizeLINESTYLEARRAY
	;alignBuffers
	
	;optimize-shapeRecord id bounds (alignBuffers carryUB 4) carryUB 4
	alignBuffers
	;insert tail outBuffer copy inBuffer
	data/shapeReduction: data/shapeReduction + (length? head inBuffer) - length? head outBuffer
	head outBuffer
]

optimize-processLines: func[usedLineIds /local linesMap i LineStyles joinStyle hasFill?][
	alignBuffers
	
	linesMap: copy []
	writeCount length? usedLineIds
	i: 0
	loop readCount [
		alignBuffers
		;print ["????" i mold usedLineIds]
		either find usedLineIds i: i + 1 [
			append linesMap i 
			optimizeLINESTYLE
		][
			skipLINESTYLE
		]
	]
	alignBuffers
	linesMap
]

optimize-processFills: func[usedFillIds /local i fillMap type id][
	fillMap: copy []
	writeCount length? usedFillIds
	i: 0
	loop readCount [
		alignBuffers
		either find usedFillIds i: i + 1 [
			append fillMap i 
			optimizeFILLSTYLE
		][;UNUSED FILL = skipping!
			skipFILLSTYLE
		]
	]
	alignBuffers
	fillMap
]

optimize-writeBBshape: func[bounds /local minx miny maxx maxy][
	set [minx maxx miny maxy] bounds
	print reform ["USING BBShape" mold bounds]
	writeBit false
	writeUB 3 5
	writeSBPair reduce [minx miny] ;-1040 -1480 880 1400
	writeUB 1 numFillBits
	
	writeBit true
	writeBit true ;straightEdge
	writeUB (nBits: to integer! log-2 tmp: (maxx - minx)) 4
	nBits: nBits + 2
	writeBit false
	writeBit false ;horiz
	writeSB tmp nBits
	
	writeBit true
	writeBit true ;straightEdge
	writeUB (nBits: to integer! log-2 tmp: (maxy - miny)) 4
	nBits: nBits + 2
	writeBit false
	writeBit true ;vert
	writeSB tmp nBits
	
	writeBit true
	writeBit true ;straightEdge
	writeUB (nBits: to integer! log-2 abs tmp: (minx - maxx)) 4
	nBits: nBits + 2
	writeBit false
	writeBit false ;horiz
	writeSB tmp nBits
	
	writeBit true
	writeBit true ;straightEdge
	writeUB (nBits: to integer! log-2 abs tmp: (miny - maxy)) 4
	nBits: nBits + 2
	writeBit false
	writeBit true ;vert
	writeSB tmp nBits
	;print ["done.." bounds]
]

updateCombinedBmpMATRIX: func[id /local ofs sc ro pos][
	either ofs: select data/combined-bitmaps id [
		;print ["updateBmpMATRIX" id "to:" ofs]
		alignBuffers
		either carryBitLogic [;scale
			writePair sc: readPair
		][	sc: 0x0 ]
		either carryBitLogic [;rotate
			writePair ro: readPair
		][	ro: 0x0 ]
		pos: readSBPair
		;probe ofs: 20 * ofs
		;ask ""
		;print [sc ro pos]
		writeSBPair probe reduce [
		;	pos/1 - (ofs/x)
		;	pos/2 - (ofs/y)
			round (pos/1 - ((ofs/x * sc/1) + (ofs/y * ro/2)))
			round (pos/2 - ((ofs/y * sc/2) + (ofs/x * ro/1)))
		]
		alignBuffers
	][
		carryMATRIX
	]
]
updateBmpMATRIX: func[id /local size pos sc ro][
	either any [
		none? size: select data/crops id
	;	all [size/1 = 0 size/2 = 0]
	][
		carryMATRIX
	][
		alignBuffers
		either carryBitLogic [;scale
			writePair sc: readPair
		][	sc: 0x0 ]
		either carryBitLogic [;rotate
			writePair ro: readPair
		][	ro: 0x0 ]
		pos: readSBPair

		writeSBPair reduce [
			round (pos/1 + ((size/5 * sc/1) + (size/6 * ro/2)))
			round (pos/2 + ((size/6 * sc/2) + (size/5 * ro/1))) ;- 30 ;((pos/2 / sc/2) * 20)
		]
		alignBuffers
	]
]


optimizeFILLSTYLE: has[type id newid][
	alignBuffers
	writeUI8 type: readUI8 ;FillStyleType
	;print ["optimizeFILLSTYLE..." type tagId]
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
			;print "gradient.."
			either find [46 84] tagId [
				;morph
				carryMATRIX
				carryMATRIX
				byteAlign
				;MORPHGRADIENT:
				loop carryUI8 [
					carryBytes 10 ;Start ratio,Start color,End ratio,End color
				]
			][	;shape
				;print "./......................."
				carryMATRIX
				byteAlign
				;GRADIENT:
				carryBits 4 ;SpreadMode + InterpolationMode
				loop carryUB 4 [
					;GRADRECORD
					carryBytes either tagId >= 32 [5][4] ;ratio + color
				]
				if all [type = 19 tagId = 83] [carryBytes 2] ;FocalPoint
			]
			;print "//"
		]
		type >= 64 [
			;bitmap
			reduce either find [46 84] tagId [
				;morph
				id: readUI16
				either find first data 'combined-bitmaps [
					either find data/combined-bitmaps id [
						writeUI16 data/combined-bmp-id
						updateCombinedBmpMATRIX id
						updateCombinedBmpMATRIX id
					][
						writeUI16 id
						carryMATRIX
						carryMATRIX
					]
				][
					writeUI16 id
					updateBmpMATRIX id
					updateBmpMATRIX id
				]
				
			][	;shape
				id: readUI16
				either find first data 'combined-bitmaps [
					either find data/combined-bitmaps id [
						writeUI16 data/combined-bmp-id
						updateCombinedBmpMATRIX id
					][
						writeUI16 id
						carryMATRIX
					]
					
				][
					writeUI16 id
					updateBmpMATRIX id
				]
			]
		]
	]
]
optimizeLINESTYLE: has[joinStyle hasFill?][
	alignBuffers
	case [
		;DefineMorphShape
		tagId = 46 [
			carryBytes 12 ;StartWidth, EndWidth, RGBA + RGBA
		]
		;DefineShape4
		any [tagId = 67 tagId = 83][
			carryBytes 2   ;Width
			carryBits  2              ;f_start_cap_style
			joinStyle: carryUB 2     ;f_join_style
			hasFill?:  carryBitLogic ;f_has_fill
			carryBits 11 ;f_no_hscale,f_no_vscale,f_pixel_hinting,5*reserved,f_no_close,2*f_end_cap_style

			if joinStyle = 2 [carryBytes 2] ;miterLimit
			either hasFill? [optimizeFILLSTYLE][carryBytes 4]
		]
		;DefineMorphShape2
		tagId = 84 [
			carryBytes 4 ;StartWidth, EndWidth
			carryBits 2              ;f_start_cap_style
			joinStyle: carryUB 2     ;f_join_style
			hasFill?:  carryBitLogic ;f_has_fill
			carryBits 11 ;f_no_hscale,f_no_vscale,f_pixel_hinting,5*reserved,f_no_close,2*f_end_cap_style
			
			if joinStyle = 2 [carryBytes 2] ;miterLimit
			either hasFill? [optimizeFILLSTYLE][carryBytes 8]
		]
		true [
			carryBytes either tagId = 32 [6][5]
		]
	];case
]
skipFILLSTYLE: has [type id][
	alignBuffers
	type: readUI8 ;FillStyleType
	;print ["optimizeFILLSTYLE..." type tagId]
	case [
		type = 0 [
			;solid fill
			case [
				find [46 84] tagId [
					skipBytes 8 ;morph RGBAs
				]
				tagId >= 32 [skipBytes 4] ;RGBA
				true [skipBytes 3] ;RGB
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
				readMATRIX
				readMATRIX
				byteAlign
				;MORPHGRADIENT:
				loop readUI8 [
					skipBytes 10 ;Start ratio,Start color,End ratio,End color
				]
			][	;shape
				readMATRIX
				;GRADIENT:
				byteAlign
				skipBits 4 ;SpreadMode + InterpolationMode
				loop readUB 4 [
					;GRADRECORD
					skipBytes either tagId >= 32 [5][4] ;ratio + color
				]
				if all [type = 19 tagId = 83] [skipBytes 2] ;FocalPoint
			]
		]
		type >= 64 [
			;bitmap
			reduce either find [46 84] tagId [
				;morph
				skipUI16
				readMATRIX
				readMATRIX
			][	;shape
				skipUI16
				readMATRIX
			]
		]
	]
]
skipLINESTYLE: has[][
	alignBuffers
	case [
		;DefineMorphShape
		tagId = 46 [
			skipBytes 12 ;StartWidth, EndWidth, RGBA + RGBA
		]
		;DefineShape4
		any [tagId = 67 tagId = 83][
			skipBytes 2   ;Width
			skipBits  2              ;f_start_cap_style
			joinStyle: readUB 2     ;f_join_style
			hasFill?:  readBitLogic ;f_has_fill
			skipBits 11 ;f_no_hscale,f_no_vscale,f_pixel_hinting,5*reserved,f_no_close,2*f_end_cap_style

			if joinStyle = 2 [skipBytes 2] ;miterLimit
			either hasFill? [skipFILLSTYLE][skipBytes 4]
		]
		;DefineMorphShape2
		tagId = 84 [
			skipBytes 4 ;StartWidth, EndWidth
			skipyBits 2              ;f_start_cap_style
			joinStyle: readUB 2     ;f_join_style
			hasFill?:  readBitLogic ;f_has_fill
			skipBits 11 ;f_no_hscale,f_no_vscale,f_pixel_hinting,5*reserved,f_no_close,2*f_end_cap_style
			
			if joinStyle = 2 [skipBytes 2] ;miterLimit
			either hasFill? [skipFILLSTYLE][skipBytes 8]
		]
		true [
			skipBytes either tagId = 32 [6][5]
		]
	];case
]
