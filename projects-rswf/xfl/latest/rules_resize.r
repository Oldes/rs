rebol []

resize-image: func[src trg percent /name fname][
	src-size: get-image-size src
	if 0 <> call/wait probe ajoin [
		to-local-file dir_imagemagick "convert"
		{ "} to-local-file src {"}
		;" -resize " form (100 * percent/1) "%x" form (100 * percent/2) "%!"
		" -resize " form (round/ceiling(percent/1 * src-size/x)) "x" form (round/ceiling(percent/2 * src-size/y)) "!"
		" -unsharp 1x2.0+.3+0.05" ;-----original
		;" -unsharp 1x2.0+.8+0.1" ;-na pozadi prilis
		" -strip"
		{ png32:"} to-local-file trg {"}
	][
		ask "!!! problem with resize !!!"
	]
]

resize-image-android: func[src trg percent /name fname /local filename tmp src-size][
	filename: last parse/all fname "/\"
	src-size: get-image-size src
	either tmp: select images filename [
		src: tmp/1
		;src-size: tmp/2
		print ["*************>" filename]
	][
		print src
		
	]
	
	
	if 0 <> call/wait probe ajoin [
		to-local-file dir_imagemagick "convert"
		{ "} to-local-file src {"}
		;" -resize " form (100 * percent/1) "%x" form (100 * percent/2) "%!"
		" -resize " form (round/ceiling(percent/1 * src-size/x)) "x" form (round/ceiling(percent/2 * src-size/y)) "!"
		" -unsharp 1x2.0+.3+0.05" ;-----original
		;" -unsharp 1x2.0+.8+0.1" ;-na pozadi prilis
		" -strip"
		{ png32:"} to-local-file trg {"}
	][
		ask "!!! problem with resize !!!"
	]
]

resize-image: :resize-image-android

