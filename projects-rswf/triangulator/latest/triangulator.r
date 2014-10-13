REBOL [
    Title: "Triangulator"
    Date: 29-Dec-2013/16:35:22+1:00
    Author: "Oldes"
	require: [
		rs-project %stream-io
	]
]

ctx-triangulator: context [
	out: make stream-io [] ;Holds output stream
	;#CURVE RELATED FUNCTIONS
	;used to convert Bazier curve to lines 
	_terms: none
	_subSteps: 0
	_bezierError: 0.75
	_minLineWidth: 20 ;in TWIPS!! so 40 = 2px
	
	_curveOutput: copy []
	
	quadraticCurve: func[
		a1x   [number!]
		a1y   [number!]
		cx    [number!]
		cy    [number!]
		a2x   [number!]
		a2y   [number!]
		;error [decimal!]
	][
		_subSteps: 0
		;_bezierError: error
		_terms: reduce [a1x a1y cx cy a2x a2y]
			
		clear _curveOutput
			
		subdivide 0.0 0.5 0 :quadratic _curveOutput
		subdivide 0.5 1.0 0 :quadratic _curveOutput
		
		;print _subSteps
		head _curveOutput
	]
	quadratic: func[t axis][ 
		oneMinusT: 1.0 - t
		a1: _terms/(1 + axis)
		c:  _terms/(3 + axis)
		a2: _terms/(5 + axis)
		(oneMinusT * oneMinusT * a1) + (2.0 * oneMinusT * t * c) + (t * t * a2)
	]
	subdivide: func[
		t0 t1 depth equation _curveOutput
		/local quadX quadY x0 y0 x1 y1 midX midY dx dy error2
	][
		quadX: equation (t0 + t1) * 0.5 0
		quadY: equation (t0 + t1) * 0.5 1
		
		x0: equation t0 0
		y0: equation t0 1
		x1: equation t1 0
		y1: equation t1 1
		
		midX: ( x0 + x1 ) * 0.5;
		midY: ( y0 + y1 ) * 0.5;
		
		dx:  quadX - midX;
		dy:  quadY - midY;
		
		error2: (dx * dx) + (dy * dy)

		either error2 > (_bezierError * _bezierError) [
			subdivide  t0 (t0 + t1) * 0.5 depth + 1 :equation _curveOutput	
			subdivide (t0 + t1) * 0.5 t1  depth + 1 :equation _curveOutput	
		][
			_subSteps: _subSteps + 1
			repend _curveOutput [x1 y1]
		]
	]
	;END OF CURVE RELATED FUNCTIONS
	
	
	
	penPosX: penPosY: 0

	
	strokeDefinition: copy []
	vertexBuffers:    copy []
	indexBuffers:     copy []
	vertices:         copy []
	indices:          copy []
	idx: 0
	
	lineWidth: 1
	lineColor: 255.255.255.255
	
	stroke-to-polyline: func[
		/local
		v0x v0y v1x v1y v2x v2y 
		d0 d1 d0x d0y d1x d1y
		n0x n0y n1x n1y cnx cny c
		c1xPos c1yPos c1xNeg c1yNeg
		elbowThickness dot
		clrR clrG clrB clrA
		pos isFirst? isLast?
		
	][
		strokeDefinition: head strokeDefinition
		;prin "stroke-to-polyline" probe strokeDefinition
		v0x: v0y:  none
		parse strokeDefinition [
			any [
				'width set lineWidth number!
				|
				'color set lineColor tuple! (
					clrR: lineColor/1 / 255
					clrG: lineColor/2 / 255
					clrB: lineColor/3 / 255
					clrA: lineColor/4 / 255
				)
				|
				set v1x number!
				set v1y number!
				pos: (
					if isFirst?: none? v0x [
						v0x: v1x
						v0y: v1y
					]
					if isLast?: not parse pos [
						opt ['width number!]
						opt ['color tuple!]
						set v2x number!
						set v2y number!
						to end
					][
						v2x: v1x
						v2y: v1y
					]
					
					d0x: v1x - v0x
					d0y: v1y - v0y
					d1x: v2x - v1x
					d1y: v2y - v1y
					
					if isLast? [
						v2x: v2x + d0x
						v2y: v2y + d0y
						d1x: v2x - v1x
						d1y: v2y - v1y
					]
					if isFirst? [
						v0x: v0x - d1x
						v0y: v0y - d1y
						d0x: v1x - v0x
						d0y: v1y - v0y
					]
					d0: square-root (d0x * d0x) + (d0y * d0y)
					d1: square-root (d1x * d1x) + (d1y * d1y)
					
					elbowThickness: lineWidth * 0.5

					unless any [isFirst? isLast?][
						;// Thanks to Tom Clapham for spotting this relationship.
						dot: ((d0x * d1x) + (d0y * d1y)) / (d0 * d1)
						either error? try [
							elbowThickness: elbowThickness / sine/radians ((PI - arccosine/radians dot) * 0.5)
						][
							elbowThickness: lineWidth * 0.5
						][
							if elbowThickness > (lineWidth * 4) [
								elbowThickness: lineWidth * 4
							]
						]
					]
					
					n0y:  d0x / d0
					n1x: - d1y / d1
					n0x: - d0y / d0
					n1y:  d1x / d1
								  
					cnx: n0x + n1x
					cny: n0y + n1y
					error? try [
						c:   (1 / square-root( (cnx * cnx) + (cny * cny) )) * elbowThickness
						cnx: cnx * c
						cny: cny * c
					]
					
					v1xPos: v1x + cnx
					v1yPos: v1y + cny
					v1xNeg: v1x - cnx
					v1yNeg: v1y - cny
							
					repend vertices [
						v1xPos v1yPos  clrR clrG clrB clrA
						v1xNeg v1yNeg  clrR clrG clrB clrA
					]
					unless isLast? [
						repend indices [
							idx
							idx + 2
							idx + 1
							idx + 1
							idx + 2
							idx + 3
						]
						idx: idx + 2
					]
					;store current point for future use
					v0x: v1x
					v0y: v1y
				)
			]	
		]
		strokeDefinition: clear head strokeDefinition
	]
	
	set 'triangulate-shape func[
		data
		/local
			lineWidth lineColor lineData curveData err
			penPosX penPosY
			startIdx
	][
		idxOld: idx
		startIdx: length? indices
		startVert: length? vertices
		
		parse/all data [
			any [
				'lineStyle
					set lineWidth integer! (
						strokeDefinition: insert strokeDefinition reduce ['width lineWidth: lineWidth * 0.05]
					)
					opt [set lineColor tuple! (
						strokeDefinition: insert strokeDefinition reduce ['color lineColor]			
					)]
				|
				'moveTo (stroke-to-polyline) set penPosX number! set penPosY number! (
					penPosX: penPosX * 0.05
					penPosY: penPosY * 0.05
					strokeDefinition: insert strokeDefinition reduce ['width lineWidth 'color lineColor penPosX penPosY]
					unless empty? indices [idx: idx + 2]
				)
				|
				'line set lineData block! (
					if none? penPosX [
						penPosX: 0
						penPosY: 0
						strokeDefinition: insert strokeDefinition reduce ['width lineWidth 'color lineColor penPosX penPosY]
						unless empty? indices [idx: idx + 2]
					]
					foreach [dx dy] lineData [
						strokeDefinition: insert strokeDefinition reduce [
							penPosX: penPosX + (dx * 0.05)
							penPosY: penPosY + (dy * 0.05)
						]
					]
				)
				|
				'curve set curveData block! (
					if none? penPosX [
						penPosX: 0
						penPosY: 0
						strokeDefinition: insert strokeDefinition reduce ['width lineWidth 'color lineColor penPosX penPosY]
						unless empty? indices [idx: idx + 2]
					]
					foreach [cx cy dx dy] curveData [
						strokeDefinition: insert strokeDefinition quadraticCurve
							penPosX penPosY
							penPosX: penPosX + (cx * 0.05)
							penPosY: penPosY + (cy * 0.05)
							penPosX: penPosX + (dx * 0.05)
							penPosY: penPosY + (dy * 0.05)
						
						
					]
				)
				| copy err 1 skip (
					ask reform ["Invalid shape definition:" mold err]
				)
			]
			(stroke-to-polyline)
		]
		;print ["shape idx: " idx]
		if ((length? vertices) / 6) > 65535 [;65535
			print ["shape idx: " idx "idxOld:" idxOld "startIdx: " startIdx " triangles: " ((length? indices) - startIdx) / 3 ]
			append/only indexBuffers  copy/part indices startIdx
			append/only vertexBuffers copy/part vertices startVert
			remove/part indices startIdx
			remove/part vertices startVert
			idxOld: idxOld + 2
			;probe indices 

			forall indices [indices/1: indices/1 - idxOld]
			indices: head indices
			;probe indices 
			;ask ""
			;ask ["VERTEX OVERFLOW" startIdx idxOld]
			startIdx: startVert: 0
			unless empty? indices [
				idx: -1 + last indices
			]
		]
		reduce [length? vertexBuffers startIdx ((length? indices) - startIdx) / 3]
	]

	init: does [
		out/clearBuffers
		forall vertexBuffers [clear vertexBuffers/1]
		forall indexBuffers  [clear indexBuffers/1]
		vertexBuffers: clear head vertexBuffers
		indexBuffers:  clear head indexBuffers
		vertices: clear head vertices
		indices:  clear head indices
		idx: 0
	]
	get-buffers-binary: func[][
		out/clearBuffers
		
		append/only indexBuffers  copy indices
		append/only vertexBuffers copy vertices
	;	probe vertexBuffers
	;	probe indexBuffers
		
		either empty? vertexBuffers/1 [
			out/writeUI8 0
		][
			out/writeUI8 length? vertexBuffers
			;print ["NUM BUFFERS:" length? vertexBuffers]
			foreach vertices vertexBuffers [
				out/writeUI32 (length? vertices) / 6
				print ["VERTEX BUFFER BYTES: " ((length? vertices) / 6) 4 * length? vertices]
				forall vertices [out/writeFloat vertices/1]
				clear head vertices
			]
			
			;shapes indexBuffer:
			foreach indices indexBuffers [
				out/writeUI32 length? indices
				probe copy/part indices 10
				print ["INDEXE BUFFERs: " length? indices]
				forall indices [out/writeUI16 indices/1]
				clear head indices
			]
		]
		clear vertexBuffers
		clear indexBuffers
		;probe copy/part head out/outBuffer 4
		head out/outBuffer
	]	
{
	triangulate-shape [
		lineStyle 20 255.0.0.255 
		moveTo 200 0 
		line [2000 0]
	]

	triangulate-shape [
		lineStyle 20 0.0.255.255 
		moveTo 200 0 
		line [0 2000 2000 2000]
	]
	
;	append/only indexBuffers  copy indices
;		append/only vertexBuffers copy vertices
	
	probe get-buffers-binary

		
	probe idx
	;probe vertices
	out: copy ""
	foreach [x y r g b a] vertices [
		append out ajoin [x ", " y ",  " r ", " g ", " b ", " a ", " lf] 
	]
	append out "^/^/"
	n: 0
	foreach [i1 i2 i3] indices [
		if n = 2 [n: 0 append out "^/"]
		append out ajoin [i1 "," i2 "," i3 ", "]
		n: n + 1
	]
	print out

	}
]