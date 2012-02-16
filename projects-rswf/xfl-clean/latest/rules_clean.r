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
			add-item-to-check current-node
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
		"DOMShape" (
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
		"DottedStroke"
	]
]