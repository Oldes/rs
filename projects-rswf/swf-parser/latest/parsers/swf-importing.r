rebol [
	title: "SWF importing"
	purpose: "Functions for importing SWF files (SWF joining) - reusing bitmap and sound assets"
]

RemoveFilters: [1] ;removing blur filters!!! - good for mobile devices

set 'import-swf-tag func[tagId tagData /local err action st st2][
	reduce either none? action: select parseActions tagId [
		;tagData
		;print ["importing tag:"  tagId]
		form-tag tagId tagData
	][
		setStreamBuffer tagData
		;print ["IMP>" index? inBuffer length? inBuffer]
		;print [tagId select swfTagNames tagId]
		
		if error? set/any 'err try [
			set/any 'result do bind/copy action 'self
		][
			print ajoin ["!!! ERROR while importing tag:" select swfTagNames tagId "(" tagId ")"]
			throw err
		]
		;head inBuffer
		;print ["IMP<" index? inBuffer length? head inBuffer]
		either inBuffer [
			form-tag tagId head inBuffer
		] [
			copy #{}
		]
	]
]



form-tag: func[
	"Creates the SWF-TAG"
		id [integer!]	"Tag ID"
		data [binary!]	"Tag data block"
		/local len
][
		either any [
			62 < len: length? data
			find [2 20 34 36 37 48] id
		] [
			;print ["Long tag:" len id]
			rejoin [
				int-to-ui16 (63 or (id * 64))
				int-to-ui32 len
				data
			]
		][
			;print ["Short tag:" len id]
			rejoin [
				int-to-ui16 (len or (id * 64))
				data
			]
		]
]
	
get-replacedID: func[id /local tmp][
	;print ["looking for " id mold replaced-ids]
;	either tmp: select/skip replaced-ids id 2 [
;		first tmp
;	][	id ]
	foreach [oid nid] replaced-ids [
		if id = oid [
			;print ["##Replacing->" mold id "->" mold nid]
			return nid
		]
	]
	id
]
replacedID: func[/ui /local id newid][
	id: copy/part inBuffer 2
	newid: get-replacedID id
	inBuffer: change inBuffer newid
	newid
]

changeID: func[ /local id new-id idbin newbin][
	id: to-integer reverse copy idbin: copy/part inBuffer 2
	;print ["new-char-id:" id mold used-ids]
	tag-bin: either find used-ids id [
		;character id already exists
		new-id: 1 + (last used-ids)
		insert tail used-ids new-id
		newbin: int-to-ui16 new-id
		repend replaced-ids [idbin newbin]
		;print [" ### replacing:" id "=>" new-id]
		inBuffer: change inBuffer newbin
		new-id
	][
		insert tail used-ids id
		used-ids: sort used-ids
		inBuffer: skip inBuffer 2
		id
	]
]



import-or-reuse: func[
	"Imports a new tag or uses already existing"
	/local idbin sum usedid
][
	;return changeID
	
	idbin: copy/part inBuffer 2
	;print ["import-or-reuse" mold idbin]
	;print ["tag-checksums:" mold tag-checksums]
	sum: checksum/secure skip inBuffer 2
	;ask ""
	either usedid: select tag-checksums sum [
		print ["reusing..." mold usedid]
		append replaced-ids reduce [idbin usedid]
		clear head inBuffer
		inBuffer: none
	][
		repend tag-checksums [sum int-to-ui16 changeID]
	]
]
	
	
skipMATRIX: does[
	byteAlign
	if readBitLogic [skipPair]
	if readBitLogic [skipPair]
	skipPair
	byteAlign
]
skipGRADIENT: func[type][
	byteAlign
	skipBits 4
	loop readUB 4 [
		skipUI8 ;ratio
		either tagId >= 32 [skipRGBA][skipRGB] ;color
	]
	if type = 19 [skipBytes 2] ;focalPoint
]
skipCXFORM: has [HasAddTerms? HasMultTerms? nbits][
	HasAddTerms?:  readBitLogic
	HasMultTerms?: readBitLogic
	nbits: readUB 4
	if HasMultTerms? [skipBits (3 * nbits)]
	if HasAddTerms?  [skipBits (3 * nbits)]
]
skipCXFORMa: has [HasAddTerms? HasMultTerms? nbits][
	HasAddTerms?:  readBitLogic
	HasMultTerms?: readBitLogic
	nbits: readUB 4
	if HasMultTerms? [skipBits (4 * nbits)]
	if HasAddTerms?  [skipBits (4 * nbits)]
]
skipSOUNDINFO: has[HasEnvelope? HasLoops? HasOutPoint? HasInPoint?][
	skipBits 4
	HasEnvelope?: readBitLogic
	HasLoops?:    readBitLogic
	HasOutPoint?: readBitLogic
	HasInPoint?:  readBitLogic
	if HasInPoint?  [skipUI32]
	if HasOutPoint? [skipUI32]
	if HasLoops?    [skipUI16]
	if HasEnvelope? [skipBytes (readUI8 * 8)]
]


