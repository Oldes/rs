rebol []


insert XFL-action-rules [
	DOMDocument-clean [
		[
			"DOMDocument" |
			"folders" |
			"fonts" |
			"media" |
			"symbols" |
			"timelines" 
		]
		(
			parse-xfl content
		) |
		"DOMFolderItem" (
			append/only folders-to-check current-node
		) |
		"Include" (
			use [dom node][
				add-item-to-check current-node
			
				;I must load the file to get info if it's exported
				dom: to-DOM as-string read/binary xfl-source-dir/LIBRARY/(encode-filename select atts "href")
				node: get-node dom %DOMSymbolItem

				if "true" = select node/2 "linkageExportForAS" [
					remove back tail items-to-check ;removes the item from clean check
					add-file-to-parse current-node  ;add this node into the parsing query
				]
			]
		) |
		[
			"DOMBitmapItem" |
			"DOMSoundItem"
		] (
			add-item-to-check current-node
		) |
		"DOMCompiledClipItem" |
		"DOMTimeline" (
			parse-xfl/act content 'DOMTimeline-clean
		) |
		"swatchLists"  |
		"extendedSwatchLists" |
		"PrinterSettings" |
		"publishHistory" 
	]
	DOMSymbolItem-clean [
		"DOMSymbolItem" (
			parse-xfl content
		) |
		"timeline" (
			parse-xfl/act content 'DOMTimeline-clean
		)
	]
	DOMTimeline-clean [
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
			check-item current-node
			parse-xfl content
		) |
		[
			"DOMShape" |
			"DOMRectangleObject" |
			"DOMOvalObject"
		](
			parse-xfl/act content 'DOMShape-clean
		) |
		"DOMSymbolInstance" (
			check-item current-node
		) |
		"DOMBitmapInstance" (
			check-item current-node
		) |
		"matrix" |
		"Matrix" |
		"DOMDynamicText" |
		"DOMInputText" |
		"DOMTLFText" |
		"MorphShape" |
		"SoundEnvelope" |
		"tweens" |
		"Actionscript" |
		"morphHintsList" |
		"DOMStaticText" |
		"transformationPoint"  ;do nothing
	]
	DOMShape-clean [
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
			check-item current-node
		) |
		"LinearGradient" |
		"DottedStroke" |
		"DashedStroke" |
		"RaggedStroke"
	]
]