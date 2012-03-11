rebol [title: "swfTags - Fields"]

pad: func[val num][head insert/dup tail val: form val #" " num - length? val]

formatFillStyle: func[data /local ][
	;print ["formatFillStyle:" mold data]
	if none? data [
		;print "formatFillStyle none??"
		return ""
	]
	ajoin switch/default data/1 [
		0  [["color: " data/2 LF]]
		16 [[
			"linearGradiend:" LF
			getTagFields data/2/1 fieldsMATRIX true 
			getFieldData 'Gradients data/2/2
			LF
		]]
		18 [[
			"radialGradient:" LF
			getTagFields data/2/1 fieldsMATRIX true
			getFieldData 'Gradients data/2/2
			LF
		]]
		19 [[
			"focalGradient:" LF
			getTagFields data/2/1 fieldsMATRIX true
			getFieldData 'Gradients data/2/2
			LF
		]]
		64 [[
			"repeating bitmap ID: " data/2/1 LF
			getTagFields data/2/2 fieldsMATRIX true
			LF
		]]
		65 [[
			"clipped bitmap ID:" data/2/1 LF
			getTagFields data/2/2 fieldsMATRIX true
			LF
		]]
		66 [[
			"non-smoothed repeating bitmap ID:" data/2/1 LF
			getTagFields data/2/2 fieldsMATRIX true
			LF
		]]
		67 [[
			"non-smoothed clipped bitmap ID:" data/2/1 LF
			getTagFields data/2/2 fieldsMATRIX true
			LF
		]]
	][	[ data LF] ]
]
formatMorphFillStyle: func[data /local ][
	;print ["formatFillStyle:" mold data]
	if none? data [
		;print "formatFillStyle none??"
		return ""
	]
	ajoin switch/default data/1 [
		0  [["color: " data/2 LF]]
		16 [[
			"linearGradiend:" LF
			getTagFields data/2/1 fieldsMATRIX true 
			getTagFields data/2/2 fieldsMATRIX true 
			getFieldData 'MorphGradients data/2/3
			LF
		]]
		18 [[
			"radialGradient:" LF
			getTagFields data/2/1 fieldsMATRIX  true
			getTagFields data/2/2 fieldsMATRIX true 
			getFieldData 'MorphGradients data/2/3
			LF
		]]
		19 [[
			"focalGradient:" LF
			getTagFields data/2/1 fieldsMATRIX true
			getTagFields data/2/2 fieldsMATRIX true 
			getFieldData 'MorphGradients data/2/3
			LF
		]]
		64 [[
			"repeating bitmap ID: " data/2/1 LF
			getTagFields data/2/2 fieldsMATRIX true
			getTagFields data/2/3 fieldsMATRIX true
			LF
		]]
		65 [[
			"clipped bitmap ID:" data/2/1 LF
			getTagFields data/2/2 fieldsMATRIX true
			getTagFields data/2/3 fieldsMATRIX true
			LF
		]]
		66 [[
			"non-smoothed repeating bitmap ID:" data/2/1 LF
			getTagFields data/2/2 fieldsMATRIX true
			getTagFields data/2/3 fieldsMATRIX true
			LF
		]]
		67 [[
			"non-smoothed clipped bitmap ID:" data/2/1 LF
			getTagFields data/2/2 fieldsMATRIX true
			getTagFields data/2/3 fieldsMATRIX true
			LF
		]]
	][	[ data LF] ]
]

getFieldData: func[type data /local i row result val][
	;print ["??" mold type mold data]
	result: copy ""
	unless data [return result]
	tabind+
	switch type [
		FillStyles [
			append result LF
			i: 1
			while [not tail? data][
				row:  data/1
				append result ajoin [
					tabs "#" i " "
					formatFillStyle row
				]
				i: i + 1
comment {
				type >= 64 [ ;bitmap
					reduce [
						readID ;bitmapID
						readMATRIX
					]
				]
			]"
					mold data/1 LF
				]
				}
				data: next data
			]
			
		]
		MorphFillStyles [
			append result LF
			i: 1
			while [not tail? data][
				row:  data/1
				append result ajoin [
					tabs "#" i " "
					formatMorphFillStyle row
				]
				i: i + 1
				data: next data
			]
		]
		LineStyles [
			i: 1
			;probe data
			while [not tail? data][
				probe row: data/1
				append result ajoin [
					LF tabs "#" i ": "
					"width: " row/1
					either none?  row/2 [""][" miterLimit:" row/2]
					ajoin either tuple? row/3 [
						[" color: " row/3]
					][	[" " formatFillStyle row/3] ]
					either row/4 [ajoin [LF tabs formatFillStyle row/4]][""]
					
				]
				data: next data
				i: i + 1
			]
		]
		Gradients [
			append result ajoin [tabs "SpreadMode: "  pick ["Pad" "Reflect" "Repeat" "-"] (data/1 + 1)  LF]
			append result ajoin [tabs "InterpolationMode: "  pick ["Normal RGB" "Linear RGB" "-" "-"] (data/2 + 1) LF]
			append result ajoin [tabs "GradientColors: " LF]
			foreach [ratio color] data/3 [
				append result ajoin [tabs "^-" pad ratio 5 color LF]
			]
			if data/4 [append result ajoin [tabs "FocalPoint: " data/4 LF]]
		]
		MorphGradients [
			append result ajoin [tabs "SpreadMode: "  pick ["Pad" "Reflect" "Repeat" "-"] (data/1 + 1)  LF]
			append result ajoin [tabs "InterpolationMode: "  pick ["Normal RGB" "Linear RGB" "-" "-"] (data/2 + 1) LF]
			append result ajoin [tabs "GradientColors: " LF]
			foreach [ratio color] data/3 [
				append result ajoin [tabs "^-" pad ratio 5 color LF]
			]
			if data/4 [append result ajoin [tabs "FocalPoint: " data/4 LF]]
		]
		ShapeRecords [
			append result ajoin [LF tabs "Style:" LF ]
			parse data [any [
				  'style set val block! (
					append result ajoin [tabs "ChangeStyle: " LF getTagFields val fieldsStyleChangeRecord true ]
				 )
				| 'line copy val some [integer!] (
					append result ajoin [tabs "Line: " val LF]
				)
				| 'curve copy val some [integer!] (
					append result ajoin [tabs "Curve: " val LF]
				)
					
			]]
		]
		SpriteTags [
			append result LF
			tabspr+
			while [not tail? data][
				append result getTagInfo data/1/1 data/1/2
				data: next data
			]
			tabspr-
		]
		SoundStreamBlock [
			;probe data
			if data/1 = 2 [
				append result ajoin [
					"MP3" LF
					getTagFields next data [
						"SampleCount"
						group "MP3SOUNDDATA" [
							"SeekSamples"
							get 'MP3FRAMEs
						]
					] true
				]
			]
		]
		MP3FRAMEs [
			;probe data
			foreach [
				Syncword
				MpegVersion
				Layer
				ProtectionBit
				ChannelMode
				ModeExtension
				Copyright
				Original
				Emphasis
				Bitrate
				SamplingRate
				soundata
			] data [
				append result ajoin [
					LF
					tabs
					"MpegVersion: " pick [2.5 "" 2 1] (1 + MpegVersion)
					" Layer: " pick ["" "III" "II" "I"] (1 + Layer)
					" CRC: " ProtectionBit = 1
					LF
					tabs
					"Bitrate: " Bitrate
					" SamplingRate: " SamplingRate
					" PaddingBit: " PaddingBit = 1
					LF
					tabs
					"ChannelMode: " pick ["Stereo" "Joint stereo (Stereo)" "Dual channel" "Single channel (Mono)"] (1 + ChannelMode)
					" Copyright: " Copyright = 1
					" Original: " Original = 1
					" Emphasis: " pick [none "50/15 ms" "" "CCIT J.17"] (1 + Emphasis)
					LF
					tabs "SampleDataSize: " length? soundata
				]
			]
		]
		BUTTONRECORDs [
			;print ["BUTTONRECORDs:" mold data]
			append result LF
			while [not tail? data][
				append result getTagFields data/1 fieldsBUTTONRECORDs true
				data: next data
			]
		]
		BUTTONstates [
			;probe data
			append result ajoin [ 
				data " ="
				either isSetBit? data 1 [" up"  ][""]
				either isSetBit? data 2 [" over"][""]
				either isSetBit? data 3 [" down"][""]
				either isSetBit? data 4 [" hit" ][""]
				LF
			]
		]
	]
	error? try [data: head data]
	tabind-
	trim/tail result
]

