rebol []

append XFL-action-rules [
	DOMDocument-shapesUpd [
		"DOMDocument" (
			parse-xfl content
		) |
		"symbols" (
			dom-symbols: content
			parse-xfl content
		) |
		"DOMTimeline" (
			parse-xfl/act content 'DOMTimeline-shapesUpd
		) |
		"DOMBitmapItem" |
		["media" | "timelines"] (
			parse-xfl content
		) |
		"DOMSoundItem"  |
		"Include"  (
			use [dom node][
				add-file-to-parse current-node  ;add this node into the parsing query
			]
		) |
		"folders" |
		"swatchLists"  |
		"extendedSwatchLists" |
		"persistentData" |
		"PrinterSettings" |
		"publishHistory"
	]
	DOMSymbolItem-shapesUpd [
		"DOMSymbolItem" (
			tmp_isSymbolGraphic?: "graphic" = select atts "symbolType"
			parse-xfl content
			tmp_isSymbolGraphic?: none
		) |
		"timeline" (
			parse-xfl/act content 'DOMTimeline-shapesUpd
		)
	]
	DOMTimeline-shapesUpd [
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
			remove-atts atts ["selected"]
			parse-xfl/act content 'DOMShape-shapesUpd
			ch: checksum mold remove-dom-formating copy content
			
			print "------------------------"
			current-node: nodes-stack/-1
			;ask mold current-node
			;probe nodes-stack/-5/2
			;probe select nodes-stack/-5/2/2 "layerType"
			
			either tmp: select shape-counter ch [
				tmp/1: tmp/1 + 1
			][
				tmp: last repend/only append shape-counter ch [1 content false]
			]
			;ask ["CHCHCH" ch]

			if all [
				;false ;do not use this optimisation now
				;not tmp_isSymbolGraphic?
				not in-guide?
				not in-tween?
				;tmp/1 > 2
			] [
				either tmp/3 [
					print ["USINGSYMB:" ch tmp/1]
					change current-node make-symbol-dom join "__symbol_" ch
				][

					print ["SHPUPD:" ch tmp/1]
					tmp/3: true
					change current-node make-symbol-dom shape-to-symbol current-node ch
				]
				file-modified?: true
			]
			
			
		) |
		"DOMSymbolInstance" (
			
		) |
		"DOMBitmapInstance" (
			remove-atts atts ["selected"]
		) |
		"matrix" |
		"Matrix" |
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
		"motionObjectXML" |
		"transformationPoint"   ;do nothing
	]
	DOMShape-shapesUpd [
		"strokes" (
			parse-xfl content
		) |
		"edges" (
			parse-xfl content
		) |
		"Edge" (
			case [
				tmp: select atts "cubics" [
					clear current-node
				]
				tmp:  select atts "edges" [
					clear-edges tmp
				]
			]
		) |
		"StrokeStyle" (
			parse-xfl content
		) |
		"SolidStroke" (
			parse-xfl content
		) |
		"StippleStroke" |

		"transformationPoint" |
		"matrix" |
		"Matrix" |
		"fills" (
			parse-xfl content
		) |
		"FillStyle" (
			parse-xfl content
		) |
		"GradientEntry" |
		"fill" (
			parse-xfl content
			
		) |
		"SolidColor" |
		"RadialGradient"  |
		"BitmapFill"  |
		"LinearGradient" |
		"DottedStroke" |
		"DashedStroke" |
		"RaggedStroke"
	]
	
]