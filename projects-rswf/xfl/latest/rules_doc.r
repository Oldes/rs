rebol []

XFL-action-rules: [
	DOMDocument [
		"DOMDocument" (
			DOMDocument: atts
			parse-xfl content
		) |
		"folders" |
		"media" (
			clear Media
			clear Media-counter
			parse-xfl content
			new-line/skip Media true 2
		) |
		"symbols" (
			clear Symbols
			dom-symbols: content
			parse-xfl content
			new-line/skip Symbols true 1
		) |
		"Include" (
			append/only Symbols atts
			repend Symbol-counter [atts/("href") 0]
			count-symbol atts/("href")
		) |
		"DOMBitmapItem" (
			;append/only Media current-node
			repend Media-counter [atts/("name") either find atts "linkageIdentifier" [1][0]]
			tmp: atts/("sourceExternalFilepath")
			
			ext: last parse tmp "."
			
			atts/("sourceExternalFilepath"): join ".\LIBRARY\" [atts/("name") either find ["png" "jpg"] ext [join "." ext][".png"]]
			error? try [atts/("href"): tmp]
			;probe atts ask ""
			export-media-item atts
			;probe atts ask ""
			current-node: nodes-stack/-1
			append/only append Media select current-node/2 "name" current-node/2
		) |
		"DOMSoundItem" (
			repend Media-counter [atts/("name") either find atts "linkageIdentifier" [1][0]]
			export-sound atts
		) |
		"DOMTimeline" (
			parse-xfl/act content 'DOMTimeline
		) |
		
		"timelines" (
			parse-xfl content
		) |
		"swatchLists"  |
		"extendedSwatchLists" |
		"PrinterSettings" |
		"publishHistory" (
			clear content
		)
	]
	DOMSymbolItem [
		"DOMSymbolItem" (
			repend Media-counter [atts/("name") either find atts "linkageIdentifier" [1][0]]
			tmp_isSymbolGraphic?: "graphic" = select atts "symbolType"
			parse-xfl content
			tmp_isSymbolGraphic?: none
		) |
		"timeline" (
			parse-xfl/act content 'DOMTimeline
		)
	]
	DOMTimeline [
		[
			"DOMTimeline" |
			"layers" |
			"frames" |
			"elements" |
			"DOMLayer" |
			"DOMGroup" |
			"members"
		]  (
			parse-xfl content
		) |
		"DOMFrame" (
			count-medium select atts "soundName"
			parse-xfl content
		) |
		"DOMShape" (
			tmp_shapeMinPos: 99999999x99999999
			parse-xfl/act content 'DOMShape
			unless all [
				tmp_isSymbolGraphic?
				not in-guide?
				not in-tween?
			]  [
				;ask ["SHP bounds:" mold tmp_shapeMinPos]
				either tmp: select shape-counter ch: checksum mold content [
					tmp/1: tmp/1 + 1
				][	repend/only append shape-counter ch [1 content false] ]
			]
		) |
		"DOMSymbolInstance" (
			count-symbol join atts/("libraryItemName") ".xml"
		) |
		"DOMBitmapInstance" (
			;if there is bitmap placed like this one, don't use any crop on it!
			if tmp: select atts "libraryItemName" [
				count-medium tmp
				unless find noCrops tmp [
					append noCrops tmp
				]
			]
		) |
		"matrix" (
			tmp_matrix: copy []
			parse-xfl content
		) |
		"Matrix" (
			append tmp_matrix atts
		) |
		"DOMDynamicText" |
		"MorphShape" |
		"SoundEnvelope" |
		"tweens" |
		"Actionscript" |
		"morphHintsList" |
		"DOMStaticText" |
		"transformationPoint"  ;do nothing
	]
	DOMShape [
		"strokes" (
			tmp_strokes: copy []
			parse-xfl content
			;print ["strokes:" mold tmp_strokes]
		) |
		"edges" (
			parse-xfl content
		) |
		"Edge" (
			if all [
				tmp:  select atts "edges"
				;none? select att 'strokeStyle
			] [
				;probe atts probe tmp_fills ask ""
				fill0: select tmp_fills select atts "fillStyle0"
				fill1: select tmp_fills select atts "fillStyle1"
				fill0bmp: all [fill0 select fill0 "bitmapPath"]
				fill1bmp: all [fill1 select fill1 "bitmapPath"]
				
				;print [mold fill0bmp mold fill1bmp] ask ""
				bb: get-edges-BB tmp
				tmp_shapeMinPos/1: min tmp_shapeMinPos/1 bb/1
				tmp_shapeMinPos/2: min tmp_shapeMinPos/2 bb/2
				;append/only Shape-bounds bb
				if any [fill0bmp fill1bmp] [
	
					if fill0bmp [
						append append append bmpFills fill0bmp bb form-matrix select fill0 'matrix
					]
					if fill1bmp [
						append append append bmpFills fill1bmp bb form-matrix select fill1 'matrix
					]
					;probe bmpFills
					;ask ""
				]
			]
		) |
		"StrokeStyle" (
			append tmp_strokes select atts "index"
			tmp_strokeStyle: copy atts
			parse-xfl content
			append/only tmp_strokes tmp_strokeStyle
		) |
		"SolidStroke" (
			append tmp_strokeStyle atts
			parse-xfl content
			append/only append tmp_strokeStyle 'fill tmp_fill
		) |

		"transformationPoint" |
		"matrix" (
			tmp_matrix: copy []
			parse-xfl content
		) |
		"Matrix" (
			append tmp_matrix atts
		) |
		"fills" (
			
			tmp_fills: copy []
			parse-xfl content
			
		) |
		"FillStyle" (
			append tmp_fills select atts "index"
			tmp_fill: copy []
			tmp_fillStyle: copy atts
			parse-xfl content
			append/only tmp_fills tmp_fillStyle
		) |
		"GradientEntry" (
			append/only tmp_gradients atts
		) |
		"fill" (
			tmp_fill: copy []
			parse-xfl content
			
		) |
		"SolidColor" (
			
			;append/only append tmp_fill 'SolidColor atts
		) |
		"RadialGradient" (
			
			tmp_gradients: copy []
			parse-xfl content
			append/only append tmp_fillStyle 'matrix tmp_matrix
			append/only append tmp_fillStyle 'gradients tmp_gradients
		) |
		"BitmapFill" (
			append tmp_fillStyle atts
			count-medium select atts "bitmapPath"
			parse-xfl content
			append/only append tmp_fillStyle 'matrix tmp_matrix
		) |
		"LinearGradient" (
			append/only append tmp_fillStyle 'gradients content
		) |
		"DottedStroke"
	]
]