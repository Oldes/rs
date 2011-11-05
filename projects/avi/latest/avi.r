REBOL [
    Title: "AVI (RIFF) parser"
    Date: 9-Nov-2007/11:19:55+1:00
    Name: none
    Version: 0.1.0
    File: none
    Home: none
    Author: "Oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: [
    	avi/parse to-rebol-file "I:\movies\co_se_deje_v_trave\Termit.avi"
	]
    Purpose: none
    Comment: none
    History: [
    	0.1.0 [9-Nov-2007 "oldes" {First version... just prints info about AVI file}]
	]
    Language: none
    Type: none
    Content: none
    Email: oliva.david@seznam.cz
    require: [
    	rs-project 'stream-io 'latest ;1.0.0
	]
	preprocess: true
]

if error? try [stream-io][do http://box.lebeda.ws/~hmm/rebol/stream-io_latest.r]

AVI: make stream-io [
	#include %RIFFAudioFormatTags.r
	avi-port: none
	AVImainHeader:
	AVIstreamHeader:
	BITMAPINFOHEADER:
	WAVEFORMATEX:
	riff-size: none
	
	seekToBuffer: func[bytes][
		;print ["seekToBuffer bytes" bytes]
		setStreamBuffer copy/part avi-port bytes
		avi-port: skip avi-port bytes
		inBuffer
	]
	open: func["Reads AVI file into buffer" avi-file [file! url!]][
		AVImainHeader: AVIstreamHeader: none
		probe avi-file
		avi-port: system/words/open/read/binary/seek avi-file
		seekToBuffer 20
	]
	alignSize: func[size /local r][
		either 0 = r: size // 2 [size][size + 2 - r]
	]
	readRIFFList: does [
		context [
			size: readUI32
			type: as-string readBytes 4
			data: readBytes (size - 4)
		]
	]
	readAVImainHeader: does [
		AVImainHeader: context[
			size:                readUI32
			MicroSecPerFrame:    readUI32
	    	MaxBytesPerSec:      readUI32
	    	PaddingGranularity:  readUI32
	    	Flags:               readBytes 4
	    	TotalFrames:         readUI32
	    	InitialFrames:       readUI32
	    	Streams:             readUI32
	    	SuggestedBufferSize: readUI32
	    	Width:               readUI32
	    	Height:              readUI32
	    	Reserved:            readBytes 16
    	]
	]
	readAVIstreamHeader: does [
		AVIstreamHeader: context [
			size:                readUI32
			Type:      as-string readBytes 4
     		Handler:   as-string readBytes 4
     		Flags:               readBytes 4
     		Priority:            readUI16
     		Language:            readUI16
     		InitialFrames:       readUI32
     		Scale:               readUI32
     		Rate:                readUI32
     		Start:               readUI32
     		Length:              readUI32
     		SuggestedBufferSize: readUI32
     		Quality:             readUI32
     		SampleSize:          readUI32
     		rcFrame:             readRcFrame
		]
	]
	readRcFrame: does [context [
			left:   readUI16
			top:    readUI16
			right:  readUI16
			bottom: readUI16
	]]
	readBITMAPINFOHEADER: does [
		BITMAPINFOHEADER: context [
			size:           readUI32
			Width:          readUI32
			Height:	        readUI32
			Planes:         readUI16
			BitCount:       readUI16
			Compression: as-string readBytes 4 
			SizeImage:	    readUI32
			XPelsPerMeter:	readUI32
			YPelsPerMeter:	readUI32 
			ClrUsed:		readUI32
			ClrImportant:	readUI32
		]
	]
	readWAVEFORMATEX: does [
		WAVEFORMATEX: context [
			wFormatTagID:    head reverse readBytes 2
            wFormatTagStr:   select RIFFAudioFormatTags wFormatTagID
			nChannels:       readUI16
			nSamplesPerSec:  readUI32 
  			nAvgBytesPerSec: readUI32
  			nBlockAlign:     readUI16
  			wBitsPerSample:  readUI16
  			cbSize:          readUI16
  			extra:           readBytes cbSize	
		]
	]
    readVIDEOFIELDDESCs: has[result][
    	result: copy []
    	loop readUI32 [
    		append result context [
 ;The compressed bitmap height and width represent the size of the compressed image. For JPEG, these values are multiples of 8
    			CompressedBMHeight:   readUI32
				CompressedBMWidth:    readUI32
 ;The valid bitmap height, width and x and y offsets represent the size of the valid data within
 ;the compressed bitmap. Because padding may be required when compressing, it is not
 ;guaranteed that all the data within the compressed image is valid. Note that compressing
 ;blanking is still valid. In the case where all the compressed bitmap comes from the video
 ;signal, then the valid height and width are equal to the compressed height and width, and the
 ;offsets are 0.
				ValidBMHeight:        readUI32
				ValidBMWidth:         readUI32
				ValidBMXOffset:       readUI32
				ValidBMYOffset:       readUI32
 ;The   is used to locate the x position of the start of the valid bitmap with
 ;reference to the video signal. The value is a measurement in units of T, which is one
 ;luminance-sampling clock, from the leading edge of the horizontal sync pulse (CCIR 624-3).
				VideoXOffsetInT:      readUI32
 ;The VideoYValidStartLine field is used to locate the line that the valid bitmap starts
 ;on. This value will be different for each field. (CCIR 624-3).
				VideoYValidStartLine: readUI32
			]
		]
		result
	]
    readVPRP: does[context[
    	VideoFormatToken:    readUI32
    	VideoStandard:       select ["UNKNOWN" "PAL" "NTSC" "SECAM"] readUI32
		VerticalRefreshRate: readUI32 ;Used when an unknown standard is specified. Normally, 60 for NTSC, and 50 for PAL.
   		HTotalInT:           readUI32 ;Defines the horizontal total, in T (one luminance sample: pixel)
   		VTotalInLines:       readUI32 ;Defines the vertical total, in lines.
   		FrameAspectRatio:    head reverse reduce [readUI16 readUI16]
									  ;Standard values for television is 4:3 or 16:9. This value can be
									  ;used with the frame width and height to calculate the pixel aspect ratio.
		FrameWidthInPixels:  readUI32 ;Defines the active frame width in pixels. The bitmap might digitize a region that is smaller or bigger than the active video width.
		FrameHeightInLines:  readUI32 ;Defines the frame height in lines. The bitmap might digitize a region that is smaller or bigger than the active video height.
		VideoFieldDescs:     readVIDEOFIELDDESCs ;One or two, depending on whether the video is interlaced or progressive.
	]]

	readRIFFINFO: has[info] [
		info: copy []
		while [not tail? inBuffer][
			repend info [
				as-string readBytes 4        ;tagID
				trim/with (as-string  readBytes alignSize readUI32) "^(00)" ;tagData
			]
		]
		new-line/skip info true 2
	]
	parse: func[
		"Parses AVI file and prints info about it's content"
		avi-file [file! url!]
		/local ChunkID ChunkSize subChunkID size 
	][
		open avi-file
		either "RIFF" = as-string readBytes 4 [
			probe riff-size: readUI32
			if "AVI " = probe riff-file-type: as-string readBytes 4 [
				probe as-string readBytes 4
				seekToBuffer readUI32
				if "hdrl" = probe as-string readBytes 4 [
					if "avih" = probe as-string readBytes 4 [
						readAVImainHeader
						? AVImainHeader
					]
				]
				while [not tail? inBuffer][
                    switch/default chunkID: as-string readBytes 4 [
                    	"LIST" [
							size: readUI32
							chunkID: as-string readBytes 4
							print ["LIST" mold chunkID size]
							switch/default chunkID [
								"strl" [
									if "strh" = probe as-string readBytes 4 [
										readAVIstreamHeader
										? AVIstreamHeader
									]
									if "strf" = probe as-string readBytes 4 [
										probe size: readUI32
										switch AVIstreamHeader/type [
											"vids" [
												readBITMAPINFOHEADER
												? BITMAPINFOHEADER
												probe readBytes (size - BITMAPINFOHEADER/size)
											]
											"auds" [
												readWAVEFORMATEX
												? WAVEFORMATEX
											]
											"mids" [print ["mids:" mold readBytes size]]
											"txts" [print ["txts:" mold readBytes size]]
										]
									]
								]
							][
								probe as-string readBytes size
							]
						]
                        "strn" [
                        	size: readUI32 
                        	print ["strn" mold as-string readBytes alignSize size]
	                        ;size: readUI32 
	                        ;chunkID: as-string readBytes 4 
	                        ;print ["LIST" mold chunkID size] 
                    	]
                    	"vprp" [
                    		size: readUI32
                    		;probe as-string inBuffer
                    		prin {"vprp" video property header: }
                    		probe readVPRP
                    		comment [{
The video properties header identifies video signal properties associated with a digital video
stream in an AVI file. This header attempts to address two main video properties:

- The type of video signal (PAL, NTSC, etc., as well as the resolution of the video signal).
- The framing of the compression within a video signal.

The parameters can be used to uniquely describe a video signal.
							}]
							;probe inBuffer
							break
                		]
                    ][

						size: readUI32
						either chunkID = "JUNK" [
							skipBytes size
						][
							print ["????" mold chunkID size]
							probe as-string readBytes size

						]
					]
				]
				

					seekToBuffer 12
					ChunkID: as-string readBytes 4
					ChunkSize: readUI32 - 4
					subChunkID: as-string readBytes 4
					print ["ChunkID:" mold ChunkID "ChunkSize:" ChunkSize ];"subChunkID:" mold subChunkID
					 
					switch/default ChunkID [
						"JUNK" [
							;seekToBuffer alignSize ChunkSize
							avi-port: skip avi-port alignSize ChunkSize
						]
						"LIST" [
							prin [mold subChunkID ": "]
							switch/default subChunkID [
								"INFO" [
									seekToBuffer alignSize ChunkSize
									probe readRIFFINFO
								]
								"movi" [
									print ["seek..." ChunkSize]
									avi-port: skip avi-port alignSize ChunkSize
									comment [
										print ["movie!!" AVImainHeader/TotalFrames * AVImainHeader/streams]
										i: 0
										forever [
											seekToBuffer 8
											ChunkID: as-string readBytes 4
											if find ChunkID "idx" [print ["XXX:" i] break]
											i: i + 1
											comment {
											ChunkID is:
											XXdb = Uncompressed video frame
											XXdc = Compressed video frame
											XXpc = Palette change
											XXwb = Audio data
											where XX is the stream number
											}
											ChunkSize: readUI32
											;print [ ChunkID  ChunkSize]
											seekToBuffer alignSize ChunkSize
											ChunkData: readBytes ChunkSize
										]
									]
									;break 
								]
								"MID " [
									seekToBuffer alignSize ChunkSize
									probe readRIFFINFO
								]
                                "DXDT" [
                                	seekToBuffer alignSize ChunkSize 
                                	probe readRIFFINFO
                            	]
							][
								print ["Unknown subChunkID:" mold subChunkID]
                                probe seekToBuffer alignSize ChunkSize 
							]
						]
						"idx1" [
							;seekToBuffer alignSize ChunkSize
							avi-port: skip avi-port alignSize ChunkSize
						]
					][
						print ["????" length? inBuffer copy/part inBuffer 20]
						inBuffer: tail inBuffer
					]
				]
		][
        	close avi-port
            print rejoin ["Not a RIFF file! " mold as-string copy/part head inBuffer 20]
            return false
		]
		close avi-port
	]
]