import-FILLSTYLEARRAY: does[
	byteAlign
	loop readCount [ ;FillStyleCount
		import-FILLSTYLE
	]
]
import-MORPHFILLSTYLEARRAY: does[
	byteAlign
	loop readCount [ ;FillStyleCount
		import-MORPHFILLSTYLE
	]
]
import-LINESTYLEARRAY: has[flags joinStyle hasFill?][
	;print [tagID mold copy/part inBuffer 10]
	loop readCount [ ;LineStyleCount
		byteAlign
		case [
			;DefineMorphShape
			tagId = 46 [ skipBytes 12 ]
			;DefineShape4 or DefineShape5
			any [tagId = 67 tagId = 83][
				skipUI16 ;Width
				skipBits 2 ;f_start_cap_style
				joinStyle: readUB 2 ;f_join_style
				hasFill?:  readBitLogic ;f_has_fill
				skipBits 11
				if joinStyle = 2 [skipUI16] ;miterLimit
				either hasFill? [import-FILLSTYLE][skipRGBA]
			]
			;DefineMorphShape2
			tagId = 84 [
				skipUI16 ;StartWidth
				skipUI16 ;EndWidth
				skipBits 2 ;f_start_cap_style
				joinStyle: readUB 2 ;f_join_style
				hasFill?:  readBitLogic ;f_has_fill
				skipBits 11
				if joinStyle = 2 [skipUI16]
				either hasFill? [import-FILLSTYLE][skipBytes 8]
			]
			true [
				skipUI16 ;Width
				either tagId = 32 [skipRGBA][skipRGB]
			]
		]
	]
]
import-MORPHLINESTYLEARRAY: has[flags joinStyle hasFill?][
	;print [tagID mold copy/part inBuffer 10]
	loop readCount [ ;LineStyleCount
		either tagId = 46 [
			skipBytes 12;<= readMORPHLINESTYLE
		][ 
			skipUI16 ;StartWidth
			skipUI16 ;EndWidth
			skipBits 2 ;f_start_cap_style
			joinStyle: readUB 2 ;f_join_style
			hasFill?:  readBitLogic ;f_has_fill
			skipBits 11
			if joinStyle = 2 [skipUI16]
			either hasFill? [import-FILLSTYLE][skipBytes 8]
		 ]
	]
]

import-FILLSTYLE: has[type][
	byteAlign
	type: readUI8 ;FillStyleType
	
	case [
		type = 0 [
			;solid fill
			case [
				find [46 84] tagId [
					;morph
					skipBytes 8 ;readRGBA readRGBA
				]
				tagId >= 32 [skipRGBA]
				true [skipRGB]
			]
		]
		any [
			type = 16 ;linear gradient fill
			type = 18 ;radial gradient fill
			type = 19 ;focal gradient fill (swf8)
		][
			;gradient
			either find [46 84] tagId [
				;morph
				skipMATRIX
				skipMATRIX
				skipGRADIENT type
			][	;shape
				skipMATRIX
				skipGRADIENT type
			]
		]
		type >= 64 [
			;bitmap
			either find [46 84] tagId [
				;morph
				replacedID
				skipMATRIX
				skipMATRIX
			][	;shape
				replacedID
				skipMATRIX
			]
		]
	]
]

import-MORPHFILLSTYLE: has[type][
	;byteAlign
	type: readUI8 ;FillStyleType
	case [
		type = 0 [;solid fill
			skipBytes 8 ;readRGBA readRGBA
		]
		any [
			type = 16 ;linear gradient fill
			type = 18 ;radial gradient fill
			type = 19 ;focal gradient fill (swf8)
		][
			;gradient
			skipMATRIX
			skipMATRIX
			;byteAlign
			skipBytes (readUI8 * 10) ;numGrads * (Sratio + SRGBA + ERatio + ERGBA)
		]
		type >= 64 [;bitmap
			replacedID
			skipMATRIX
			skipMATRIX
		]
	]
]

