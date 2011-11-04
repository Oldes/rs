rebol []


combine-updateShape: has [id bounds end?][
	id: carryUI16 ;shapeID
	;	print ["SH" id tagId "\"]
	
	writeRect bounds: readRect ;shape bounds
	;print ["BOUNDS:" mold bounds]
	if tagId >= 67 [
		writeRect readRect ;edgeBounds
		carryBytes 1    ;flags: 6*reserved,usesNonScalingStrokes,usesScalingStrokes
	]
	alignBuffers
	
	loop carryCount [
		alignBuffers
		optimizeFILLSTYLE
	]
	loop carryCount [
		alignBuffers
		optimizeLINESTYLE
	]

	;ask ""
	
	numFillBits: carryUB 4
	numLineBits: carryUB 4
	end?: false
	

	until [
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
						carryUB numFillBits
					] ;fillStyle0
					if 0 < (states and 4 ) [
						carryUB numFillBits
					] ;fillStyle1
					if 0 < (states and 8 ) [
						carryUB numLineBits
					];lineStyle
					if 0 < (states and 16) [
						;print "2XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
						;probe states
						;ask ""
						
						alignBuffers
				
						loop carryCount [
							alignBuffers
							optimizeFILLSTYLE
						]
						loop carryCount [
							alignBuffers
							optimizeLINESTYLE
						]
						
						numFillBits: carryUB 4 ;Number of fill index bits for new styles
						numLineBits: carryUB 4 ;...line...
						break ;continue in main loop
					] ;NewStyles

					false ;continue
				]		
			]
		]
		end?
	]
	;ask "end"

	alignBuffers

	head outBuffer
]
