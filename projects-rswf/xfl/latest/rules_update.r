rebol []

append XFL-action-rules [
	DOMDocument-upd [
		[
			"DOMDocument" |
			"symbols"
		](
			parse-xfl content
		) |
		"DOMTimeline" (
			parse-xfl/act content 'DOMTimeline-upd
		) |
		"DOMBitmapItem" (
			if any [
				find Media-to-remove atts/("name")
				0 = select Media-counter (atts/("name"))
			] [
				;ask ["removing:" mold atts]
				append log_removed rejoin [atts/("name") tab atts/("href") lf]
				error? try [delete join xfl-folder-new to-rebol-file as-string utf8/decode atts/("href")]
				error? try [delete join xfl-folder-new [%bin/ atts/("bitmapDataHRef")]]
				clear current-node
			]
		) |
		["media" | "timelines"] (
			parse-xfl content
		) |
		"DOMSoundItem" (
			if any [
				0 = select Media-counter (atts/("name"))
			] [
				;ask ["removing:" mold atts]
				append log_removed rejoin [atts/("name") tab atts/("href") lf]
				error? try [delete join xfl-folder-new [%LIBRARY/ to-rebol-file as-string utf8/decode atts/("href")]]
				error? try [delete join xfl-folder-new [%bin/ atts/("soundDataHRef")]]
				clear current-node
			]
		) |
		"Include" (
			if 0 = select Symbol-counter (atts/("href")) [
				;ask ["removing:" mold atts]
				append log_removed rejoin [atts/("href") lf]
				error? try [delete join xfl-folder-new [%LIBRARY/ to-rebol-file as-string utf8/decode atts/("href")]]
				clear current-node
			]
		) |
		"folders" |
		"swatchLists"  |
		"extendedSwatchLists" |
		"PrinterSettings" |
		"publishHistory"
	]
	DOMSymbolItem-upd [
		"DOMSymbolItem" (
			tmp_isSymbolGraphic?: "graphic" = select atts "symbolType"
			parse-xfl content
			tmp_isSymbolGraphic?: none
		) |
		"timeline" (
			parse-xfl/act content 'DOMTimeline-upd
		)
	]
	DOMTimeline-upd [
		[
			"DOMTimeline" |
			"layers" |
			"frames" |
			"DOMFrame" |
			"elements" |
			"DOMGroup" |
			"members" |
			"Actionscript" 
			
		]  (
			parse-xfl content
		) |
		"DOMLayer" (
			;remove-atts atts ["current" | "isSelected"]
			parse-xfl content
		) |
		"DOMShape" (
			;remove-atts atts ["selected"]
			ch: checksum mold content 

			parse-xfl/act content 'DOMShape-upd
			current-node: nodes-stack/-1
			;ask mold current-node
			;probe nodes-stack/-5/2
			;probe select nodes-stack/-5/2/2 "layerType"
			
			if all [
				false ;do not use this optimisation now
				not tmp_isSymbolGraphic?
				not in-guide?
				not in-tween?
				tmp: select shape-counter ch
				tmp/1 > 2
			] [
				either tmp/3 [
					;ask ["USINGSYMB:" ch tmp/1]
					change current-node get-symbol-dom join "__symbol_" ch
				][

					;ask ["SHPUPD:" ch tmp/1]
					change current-node get-symbol-dom shape-to-symbol current-node ch
					tmp/3: true
				]
			]
			
			;either tmp: select shape-counter ch: checksum mold content [
			;	tmp/1: tmp/1 + 1
			;][	repend/only append shape-counter ch [1 content] ]
			;ask ["CHCHCH" checksum mold content]
		) |
		"DOMSymbolInstance" (
			
		) |
		"DOMBitmapInstance" (
			remove-atts atts ["selected"]
		) |
		"matrix" (
			tmp_matrix: copy []
			parse-xfl content
		) |
		"Matrix" (
			append tmp_matrix atts
		) |
		"script" (
			comment {
			either all [
				block? content
				string? content/1
				1 = length? content
			][
				insert content/1 "<![CDATA["
				append content/1 "]]>"
			][
				ask ["SCRIPT???" mold current-node]
			]
			}
		) |
		"DOMDynamicText" |
		"MorphShape" |
		"SoundEnvelope" |
		"tweens" |
		"morphHintsList" |
		"DOMStaticText" |
		"transformationPoint"   ;do nothing
	]
	DOMShape-upd [
		"strokes" (
			tmp_strokes: copy []
			parse-xfl content
			;print ["strokes:" mold tmp_strokes]
		) |
		"edges" (
			used-BB-opt?: false
			parse-xfl content
		) |
		"Edge" (
			case [
				all [used-BB-opt? find atts "cubics"] [clear current-node]
				all [
					;false
					tmp:  select atts "edges"
				] [
					;probe atts probe tmp_fills ask ""
					fill0: select tmp_fills select atts "fillStyle0"
					fill1: select tmp_fills select atts "fillStyle1"
					fill0bmp: all [fill0 select fill0 "bitmapPath"]
					fill1bmp: all [fill1 select fill1 "bitmapPath"]
					;print [mold fill0bmp mold fill1bmp] ask ""
					;probe tmp_fills
					;probe atts
					case [
						;false
						all [
							fill1bmp
							none? find noBB-fills fill1bmp
							none? fill0
							none? select atts "strokeStyle"
						]
						 [
						 
							print ["USING BB 1" fill1bmp]
							used-BB-opt?: true
							probe bb: get-edges-BB tmp
							x1: form-float round/to bb/1 .5
							y1: form-float round/to bb/2 .5
							x2: form-float round/to bb/3 .5
							y2: form-float round/to bb/4 .5
							clear tmp
							insert tmp rejoin [
								#"!" x1 #" " y1
								#"|" x2 #" " y1
								#"!" x2 #" " y1
								#"|" x2 #" " y2
								#"!" x2 #" " y2
								#"|" x1 #" " y2
								#"!" x1 #" " y2
								#"|" x1 #" " y1
							]
							;probe atts
							;ask ""
						]
						all [
							fill0bmp
							none? find noBB-fills fill0bmp
							none? fill1
							none? select atts "strokeStyle"
						] [
							used-BB-opt?: true
							print ["USING BB 0" fill0bmp]
							probe bb: get-edges-BB tmp
							x1: form-float round/to bb/1 .5
							y1: form-float round/to bb/2 .5
							x2: form-float round/to bb/3 .5
							y2: form-float round/to bb/4 .5
							clear tmp
							insert tmp rejoin [
								#"!" x1 #" " y1
								#"|" x1 #" " y2
								#"!" x1 #" " y2
								#"|" x2 #" " y2
								#"!" x2 #" " y2
								#"|" x2 #" " y1
								#"!" x2 #" " y1
								#"|" x1 #" " y1
							]
							;probe atts
							;ask ""
						]
					]
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
		"RaggedStroke" (
			append tmp_strokeStyle atts
			parse-xfl content
			append/only append tmp_strokeStyle 'fill tmp_fill
		) |
		"StippleStroke" (
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
			append/only append tmp_fill 'SolidColor atts
		) |
		"RadialGradient" (
			
			tmp_gradients: copy []
			parse-xfl content
			append/only append tmp_fillStyle 'matrix tmp_matrix
			append/only append tmp_fillStyle 'gradients tmp_gradients
		) |
		"BitmapFill" (
			append tmp_fillStyle atts
			if tmp: select crops atts/("bitmapPath") [
				atts/("bitmapPath"): to-string tmp/7
				opt-updateBmpMATRIX second first get-nodes content %matrix/Matrix tmp
			]
			probe current-node
			;ask ""
			
		) |
		"LinearGradient" (
			append/only append tmp_fillStyle 'gradients content
		) |
		"DottedStroke"
		
	]
]