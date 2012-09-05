rebol [title: "swfTags"]
swfTagNames: make hash! [
	0 "end"
	1 "showFrame"
	2 "DefineShape"
	3 "FreeCharacter"
	4 "PlaceObject"
	5 "RemoveObject"
	6 "DefineBits (JPEG)"
	7 "DefineButton"
	8 "JPEGTables"
	9 "setBackgroundColor"
	10 "DefineFont"
	11 "DefineText"
	12 "DoAction Tag"
	13 "DefineFontInfo"
	14 "DefineSound"
	15 "StartSound"
	18 "SoundStreamHead"
	17 "DefineButtonSound"
	19 "SoundStreamBlock"
	20 "DefineBitsLossless"
	21 "DefineBitsJPEG2"
	22 "DefineShape2"
	23 "DefineButtonCxform"
	24 "Protect"
	26 "PlaceObject2"
	28 "RemoveObject2"
	31 "?GeneratorCommand?"
	32 "DefineShape3"
	33 "DefineText2"
	34 "DefineButton2"
	35 "DefineBitsJPEG3"
	36 "DefineBitsLossless2"
	37 "DefineEditText"
	38 "DefineVideo"
	39 "DefineSprite"
	40 "SWT-CharacterName"
	41 "SerialNumber"
	42 "DefineTextFormat"
	43 "FrameLabel"
	45 "SoundStreamHead2"
	46 "DefineMorphShape"
	48 "DefineFont2"
	49 "?GenCommand?"
	50 "?DefineCommandObj?"
	51 "?Characterset?"
	52 "?FontRef?"
	56 "ExportAssets"
	57 "ImportAssets"
	58 "EnableDebugger"
	59 "DoInitAction"
	60 "DefineVideoStream"
	61 "VideoFrame"
	62 "DefineFontInfo2"
	63 "DebugID"
	64 "ProtectDebug2"
	65 "ScriptLimits"
	66 "SetTabIndex"
	67 "DefineShape4"
	69 "FileAttributes"
	70 "PlaceObject3"
	71 "Import2"
	73 "DefineAlignZones"
	74 "CSMTextSettings"
	75 "DefineFont3"
	77 "MetaData"
	78 "DefineScalingGrid"
	72 "DoAction3"
	76 "DoAction3StartupClass"
	82 "DoAction3"
	83 "DefineShape5"
	84 "DefineMorphShape2"
	86 "DefineSceneAndFrameLabelData"
	87 "DefineBinaryData"
	88 "DefineFontName"
	89 "StartSound2"
	90 "DefineBitsJPEG4"
	91 "DefineFont4"
	93 "Telemetry"
	1023 "DefineBitsPtr"
]

swfTagParseActions: make hash! [
	;0 [print ""] ;end
	;1 [print ""] ;showFrame
	2  [parse-DefineShape]
	4  [parse-PlaceObject]
	5  [parse-RemoveObject]
	6  [parse-DefineBits]
	7  [parse-DefineButton]
	8  [parse-JPEGTables]
	9  [to-tuple tagData] ;setBackgroundColor
	10 [parse-DefineFont]
	11 [parse-DefineText]
	12 [parse-DoAction]
	13 [parse-DefineFontInfo]
	14 [parse-DefineSound]
	15 [parse-StartSound]
	17 [parse-DefineButtonSound]
	18 [parse-SoundStreamHead]
	19 [parse-SoundStreamBlock]
	20 [parse-DefineBitsLossless]
	21 [parse-DefineBitsJPEG2]
	22 [parse-DefineShape] ;DefineShape2
	23 [parse-DefineButtonCxform]
	;24 none ;Protected file!
	26 [parse-PlaceObject2]
	28 [parse-RemoveObject2]
	32 [parse-DefineShape] ;DefineShape3
	33 [parse-DefineText] ;DefineText2
	34 [parse-DefineButton2] ;DefineButton2
	35 [parse-DefineBitsJPEG3]
	36 [parse-DefineBitsLossless] ;DefineBitsLossless2
	37 [parse-DefineEditText]
	;38 [parse-DefineVideo ]
	39 [parse-DefineSprite]
	40 [parse-SWT-CharacterName]
	41 [parse-SerialNumber]
	42 [parse-DefineTextFormat]
	43 [probe readSTRING] ;FrameLabel
	45 [parse-SoundStreamHead] ;SoundStreamHead2
	46 [parse-DefineMorphShape]
	48 [parse-DefineFont2] ;DefineFont2
	56 [parse-ExportAssets]
	57 [parse-ImportAssets]
	58 [parse-EnableDebugger]
	59 [parse-DoInitAction]
	60 [parse-DefineVideoStream]
	61 [parse-VideoFrame]
	62 [parse-DefineFontInfo2]
	63 [readRest] ;DebugID
	64 [parse-EnableDebugger2]
	65 [parse-ScriptLimits]
	66 [parse-SetTabIndex]
	67 [parse-DefineShape] ;DefineShape4
	69 [parse-FileAttributes]
	70 [parse-PlaceObject3]
	71 [parse-ImportAssets2] ;Import2
	73 [parse-DefineAlignZones]
	74 [parse-CSMTextSettings] ;CSMTextSettings
	75 [parse-DefineFont2] ;DefineFont3
	77 [as-string tagData] ;MetaData
	78 [parse-DefineScalingGrid]
	72 [parse-DoABC] ;Action3
	76 [parse-SymbolClass] ;Action3StartupClass
	82 [parse-DoABC2]
	83 [parse-DefineShape] ;DefineShape5
	84 [parse-DefineMorphShape2]
	86 [parse-DefineSceneAndFrameLabelData] ;DefineSceneAndFrameLabelData
	87 [parse-DefineBinaryData]
	88 [parse-DefineFontName]
	89 [parse-StartSound2]
	90 [parse-DefineBitsJPEG4]
	93 [tagData]
	91 [parse-DefineFont4]
	;1023 [readRest] ;DefineBitsPtr
]