import-SHAPERECORD: func[numFillBits numLineBits /local nBits lineType states records][
	byteAlign	
	;print ["import-SHAPERECORD:" numFillBits numLineBits]
	until [
		either readBitLogic [ ;edge?
			either readBitLogic [;straightEdge?
				;print "line - "
				nBits: 2 + readUB 4
				either readBitLogic [
					;GeneralLine
					skipBits (2 * nBits)
				][
					skipBits (1 + nBits)
				]
			][
				;print "curve - "
				nBits: 2 + readUB 4
				;print [mold copy/part back inBuffer 5 availableBits bitBuffer (4 * nBits)]
				skipBits (4 * nBits)
				;skipBits nBits ;(4 * nBits)
				;skipBits nBits ;
				;skipBits nBits ;
				;skipBits nBits ;
			]
			false
		][
			states: readUB 5
			;print ["STATES:" states]
			either states = 0 [
				;EndShapeRecord
				true ;end
			][
				
				if 0 < (states and 1 ) [ skipPair ] ;move
				if 0 < (states and 2 ) [ skipBits numFillBits] ;fillStyle0
				if 0 < (states and 4 ) [ skipBits numFillBits] ;fillStyle1
				if 0 < (states and 8 ) [ skipBits numLineBits] ;lineStyle
				if 0 < (states and 16) [
					import-FILLSTYLEARRAY
					import-LINESTYLEARRAY
					numFillBits: readUB 4 ;Number of fill index bits for new styles
					numLineBits: readUB 4 ;...line...
	
				] ;NewStyles
				
				false ;continue
			]		
		]
	]
]
import-Shape: has[type][
	changeID
	skipRect
	if tagId = 83 [
		skipRect ;edgeBounds
		skipByte
	]
	import-FILLSTYLEARRAY
	import-LINESTYLEARRAY
	import-SHAPERECORD (byteAlign readUB 4) readUB 4
]

import-DefineButton: does [
	changeID
	import-BUTTONRECORDs
]
import-DefineButton2: does [
	changeID
	skipBytes 3 ;UI8 flags + UI16 ActionOffset
	import-BUTTONRECORDs
]
import-DefineButtonSound: has[id] [
	replacedID ;ButtonId
	loop 4 [
		if #{0000} <> replacedID [skipSOUNDINFO]
	]
]
import-BUTTONRECORDs: has[reserved states] [
	until [
		byteAlign
		reserved: readUB 4
		states:   readUB 4
		either all [reserved = 0 states = 0] [true][;end
			replacedID
			skipUI16 ;PlaceDepth
			skipMATRIX
			either tagId = 34 [skipCXFORMa][none]
			false ;continue
		]
	]
]

import-PlaceObject2: has[flags1 flags2 atFiltersBufer filters][
	flags1: readUI8
	atFlags2Buffer: inBuffer
	if tagId = 70 [
		flags2: readUI8
	]
	
	either spriteLevel = 0 [
		;if we are in root, update depth level up from the existing depth
		last-depth: init-depth + readUI16
		change (skip inBuffer -2) int-to-ui16 last-depth
	][	skipUI16] ;depth
	either tagId = 70 [;placeObject3

		if any [
			isSetBit? flags2 4 ;PlaceFlagHasClassName
			all [
				isSetBit? flags1 2 ;PlaceFlagHasCharacter
				isSetBit? flags2 5 ;PlaceFlagHasImage
			]
		][
			skipString ;ClassName
		]
		if isSetBit? flags1 2 [replacedID]
		if all [
			isSetBit? flags2 1 ;PlaceFlagHasFilterList
			not empty? RemoveFilters
		][
			;ask "removing filters..."
			if isSetBit? flags1 3 [skipMatrix]  ;PlaceFlagHasMatrix
			if isSetBit? flags1 4 [skipCXFORMa] ;PlaceFlagHasColorTransform
			if isSetBit? flags1 5 [skipUI16]    ;PlaceFlagHasRatio
			if isSetBit? flags1 6 [skipString]  ;PlaceFlagHasName
			if isSetBit? flags1 7 [skipUI16]    ;PlaceFlagHasClipDepth
			atFiltersBufer: inBuffer
			filters: readFILTERS
			if all [1 = filters/1 2 = length? filters][
				;IF THERE IS ONLY ONE FILTER (blur), REMOVE IT! - just a fix hack, should be improved
				remove/part atFiltersBufer ((index? inBuffer) - (index? atFiltersBufer))
				
				atFlags2Buffer/1: to-char (flags2 and 254) ;removing PlaceFlagHasFilterList flag
			]
		]
			
	][
		if isSetBit? flags1 2 [replacedID]
	]
]

