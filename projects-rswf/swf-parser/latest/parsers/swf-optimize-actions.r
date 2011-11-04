rebol [title: "SWF-optimize tag Actions"]

swfTagOptimizeActions: make hash! [
;	0  ["end"]
;	1  ["showFrame"]
	2  [
		optimize-detectBmpFillBounds	
		;parse-defineShape
	]
;	4  [parse-PlaceObject]
;	5  [parse-RemoveObject]
		6  [parse-DefineBits]
	7  [parse-DefineButton]
		;8  [ajoin ["JPEGTables " mold JPEGTables: parse-JPEGTables]]
		8  [
			JPEGTables: parse-JPEGTables
			head remove/part skip tail JPEGTables -2 2
			none
		]
;		9  [ajoin ["Background " form to-tuple tagData]]
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
		22 [optimize-detectBmpFillBounds] ;DefineShape2
	23 [parse-DefineButtonCxform]
	;24 none ;Protected file!
;		26 [convert-PlaceObject2]
	28 [parse-RemoveObject2]
		32 [optimize-detectBmpFillBounds] ;DefineShape3
	33 [parse-DefineText] ;DefineText2
	34 [parse-DefineButton2] ;DefineButton2
	35 [
		parse-DefineBitsJPEG3
	]
	36 [parse-DefineBitsLossless] ;DefineBitsLossless2
	37 [parse-DefineEditText]
	;38 [parse-DefineVideo ]
		39 [convert-DefineSprite]
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
	64 [parse-EnableDebugger2]
	65 [parse-ScriptLimits]
	66 [parse-SetTabIndex]
		67 [optimize-detectBmpFillBounds] ;DefineShape4
		69 [ajoin ["FileAttributes " mold parse-FileAttributes]]
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
		83 [optimize-detectBmpFillBounds] ;DefineShape5
	84 [parse-DefineMorphShape2]
	86 [parse-DefineSceneAndFrameLabelData] ;DefineSceneAndFrameLabelData
	87 [parse-DefineBinaryData]
	88 [parse-DefineFontName]
	;1023 [readRest] ;DefineBitsPtr
]

swfTagOptimizeActions2: make hash! [
	2  [optimize-updateShape]
	22  [optimize-updateShape]
	32  [optimize-updateShape]
	67  [optimize-updateShape]
	83  [optimize-updateShape]
]