fieldsFillStyles: func[data][
	tabind+
		result: copy ""
]


fieldsDefineShape: [
	"ID"
	"Bounds"
	group "Edge" [
		"EdgeBounds"
		"UsesNonScalingStrokes"
		"UsesScalingStrokes"
	]
	group "StylesAndShapes" [
		get 'FillStyles
		get 'LineStyles
		get 'ShapeRecords
	]
]
fieldsMATRIX: [
	"Scale"
	"Rotate"
	"Translate"
]
fieldsCXFORM: [
	"Multiplication"
	"Addition"
]
fieldsBUTTONRECORDs: reduce [
	'get 'BUTTONstates 'noIndent
	"ID"
	"PlaceDepth"
	fieldsMATRIX 'noIndent
	fieldsCXFORM 'noIndent

]

fieldsStyleChangeRecord: [
	"Move"
	"FillStyle0"
	"FillStyle1"
	"LineStyle"
	group "NewStyles" [
		get 'FillStyles
		get 'LineStyles
		"numFillBits"
		"numLineBits"
	]
]
fieldsDefineText: reduce [
	"ID"
	"TextBounds"
	fieldsMATRIX 'noIndent
	'group "TextRecords" [
		"FontID"
		"Color"
		"XOffset"
		"YOffset"
		"TextHeight"
		"Glyphs"
	]
]
fieldsDefineBitsLossless: [
	"BitmapID"
	"BitmapFormat"
	"BitmapWidth"
	"BitmapHeight"
	"BitmapColorTableSize"
	"ZlibBitmapData"
]
fieldsSoundStreamHead: [ ;SoundStreamHead
		"reserved"
		"PlaybackSoundRate"
		"16bit?"
		"Stereo?"
		"StreamSoundCompression"
		"StreamSoundRate"
		"StreamSoundSize"
		"StreamSoundType"
		"StreamSoundSampleCount"
		"LatencySeek"
	]
	
