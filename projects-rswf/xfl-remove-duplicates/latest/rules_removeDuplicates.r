rebol []

append XFL-action-rules [
	DOMDocument-removeDuplicates [
		"DOMDocument" (
			parse-xfl content
		) |
		"symbols" (
			dom-symbols: content
			parse-xfl content
		) |
		"DOMTimeline" (
			parse-xfl/act content 'DOMTimeline-removeDuplicates
		) |
		"DOMBitmapItem" (
			store-bitmap-hash current-node
		) |
		["media" | "timelines"] (
			parse-xfl content
		) |
		"DOMSoundItem"  |
		"Include"  (
			add-file-to-parse current-node  ;add this node into the parsing query
		) |
		"folders" |
		"swatchLists"  |
		"extendedSwatchLists" |
		"persistentData" |
		"PrinterSettings" |
		"publishHistory"
	]
	DOMSymbolItem-removeDuplicates [
		"DOMSymbolItem" (
			tmp_isSymbolGraphic?: "graphic" = select atts "symbolType"
			parse-xfl content
			tmp_isSymbolGraphic?: none
		) |
		"timeline" (
			parse-xfl/act content 'DOMTimeline-removeDuplicates
		)
	]
	DOMTimeline-removeDuplicates [
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
			parse-xfl/act content 'DOMShape-removeDuplicates
		) |
		"DOMSymbolInstance" |
		"DOMBitmapInstance" (
			if all [
				tmp: select atts "libraryItemName"
				tmp: select bitmap-duplicates tmp
			][
				tmp: to string! tmp
				if verbose > 0 [
					print ["Removing DOMBitmapInstance duplicate" mold atts/("libraryItemName") "->" mold tmp]
				]
				atts/("libraryItemName"): tmp
				file-modified?: true
			]
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
		"transformationPoint" |
		"betweenFrameMatrixList" |
		"IKTree"   ;do nothing
	]
	DOMShape-removeDuplicates [
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
			if all [
				tmp: select atts "bitmapPath"
				tmp: select bitmap-duplicates tmp
			][
				tmp: to string! tmp
				if verbose > 0 [
					print ["Removing BitmapFill duplicate" mold atts/("bitmapPath") "->" mold tmp]
				]
				atts/("bitmapPath"): tmp
				file-modified?: true
			]
		) |
		"LinearGradient" |
		"DottedStroke" |
		"DashedStroke" |
		"RaggedStroke"
	]
	
]