swfTagImportActions: make hash! [
	2  [import-Shape]
	4  [replacedID] ;PlaceObject
	5  [replacedID] ;RemoveObject
	6  [import-or-reuse] ;DefineBits
	7  [import-DefineButton]
	;8  [parse-JPEGTables]
	;9  [to-tuple tagData] ;setBackgroundColor
	10 [import-or-reuse] ;DefineFont
	11 [import-DefineText] ;DefineText
	;12 [parse-DoAction]
	13 [replacedID] ;DefineFontInfo
	14 [import-or-reuse] ;DefineSound
	15 [replacedID] ;StartSound
	17 [import-DefineButtonSound]
	;18 [parse-SoundStreamHead]
	;19 [parse-SoundStreamBlock]
	20 [import-or-reuse] ;DefineBitsLossless
	21 [import-or-reuse] ;DefineBitsJPEG2
	22 [import-Shape] ;DefineShape2
	23 [replacedID] ;DefineButtonCxform
	;24 none ;Protected file!
	26 [import-PlaceObject2]
	;28 [parse-RemoveObject2]
	32 [import-Shape] ;DefineShape3
	33 [import-DefineText] ;DefineText2
	34 [import-DefineButton2]
	35 [import-or-reuse] ;[probe checksum skip inBuffer 2 ask "??3" changeID  ] ;DefineBitsJPEG3
	36 [import-or-reuse] ;DefineBitsLossless2
	37 [import-DefineEditText]
	38 [import-or-reuse] ;DefineVideo
	39 [import-DefineSprite]
	40 [import-or-reuse] ;SWT-CharacterName
	;41 [parse-SerialNumber]
	42 [print "!! Importing unknown TAG DefineTextFormat" replacedID] ;DefineTextFormat
	43 [append imported-labels probe as-string readSTRING] ;FrameLabel
	;45 [parse-SoundStreamHead] ;SoundStreamHead2
	46 [import-DefineMorphShape]
	48 [import-or-reuse] ;DefineFont2
	56 [import-ExportAssets]
	57 [import-ImportAssets]
	;58 [parse-EnableDebugger]
	59 [replacedID] ;DoInitAction
	60 [import-or-reuse] ;DefineVideoStream
	61 [replacedID] ;parse-VideoFrame
	62 [replacedID] ;DefineFontInfo2
	;64 [parse-EnableDebugger2]
	;65 [parse-ScriptLimits]
	;66 [parse-SetTabIndex]
	67 [import-Shape] ;DefineShape4
	;69 [parse-FileAttributes]
	70 [import-PlaceObject2] ;PlaceObject3
	71 [import-ImportAssets] ;Import2
	73 [replacedID] ;DefineAlignZones
	74 [replacedID] ;CSMTextSettings
	75 [import-or-reuse] ;DefineFont3
	;77 [as-string tagData] ;MetaData
	78 [replacedID] ;DefineScalingGrid
	;72 [skipUI32 skipString write/binary join %ABC_ last used-ids inBuffer head inBuffer]
	;72 [parse-DoABC] ;Action3
	76 [import-SymbolClass] ;Action3StartupClass
	;82 [skipUI32 skipString write/binary join %ABC_ last used-ids inBuffer head inBuffer]
	;82 [parse-DoABC2]
	83 [import-Shape] ;DefineShape5
	84 [import-DefineMorphShape2]
	;86 [parse-DefineSceneAndFrameLabelData] ;DefineSceneAndFrameLabelData
	87 [import-or-reuse] ;DefineBinaryData
	88 [replacedID] ;DefineFontName
	90 [import-or-reuse] ;DefineBitsJPEG4
	91 [import-or-reuse] ;DefineFont4
]


swfTagParseImages: make hash! [
	6  [parse-DefineBits]
	8  [
		JPEGTables: parse-JPEGTables
		;head remove/part skip tail JPEGTables -2 2
		none
	]
	20 [parse-DefineBitsLossless]
	21 [parse-DefineBitsJPEG2]
	35 [parse-DefineBitsJPEG3]
	36 [parse-DefineBitsLossless2]
	90 [parse-DefineBitsJPEG4]
]

swfTagRescaleActions: make hash! [
	2  [rescale-Shape]
	6  [rescale-DefineBits]
	8  [
		JPEGTables: parse-JPEGTables
		;head remove/part skip tail JPEGTables -2 2
		none
	]
	20 [rescale-DefineBitsLossless]
	21 [rescale-DefineBitsJPEG2]
	22 [rescale-Shape]
	26 [rescale-PlaceObject2]
	32 [rescale-Shape]
	35 [rescale-DefineBitsJPEG3]
	36 [rescale-DefineBitsLossless2]
	39 [rescale-DefineSprite]
	
	46 [rescale-DefineMorphShape]
	
	67 [rescale-Shape]
	70 [rescale-PlaceObject3] ;PlaceObject3
	83 [rescale-Shape]
	84 [rescale-DefineMorphShape]
]

