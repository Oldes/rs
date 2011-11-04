Rebol [
	title: "SWF Examiner"
	Author: "oldes"
	Date:   21-11-2002
	version: 0.0.12
    File:    %exam-swf.r
    Email:   oliva.david@seznam.cz
	Purpose: {
       Basic SWF  parser which can
	   show all standard informations from the file. 
    }
    Category: [file util 3]
	History: [
		0.0.20 [21-11-2002 {Now using direct streaming}]
		0.0.12 [17-12-2001 {Support for new tags} "oldes"]
		0.0.7 [30-11-2001 {
		Fixed converting numbers from binary.
		Added support for some other tags as morping and so on} "oldes"]
		0.0.2 [6-11-2001 "New start..." "oldes"]
		0.0.1 [3-Sep-2000 "Initial version" "oldes"]
	]
	comment: {}
	require: [
		rs-project 'ieee
		rs-project 'stream-io
	]
]


details?: true
system/options/binary-base: 16



;--------------------------------------




swf-tags: make block! [
	0 ["end" [print ""]]
	1 ["showFrame" [print ""]]
	2 ["DefineShape" [either details? [parse-DefineShape][probe tag-bin]]]
	4 ["PlaceObject" [parse-PlaceObject]]
	5 ["RemoveObject" [parse-RemoveObject]] 
	22 ["DefineShape2" [either details? [parse-DefineShape][probe tag-bin]]] ;Extends the capabilities of DefineShape with the ability to support more than 255 styles in the style list and multiple style lists in a single shape. (SWF 2.0)
	24 ["Protected file!"]
	32 ["DefineShape3" [either details? [parse-DefineShape][probe tag-bin]]]	;Extends the capabilities of DefineShape2 by extending all of the RGB color fields to support RGBA with alpha transparency. (SWF 3.0)
	9 ["setBackgroundColor" [print to-tuple tag-bin]]
	10 ["DefineFont" [parse-defineFont]]
	11 ["DefineText" [parse-defineText]]
	12 ["DoAction Tag" [print "" parse-ActionRecord tag-bin]]
	13 ["DefineFontInfo"]
	
	14 ["DefineSound" [parse-defineSound]]
	15 ["StartSound" [parse-startSound]]
	18 ["SoundStreamHead" [parse-SoundStreamHead ]]
	19 ["SoundStreamBlock" [parse-MP3STREAMSOUNDDATA]]
	;19 ["SoundStreamBlock" [write/binary/append %/j/test/t.mp3 skip tag-bin 4]]
	;19 ["SoundStreamBlock" [print [length? tag-bin read-short read-short length? tag-bin] probe tag-bin]]
	
	20 ["DefineBitsLossless" [parse-DefineBitsLossless]]
	21 ["DefineBitsJPEG2" [parse-DefineBitsJPEG2]]
	26 ["PlaceObject2" [ tag-bin  parse-PlaceObject2]]
	28 ["RemoveObject2" ]
	33 ["DefineText2" [parse-defineText]]
	34 ["DefineButton2" [parse-DefineButton2]]
	35 ["DefineBitsJPEG3" [parse-DefineBitsJPEG3]]
	36 ["DefineBitsLossless2" [parse-DefineBitsLossless]]
	37 ["DefineEditText" [parse-DefineEditText]]
	39 ["DefineSprite" [parse-sprite]]
	40 ["SWT-CharacterName" [
		print ["ID:" tag-bin-part/rev 2 "="	mold to-string copy/part tag-bin find tag-bin #{00}] 
	]]
	41 ["SerialNumber" [probe tag-bin]]
	42 ["DefineTextFormat" [probe tag-bin]]
	43 ["FrameLabel" [print mold to-string head remove back tail tag-bin]]
	45 ["SoundStreamHead2" [print ""]]
	;46 ["DefineMorphShape" [parse-DefineMorphShape]]
	48 ["DefineFont2" [parse-DefineFont2]]
	;swf 5
	56 ["ExportAssets" [parse-Assets]]
	57 ["ImportAssets" [parse-Assets/import]]
	58 ["EnableDebugger" [prin "Password:" probe tag-bin]]	
	;swf 6
	59 ["DoInitAction" [print "" parse-ActionRecord/init tag-bin]]
	60 ["DefineVideoStream" [probe tag-bin]]
	61 ["VideoFrame" [print ""]]
	62 ["DefineFontInfo2" [parse-DefineFontInfo/mx]]
	64 ["ProtectDebug2" [probe tag-bin]]
	;swf7
	65 ["ScriptLimits" [parse-ScriptLimits]]
	66 ["SetTabIndex" [parse-SetTabIndex]]
	67 ["DefineShape4" [either details? [parse-DefineShape][probe tag-bin]]]
	;swf8
	69 ["FileAttributes" [probe tag-bin]]
	70 ["PlaceObject2WithBlend" [probe tag-bin  parse-PlaceObject2/Blend]]
	71 ["Import2" [probe tag-bin ]]
	73 ["DefineAlignZones" [probe length? tag-bin ]]
	74 ["CSMTextSettings" [parse-CSMTextSettings]]
	75 ["DefineFont3" [parse-DefineFont2]]
	77 ["MetaData" [probe to-string tag-bin]]
	78 ["DefineScalingGrid" [probe  tag-bin]]
	
	;unknown?! and swf9
	72 ["DoAction3" [parse-Action3Record tag-bin]]
	76 ["DoAction3StartupClass" [parse-Action3StartupClass tag-bin]]
	82 ["DoAction3" [parse-Action3Record/withClass tag-bin]]
	83 ["DefineShape5" [either details? [parse-DefineShape][probe tag-bin]]]
	84 ["DefineMorphShape2" [probe  tag-bin]]
	86 ["DefineSceneAndFrameLabelData" [parse-DefineSceneAndFrameLabelData tag-bin]]
]
tag: length: data: none
indent: 0



;STREAM IO FUNCTIONS:
	buffer:    none
	bitCursor: 0
	bitBuffer: none
	
	setStreamBuffer: func[buff][
		buffer: buff
		bitCursor: 0
		bitBuffer: none
	]
	readBit: does [
		if none? bitBuffer [
			bitBuffer: first buffer
			bitCursor: 1
			buffer: next buffer
		]
		
		if (bit: 128 and bitBuffer) > 0 [bit: 1]
		either (bitCursor: bitCursor + 1) > 8 [
			bitBuffer: none 
			bitCursor: 0
		][
			bitBuffer: bitBuffer * 2
		]
		bit
	]
	readSB: func[nbits [integer!] /local result][
		if nbits = 0 [return 0]
		result: copy ""
		loop nbits [ append result readBit ]
		insert/dup result result/1 (32 - nbits)
		to integer! debase/base result 2
	]
	readUB: func[nbits [integer!] /local result][
		if nbits = 0 [return 0]
		result: copy ""
		loop nbits [ append result readBit ]
		insert/dup result 0 (32 - nbits)
		to integer! debase/base result 2
	]
	
	;"010001111101111" =  0.14036
	;"01111110001100100" =  0.98591
	readFB: func[nbits /local high low b] [
		high: either nbits <= 17 [b: 0][readSB (b: nbits - 17)]
		low:  (readSB (nbits - b)) / 65535
		high + low
	]
	readRect: has[nbits][
		nbits: readUB 5
		reduce [
			readSB nbits ;Xmin
			readSB nbits ;Xmax
			readSB nbits ;Ymin
			readSB nbits ;Ymax
		]
	]
	byteAlign: does [
		if bitCursor > 0 [
			bitCursor: 0
			bitBuffer: none
		]
		buffer
	]
	
	readByte: func[/local byte][
		byte:   copy/part buffer 1
		buffer: next buffer
		byte
	]
	readBytes: func[nbytes /local bytes][
		bytes: copy/part buffer nbytes
		buffer: skip buffer nbytes
		bytes
	]
	readBytesRev: func[nbytes /local bytes][
		bytes: copy/part buffer nbytes
		buffer: skip buffer nbytes
		reverse bytes
	]
	readBytesArray: func [
		"Slices the binary data to parts which length is specified in the bytes block"
		bytes [block!]
		/local result b
	][
		result: copy []
		while [not tail? bytes] [
			insert tail result readBytes bytes/1
			bytes: next bytes
		]
		result
	]
	readUI8:   has[i][i: first buffer buffer: next buffer i]
	readUI32:  func[][to integer! readBytesRev 4]
	readUI16:  func[][to integer! readBytesRev 2]
	readSI16:  func[/local i][
		i: readBytesRev 2
		i: either #{8000} = (i and #{8000}) [
			negate (32768 - to integer! (i and #{7FFF}))
		][to integer! i]
	]
	readShort: :readUI16 ;just to make it clear
	readLongFloat: func["reads 4 bytes and converts them to decimal!" /local tmp][
		from-ieee32 join (readBytesRev 3) (readBytes 1)
	]
	readTuple:  does[to tuple! readBytes 4]
	readStringP: has[str][
		parse/all buffer [copy str to "^(00)" 1 skip buffer:]
		buffer: as-binary buffer
		str
	]
	readString: has[str b][
		str: copy ""
		while [#{00} <> b: readByte][ insert tail str b]
		str
	]
	readUI30: has[r b s][
		b: first buffer buffer: next buffer
		if b < 128 [return b]
		r: b and 127
		s: 128
		while [b: first buffer buffer: next buffer][
			r: r + (b * s)
			if 128 > b [return r]
			s: s + 128
		]
	]
	readCount: has[c][
		either 255 = c: readUI8 [readUI16][c]
	]
;=========================================================

;help functions:

roundTo: func[val digits /local i][	(round (i: 10 ** digits) * val) / i ]

extract-data: func[type][
	swf/chunk/data: slice-bin/integers swf/chunk/data select swf/chunk-bytes type
]

;end of help functions


tabs: has [t][t: make string! indent insert/dup t tab indent t] 
ind-: does [indent: indent - 1]
ind+: does [indent: indent + 1]


parse-Assets: func[ /import /local assets file id name][
	assets: make block! 6
	ind+
	either import [
		parse/all tag-bin [
			copy file to #"^@" 3 skip
			some [
				copy id 2 skip copy name to #"^@" 1 skip
				(append assets reduce [bin-to-int as-binary id name])
			]
		]
		assets: reduce [file assets]
		print ["ImportingAssets" mold assets/2 "from" assets/1]
	][
		parse/all tag-bin [
			2 skip
			some [
				copy id 2 skip copy name to #"^@" 1 skip
				(append assets reduce [bin-to-int as-binary id name])
			]
		]
		print ["ExportingAssets" mold assets]
	]
	ind-
	assets
]
parse-MP3STREAMSOUNDDATA: func[][
	ind+
		print [tabs "SampleCount:" read-short]
		parse-MP3SOUNDDATA
	ind-
]
parse-MP3SOUNDDATA: func[/local frames][
	ind+
	;probe tag-bin
	print [tabs "SeekSamples:" SI16-to-int x: tag-bin-part 2]
	frames: 0
	while [not empty? tag-bin ][
		frames: frames + 1
		parse-MP3FRAME
	]
	print [tabs "frames:" frames]
	ind-
]
parse-MP3FRAME: func[
	/local crc sdsize tmp
	Syncword MpegVersion Layer ProtectionBit
	Bitrate SamplingRate PaddingBit Reserved
	ChannelMode ModeExtension Copyright Original Emphasis
][
	ind+
	tmp: enbase/base tag-bin-part 4 2
	set [
		Syncword MpegVersion Layer ProtectionBit
		Bitrate SamplingRate PaddingBit Reserved
		ChannelMode ModeExtension Copyright Original Emphasis
	] yyy: slice-bin/integers tmp [11 2 2 1  4 2 1 1  2 2 1 1 2]
	comment {
	Bitrate: pick either MpegVersion = 3 [
		["free" 32 40 48 56 64 80 96 112 128 160 192 224 256 320 "bad"] 
	][
			["free" 8 16 24 32 40 48 56 64 80 96 112 128 144 160 "bad"]
	] (1 + Bitrate)
	SamplingRate: pick switch MpegVersion [
		3 [[44100 48000 32000 "--"]]
		2 [[22050 24000 16000 "--"]]
		0 [[11025 12000 8000 "--"]]
	] (1 + SamplingRate)
	sdsize: to-integer ((((either MpegVersion = 3 [144][72]) * Bitrate * 1000) / SamplingRate) + PaddingBit - 4)
	}
	
		Bitrate: pick (switch layer either MpegVersion = 3 [[
			3 [[32 64 96 128 160 192 224 256 288 320 352 384 416 448]]
			2 [[32 48 56  64  80  96 112 128 160 192 224 256 320 384]]
			1 [[32 40 48  56  64  80  96 112 128 160 192 224 256 320]]
		]][[
			3 [[32 48 56  64  80  96 112 128 144 160 176 192 224 256]]
			2 [[ 8 16 24  32  40  48  56  64  80  96 112 128 144 160]]
			1 [[ 8 16 24  32  40  48  56  64  80  96 112 128 144 160]]
		]]) Bitrate
		SamplingRate: pick switch MpegVersion [
			3 [[44100 48000 32000 "--"]]
			2 [[22050 24000 16000 "--"]]
			0 [[11025 12000 8000 "--"]]
		] (1 + SamplingRate)
		;sdsize: to-integer ((((either MpegVersion = 3 [144][72]) * Bitrate * 1000) / SamplingRate) + PaddingBit - 4)
		;comment {
		sdsize: either MpegVersion = 3 [ ;version 1
			((( either layer = 3 [48000][144000]) * bitrate) / SamplingRate) + PaddingBit  - 4
		][
			((( either layer = 3 [24000][72000]) * bitrate) / SamplingRate) + PaddingBit - 4
		]
		;}
	;comment {
	print [tabs
		"MpegVersion:" pick [2.5 "" 2 1] (1 + MpegVersion)
		"Layer:" pick ["" "III" "II" "I"] (1 + Layer)
		"Protected by CRC:" ProtectionBit = 1
	]
	print [tabs
		"Bitrate:" Bitrate
		"SamplingRate:" SamplingRate
		"PaddingBit:" PaddingBit = 1
	]
	print [tabs
		"ChannelMode:" pick ["Stereo" "Joint stereo (Stereo)" "Dual channel" "Single channel (Mono)"] (1 + ChannelMode)
		"Copyright:" Copyright = 1
		"Original:" Original = 1
		"Emphasis:" pick [none "50/15 ms" "" "CCIT J.17"] (1 + Emphasis)
	]
	print [tabs "SampleDataSize:" sdsize]
	;}
	if ProtectionBit = 0 [crc: tag-bin-part 2]
	data: tag-bin-part to integer! sdsize
	;probe length? tag-bin
	ind-
]

parse-SoundStreamHead: func[][
	ind+
	flags: enbase/base tag-bin-part 2 2
	print [tabs "Flags:" mold flags]
	set [
		Reserved psRate psSize psType
		StreamSoundCompression StreamSoundRate StreamSoundSize StreamSoundType
	] slice-bin/integers flags [4 2 1 1  4 2 1 1]
	StreamSoundSampleCount: read-short
	print [tabs "PlaybackSoundRate:" pick [5.5 11 22 44] (1 + psRate) "kHz"]
	print [tabs "PlaybackSoundSize:" pick ["snd8Bit" "snd16Bit"] (1 + psSize)]
	print [tabs "PlaybackSoundType:" pick ["sndMono" "sndStereo"] (1 + psType)]
	print [tabs "StreamSoundCompression:" pick ["uncompressed" "ADPCM" "MP3" "uncompressed little-endian" "" "" "Nellymoser"] (1 + StreamSoundCompression)]
	print [tabs "StreamSoundRate:" pick [5.5 11 22 44] (1 + StreamSoundRate) "kHz"]
	print [tabs "StreamSoundSize:" pick ["snd8Bit" "snd16Bit"] (1 + StreamSoundSize)]
	print [tabs "StreamSoundType:" pick ["sndMono" "sndStereo"] (1 + StreamSoundType)]
	print [tabs "StreamSoundSampleCount:" StreamSoundSampleCount]
	ind-
]

parse-defineSound: func[/local flags sID sFormat sRate sSize sType][
	ind+ print ""
	print [tabs "Sound ID:" sID: tag-bin-part/rev 2]
	flags: enbase/base tag-bin-part 1 2
	print [tabs "Flags:" mold flags]
	set [sFormat sRate sSize sType] slice-bin/integers flags [4 2 1 1]
	print [tabs "SoundFormat:" pick ["uncompressed" "ADPCM" "MP3" "uncompressed little-endian" "" "" "Nellymoser"] (1 + sFormat)]
	print [tabs "SoundRate:  " pick [5.5 11 22 44] (1 + sRate) "kHz"]
	print [tabs "SoundSize:  " pick ["snd8Bit" "snd16Bit"] (1 + sSize)]
	print [tabs "SoundType:  " pick ["sndMono" "sndStereo"] (1 + sType)]
	print [tabs "SoundSampleCount:" to-integer tag-bin-part/rev 4]
	print [tabs "SoundData:" length? tag-bin "bytes"]
	;if sFormat = 2 [write/binary rejoin [%/j/test/mp3_ sID ".mp3"] tag-bin]
	switch sFormat [
		0 [ write/binary %/j/test/x.wav tag-bin]
		2 [	parse-MP3SOUNDDATA]
	]
	ind-
]
parse-startSound: func[][
	ind+ print ""
	print [tabs "Sound ID:" tag-bin-part/rev 2]
	probe flags: enbase/base tag-bin-part 1 2
	ind-
]
parse-DefineBitsJPEG2: func[/local id jpegData][
	ind+
	print ""
	print [tabs "Bitmap ID:" id: tag-bin-part/rev 2]
	jpegData: tag-bin
	ind-
	reduce [id jpegData]
]
parse-DefineBitsJPEG3: func[/local id alphaDataOffset jpegData][
	ind+
	print ""
	print [tabs "Bitmap ID:" id: tag-bin-part/rev 2]
	alphaDataOffset: read-ui32
	jpegData: tag-bin-part alphaDataOffset
	BitmapAlphaData: tag-bin
	ind-
	reduce [id jpegData BitmapAlphaData]
]
parse-DefineBitsLossless: func[/local bitmapFormat x][
	ind+
	print ""
	;probe copy/part tag-bin 10
	print [tabs "Bitmap ID:" tag-bin-part/rev 2]
	print [tabs "BitmapFormat:" select [3 8 4 16 5 32] bitmapFormat: to-integer tag-bin-part 1 "bits"]
	print [tabs "Size:" to-pair reduce [
		read-short
		read-short]
	]
	either bitmapFormat = 3 [
		print [tabs "BitmapColorTableSize:" tag-bin-part 1]
		;probe ( zlib/decompress tag-bin)
	][
		probe ( x: zlib/decompress/l tag-bin 16000)
		print length? x
	]
	ind-
]

parse-DefineMorphShape: func[/local i end-bin][
	ind+
	print "" ;tag-bin
	print [tabs "Char ID:" tag-bin-part/rev 2]
	print [tabs "Rect start:" mold read-rectangle]
	print [tabs "Rect end  :" mold read-rectangle]
	print [tabs "Offset:" i: to-integer tag-bin-part/rev 4]
	end-bin: copy skip tag-bin i
	print [tabs "MorphFillStyles:" i: get-count]
	loop i [parse-MORPHFILLSTYLE]
	print [tabs "MorphLineStyles:" i: get-count]
	ind+
	loop i [
		print [tabs "StartWidth:" read-short]
		print [tabs "EndWidth  :" read-short]
		print [tabs "StartColor:" read-tuple]
		print [tabs "EndColor  :" read-tuple]
	]
	ind-
	print [tabs "StartEdges:"]
	ind+ parse-SHAPE ind-
	print [tabs "EndEdges:"]
	tag-bin: end-bin
	ind+ parse-SHAPE ind-
	ind-
]

parse-MORPHFILLSTYLE: func[/local type i][
	ind+
	print [tabs "Type:" type: tag-bin-part 1]
	if type = #{00} [
		print [tabs "StartColor:" read-tuple]
		print [tabs "EndColor  :" read-tuple]
	]
	if type = #{10} [
		print [tabs "StartGradientMatrix:" parse-matrix]
		print [tabs "EndGradientMatrix  :" parse-matrix]
		print [tabs "Gradients:" i: tag-bin-part 1]
		ind+
		loop i [
			print [tabs "StartRatio:" tag-bin-part 1]
			print [tabs "StartColor:" read-tuple]
			print [tabs "EndRatio  :" tag-bin-part 1]
			print [tabs "EndColor  :" read-tuple]
		]
		ind- 
	]
	if find #{4041} type [
		print [tabs "BitmapId:" tag-bin-part/rev 2]
		print [tabs "StartBitmapMatrix:" parse-matrix]
		print [tabs "EndBitmapMatrix  :" parse-matrix]
	]
	ind-
]
parse-DefineButton2: func[/local tmp ofs key menu?][
	ind+
	print "" ;tag-bin
	print [tabs "Button ID:" tag-bin-part/rev 2]
	print [tabs "Menu:" menu?: #{01} = tag-bin-part 1]
	;Offset to the first Button2ActionCondition 
	ofs: read-short
	;print [tabs "Offset:" ofs]
	ofs: either ofs = 0 [(length? tag-bin) - 1][ofs - 3]
	parse-BUTTONRECORD tag-bin-part ofs
	tag-bin-part 1 ;ButtonEndFlag = #{00}
	if not empty? tag-bin [
		print [tabs "Actions:"]
		ind+
		while [not tail? tag-bin][
			ofs: read-short
			;print [tabs "ActionsOffset:" ofs]
			parse (enbase/base tag-bin-part/rev 2 2) [
				copy key 7 skip copy tmp to end
			]
			st: make block! []
			either menu? [
				if tmp/1 = #"1" [insert st 'DragOut]
				if tmp/2 = #"1" [insert st 'DragOver]
			][
				if tmp/3 = #"1" [insert st 'ReleaseOutside]
				if tmp/4 = #"1" [insert st 'DragOver]
			]
			if tmp/5 = #"1" [insert st 'DragOut]
			if tmp/6 = #"1" [insert st 'Release]
			if tmp/7 = #"1" [insert st 'Press]
			if tmp/8 = #"1" [insert st 'RollOut]
			if tmp/9 = #"1" [insert st 'RollOver]
			print [tabs "Condition:" mold st "Key:" mold to-char ub-to-int key]
			tmp: tag-bin-part either ofs = 0 [length? tag-bin][ofs - 4]
			;first 7bits are reserved
			parse-ActionRecord tmp
		]
		ind-
	]
	ind-
]

parse-BUTTONRECORD: func[bin /local buff tmp st][
	buff: copy tag-bin tag-bin: copy bin
	print [tabs "Buttons:" tag-bin ]
	ind+
		while [not tail? tag-bin][
		tmp: copy skip (enbase/base tag-bin-part 1 2) 4
		st: make block! 4
		repeat i 4 [
			if tmp/:i = #"1" [insert st pick [hit down over up] i]
		]
		print [tabs "States:" mold st]
		ind+
		print [tabs "ButtonCharacter:" tag-bin-part/rev 2]
		print [tabs "ButtonLayer:" tag-bin-part/rev 2]
		ind-
		parse-matrix
		parse-CXFORMWITHALPHA
		]
	ind-
	tag-bin: buff
]



parse-DefineFont2: func[/local flags NameLen glyphs ofsTable wideOfs ofsFST
	FontShapeTable
][
	ind+
	print ""
	;probe tag-bin
	print [tabs "Font ID:" tag-bin-part/rev 2]
	flags: enbase/base tag-bin-part 1 2
	print [tabs "Flags:" flags]
	print [tabs "LanguageCode:"  to-integer tag-bin-part 1]
	NameLen: to-integer tag-bin-part 1
	print [tabs "Name:" to-string tag-bin-part NameLen]
	print [tabs "Glyphs:" glyphs: read-short]
	wideOfs: either flags/5 = #"1" [4][2]
	OffsetTable: make block! glyphs
	ofs: to-integer tag-bin-part/rev wideOfs ;offset to the first glyph in the shapeTbale
	loop (glyphs - 1) [
		append OffsetTable (to-integer tag-bin-part/rev wideOfs) - ofs
	]
	;print [tabs "OffsetTable:" ofsTable: tag-bin-part (glyphs * wideOfs)]	
	;print ["!!!:" length? OffsetTable
	print [tabs "CodeOffset:" codeOffset: to-integer tag-bin-part/rev wideOfs]
	append OffsetTable codeOffset - ofs
	print [tabs "OffsetTable:" length? OffsetTable]
	GlyphShapeTable: make block! glyphs
	last-ofs: 0
	foreach ofs OffsetTable [
		append GlyphShapeTable tag-bin-part (ofs - last-ofs)
		last-ofs: ofs
	]	
	;ofsFST: codeOffset - (length? ofsTable) - wideOfs
	;parse-SHAPE
	;FontShapeTable: tag-bin-part ofsFST
	;print [tabs "FontShapeTable:" length? FontShapeTable]
	FontCodeTable: tag-bin-part (glyphs * wideOfs)
	if details? [print [tabs "FontCodeTable:" mold FontCodeTable]]
	if flags/1 = #"1" [
		print [tabs "FontAscent:" SB-to-int tag-bin-part 2]
		print [tabs "FontDescent:" SB-to-int tag-bin-part 2]
		print [tabs "FontLeading:" SB-to-int tag-bin-part 2]
		FontAdvanceTable: make block! glyphs
		loop glyphs [
			append FontAdvanceTable SB-to-int tag-bin-part 2
		]
		print [tabs "FontAdvanceTable:" mold FontAdvanceTable]
		FontBoundsTable:  make block! glyphs
		loop glyphs [
			append/only FontBoundsTable read-rectangle
		]
		print [tabs "FontBoundsTable:" mold FontBoundsTable]
		print [tabs "KerningCount:" read-short]
	]
	if not empty? tag-bin [
		print [tabs "..." tag-bin]
	]
	ind-
]

parse-defineFont: func[/local id OffsetTable ofs GlyphShapeTable last-ofs][
	ind+
	print ""
	print [tabs "Font ID:" id: tag-bin-part 2]
	ofs: read-short
	OffsetTable: make block! ofs / 2
	print [tabs "Glyphs: " ofs / 2]
	loop (ofs / 2) - 1 [
		append OffsetTable (read-short) - ofs
	]
	append OffsetTable length? tag-bin
	;print [tabs "OffsetTable:" mold OffsetTable]
	GlyphShapeTable: make block! (ofs / 2)
	last-ofs: 0
	foreach ofs OffsetTable [
		append GlyphShapeTable tag-bin-part (ofs - last-ofs)
		last-ofs: ofs
	]
	;forall GlyphShapeTable [
	;	tag-bin: copy first GlyphShapeTable
	;	parse-SHAPE
	;]
	;print [tabs "...:" tag-bin]
	ind-
	return reduce [id GlyphShapeTable]
]

parse-DefineFontInfo: func[/mx /local nameLen flags CodeTable][
	ind+
	print ""
	print [tabs "Font ID:" tag-bin-part 2]
	NameLen: to-integer tag-bin-part 1
	print [tabs "Name:" to-string tag-bin-part NameLen]
	print [tabs "Flags:" flags: enbase/base tag-bin-part 1 2]
	if mx [
		print [tabs "LanguageCode:"  to-integer tag-bin-part 1]
	]
	CodeTable: tag-bin
	print [tabs "Glyphs in CodeTable:" (length? CodeTable) / 2]
	ind-
]

parse-defineText: func[/local flags][
	ind+
	print ""
	print [tabs "Text ID:" tag-bin-part/rev 2]
	print [tabs "Rect:" mold read-rectangle]
	print [tabs "Matrix:" ] parse-matrix
	print [tabs "NglyphBits:" NglyphBits: to-integer tag-bin-part 1]
	print [tabs "NadvanceBits:" NadvanceBits: to-integer tag-bin-part 1]
	print [tabs "TextRecords:" ]
	ind+
	while [#{00} <> flags: tag-bin-part 1][
		flags: enbase/base flags 2
		either flags/1 = #"1" [
			;Text Style Change Record
			if flags/5 = #"1" [
				print [tabs "TextFontID:" tag-bin-part/rev 2 ]
			]
			if flags/6 = #"1" [
				print [tabs "TextColor:" to-tuple tag-bin-part either tagid = 11 [3][4]]
			]
			if flags/7 = #"1" [
				print [tabs "TextXOffset:" read-short ]
			]
			if flags/8 = #"1" [
				print [tabs "TextYOffset:" read-short ]
			]
			if flags/5 = #"1" [
				print [tabs "TextHeight:" (read-short) / 20 ]
			]
		][
			;Glyph Record
			print [tabs "TextGlyphCount:" nGlyphs: ub-to-int copy next flags]
			bytes: (extend-int (nGlyphs * (NglyphBits + NadvanceBits))) / 8
			bits: enbase/base tag-bin-part bytes 2
			parse bits [any [
				copy i NglyphBits skip
				copy j NadvanceBits skip
				;(print [tabs "GlyphEntry:" ub-to-int i sb-to-int j])
			]]
		]
	]
	ind-
	ind-
]
parse-DefineEditText: func[/local flags bits rect InitialText var][
	ind+
	print ""
	;probe tag-bin
	print [tabs "TextID:" tag-bin-part/rev 2]
	bits: enbase/base tag-bin 2
	rect: get-rect bits
	bits: skip bits extend-int (5 + (4 * length? rect/1))
	forall rect [rect/1: SB-to-int rect/1] rect: head rect
	print [tabs "Bounds:" rect]
	flags: copy/part bits 16
	tag-bin: load rejoin ["2#{" skip bits 16 "}"]
	print [tabs "Flags:" flags]
	ind+
	if flags/8 = #"1" [
		print [tabs "HasFont:" tag-bin-part/rev 2]
		print [tabs "FontHeight:" tag-bin-part/twips 2]
	]
	if flags/6 = #"1" [print [tabs "TextColor:" tag-bin-part 4]]
	if flags/7 = #"1" [print [tabs "MaxLength:" read-short]]
	if flags/11 = #"1" [
		;HasLayout
		print [tabs "Align:" pick ['left 'right 'center 'justify] 1 + to-integer tag-bin-part 1]
		print [tabs "LeftMargin:" tag-bin-part/twips 2]
		print [tabs "RightMargin:" tag-bin-part/twips 2]
		print [tabs "Indent:" tag-bin-part/twips 2]
		print [tabs "Leading:" tag-bin-part/twips 2]
	]
	ind-
	parse/all tag-bin [copy var to #"^@" 1 skip InitialText: [to #"^@" | to end]]
	print [tabs "VariableName:" var]
	if flags/1 = #"1" [print [tabs "InitialText:" InitialText]]
	
	probe debase/base bits 2
	
	ind-
]
parse-PlaceObject: func[][
	ind+
	print "";tag-bin
	print [tabs "CharID:" tag-bin-part 2]
	print [tabs "Depth:" tag-bin-part 2]
	parse-matrix

	ind-
]
parse-RemoveObject: func[][
	ind+
	print "";tag-bin
	print [tabs "CharID:" tag-bin-part 2]
	print [tabs "Depth:" tag-bin-part 2]
	ind-
]
parse-PlaceObject2: func[ /Blend /local flags depth CharacterID r MXflags tmp blendflags][
	ind+
	print "";tag-bin
	either blend [
		set [flags blendflags depth] slice-bin tag-bin-part 4 [1 1 2]
	][	set [flags depth] slice-bin tag-bin-part 3 [1 2] ]
	flags: enbase/base flags 2
	print [tabs "Flags:" flags]
	print [tabs "Depth:" to-integer reverse depth]
	print [tabs  either flags/8 = #"1" ["Character is already in the list"]["Placing new character"]]
	if flags/7 = #"1" [
		print [tabs "CharacterID:" read-short]
	]
	if flags/6 = #"1" [
		print [tabs "Matrix:" ]
		parse-matrix
	]
	if flags/5 = #"1" [
		print [tabs "ColorTransform:"]
		parse-CXFORMWITHALPHA
	]
	if flags/4 = #"1" [
		print [tabs "Ratio:" r: read-short rejoin ["( " roundTo (r / 65535 * 100) 2 "% )"]]
	]
	if flags/2 = #"1" [
		print [tabs "ClipDepth:" read-short]
	]
	if flags/3 = #"1" [
		print [tabs "Name:" mold to-string tmp: copy/part tag-bin find tag-bin #{00}]
		tag-bin: skip tag-bin 1 + length? tmp
	]
	if flags/1 = #"1" [
		print [tabs "ClipActions:" tag-bin]
		something: tag-bin-part 2
		print [tabs "Flags:" flags: enbase/base tag-bin-part 2 2]
		either swf/header/version > 5 [
			probe something: tag-bin-part 2
			while [#{00000000} <> type: tag-bin-part 4][
				print [tabs "On" select [
					#{01000000} "Load"
					#{02000000} "EnterFrame"
					#{04000000} "Unload"
					#{10000000} "MouseDown"
					#{20000000} "MouseUp"
					#{08000000} "MouseMove"
					#{40000000} "KeyDown"
					#{80000000} "KeyUp"
					#{00010000} "Data"
					
					#{00040000} "Press"
					#{00080000} "Release"
					#{00100000} "ReleaseOutside"
					#{00200000} "RollOver"
					#{00400000} "RollOut"
					#{00800000} "DragOver"
					#{00000200} "Key"
					] type ;"(" type enbase/base type 2")"
				]
				ofs: to-integer tag-bin-part/rev 4
				tmp: tag-bin-part ofs
				if type = #{00000200}  [
					print [tabs "<" select [
						#{01} "keyLeft"
						#{02} "keyRight"
						#{03} "keyHome"
						#{04} "keyEnd"
						#{05} "keyInsert"
						#{06} "keyDelete"
						#{08} "keyBackspace"
						#{0D} "keyEnter"
						#{0E} "keyUp"
						#{0F} "keyDown"
						#{10} "keyPageUp"
						#{11} "keyPageDown"
						#{12} "keyTab"
						#{13} "keyEscape"
						#{20} "keySpace"
						] copy/part tmp 1 ">"
					]
					tmp: next tmp
				]
				parse-ActionRecord tmp
			]
		][
			while [#{0000} <> type: tag-bin-part 2][
				print [tabs "On" select [
					#{0100} "Load"
					#{0200} "EnterFrame"
					#{0400} "Unload"
					#{1000} "MouseDown"
					#{2000} "MouseUp"
					#{0800} "MouseMove"
					#{4000} "KeyDown"
					#{8000} "KeyUp"
					#{0001} "Data"
					] type
				]
				ofs: to-integer tag-bin-part/rev 4
				parse-ActionRecord tag-bin-part ofs
			]
		]
	]
	if blend [
		blendtype: select [
			#{02} "Layer"
			#{06} "Darken"
			#{03} "Multiply"
			#{05} "Lighten"
			#{04} "Screen"
			#{0D} "Overlay"
			#{0E} "HardLight"
			#{08} "Add"
			#{09} "Subtract"
			#{07} "Diference"
			#{0A} "Invert"
			#{0B} "Alpha"
			#{0C} "Erase"
		] tag-bin-part 1
		print [tabs "BLEND:" blendtype]
	]
	ind-
]



