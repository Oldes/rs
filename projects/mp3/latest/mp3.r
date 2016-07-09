REBOL [
    Title: "MP3 stream parser"
    Name:  "mp3-stream-parser"
    Date: 1-Apr-2009/21:10:30+2:00
	File: %mp3-stream-parser.r
    Version: 1.0.0
    Home: http://box.lebeda.ws/~hmm/rebol/mp3.html
    Author: "Oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: [
		;to get just a part of MP3 file:
			mp3/open %Electric_Bazar_Cie-America.mp3
			write/binary %test.mp3 mp3/get-sample-of-length 0:0:4.5
			;you can continue to read other samples here...
			;...and close the stream if you don't need it
			mp3/close
		;to go thru complete file and parse it:
			mp3/parse/file %test.mp3
			print [
				"Frames total:" mp3/num_frames
				"^/Duration:    " to-time mp3/duration
			]
	]
    Purpose: {MP3 parser with streaming input}
    Comment: none
    History: none
    Language: none
    Type: none
    Content: none
    Email: oliva.david@seznam.cz
	library: [
        level: [intermediate advanced] 
        type: 'tool 
        domain: 'file-handling 
        platform:     'all
		tested-under: none
		support:      none
		license:      'public-domain
		see-also:     none
    ]
]

;### MP3
MP3: context [
	inBuffer: outBuffer:
	MP3-port: ID3v2: ID3v1: frame:
	MP3FrameHeader:
	continue?: none
	num_frames: duration: 0
	
	headers: make hash! [] ;used to cache parsed mp3 frame headers

;## Functions used to read data from input stream
	seekToBuffer: func[bytes /local new][
		either any [
			none? inBuffer
			tail? inBuffer
		][
			inBuffer: copy/part MP3-port bytes
			;print "seekToBuffer <-complete"
		][
			inBuffer: remove/part head inBuffer (-1 + index? inBuffer)
			if all [
				0 < bytes: (bytes - length? inBuffer)
			;	bytes > 8192 
			][
				if new: copy/part MP3-port bytes [
					insert tail inBuffer new
					;print ["seekToBuffer <-only" bytes]
				]
			]
		]
		inBuffer
	]
	checkBufferSize: func[bytes][
		if bytes > length? inBuffer [
			;print "Refilling inBuffer"
			seekToBuffer bytes
		]
		bytes
	]
	skipBytes: func[nbytes][inBuffer: skip inBuffer nbytes]
	readBytes: func[nbytes][
		copy/part inBuffer
			inBuffer: skip inBuffer nbytes
	]
	
	readBytesRev: func[nbytes][
		head reverse
			copy/part inBuffer
				inBuffer: skip inBuffer nbytes
	]
	readUI8:   has[i][i: first inBuffer inBuffer: next inBuffer i]
	readUI16:  does[to integer! readBytesRev 2]
	readUI32:  does[to integer! readBytesRev 4]

	readSynchSafeInt: does [
		((readUI8 and 127) * 2097152)+
		((readUI8 and 127) * 16384)+
		((readUI8 and 127) * 128)+
		( readUI8 and 127)
	]
	readID3v1: does [
		checkBufferSize 128
		ID3v1: context [
			Type: 1
			Title:   as-string  trim/with readBytes 30 #"^(00)"
			Artist:  as-string  trim/with readBytes 30 #"^(00)"
			Album:   as-string  trim/with readBytes 30 #"^(00)"
			Year:    to-integer as-string  readBytes 4
			Comment: as-string  trim/with readBytes 30 #"^(00)"
			Gendre:  readUI8
		]
	]
	readID3v2: does [
		;http://www.id3.org/id3v2.4.0-structure
		ID3v2: context [
			Type: 2
			Version:           readUI16
			Flags:             readUI8
			Header:            readBytes checkBufferSize readSynchSafeInt ;<-not parsed yet
			Extended: (
				either (flags and 64) [
					print "has extended header!"
					readBytes checkBufferSize readSynchSafeInt
				][ none ]
			)
		]
	]
	readMP3FrameHeader: has[hdrb hdr ][
		hdrb: next copy/part inBuffer 4
		unless MP3FrameHeader: select headers hdrb [
			probe hdr: to integer! hdrb
			if 14680064 = (14680064 and hdr) [
				probe MP3FrameHeader: context [
					MpegVersion: shift (1572864 and hdr) 19
					Layer:       shift (393216  and hdr) 17
					;Protected?: shift (65536   and hdr) 16
					Bitrate: pick (switch layer either MpegVersion = 3 [[
						3 [[32 64 96 128 160 192 224 256 288 320 352 384 416 448]]
						2 [[32 48 56  64  80  96 112 128 160 192 224 256 320 384]]
						1 [[32 40 48  56  64  80  96 112 128 160 192 224 256 320]]
					]][[
						3 [[32 48 56  64  80  96 112 128 144 160 176 192 224 256]]
						2 [[ 8 16 24  32  40  48  56  64  80  96 112 128 144 160]]
						1 [[ 8 16 24  32  40  48  56  64  80  96 112 128 144 160]]
					]]) shift (61440 and hdr) 12
					SamplingRate: pick switch MpegVersion [
						3 [[44100 48000 32000 none]]
						2 [[22050 24000 16000 none]]
						0 [[11025 12000 8000  none]]
					] (1 + (shift (3072 and hdr) 10))
				
					PaddingBit:  shift (512 and hdr) 9
			
					sdsize: to integer! either MpegVersion = 3 [ ;version 1
						((( either layer = 3 [48000][144000]) * Bitrate) / SamplingRate) + PaddingBit
					][
						((( either layer = 3 [24000][72000]) * Bitrate) / SamplingRate) + PaddingBit
					]
				]
				repend headers [hdrb MP3FrameHeader]
			]
		]
		
		MP3FrameHeader
	]
	
;## main functions	
	open: func["Opens MP3 file for parsing" MP3-file [file! url!]][
		close ;<- try to close still opened previous port
		MP3Header: ID3v2: ID3v1: frame: none
		num_frames: duration: 0
		inBuffer:  make binary! 100 * 1024
		outBuffer: make binary! 100 * 1024
		MP3-port: system/words/open/read/binary/direct MP3-file
		seekToBuffer 50480
	]
	close: does [
		clear headers
		error? try [system/words/close MP3-port]
	]

	parse: func[
		"Parses MP3 file and prints info about it's content"
		/file MP3-file [file! url!]
	][
		continue?: true
		if file [open MP3-file]
		while [all [continue? inBuffer]][
			either all [
				255 = first inBuffer
				224 < second inBuffer
			][
				on-read-MP3Frame readMP3FrameHeader
			][
				switch/default as-string readBytes 3 [
					"ID3" [ on-read-ID3 readID3v2]
					"TAG" [ on-read-ID3 readID3v1]
				][
					ask "UNKNOWN TAG?"
				]
			]
			if all [continue? 5048 > length? inBuffer] [
				seekToBuffer 50480
			]
		]
		close
		true
	]

;## parse events
	on-read-MP3Frame: func[hdr][
		num_frames: num_frames + 1
		duration: duration + (1152 / hdr/SamplingRate)
		;? hdr
		skipBytes hdr/sdsize
	]
	on-read-ID3: func[id3][
		?? id3
	]
	
;## get-sample-of-length
	get-sample-of-length: func[timeLength [time!] /since startTime [time!] /local hdr endTime][
		clear outBuffer
		startTime: either since [to decimal! startTime][duration]
		endTime:   startTime + to-decimal timeLength
		while [inBuffer][
			either all [
				255 = first inBuffer
				224 < second inBuffer
			][
				hdr: readMP3FrameHeader
				either startTime <= duration [
					either endTime >= duration: duration + (1152 / hdr/SamplingRate) [
						insert tail outBuffer readBytes hdr/sdsize
					][
						break
					]
				][
					duration: duration + (1152 / hdr/SamplingRate)
					skipBytes hdr/sdsize
				]
			][
				switch/default as-string copy/part inBuffer 3 [
					"ID3" [ skipBytes 3  readID3v2]
					"TAG" [ skipBytes 3  readID3v1]
				][	inBuffer: next inBuffer]
			]
			if 5048 > length? inBuffer [
				seekToBuffer 50480
			]
		]
		outBuffer
	]
]