resize-point: func[data /to scale /local x y s e][
	;print ["RSZP<--" data]
	unless scale [scale: .000005]
	parse data [
		some [
			SP
			s:
			[copy x rl_edgNumber (x: load x) | rl_hexNum (x: n)]
			e: (s: change/part s (round/to scale-x * x scale) e) :s
			SP "," SP
			s:
			[copy y rl_edgNumber (y: load y) | rl_hexNum (y: n)] 
			e: (s: change/part s (round/to scale-y * y scale) e) :s
		]
	]
	;print ["RSZP-->" data]
	;ask ""
]
append XFL-action-rules [
	DOMDocument-rsz [
		[
			"DOMDocument" (
				either tmp: select atts "width" [
					atts/("width"): round scale-x * to-integer tmp
				][
					repend atts ["width" round scale-x * 550]
				]
				either tmp: select atts "height" [
					atts/("height"): round scale-y * to-integer tmp
				][
					repend atts ["height" round scale-y * 400]
				]
			)|
			"symbols" |
			"media" |
			"timelines"
		](
			parse-xfl content
		) |
		"DOMTimeline" (
			parse-xfl/act content 'DOMTimeline-rsz
		) |
		"DOMBitmapItem" (
			probe atts
			print "------------------"
			tmp: atts/("name")
			parse tmp [".\LIBRARY\" copy tmp to end]
			ext: last parse tmp "."
			unless select atts "sourceExternalFilepath" [append atts ["sourceExternalFilepath" none]]
			originalName: copy atts/("sourceExternalFilepath"): join "./LIBRARY/" [tmp either find ["png" "jpg"] ext [""][".png"]]
			error? try [atts/("href"): atts/("sourceExternalFilepath") ]
			if tmp: select atts "sourceLastImported" [change clear tmp to-timestamp now]
			
			ext: last parse atts/("sourceExternalFilepath") "."
			;probe atts ask "exporting..."
			;export-media-item/overwrite atts
			temp-file: rejoin [enbase/base  checksum/secure join tmp now 16 "." ext] 
			export-media-item/into-file atts temp-file
			;ask "resizing..."
			resize-image/name 
				tmp: join xfl-folder-new  temp-file ;to-rebol-file as-string utf8/decode atts/("sourceExternalFilepath") 
				tmp ;head insert find/last tmp "." "_sc"
				reduce [scale-x scale-y]
				originalName
				
;ask ""
			import-media-img/as tmp select atts "bitmapDataHRef"
			delete tmp
		) |
		"DOMCompiledClipItem" |
		"Include" (
			append files-to-parse atts/("href")
		)|
		"DOMSoundItem" |
		"folders" |
		"fonts" |
		"swatchLists"  |
		"extendedSwatchLists" |
		"PrinterSettings" |
		"publishHistory" |
		"swcCache"
	]
	DOMSymbolItem-rsz [
		"DOMSymbolItem" (
			if tmp: select atts "lastModified"       [change clear tmp to-timestamp now]
			if tmp: select atts "sourceLastModified" [change clear tmp to-timestamp now]
			parse-xfl content
		) |
		"timeline" (
			parse-xfl/act content 'DOMTimeline-rsz
		)
	]
	DOMTimeline-rsz [
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
			parse-xfl/act content 'DOMShape-rsz
		) |
		[
			"DOMStaticText" |
			"DOMInputText"
		] (
			if atts [
				if find atts "width"  [atts/("width"):  round/to scale-x * to decimal! atts/("width") .05]
				if find atts "height" [atts/("height"): round/to scale-y * to decimal! atts/("height") .05]
			]
			parse-xfl content
		) |
		"DOMSymbolInstance" (
			if find atts "centerPoint3DX" [atts/("centerPoint3DX"): scale-x * to decimal! atts/("centerPoint3DX")]
			if find atts "centerPoint3DY" [atts/("centerPoint3DY"): scale-y * to decimal! atts/("centerPoint3DY")]
			parse-xfl content
		) |
		"DOMBitmapInstance" (
			parse-xfl content
		) |
		
		"matrix" (
			parse-xfl content
		) |
		"Matrix" (
			if atts [
				if find atts "tx" [atts/("tx"): round/to scale-x * to decimal! atts/("tx") .05]
				if find atts "ty" [atts/("ty"): round/to scale-y * to decimal! atts/("ty") .05]
			]
		) |
		"Point" (
			if atts [
				if find atts "x" [atts/("x"): round/to scale-x * to decimal! atts/("x") .05]
				if find atts "y" [atts/("y"): round/to scale-y * to decimal! atts/("y") .05]
			]
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
				;ask ["SCRIPT???" mold current-node]
			]}
		) |
		[
			"BlurFilter" |
			"GlowFilter"
		] (
			unless atts [current-node/2: atts: copy []]
			unless tmp: select atts "blurX" [tmp: 5 append atts ["blurX" none]]	atts/("blurX"): round/to scale-x * to decimal! tmp .05
			unless tmp: select atts "blurY" [tmp: 5 append atts ["blurY" none]]	atts/("blurY"): round/to scale-y * to decimal! tmp .05
		) |
		["DropShadowFilter" | "BevelFilter" | "GradientGlowFilter" | "GradientBevelFilter"](			
			unless atts [current-node/2: atts: copy []]
			unless tmp: select atts "blurX" [tmp: 5 append atts ["blurX" none]]	atts/("blurX"): round/to scale-x * to decimal! tmp .05
			unless tmp: select atts "blurY" [tmp: 5 append atts ["blurY" none]]	atts/("blurY"): round/to scale-y * to decimal! tmp .05
			unless tmp: select atts "distance" [tmp: 5 append atts ["distance" none]]	atts/("distance"): round/to scale-xy * to decimal! tmp .05
		) |
		"MorphSegment" (
			if tmp: select atts "startPointA" [resize-point tmp]
			if tmp: select atts "startPointB" [resize-point tmp]
			parse-xfl content
		) |
		"MorphCurves" (
			if tmp: select atts "controlPointA" [resize-point tmp]
			if tmp: select atts "controlPointB" [resize-point tmp]
			if tmp: select atts "anchorPointA"  [resize-point tmp]
			if tmp: select atts "anchorPointB"  [resize-point tmp]
			parse-xfl content
		) |
		"MorphHint" (
			if tmp: select atts "startPoint" [resize-point tmp]
			if tmp: select atts "endPoint"   [resize-point tmp]
			parse-xfl content
		) |
		"DOMDynamicText" (
			if atts [
				if tmp: select atts "width"  [atts/("width"):  round/to scale-x * to decimal! tmp .05]
				if tmp: select atts "height" [atts/("height"): round/to scale-y * to decimal! tmp .05]
			]
			parse-xfl content
		) |
		"DOMTextAttrs" (
			if atts [
				if tmp: select atts "letterSpacing" [atts/("letterSpacing"): round/to scale-xy * to decimal! tmp .05]
				if tmp: select atts "indent"        [atts/("indent"):        round/to scale-xy * to decimal! tmp .05]
				if tmp: select atts "leftMargin"    [atts/("leftMargin"):    round/to scale-xy * to decimal! tmp .05]
				if tmp: select atts "rightMargin"   [atts/("rightMargin"):   round/to scale-xy * to decimal! tmp .05]
				unless tmp: select atts "lineSpacing" [tmp: 2 append atts ["lineSpacing" none]]
				atts/("lineSpacing"): round/to scale-xy * to decimal! tmp .05
								
				unless tmp: select atts "size" [tmp: 12 append atts ["size" none]]
				atts/("size"): tmp: round/to scale-xy * to decimal! tmp .05
				unless find atts "bitmapSize" [append atts ["bitmapSize" none]]
				atts/("bitmapSize"): to-integer 20 * tmp
			]
		) |	
		"SoundEnvelope" |
		"tweens" |
		"color" |
		"AdjustColorFilter" |
		"characters" (
			probe content
			if content [replace/all content/1 "^M" "&#xD;"]
		)	
	]

	DOMShape-rsz [
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
			"BitmapFill" |
			["SolidStroke" | "StippleStroke" | "RaggedStroke"] (
				
				either tmp: select atts "weight" [
					atts/("weight"): max .5 round/to scale-xy * to decimal! tmp .01
				][
					repend atts ["weight" max .5 round/to scale-xy * 1.0 .01]
				]
				if all [1 > atts/("weight") tmp: select atts "solidStyle" tmp = "hairline"][
					atts/("solidStyle"): "solid"
				]
			)|
			"StrokeStyle"
		] (
			parse-xfl content
		) |
		"Edge" (
			case [
				tmp: select atts "cubics" [
					comment {
					ch_cubics_marks: charset "![]/|();,Qq ^-" 
					use [s e x y][
						parse/all tmp [
							some [
								any ch_cubics_marks
								s:
								[copy x rl_edgNumber (x: load x) | rl_hexNum (x: n)]
								e: (s: change/part s (round scale-x * x) e) :s
								any ch_cubics_marks
								s:
								[copy y rl_edgNumber (y: load y) | rl_hexNum (y: n)] 
								e: (s: change/part s (round scale-y * y) e) :s
							]
						]
					]}
					clear current-node
				]
				all [
					;false
					tmp:  select atts "edges"
				] [
					use [s e x y][
						parse/all tmp [
							some [
								SP [
									[#"!" | #"[" | #"]" | #"/" | #"|"]
									some [
										SP
										s:
										[copy x rl_edgNumber (x: load x) | rl_hexNum (x: n)]
										e: (s: change/part s (form-float round/to scale-x * x .5) e) :s
										SP
										s:
										[copy y rl_edgNumber (y: load y) | rl_hexNum (y: n)] 
										e: (s: change/part s (form-float round/to scale-y * y .5) e) :s
										opt [#"S" ch_digits]
										;opt [s: #"S" ch_digits e: (e: remove/part s e) :e]
									]
									
									;remove optional "select" information
									
								]
							]
						]
					]
				]
			]
		) |
		"Matrix" (
			if atts [
				if find ["RadialGradient" "LinearGradient"] nodes-stack/(-3)/1 [
					if find atts "a" [atts/("a"): scale-x * to decimal! atts/("a")]
					if find atts "b" [atts/("b"): scale-y * to decimal! atts/("b")]
					if find atts "c" [atts/("c"): scale-x * to decimal! atts/("c")]
					if find atts "d" [atts/("d"): scale-y * to decimal! atts/("d")]
				]
				if find atts "tx" [atts/("tx"): round/to scale-x * to decimal! atts/("tx") .05]
				if find atts "ty" [atts/("ty"): round/to scale-y * to decimal! atts/("ty") .05]
			]
		) |
		"Point" (
			if atts [
				if find atts "x" [atts/("x"): round/to scale-x * to decimal! atts/("x") .05]
				if find atts "y" [atts/("y"): round/to scale-y * to decimal! atts/("y") .05]
			]
		) |
		"GradientEntry" |
		"SolidColor" |
		"DottedStroke"
	]
]