parse-CXFORM: func[/local bits flags nBits v1 v2 v3][
	ind+
	bits: enbase/base copy tag-bin 2
	probe flags: copy/part bits 2
	bits: skip bits 2
	nBits: UB-to-int copy/part bits 4
	bits: skip bits 4
	used-bits: 6
	if flags/2 = #"1" [
		parse bits [copy v1 nBits skip copy v2 nBits skip copy v3 nBits skip copy bits to end]
		print [tabs "Multiply:" SB-to-int v1 SB-to-int v2 SB-to-int v3]
		used-bits: used-bits + (3 * nBits)
	]
	if flags/1 = #"1" [
		parse bits [copy v1 nBits skip copy v2 nBits skip copy v3 nBits skip copy bits to end]
		print [tabs "Addition:" SB-to-int v1 SB-to-int v2 SB-to-int v3]
		used-bits: used-bits + (3 * nBits)
	]
	tag-bin: skip tag-bin (extend-int used-bits) / 8
	ind-
]
parse-CXFORMWITHALPHA: func[/local bits flags nBits v1 v2 v3 v4][
	ind+
	bits: enbase/base copy tag-bin 2
	flags: copy/part bits 2
	bits: skip bits 2
	nBits: UB-to-int copy/part bits 4
	bits: skip bits 4
	used-bits: 6
	if flags/2 = #"1" [
		parse bits [copy v1 nBits skip copy v2 nBits skip copy v3 nBits skip copy v4 nBits skip copy bits to end]
		print [tabs "Multiply:" SB-to-int v1 SB-to-int v2 SB-to-int v3 SB-to-int v4]
		used-bits: used-bits + (4 * nBits)
	]
	if flags/1 = #"1" [
		parse bits [copy v1 nBits skip copy v2 nBits skip copy v3 nBits skip copy v4 nBits skip copy bits to end]
		print [tabs "Addition:" SB-to-int v1 SB-to-int v2 SB-to-int v3 Sb-to-int v4]
		used-bits: used-bits + (4 * nBits)
	]
	tag-bin: skip tag-bin (extend-int used-bits) / 8
	ind-
]
parse-matrix: func[
	/local bits used-bits val
	 ScaleX ScaleY RotateSkew0 RotateSkew1 TranslateX TranslateY
][
	ind+
	bits: enbase/base copy tag-bin 2
	used-bits: 7
	parse bits [
		[
			#"0" ;(tabs print "Has no scale")
			|
			#"1" (prin [tabs "Scale:"])
			copy val 5 skip (val: UB-to-int val)
			copy ScaleX val skip
			copy ScaleY val skip
			(print [(FB-to-int ScaleX) "x" (FB-to-int ScaleY)]
				used-bits: used-bits + 5 + (2 * val)
			)
		]
		[
			#"0" ;(print "Has no rotation")
			|
			#"1" (prin [tabs "Rotation: "])
			copy val 5 skip (probe val: UB-to-int val)
			copy RotateSkew0 val skip
			copy RotateSkew1 val skip
			(	print [FB-to-int RotateSkew0 FB-to-int RotateSkew1]
				used-bits: used-bits + 5 + (2 * val)
			)
		]
		copy val 5 skip (val: UB-to-int val)
		copy TranslateX val skip
		copy TranslateY val skip
		(
			if val = 0 [TranslateX: TranslateY: "0"]
			print [tabs "Translate:" (SB-to-int TranslateX) / 20 (SB-to-int TranslateY) / 20]
			used-bits: used-bits + (2 * val)
		)
		to end
	]
	tag-bin: skip tag-bin (extend-int used-bits) / 8
	ind-
]