import-DefineText: has[GlyphBits AdvanceBits HasFont? HasColor? HasYOffset? HasXOffset?] [
	changeID     ;charId
	skipRECT   ;TextBounds
	skipMATRIX ;TextMatrix
	byteAlign
	;TEXTRECORD:
	GlyphBits:   readUI8
	AdvanceBits: readUI8
	;probe inBuffer
	while [readBitLogic][ ;TextRecordType
		skipBits 3
		HasFont?:    readBitLogic
		HasColor?:   readBitLogic
		HasYOffset?: readBitLogic
		HasXOffset?: readBitLogic
		if HasFont?    [replacedID]
		if HasColor?   [either tagId = 11 [skipRGB][skipRGBA]]
		if HasXOffset? [skipSI16  ]
		if HasYOffset? [skipSI16  ]
		if HasFont?    [skipUI16  ]
		;GLYPHENTRY:
		skipBits (readUI8 * (GlyphBits + AdvanceBits))
		byteAlign
	]
]

import-DefineEditText: has[HasText? HasTextColor? HasMaxLength? HasFont? HasLayout?][
	changeID
	skipRECT      ;Bounds
	HasText?:     readBitLogic
	skipBits 4
	HasTextColor?: readBitLogic
	HasMaxLength?: readBitLogic
	HasFont?:      readBitLogic
	skipBits 2
	HasLayout?:    readBitLogic
	byteAlign
	if HasFont?   [replacedID skipUI16] ;FontID,Height
	if HasTextColor? [skipRGBA   ]
	if HasMaxLength? [skipUI16   ]
	if HasLayout?    [skipBytes 9]
	skipString ;VariableName
	if HasText?      [skipString ]
]

import-DefineSprite: has[i h] [
	changeID
	skipUI16 ;FrameCount
	i: index? inbuffer
	;print ["SPR>:" i length? inBuffer probe inBuffer]
	h: copy/part head inBuffer (i - 1)
	inBuffer: at join h importSWFTAGs inBuffer i
	;print ["SPR<:" index? inbuffer length? inBuffer  probe inBuffer]
]

import-DefineMorphShape: does [
	changeID
	skipRECT ;StartBounds
	skipRECT ;EndBounds
	skipUI32 ;Offset
	import-MORPHFILLSTYLEARRAY
	skipBytes (readCount * 12) ;MORPHLINESTYLEs
	import-SHAPERECORD readUB 4 readUB 4 ;StartEdges
	import-SHAPERECORD readUB 4 readUB 4 ;EndEdges
]

import-DefineMorphShape2:  does [
	changeID
	skipRECT ;StartBounds
	skipRECT ;EndBounds
	skipRECT ;StartEdgeBounds
	skipRECT ;EndEdgeBounds
	skipBytes 5 ;UI8 flags + UI32 offset
	import-MORPHFILLSTYLEARRAY
	import-MORPHLINESTYLEARRAY
	;probe readLINESTYLEARRAY
	import-SHAPERECORD readUB 4 readUB 4 ;StartEdges
	
	import-SHAPERECORD readUB 4 readUB 4 ;EndEdges
]

import-ExportAssets: has[id name][
	loop readUI16 [
		id:   replacedID
		name: join "imp_" readSTRING
		unless find imported-names [name][
			repend imported-names [to-word name to integer! reverse copy id]
		]
	]
]
import-ImportAssets: does[
	skipSTRING
	if swfVersion >= 8 [
		skipUI16	;f_version + f_reserved
	]
	loop readUI16 [changeID skipSTRING]
]




import-SymbolClass: does[
	print "symbolClass"
	loop readUI16 [	replacedID skipSTRING]
]

	
