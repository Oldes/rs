rebol []

append XFL-action-rules [
	DOMDocument-foreachItem [
		"DOMDocument" (
			parse-xfl content
		) |
		"DOMTimeline" (
			parse-xfl/act content 'DOMTimeline-foreachItem
		) |
		"symbols" (
			dom-symbols: content
			parse-xfl content
		) |
		[
			"DOMFolderItem" |
			"DOMBitmapItem" |
			"DOMSoundItem"
		] (
			onItemCallback current-node
		) |
		["media" | "timelines"] (
			parse-xfl content
		) |
		"Include"  (
			add-file-to-parse current-node  ;add this node into the parsing query
		) |
		"folders" |
		"swatchLists"  |
		"extendedSwatchLists" |
		"PrinterSettings" |
		"publishHistory"
	]
	DOMSymbolItem-foreachItem [
		"DOMSymbolItem" (
			tmp_isSymbolGraphic?: "graphic" = select atts "symbolType"
			parse-xfl content
			tmp_isSymbolGraphic?: none
		) |
		"timeline" (
			parse-xfl/act content 'DOMTimeline-foreachItem
		)
	]
	DOMTimeline-foreachItem [
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
			parse-xfl/act content 'DOMShape-foreachItem
		) |
		"DOMSymbolInstance" |
		"DOMBitmapInstance" (
			onNodeCallback current-node
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
	DOMShape-foreachItem [
		"strokes" (
			parse-xfl content
		) |
		"edges" |
		"Edge" |
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
		"BitmapFill" (
			onNodeCallback current-node
		) |
		"LinearGradient" |
		"DottedStroke" |
		"DashedStroke" |
		"RaggedStroke"
	]
	
]