parse-sprite: func[][
	ind+
	print ""
	;print tag-bin
	print [tabs "Sprite ID:" tag-bin-part 2]
	print [tabs "FrameCount:" tag-bin-part 2]
		ind+
		foreach-tag copy tag-bin  show-info
		ind-
	ind-
]
parse-DefineShape: func [/local flags][
	ind+
	print "";tag-bin
	print [tabs "ShapeId:" tag-bin-part 2]
	print [tabs "Rect:" mold read-rectangle]
	if tagid >= 67 [
		print [tabs "EdgeRect:" mold read-rectangle]
		flags: enbase/base read-byte 2
		print [tabs "Flags:" mold flags]
		;print [tabs "usesNonScalingStrokes:" 
		
	]
	parse-SHAPE/WITHSTYLE
	ind-
]

parse-SHAPE: func[/withstyle /local fills bits NumBits points b][
	if withstyle [
		parse-FILLSTYLEARRAY
		parse-LINESTYLEARRAY
	]
	NumBits: slice-bin/integers (enbase/base tag-bin-part 1 2) [4 4]
	print [tabs "NumFillBits:" NumBits/1]
	print [tabs "NumLineBits:" NumBits/2]
	bits: enbase/base copy tag-bin 2
	
	d-pos: 0x0	;drawing position
	points: make block! []
	add-point: func[x y][
		np: to-pair reduce [
			d-pos/1 + x
			d-pos/2 + y
		]
		append points np
		d-pos: np
	]
	while ["000000" <> copy/part bits 6 ][
		either bits/1 = #"0" [
			;STYLECHANGERECORD
			states: next copy/part bits 6 ;I skip the first bit (TypeFlag)
			print [tabs "States:" states]
			bits: skip bits 6
			if states/5 = #"1" [
				;Move bit count
				MoveBits: UB-to-int copy/part bits 5
				bits: skip bits 5
				print [tabs "MoveBits:" MoveBits]
				MoveDeltaX: SB-to-int copy/part bits MoveBits
				bits: skip bits MoveBits
				MoveDeltaY: SB-to-int copy/part bits MoveBits
				print [tabs "MoveX:" MoveDeltaX / 20]
				print [tabs "MoveY:" MoveDeltaY / 20]
				bits: skip bits MoveBits
				insert points d-pos: to-pair reduce [MoveDeltaX MoveDeltaY]
			]
			if states/4 = #"1" [
				;Fill style 0 change flag
				FillStyle0: UB-to-int copy/part bits NumBits/1
				bits: skip bits NumBits/1
				print [tabs "FillStyle0:" FillStyle0]
			]
			if states/3 = #"1" [
				;Fill style 1 change flag
				FillStyle1: UB-to-int copy/part bits NumBits/1
				bits: skip bits NumBits/1
				print [tabs "FillStyle1:" FillStyle1]
			]
			if states/2 = #"1" [
				;Line style change flag
				LineStyle: UB-to-int copy/part bits NumBits/2
				bits: skip bits NumBits/2
				print [tabs "LineStyle:" LineStyle]
			]
			if states/1 = #"1" [
				;New styles flag
				print "NEW STYLES"
				b: length? bits
				bits: refill-bits copy bits
				b: (length? bits) - b
				tag-bin: debase/base bits 2
				if b > 0 [tag-bin-part 1]
				parse-FILLSTYLEARRAY
				parse-LINESTYLEARRAY
				NumBits: slice-bin/integers (enbase/base tag-bin-part 1 2) [4 4]
				print [tabs "NumFillBits:" NumBits/1]
				print [tabs "NumLineBits:" NumBits/2]
				bits: enbase/base copy tag-bin 2
			]
		][
			;Edge Records
			bits: next bits
			Straight?: bits/1 = #"1"
			bits: next bits
			ind+
			NBits: 2 + UB-to-int copy/part bits 4
			bits: skip bits 4
			;print [tabs "NBits:" NBits]
				
			either Straight? [
				;StraightFlag
				print [tabs "StraightFlag"]
				LineFlag: bits/1
				bits: next bits
				either LineFlag = #"1" [
					DeltaX: SB-to-int copy/part bits NBits
					bits: skip bits NBits
					DeltaY: SB-to-int copy/part bits NBits
					bits: skip bits NBits
				][
					vertFlag?: #"1" = bits/1
					bits: next bits
					either vertFlag? [
						DeltaY: SB-to-int copy/part bits NBits
						DeltaX: 0
					][
						DeltaX: SB-to-int copy/part bits NBits
						DeltaY: 0
					]
					bits: skip bits NBits
				]
				print [tabs "X-Y:" DeltaX / 20 DeltaY / 20]
			][
				print [tabs "CurvedFlag"]
				CDeltaX: SB-to-int copy/part bits NBits
				bits: skip bits NBits
				CDeltaY: SB-to-int copy/part bits NBits
				bits: skip bits NBits
				add-point CDeltaX CDeltaY
				print [tabs "Control X-Y:" CDeltaX / 20 CDeltaY / 20 ]
				ADeltaX: SB-to-int copy/part bits NBits
				bits: skip bits NBits
				ADeltaY: SB-to-int copy/part bits NBits
				bits: skip bits NBits
				add-point ADeltaX ADeltaY
				print [tabs "Anchor  X-Y:" ADeltaX / 20 ADeltaY / 20 ]
			]
			;probe points
			ind-		
		]
	]
]
parse-FILLSTYLEARRAY: func[/local fills type color i][
	print [tabs "FillStyleCount:" fills: get-count ]
	if fills > 0 [
		ind+
		loop fills [
			print [tabs "FillStyleType:" type: tag-bin-part 1]
			if type = #{00} [
				color: tag-bin-part either tagid >= 32 [4][3]
				print [tabs "Color:" color]
			]
			if found? find #{1012} type [
				print [tabs "Gradient matrix:" ] parse-matrix
				print [tabs "NumGradients:" i: to-integer tag-bin-part 1]
				loop i [
					print [tabs "Ratio:" to-integer tag-bin-part 1]
					print [tabs "Color:" to-tuple tag-bin-part either tagid >= 32 [4][3]]
				]
			]
			if found? find #{40414243} type [
				print [tabs switch type [
					#{40} ["tiled"]
					#{41} ["clipped"]
					#{42} ["no sm. tiled"]
					#{43} ["no sm. clipped"]
				] "bitmap" tag-bin-part/rev 2]
				print [tabs "Bitmap matrix:" ] parse-matrix
			]
		]
		ind-
	]
]
parse-LINESTYLEARRAY: func[][
	print [tabs "LineStyleCount:" lines: get-count ]
	if tag-bin/1 > 0 [
		ind+
		loop lines [parse-LINESTYLE]
		ind-
	]
]
parse-LINESTYLE: func[/local width rgb flags][
	width: bin-to-int tag-bin-part 2
	if tagid >= 67 [
		flags: enbase/base tag-bin-part 2 2
		print [tabs "Flags:" mold flags]
	]
	rgb: tag-bin-part either tagid >= 32 [4][3]
	print [tabs "width:" width "RGB:" rgb]
]

