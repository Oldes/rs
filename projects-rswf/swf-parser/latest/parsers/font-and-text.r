rebol [
	title: "SWF font and text parse functions"
	purpose: "Functions for parsing font and text tags in SWF files"
]

	parse-DefineFont: has[id OffsetTable GlyphShapeTable last-ofs][
		reduce [
			readID ;fontID
			(
				OffsetTable: make block! ofs / 2
				loop (ofs / 2) - 1 [
					append OffsetTable (readUI16) - ofs
				]
				append OffsetTable length? inBuffer
				GlyphShapeTable: make block! (ofs / 2)
				last-ofs: 0
				foreach ofs OffsetTable [
					append GlyphShapeTable readBytes (ofs - last-ofs)
					last-ofs: ofs
				]

				GlyphShapeTable
			)
		]
	]
	
	parse-DefineFont2: has[
		flags OffsetTable NumGlyphs WideOffsets? CodeTableOffset GlyphShapeTable last-ofs
	][
		reduce [
			readID ;fontID
			flags: readUI8
			readUI8  ;langCode
			as-string readBytes readUI8 ;fontName
			(
				NumGlyphs: readUI16
				;OffsetTable: copy []
				WideOffsets?: 8 = (8 and flags)
				;ofs: 0 ;either WideOffsets? [readUI32][readUI16]
				loop NumGlyphs [
					;append OffsetTable (either WideOffsets? [readUI32][readUI16])
					either WideOffsets? [readUI32][readUI16]
				]
				either WideOffsets? [readUI32][readUI16] ;CodeTableOffset
				GlyphShapeTable: copy []
				loop NumGlyphs [
					byteAlign
					append/only GlyphShapeTable readSHAPE
				]
				;last-ofs: 0
				;foreach ofs OffsetTable [
				;	append GlyphShapeTable readBytes (ofs - last-ofs)
				;	last-ofs: ofs
				;]
				;probe inBuffer
				GlyphShapeTable
			)
			readStringNum (NumGlyphs * either WideOffsets? [4][2]) ;CodeTable
			either 128 = (128 and flags) [;FontFlagsHasLayout
				reduce [
					readSI16 ;FontAscent
					readSI16 ;FontDescent
					readSI16 ;FontLeading
					(
						tmp: copy [] 
						loop NumGlyphs [append tmp readSI16]
						tmp ;FontAdvanceTable
					)
					(
						clear tmp  
						loop NumGlyphs [append tmp readRECT]
						tmp ;FontBoundsTable
					)
					(
						byteAlign
						readKERNINGRECORDs WideOffsets?
					)
				]
			][	none ]
		]
	]
	
	parse-DefineFont4: does[
		reduce [
			readID ;fontID
			readUI8 ;flags
			as-string readString ;fontName
			readRest ;FontData
;When present, this is an OpenType CFF font, as defined in the OpenType specification at www.microsoft.com/typography/otspec.
;The following tables must be present: ‘CFF ’, ‘cmap’, ‘head’, ‘maxp’, ‘OS/2’, ‘post’, and either
; (a) ‘hhea’ and ‘hmtx’, or
; (b) ‘vhea’, ‘vmtx’, and ‘VORG’.
;The ‘cmap’ table must include one of the following kinds of Unicode ‘cmap’ subtables: (0, 4), (0, 3), (3, 10), (3, 1), or (3, 0)
;[notation: (platform ID, platformspecific encoding ID)]. Tables such as ‘GSUB’, ‘GPOS’, ‘GDEF’, and ‘BASE’ may also be present.
;Only present for embedded fonts.
		]
	]
	
	parse-DefineText: does [ ;same for DefineText2
		reduce [
			probe readID     ;charId
			readRECT   ;TextBounds
			readMATRIX ;TextMatrix
			readTEXTRECORD (byteAlign readUI8) readUI8 ;GlyphBits AdvanceBits
		]
	]
	parse-DefineEditText: has[HasText? HasTextColor? HasMaxLength? HasFont? HasLayout?][
		reduce [
			readID
			readRECT      ;Bounds
			(
				byteAlign
				HasText?:     readBitLogic
				readBitLogic  ;WordWrap
			)
			readBitLogic  ;Multiline
			readBitLogic  ;Password
			readBitLogic  ;ReadOnly
			(
				HasTextColor?: readBitLogic
				HasMaxLength?: readBitLogic
				HasFont?:      readBitLogic
				readBit        ;Reserved1
			)
			readBitLogic   ;AutoSize
			(
				HasLayout?:    readBitLogic
				readBitLogic   ;NoSelect
			)
			readBitLogic   ;Border
			readBit        ;Reserved2
			readBitLogic   ;HTML
			
			readBitLogic   ;UseOutlines
			either HasFont?      [reduce [readUsedID readUI16]][none] ;FontID,Height
			either HasTextColor? [readRGBA  ][none]
			either HasMaxLength? [readUI16  ][none]
			either HasLayout?    [
				reduce [
					readUI8  ;align
					readUI16 ;LeftMargin	
					readUI16 ;RightMargin
					readUI16 ;Indent
					readUI16 ;Leading
				]
			][	none]
			readString ;VariableName
			either HasText? [readString][none] ;InitialText
		]
	]
	parse-DefineTextFormat: does [
		readRest ;I don't know what it is
	]

	readTEXTRECORD: func[GlyphBits AdvanceBits /local records HasFont? HasColor? HasYOffset? HasXOffset?][
		records: copy []
		while [readBitLogic][ ;TextRecordType
			readUB 3 ;StyleFlagsReserved
			HasFont?:    readBitLogic
			HasColor?:   readBitLogic
			HasYOffset?: readBitLogic
			HasXOffset?: readBitLogic
			append records reduce [
				either HasFont?    [readUsedID][none] ;fontID
				either HasColor?   [either tagId = 11 [readRGB][readRGBA]][none]
				either HasXOffset? [readSI16  ][none]
				either HasYOffset? [readSI16  ][none]
				either HasFont?    [readUI16  ][none] ;TextHeight
				readGLYPHENTRY GlyphBits AdvanceBits
			]
			byteAlign
		]
		
		records
	]
	readGLYPHENTRY: func[GlyphBits AdvanceBits /local glyphs][
		glyphs: copy []
		loop readUI8 [;GlyphCount
			insert tail glyphs reduce [
				readUB GlyphBits   ;GlyphIndex
				readSB AdvanceBits ;GlyphAdvance
			]
		]
		glyphs
	]
	
	readKERNINGRECORDs: func[wide? /local result][
		result: copy []
		either wide? [
			loop readUI16 [
				insert tail result reduce [
					readUI16 ;FontKerningCode1
					readUI16 ;FontKerningCode2
					readSI16 ;FontKerningAdjustment
				]
			]
		][
			loop readUI16 [
				insert tail result reduce [
					readUI8  ;FontKerningCode1
					readUI8  ;FontKerningCode2
					readSI16 ;FontKerningAdjustment
				]
			]
		]
		result
	]

	parse-DefineFontInfo: has[flags][
		reduce [
			readUsedID ;fontID
			as-string readBytes readUI8  ;FontName
			readUI8    ;flags
			readRest   ;CodeTable
		]
	]
	parse-DefineFontInfo2: has[flags][
		reduce [
			readUsedID ;fontID
			as-string readBytes readUI8  ;FontName
			readUI8    ;flags
			readUI8    ;langCode
			readRest   ;CodeTable
		]
	]
	
	parse-DefineAlignZones: does [reduce[
		readUsedID
		readUB 2 ;csmTableHint
		readALIGNZONERECORDs
	]]
	
	readALIGNZONERECORDs: has[records numZoneData zoneData][
		records: copy []
		while [not tail? inBuffer][
			repend/only records [
				(
					numZoneData: readUI8
				 	zoneData: make block! numZoneData
					loop numZoneData [
						insert tail zoneData readUI32
					]
					zoneData
				)
				readUI8 ;zoneMask
			]
		]
		records
	]
	
	parse-CSMTextSettings: does [reduce [
		readUsedID ;textID
		readUB 2 ;styleFlagsUseSaffron
		readUB 3 ;gridFitType
		readUB 3 ;reserved
		readUI32 ;thickness
		readUI32 ;sharpness
		readUI8  ;reserved
	]]
	
	parse-DefineFontName: does [reduce[
		readUsedID ;fontID
		readString ;fontName
		readString ;copyright
	]]