fieldsSOUNDINFO: [
	"reserved"
	"SyncStop?"
	"SyncNoMultiple?"
	"InPoint"
	"OutPoint"
	"Loops"
	"Envelope"
]
fieldsStartSound: reduce [
	"SoundID"
	fieldsSOUNDINFO 'noIndent
]

#include %format/actions.r

fieldsACTIONRECORDs: get in actionFormater 'fieldsACTIONRECORDs ;none

tagFields: make hash! reduce [
	;0 [print ""]        ;end
	;1 [print ""]        ;showFrame
	2  fieldsDefineShape ;DefineShape
	4  reduce [          ;PlaceObject
		"ID"             ;ID of character to place
		"Depth"          ;Depth of character
		fieldsMATRIX     ;Transform matrix data
		fieldsCXFORM     ;Color transform data
	]
	5  ["ID" "Depth"   ] ;RemoveObject
	6  ["ID" "JPEGData"] ;DefineBits
	7  reduce [ ;DefineButton
		"ID" 
		'get 'BUTTONRECORDs
		:fieldsACTIONRECORDs
	]
	8  ["JPEGData"]       ;JPEGTables
	;9  [to-tuple tagData] ;setBackgroundColor
	10 ["ID" "GlyphShapeTable"] ;DefineFont
	11 fieldsDefineText
	12 :fieldsACTIONRECORDs ;DoAction
	13 [ ;DefineFontInfo
		"FontID"
		"Name"
		"Flags"
		"CodeTable"
	]
	14 [ ;DefineSound
		"ID"
		"Format"
		"Rate"
		"Size"
		"Type"
		"SampleCount"
		"Data"
	]
	15 reduce [ ;StartSound
		"ID"
		'group fieldsSOUNDINFO
	]

	17 reduce [ ;DefineButtonSound
		"ButtonID"
		'group "OverUpToIdle" fieldsStartSound
		'group "IdleToOverUp" fieldsStartSound
		'group "OverUpToOverDown" fieldsStartSound
		'group "OverDownToOverUp" fieldsStartSound
	]
	18 fieldsSoundStreamHead 
	19 [
		get 'SoundStreamBlock
	]
	20 fieldsDefineBitsLossless ;DefineBitsLossless
	21 ["ID" "JPEGData"]  ;DefineBitsJPEG2
	22 fieldsDefineShape ;DefineShape2
	23 [ ;DefineButtonCxform
		"ButtonID"
		fieldsCXFORM
	]
	;24 none ;Protected file!
	26 reduce [ ;PlaceObject2
		"Depth"
		"Move?"
		"Character"
		fieldsMATRIX
		fieldsCXFORM
		"Ratio"
		"Name"
		"ClipDepth"
		'group "CLIPACTIONS" [
			"reserved"
			"AllEventFlags"
			"Actions"
		]
	]
	28 ["Depth"] ;RemoveObject2
	32 fieldsDefineShape  ;DefineShape3
	33 fieldsDefineText   ;DefineText2
	34 reduce [ ;DefineButton2
		"ID" 
		'get 'BUTTONRECORDs
		:fieldsACTIONRECORDs
	]
	35 ["ID" "JPEGData" "BitmapAlphaData"] ;DefineBitsJPEG3
	36 fieldsDefineBitsLossless ;DefineBitsLossless2
	37 [ ;DefineEditText
		"ID"
		"Bounds"
		"WordWrap?"
		"Multiline?"
		"Password?"
		"ReadOnly?"
		"Reserved1"
		"AutoSize?"
		"NoSelect?"
		"Border?"
		"Reserved2"
		"HTML?"
		"UseOutlines?"
		group "Font" ["FontID" "Height"]
		"TextColor"
		"MaxLength"
		group "Layout" [
			"Align"
			"LeftMargin"
			"RightMargin"
			"Indent"
			"Leading"
		]
		"VariableName"
		"InitialText"
	]
	39 [  ;DefineSprite
		"ID"
		"FrameCount"
		get 'SpriteTags
	] 
	;40 [] ;SWT-CharacterName]
	;41 [] ;SerialNumber]
	;42 [] ;DefineTextFormat]
	43 [readSTRING] ;FrameLabel
	45 fieldsSoundStreamHead ;SoundStreamHead2

	46 [
		"ID"
		"StartBounds"
		"EndBounds"
		"Offset"
		get 'MorphFillStyles
		"MorphLineStyles"
		"StartEdges"
		"EndEdges"
		
	] ;DefineMorphShape]
	48 [ ;DefineFont2
		"ID"
		"Flags"
		"LangCode"
		"FontName"
		"GlyphShapeTable"
		"CodeTable"
		group "Layout" [
			"FontAscent"
			"FontDescent"
			"FontLeading"
			"FontAdvanceTable"
			"FontBoundsTable"
			"KERNINGRECORDs"
		]
	]
	;56 ExportAssets
	57 [ ;ImportAssets
		"FromURL"
		"Assets"
	]
	;58 EnableDebugger
	59 reduce [ ;DoInitAction
		"CharacterID"
		:fieldsACTIONRECORDs
	]
	60 [] ;DefineVideoStream]
	61 [] ;VideoFrame]
	62 [] ;DefineFontInfo2]
	64 [] ;EnableDebugger2]
	65 [] ;ScriptLimits]
	66 [] ;SetTabIndex]
	67 fieldsDefineShape ;DefineShape4
	69 [] ;FileAttributes]
	70 reduce [          ;PlaceObject3
		"Depth"
		"Move?"
		"Character"
		fieldsMATRIX
		fieldsCXFORM
		"Ratio"
		"Name"
		"ClipDepth"
		"Filters"
		"Blend"
		"BitmapCaching"
		'group "CLIPACTIONS" [
			"reserved"
			"AllEventFlags"
			"Actions"
		]
	]
	;71 [] ;ImportAssets2] ;Import2
	73 [] ;DefineAlignZones]
	74 [] ;CSMTextSettings] ;CSMTextSettings
	75 [] ;DefineFont2] ;DefineFont3
	77 ["MetaData"] ;MetaData
	78 [ ;DefineScalingGrid
		"CharID"
		"GridRectangle"
	]
	72 [] ;DoABC] ;Action3
	76 ["ID" "frame"] ;SymbolClass] ;Action3StartupClass
	82 ["Flags" "Name" "ABC decompiled"] ;DoABC2]
	83 fieldsDefineShape ;DefineShape5
	84 [
		"ID"
		"StartBounds"
		"EndBounds"
		"StartEdgeBounds"
		"EndEdgeBounds"
		"UsesNonScalingStrokes"
		"UsesScalingStrokes"
		"Offset"
		"MorphFillStyles"
		"MorphLineStyles"
		"StartEdges"
		"EndEdges"
	];DefineMorphShape2

	86 [
		"Scenes"
		"FrameLabels"
	] ;DefineSceneAndFrameLabelData
	87 [] ;DefineBinaryData]
	88 [] ;DefineFontName]
	89 reduce [ ;StartSound2
		"SoundClassName"
		'group fieldsSOUNDINFO
	]
	90 [;DefineBitsJPEG4
		"ID"
		"DeblockParam"
		"JPEGData"
		"BitmapAlphaData"
	]
	91 [;DefineFont4
		"FontID"
		"flags"
		"FontName"
		"FontData"
	]
	;1023 [readRest] ;DefineBitsPtr
]










