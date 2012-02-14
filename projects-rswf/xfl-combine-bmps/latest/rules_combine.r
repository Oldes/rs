rebol []


insert XFL-action-rules [
	DOMDocument-combine [
		[
			"DOMDocument"|
			
			"timelines" |
			"symbols" 
		](
			parse-xfl content
		) |
		"DOMTimeline" (
			parse-xfl/act content 'DOMTimeline-combine
		) |
		"DOMBitmapItem" |
		"DOMCompiledClipItem" |
		"Include" (
			append files-to-parse atts/("href")
		)|
		
		"media" |
		"folders" |
		"fonts" |
		"DOMFolderItem" |
		"DOMSoundItem" |
		"swatchLists"  |
		"extendedSwatchLists" |
		"PrinterSettings" |
		"publishHistory" |
		"swcCache"
	]
	DOMSymbolItem-combine [
		"DOMSymbolItem" (
			if tmp: select atts "lastModified"       [change clear tmp to-timestamp now]
			if tmp: select atts "sourceLastModified" [change clear tmp to-timestamp now]
			parse-xfl content
		) |
		"timeline" (
			parse-xfl/act content 'DOMTimeline-combine
		)
	]
	DOMTimeline-combine [
		[
			"DOMTimeline" |
			"layers" |
			"frames" |
			"DOMFrame" |
			"elements" |
			"DOMGroup" |
			"members" |
			"Actionscript" |
			"transformationPoint" |
			"filters" |
			"MorphShape" |
			"morphHintsList" |
			"morphSegments" |
			"textRuns" |
			"DOMTextRun" |
			"textAttrs"	
		]  (
			parse-xfl content
		) |
		"DOMLayer" (
			parse-xfl content
		) |
		"DOMShape" (
			;remove-atts atts ["selected"]
			parse-xfl/act content 'DOMShape-combine
		) |
		"DOMStaticText" |
		"DOMInputText"	|
		"DOMSymbolInstance" (
			parse-xfl content
		) |
		"DOMBitmapInstance" (
			combine-DOMBitmapInstance current-node
			parse-xfl content
		) |
		
		"matrix" (
			parse-xfl content
		) |
		"Matrix" |
		"Point"  |
		"script" |
		"BlurFilter" |
		"GlowFilter" |
		"DropShadowFilter" | "BevelFilter" | "GradientGlowFilter" | "GradientBevelFilter" |
		"MorphSegment" (
			parse-xfl content
		) |
		"MorphCurves" (
			parse-xfl content
		) |
		"MorphHint" (
			parse-xfl content
		) |
		"DOMDynamicText" (
			parse-xfl content
		) |
		"DOMTextAttrs" |	
		"SoundEnvelope" |
		"tweens" |
		"color" |
		"AdjustColorFilter" |
		"characters" (
			probe content
			if content [replace/all content/1 "^M" "&#xD;"]
		)	
	]

	DOMShape-combine [
		[
			"transformationPoint" |
			"matrix" |
			"strokes" |
			"fills" |
			"edges" |
			"fill" |
			"FillStyle" |
			"RadialGradient" |
			"LinearGradient" |
			
			"SolidStroke" | "StippleStroke" | "RaggedStroke" |
			"StrokeStyle"
		] (
			parse-xfl content
		) |
		"BitmapFill" (
			combine-BitmapFill current-node
		)|
		"Edge" (
			case [
				tmp: select atts "cubics" [
					clear current-node
				]
				all [
					;false
					tmp:  select atts "edges"
				] [
					;...
				]
			]
		) |
		"Matrix" |
		"Point" |
		"GradientEntry" |
		"SolidColor" |
		"DottedStroke"
	]
]