rebol [
	title: "SWF sound related parse functions"
	purpose: "Functions for parsing sound related tags in SWF files"
]

	parse-DefineSound: does [
		reduce [
			readID       ;soundid
			readUB 4     ;SoundFormat
			readUB 2     ;SoundRate
			readBitLogic ;SoundSize
			readBitLogic ;SoundType
			readUI32     ;SoundSampleCount
			readRest     ;SoundData
		]
	]

;## StartSound is a control tag that either starts (or stops) playing a sound defined by DefineSound.	
	parse-StartSound: does [
		reduce [
			readUsedID
			readSOUNDINFO
		]
	]
	parse-StartSound2: does [
		reduce [
			as-string readString ;SoundClassName
			readSOUNDINFO
		]
	]
	parse-SoundStreamHead: does [
		reduce [
			(readUB 4 none) ;reserved
			readUB 2 ;PlaybackSoundRate
			readBitLogic ;PlaybackSoundSize
			readBitLogic ;PlaybackSoundType
			StreamSoundCompression: readUB 4
			readUB 2 ;StreamSoundRate
			readBitLogic ;StreamSoundSize
			readBitLogic ;StreamSoundType
			readUI16 ;StreamSoundSampleCount
			either StreamSoundCompression = 2 [readSI16][none]
		]
	]
	
	parse-SoundStreamBlock: does [
		reduce [
			
			switch/default StreamSoundCompression [
				2 [ readMP3STREAMSOUNDDATA ]
			][ readRest ]
		]
	]

	readMP3STREAMSOUNDDATA: does [
		reduce [
			StreamSoundCompression
			readUI16 ;SampleCount
			readMP3SOUNDDATA
		]
	]
	readMP3SOUNDDATA: does [
		reduce [
			readSI16 ;SeekSamples
			readMP3FRAMEs
		]
	]
	readMP3FRAMEs: has[frames MpegVersion Layer Bitrate SamplingRate sampleDataSize][
		frames: copy []
		while [not tail? inBuffer][
			repend frames [
				readUB 11    ;Syncword
				MpegVersion: readUB 2
				Layer:       readUB 2
				readBitLogic ;ProtectionBit
				(
					Bitrate:      readUB 4
					SamplingRate: readUB 2     ;SamplingRate
					PaddingBit:  readBit
					readBit      ;Reserved
					readUB 2     ;ChannelMode
				)
				readUB 2     ;ModeExtension
				readBitLogic ;Copyright
				readBitLogic ;Original
				readUB 2     ;Emphasis
				Bitrate:      transMP3Bitrate Layer MpegVersion Bitrate
				SamplingRate: transMP3SamplingRate  MpegVersion SamplingRate
				(
					sampleDataSize: to integer! either MpegVersion = 3 [ ;version 1
						((( either Layer = 3 [48000][144000]) * Bitrate) / SamplingRate) + PaddingBit  - 4
					][
						((( either Layer = 3 [24000][72000]) * Bitrate) / SamplingRate) + PaddingBit - 4
					]
					readBytes sampleDataSize
				)
			]
		]
		frames
	]
	
	transMP3Bitrate: func[Layer MpegVersion Bitrate][
		;print ["transMP3Bitrate:" Layer MpegVersion Bitrate]
		pick (switch Layer either MpegVersion = 3 [[
			3 [[32 64 96 128 160 192 224 256 288 320 352 384 416 448]]
			2 [[32 48 56  64  80  96 112 128 160 192 224 256 320 384]]
			1 [[32 40 48  56  64  80  96 112 128 160 192 224 256 320]]
		]][[
			3 [[32 48 56  64  80  96 112 128 144 160 176 192 224 256]]
			2 [[ 8 16 24  32  40  48  56  64  80  96 112 128 144 160]]
			1 [[ 8 16 24  32  40  48  56  64  80  96 112 128 144 160]]
		]]) Bitrate
	]
	transMP3SamplingRate: func[MpegVersion SamplingRate][
		;print ["transMP3SamplingRate:" MpegVersion SamplingRate]
		pick switch MpegVersion [
			3 [[44100 48000 32000 "--"]]
			2 [[22050 24000 16000 "--"]]
			0 [[11025 12000 8000  "--"]]
		] (1 + SamplingRate)
	]
	
	readSOUNDINFO: has[HasEnvelope? HasLoops? HasOutPoint? HasInPoint?][
		reduce [
			(readUB 2 none) ;reserved
			readBitLogic    ;SyncStop
			readBitLogic    ;SyncNoMultiple
			(
				HasEnvelope?: readBitLogic
				HasLoops?:    readBitLogic
				HasOutPoint?: readBitLogic
				HasInPoint?:  readBitLogic
				either HasInPoint? [readUI32][none]
			)
			either HasOutPoint? [readUI32][none]
			either HasLoops?    [readUI16][none]
			either HasEnvelope? [readSOUNDENVELOPE][none]
		]
	]
	readSOUNDENVELOPE: does [
		result: copy []
		loop readUI8 [
			insert tail result reduce [
				readUI32 ;Pos44
				readUI16 ;LeftLevel
				readUI16 ;RightLevel
			]
		]
		result
	]