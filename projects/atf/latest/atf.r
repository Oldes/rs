REBOL [
    Title: "Atf"
    Date: 18-Mar-2013/16:39:11+1:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "A Rebol"
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
    	rs-project 'stream-io
	]
]


ATF: make stream-io [
	atf-port: none
	atf-header: none
	
	seekToBuffer: func[bytes][
		;print ["seekToBuffer bytes" bytes]
		setStreamBuffer copy/part atf-port bytes
		atf-port: skip atf-port bytes
		inBuffer
	]
	open: func["Reads ATF file into buffer" atf-file [file! url!]][
		;AVImainHeader: AVIstreamHeader: none
		probe atf-file
		atf-port: system/words/open/read/binary/seek atf-file
		seekToBuffer 6
	]
	read-atf-header: does [
		atf-header: context [
			flags:  readUI8
			isCube: 128 and flags = 128
			format: pick ["RGB" "RGBA" "Compressed" "Raw" "Compressed Alpha" "Raw Alpha"] 1 + (127 and flags)
			width:  pick [1 2 4 16 32 64 128 256 512 1024 2048] 1 + readUI8
			height: pick [1 2 4 16 32 64 128 256 512 1024 2048] 1 + readUI8
			textureCount: readUI8
		]
	]
	parse: func[
		"Parses ATF file and prints info about it's content"
		atf-file [file! url!]
		/local ChunkID ChunkSize subChunkID size 
	][
		open atf-file
		either "ATF" = as-string readBytes 3 [
			;readByte
			print bytes: to-integer readBytes 3
			seekToBuffer bytes
			probe read-atf-header
			probe readBytes 10
		][
			print "Not ATF file"
			return false
		]
		close atf-port
	]
]

ATF/parse %/c/dev/utils/red1.atf
ATF/parse %/c/dev/utils/red2.atf
ATF/parse %/c/dev/utils/red16.atf
ATF/parse %/c/dev/utils/red16.etc
ATF/parse %/c/dev/utils/red16.dxt
