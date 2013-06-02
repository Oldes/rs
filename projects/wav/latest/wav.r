REBOL [
    Title: "Wav"
    Date: 28-Feb-2011/11:21:33+1:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "Oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: none
    Purpose: none
    Comment: none
    History: none
    Language: none
    Type: none
    Content: none
    Email: none
	require: [
		rs-project %stream-io
	]
]
system/options/binary-base: 32
ctx-wav: make stream-io [
	wav-port: none
	wav-data-size: 0
	wav-Format: none
	
	readRIFFTypeChunk: does [
		context [
			id:    as-string readBytes 4
			size:  readUI32
			type:  as-string readBytes 4
		]
	]
	readWAVFormat: does [
		context [
			compression:   readUI16
			channels:      readUI16
			sampleRate:    readUI32
			bytesPerSec:   readUI32
			blockAlign:    readUI16
			bitsPerSample: readUI16
			extraBytes: readBytes readUI16
		]
	]
	readCUEPoint: does [
		context [
			id:            readUI32 ;unique identification value
			position:      readUI32 ;play order position
			data-id:       as-string readBytes 4 ;RIFF ID of corresponding data chunk
			chunk-start:   readUI32 ;Offset of Data Chunk *
			block-start:   readUI32 ;Offset to sample of First Channel
			sample-offset: readUI32 ;Byte Offset to sample byte of First Channel
		]
	]
	readLabelChunk: does [
		context [
			data-size: readUI32
			cue-id: readUI32
			text:   as-string readBytes (data-size - 4)
		]
	]
	seekToBuffer: func[bytes][
		;print ["seekToBuffer bytes" bytes]
		setStreamBuffer copy/part wav-port bytes
		wav-port: skip wav-port bytes
		inBuffer
	]
	open: func["Reads WAV file into buffer" wav-file [file! url!]][
		WAVHeader: none
		probe wav-file
		wav-port: system/words/open/read/binary/seek wav-file
		seekToBuffer 20
		
	]
	parse: func[
		"Parses AVI file and prints info about it's content"
		wav-file [file! url!]
		/local tmp ChunkID ChunkSize subChunkID size 
	][
		open wav-file
		probe tmp: readRIFFTypeChunk
		either all [tmp/id = "RIFF" tmp/type = "WAVE"][
			probe tail? inBuffer
			while [not tail? inBuffer][
				
				probe id:   as-string readBytes 4
				seekToBuffer size: readUI32
				switch id [
					"fmt " [
						probe wav-Format: readWAVFormat
					]
					"data" [
						print ["size:   " size]
						print ["samples:" size / (wav-Format/bitsPerSample / 8)]
						skipBytes size
					]
					"cue " [
						print ["CUE:"]
						loop readUI32 [
							probe readCUEPoint
						]
					]
					"LIST" [
						print ["LIST:" size]
						;probe as-string readBytes size
						if #{6164746C} = readBytes 4 [ ;adtl
							probe as-string inBuffer
							while [#{6C61626C} = probe readBytes 4][ ;labl
								probe readLabelChunk
							]
						]
					]
				][
					skipBytes size
				]
				seekToBuffer 8
			]
		][
			close wav-port
			make error! ["Not a WAV file!" wav-file]
		]
		close wav-port
	]
]