convert-DefineShape: has[shape result fillStyles lineStyles pos st dx dy tmp lineStyle fillStyle0 fillStyle1] [
	shape: parse-DefineShape
	fillStyles: shape/4/1
	lineStyles: shape/4/2
	lineStyle: fillStyle0: fillStyle1: none
	
	;if block? lineStyles [
	;	forall lineStyles [
	;		change lineStyles/1 (lineStyles/1/1)
	;	]
	;	lineStyles: head lineStyles
	;]
	pos: 0x0
	result: ajoin [
		"Shape " shape/1 " [^/^-units twips^/"
		"^-bounds " shape/2/1 "x" shape/2/3 " " shape/2/2 "x" shape/2/4 lf
		either shape/3 [
			ajoin [
				"^-edge [^/"
				"^-^-bounds " shape/3/1/1 "x" shape/3/1/2 " " shape/3/1/3 "x" shape/3/1/4
				either shape/3/2 ["^-^-UsesNonScalingStrokes^/"][""]
				either shape/3/2 ["^-^-UsesScalingStrokes^/"][""]
				"^-]^/"
			]
		][""]
	]
	parse shape/4/3 [
		any [
			'style set st block! (
				;probe st
				if st/2 [
					if fillStyle0 <> st/2 [
						fillStyle0: st/2
						either tmp: fillStyles/(fillStyle0) [
							append result ajoin [
								"^-fill " 
								switch tmp/1 [
									0   [reduce ["color" tmp/2]]
									64 66  [rejoin [
											"bitmap [" reduce [
												"id" tmp/2/1
												convert-MATRIX tmp/2/2
											]
											"]"
										]
									]
									
								]
								lf
							]
						][
							append result "^-fill none^/"
						]
					]
				]
				if st/4 [
					if lineStyle <> st/4 [
						lineStyle: st/4
						append result ajoin [
							"^-pen " lineStyles/(linestyle) lf
						]
					]
				]
				if st/1 [
					pos: as-pair st/1/1 st/1/2
				]
			)
			|
			'line (
				append result ajoin ["^-line " pos " "]
			) some [set dx integer! set dy integer! (
				pos: pos + as-pair dx dy
				append result ajoin [pos " "]
			)] (append result lf)
			|
			'curve (
				append result ajoin ["^-curve " pos " "]
			) some [
				set dx integer! set dy integer! (
					pos: pos + as-pair dx dy
					append result ajoin [pos " "]
				)
			] (append result lf)
		]	
	]
	
	
	;probe shape/4/3
	append result "^/]"
	result
]

convert-PlaceObject2: has [data][
	data: parse-PlaceObject2
	ajoin [
		
		either data/7 [rejoin [as-string data/7 ": "]][""]
		"Place " data/3 " ["
			either data/2 ["move "][""]
			either data/1 [join "depth " data/1][""]
			either data/4 [convert-MATRIX data/4][""]
			either data/6 [join " ratio " data/6][""]
			either data/8 [join " clipDepth " data/8][""]
		"]" 
	]
]

convert-MATRIX: func[m][
	ajoin [
		either m/3 [join " at " to-pair m/3 ][""]
		either m/1 [join " scale "  mold m/1    ][""]
		;either m/1 [join " scale " "[1 1]"      ][""]
		either m/2 [join " rotate " mold m/2    ][""]
		
	]
]

convert-DefineSprite: has [spr result][
	spr: parse-DefineSprite
	result: rejoin ["Sprite " spr/1 " [^/"]
	foreach tag spr/3 [
		append result ajoin ["^-" tag/2 lf]
	]
	append result "]^/"
	result
]