parse-ScriptLimits: func[][
	ind+
	print "";tag-bin
	print [tabs "MaxRecursionDepth:" read-short]
	print [tabs "ScriptTimeoutSeconds:" read-short]
	ind-
]

parse-SetTabIndex: func[][
	ind+
	print "";tag-bin
	print [tabs "id:" read-short]
	print [tabs "index:" read-short]
	ind-
]

parse-CSMTextSettings: func[/local flags][
	ind+
	print tag-bin
	print [tabs "id:" read-short]
	flags: read-short
	
	print [tabs "Type:" pick ["System" "Internal Flash Type"] 1 + (3 and to-integer (flags / 64))]
	print [tabs "Grid aligment:" pick ["no" "pixel" "1/3pixel (LCD displays)"] 1 + (7 and to-integer (flags / 8))]
	print [tabs "thickness:" read-longFloat]
	print [tabs "sharpness:" read-longFloat]
	
	ind-
]

parse-DefineSceneAndFrameLabelData: has[n scenes][
	ind+
	scenes: copy []
	n: read-short
	loop n [
		append scenes read-string
		append scenes read-U30integer
	]
	print [tabs "scenes/frames:" mold scenes]
	ind-
]

ConstantPool: make block! []

parse-ActionRecord: func[bin-data /init /local vals cp str pstr word dec reg logic i32 ofs undefined data codesize unknown][
	ind+
	;probe bin-data
	if init [
		print [tabs "For sprite:" copy/part bin-data 2]
		bin-data: skip bin-data 2
	]
	actions: make block! []
	aparsers: [
		"aGetURL" [
			print [tabs aname mold parse/all data "^@"]
		]
		"aConstantPool" [
			clear ConstantPool
			parse/all data [
				2 skip
				any [copy val to "^@" 1 skip (insert tail ConstantPool val)]
			]
			print [tabs aname mold ConstantPool]
		]
		"aIf" [
			ofs: sb-to-int data
			either ofs < 0 [
				print [tabs aname data "(" ofs ")"]
			][ 
				print [tabs aname]
				parse-ActionRecord bin-part ofs
			]
		]
		"aDefineFunction" [
			vals: make block! []
			set [data codeSize] slice-bin data reduce [(length? data) - 2 2]
			parse/all data [str word any [str]]
			print [tabs aname rejoin [vals/1 mold skip vals 2] mold codeSize]
			parse-ActionRecord bin-part bin-to-int codeSize
		]
		"aDefineFunction2" [
			vals: make block! []
			use [name tmp NumParams RegisterCount flags params unknown reg par Suppress][
				parse/all data [copy name to #"^@" 1 skip data: to end]
				data: as-binary data
				print [tabs aname actionid name]
				set [NumParams RegisterCount flags] slice-bin data reduce [2 1 2]
				data: skip data 5
				NumParams: to-integer reverse NumParams
				RegisterCount: to-integer RegisterCount
				flags: enbase/base as-binary flags 2

				params: make block! 20
				Suppress: make block! 3
				
				;probe as-binary data
				if #"1" = flags/1 [
					;print "Preload _parent into register"
					insert params [0 "_parent"]
				]
				if #"1" = flags/2 [
					;print "Preload _root into register"
					insert params [0 "_root"]
				]
				if #"1" = flags/3 [
					;print "Don't create super variable"
					append Suppress "super"
				]
				if #"1" = flags/4 [
					;print "Preload 'super' into register"
					insert params [0 "super"]
				]
				if #"1" = flags/5 [
					;print "Don't create 'arguments' variable"
					append Suppress "arguments"
				]
				if #"1" = flags/6 [
					;print "Preload 'arguments' into register"
					insert params [0 "arguments"]
				]
				if #"1" = flags/7 [
					;print "Don't create 'this' variable"
					append Suppress "this"
				]
				if #"1" = flags/8 [
					;print "Preload 'this' into register"
					insert params [0 "this"]
				]
				if #"1" = flags/16 [
					;print "Preload _global into register"
					insert params [0 "_global"]
				]
				
	
				;probe as-binary data
				
				
				loop NumParams [
					parse/all data [
						copy reg 1 skip
						copy par to "^@" 1 skip
						(repend params [to-integer as-binary reg to-string par])
						data: to end
					]
				]
				;parse/all data [copy codeSize 2 skip (codeSize: bin-to-int codeSize) to end]
				codeSize: bin-to-int copy/part data 2
				print [tabs "|_ NumParams:" NumParams "RegisterCount:" RegisterCount "Flags:" flags "codeSize:" codeSize]
				print [tabs "\_ PARAMS:" mold params "Suppress:" mold Suppress]
			]
			parse-ActionRecord bin-part codeSize
		]
		"aPush" [
			vals: make block! []
			parse/all data [some [cp | i32 | dec | pstr | logic | reg | null | undefined]]
			print [tabs aname mold vals]
		]
	]
	cp: ["^H" copy v 1 skip
		(append vals rejoin ["CP:" pick ConstantPool v: 1 + str-to-int v])
	]
	i32: ["^G" copy v 4 skip
		(append vals v: str-to-int v)
	]
	pstr: ["^@" copy v to "^@" 1 skip
		(append vals v)
	]
	logic: ["^E" copy v 1 skip
		(append vals pick [false true] 1 + str-to-int v)
	]
	null: ["^B" ( append vals 'null )]
	undefined: ["^C" (append vals 'undefined )]
	dec: ["^F" copy v 8 skip
		(append vals from-ieee64/flash as-binary v)
	]
	reg: ["^D" copy v 1 skip
		(append vals to-path join "register/" str-to-int v)
	]
	str: [copy v to "^@" 1 skip (append vals v) ]
	word: [copy v 2 skip (append vals str-to-int v)	]
	
	actionid: none
	bin-part: func[bytes][b: copy/part bin-data bytes bin-data: skip bin-data bytes b]
	while [all [actionid <> #{00} not empty? bin-data] ][
		actionid: bin-part 1
		length: to-integer either actionid > #{80} [reverse bin-part 2][0]
		data: bin-part length
		aname: select actionids actionid
		switch/default aname aparsers [
			print [tabs aname actionid]
		]
	]
	ind-
]
actionids: make hash! [
	#{00} "END of aRecord"
	;SWF3 as
	#{04} "aNextFrame"
	#{05} "aPrevFrame"
	#{06} "aPlay"
	#{07} "aStop"
	#{08} "aToggleQuality"
	#{09} "aStopSounds"	
	#{81} "aGotoFrame"
	#{83} "aGetURL"
	#{8A} "aWaitForFrame"
	#{8B} "aSetTarget"
	#{8C} "aGoToLabel"
	;Stack Operations
	#{96} "aPush"
	#{17} "aPop"
	;Arithmetic Operators
	#{0A} "aAdd"
	#{0B} "aSubtract"
	#{0C} "aMultiply"
	#{0D} "aDivide"
	;Numerical Comparison
	#{0E} "aEquals"
	#{0F} "aLess"
	;Logical Operators
	#{10} "aAnd"
	#{11} "aOr"
	#{12} "aNot"
	;String Manipulation
	#{13} "aStringEquals"
	#{14} "aStringLength"
	#{21} "aStringAdd"
	#{15} "aStringExtract"
	#{29} "aStringLess"
	#{31} "aMBStringLength"
	#{35} "aMBStringExtract"
	;Type Conversion
	#{18} "aToInteger"
	#{32} "aCharToAscii"
	#{33} "aAsciiToChar"
	#{36} "aMBCharToAscii"
	#{37} "aMBAsciiToChar"
	;Control Flow
	#{99} "aJump"
	#{9D} "aIf"
	#{9E} "aCall"
	;Variables
	#{1C} "aGetVariable"
	#{1D} "aSetVariable"
	;Movie Control
	#{9A} "aGetURL2"
	#{9F} "aGotoFrame2"
	#{20} "aSetTarget2"
	#{22} "aGetProperty"
	#{23} "aSetProperty"
	#{24} "aCloneSprite"
	#{25} "aRemoveSprite"
	#{27} "aStartDrag"
	#{28} "aEndDrag"
	#{8D} "aWaitForFrame2"
	;Utilities
	#{26} "aTrace"
	#{34} "aGetTime"
	#{30} "aRandomNumber"
	;SWF 5
	;ScriptObject as
	#{3D} "aCallFunction"
	#{52} "aCallMethod"
	#{88} "aConstantPool"
	#{9B} "aDefineFunction"
	#{3C} "aDefineLocal"
	#{41} "aDefineLocal2"
	#{43} "aDefineObject" ;this was not in the specification!
	#{3A} "aDelete"
	#{3B} "aDelete2"
	#{46} "aEnumerate"
	#{49} "aEquals2"
	#{4E} "aGetMember"
	#{42} "aInitArray/Object"
	#{53} "aNewMethod"
	#{40} "aNewObject"
	#{4F} "aSetMember"
	#{45} "aTargetPath"
	#{94} "aWith"
	;Type as
	#{4A} "aToNumber"
	#{4B} "aToString"
	#{44} "aTypeOf"
	;Math as
	#{47} "aAdd2"
	#{48} "aLess2"
	#{3F} "aModulo"
	;Stack Operator as
	#{60} "aBitAnd"
	#{63} "aBitLShift"
	#{61} "aBitOr"
	#{64} "aBitRShift"
	#{65} "aBitURShift"
	#{62} "aBitXor"
	#{51} "aDecrement"
	#{50} "aIncrement"
	#{4C} "aPushDuplicate"
	#{3E} "aReturn"
	#{4D} "aStackSwap"
	#{87} "aStoreRegister"
	
	;flashMX as
	#{54} "aInstanceOf"
	#{55} "aEnumerate2"
	#{66} "aStrictEqual"
	#{67} "aGreater"
	#{68} "aStringGreater"
	#{69} "aExtends"
	
	;flashMX2004 as ( guessing )
	#{2A} "aThrow"
	#{2B} "aCastOp"
	#{2C} "aImplementsOp"
	#{8E} "aDefineFunction2"
	#{8F} "aTry"
]

parse-Action3StartupClass: func[][
	ind+
	parse/all tag-bin [
		copy id 4 skip (id: to-integer reverse to-binary id)
		copy frame to #"^@" 1 skip
	]
	print [newline tabs "AS3id:" id]
	print [tabs "AS3frame:" frame]	
	ind-
]
parse-Action3Record: func[/withClass /local id frame abc][
	ind+
	either withClass [
		parse/all tag-bin [
			copy id 4 skip (id: to-integer reverse to-binary id)
			copy frame to #"^@" 1 skip
			copy abc to end
		]
		print [newline tabs "AS3id:" id]
		print [tabs "AS3frame:" frame]	
	][
		abc: copy tag-bin
	]

	;probe abc
	write/binary join rswf-root-dir %tmp.abc abc
	error? try [
		call/wait rejoin [ to-local-file rswf-root-dir/bin/abcdump.exe " " to-local-file rswf-root-dir/tmp.abc]
		print read rswf-root-dir/tmp.abc.il
	]
	
	ind-
]

parse-swf-header: func[/local sig nbits rect version length tmp][
	sig: stream-part 3
	either sig <> #{465753} [
		either sig = #{435753} [
			print ["This file is compressed Flash MX file!"]
			swf/header/version: to-integer stream-part 1
			swf/header/length: to-integer stream-part/rev 4
			tmp: copy swf-stream
			error? try [close swf-stream]
			if all [
				error? try [swf-stream: copy to-binary decompress tmp]
				error? try [swf-stream: copy to-binary zlib/decompress/l tmp (swf/header/length + 100)]
			][
				print "Cannot decompress the data:("
				halt
			]
		][
			print "Illegal swf header!"
			close swf-stream
			halt
		]
		
	][
		swf/header/version: to-integer stream-part 1
		swf/header/length: to-integer stream-part/rev 4
	]
	swf-buff: stream-part 1
	nbits: to-integer debase/base (refill-bits copy/part (enbase/base swf-buff 2) 5) 2
	insert tail swf-buff stream-part (((extend-int (5 + (4 * nbits))) / 8) - 1)
	rect: slice-bin (skip enbase/base swf-buff 2 5) reduce [nbits nbits nbits nbits]
	forall rect [rect/1: SB-to-int rect/1]
	swf/header/frame-size: head rect
	swf/header/frame-rate: to-integer stream-part 2
	swf/header/frame-count: to-integer stream-part/rev 2
]

foreach-tag: func[bin action /local t][
	bind action 'tag
	while [not tail? bin][
		t: copy/part bin 2
		bin: skip bin 2
		set [tag length] slice-bin (enbase/base (reverse t) 2) [10 6]
		tag:    to-integer debase/base refill-bits tag 2
		length: to-integer debase/base refill-bits length 2
		;print [tag length]
		if length = 63 [length: to-integer reverse copy/part bin 4 bin: skip bin 4]
		data: copy/part bin length
		bin: skip bin length
		do action
	]
]


stream-part: func[bytes /rev /twips "Converts the result to number in twips" /local tmp][
	tmp: copy/part swf-stream bytes
	if binary? swf-stream [swf-stream: skip swf-stream bytes]
	either rev [
		reverse tmp
	][	either twips [(to-integer reverse tmp) / 20][tmp]]
]

foreach-stream-tag: func[ action /local t rh-length][
	bind action 'rh-length
	while [all [not none? t: stream-part 2 not empty? t]][
		rh-length: 2
		set [tag length] slice-bin (enbase/base (reverse t) 2) [10 6]
		tag:    to-integer debase/base refill-bits tag 2
		length: to-integer debase/base refill-bits length 2
		if length = 63 [rh-length: 6 length: to-integer stream-part/rev 4]
		data: either length > 0 [copy stream-part length][make binary! 0 ]
		do action
	]
]

show-info: make block! [
	tagid: tag
	use [ta][
		ta: select swf-tags tag
		either found? ta [
			prin rejoin [tabs ta/1 "(" tagid "): "]
			either none? ta/2 [
				print [tag length data]
			][
				setStreamBuffer data
				do ta/2
			]
		][
			print [tabs tag length data]
		]
	]
	;if tag = 12 [parse-ActionRecord data]
]

sysprint: get in system/words 'print
sysprin: get in system/words 'prin


open-swf-stream: func[swf-file [file! url! string!] "the SWF source file" /local f][
	if string? swf-file [swf-file: to-rebol-file swf-file]
	swf: make object! [
		header: make object! [
			version: none
			length: none
			frame-size: make block! []
			frame-rate: none
			frame-count: none
		]
		rect: none
		data: make block! 10
	]
	if none? swf-file [
		swf-file: either empty? swf-file: ask "SWF file:" [%new.swf][
			either "http://" = copy/part swf-file 7 [to-url swf-file][to-file swf-file]
		]
	]
	if not exists? swf-file [
		f: join swf-file ".swf"
		either exists? f [swf-file: f][print ["Cannot found the file" swf-file "!"]]
	]
	open/direct/read/binary swf-file
]

set 'extract-swf-tags func[
	"Returns block of specified SWF tags"
	swf-file [file! url! string!] "the SWF source file"
	tagids [block!] "Tag IDs to extract"
	/local result
][
	result: make block! 1000
	setStreamBuffer swf-stream: open-swf-stream swf-file
	if error? err: try [
		prin "Extractings SWF tags... "
		parse-swf-header
		print "-------------------------"
		foreach-stream-tag [
			if find tagids tag [
				print [tag length]
				repend result [tag data]
			]
		]
	][
		if port? swf-stream [close swf-stream]
		throw err
	]
	if port? swf-stream [close swf-stream]
	result
]

set 'exam-swf func[
	"Examines SWF file structure"
	/file swf-file [file! url! string!] "the SWF source file"
	/quiet "No visible output"
	/into out-file [file!]
	/store "If you want to store parsed tags in the swf/data block"
	/local info err
][
	if all [file string? swf-file][swf-file: to-rebol-file swf-file]
	;--------[ global variables ]----------
	obj-id: 0
	indent: 0

	swf-stream: open-swf-stream swf-file
	
	if quiet [
		prin: print: func[str][reduce str]
	]
	if into [
		out-file: open/new/write out-file
		prin: func[str][
			insert tail out-file reform str
		]
		print: func[str][
			prin join reform str newline
		]
	]
	if error? err: try [
		prin "Searching the binary file... "
		parse-swf-header
		print "-------------------------"
		probe swf/header
		info: make block! either store [[repend/only swf/data [tag length data]]][[]]
		foreach-stream-tag append info show-info
		print: :sysprint
		prin: :sysprin
	][
		print: :sysprint
		prin: :sysprin
		if port? swf-stream [close swf-stream]
		throw err
	]
	if port? swf-stream [close swf-stream]
	error? try [close out-file]
	swf
]





