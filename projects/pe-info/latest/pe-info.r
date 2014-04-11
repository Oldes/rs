REBOL [
    Title: "Pe-info"
    Date: 10-May-2013/10:14:56+2:00
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


PE: make stream-io [
	PE-port: none
	PE-header: none
	
	MSDOS-stub:
	file-header:	none
	section-header: none
	rsrc-table:     none
	rsrc-ptr:       none
	
	section-headers: copy []
	
	seekToBuffer: func[bytes][
		;print ["seekToBuffer bytes" bytes]
		setStreamBuffer copy/part PE-port bytes
		PE-port: skip PE-port bytes
		inBuffer
	]
	open: func["Reads PE file into buffer" PE-file [file! url!]][
		;AVImainHeader: AVIstreamHeader: none
		probe PE-file
		PE-port: system/words/open/read/binary/seek PE-file
		seekToBuffer size? PE-file
	]

	read-file-header: does [
		file-header: context [
			machine:          readUI16
			sections-nb:      readUI16
			timestamp:        readUI32		;-- file creation timestamp
			symbols-ptr:      readUI32		;-- OBJ only
			symbols-nb:       readUI32		;-- OBJ only
			opt-headers-size: readUI16		;-- zero for OBJ
			flags:            readUI16		
		]
	]
	read-optional-header: does [
		optional-header: context[			;-- optional header for image only
			magic:          readUI16			;-- different for 32/64-bit
			major-link-version: readUI8
			minor-link-version: readUI8
			code-size:       readUI32
			initdata-size:       readUI32
			uninitdata-size:       readUI32
			entry-point-addr:       readUI32
			code-base:       readUI32
			data-base:       readUI32		;-- 32-bit only (remove field for 64-bit)
			image-base:       readUI32		;-- 8 bytes for 64-bit
			memory-align:       readUI32
			file-align:       readUI32
			major-OS-version: readUI16			;-- should be 4.0
			minor-OS-version: readUI16
			major-img-version: readUI16
			minor-img-version: readUI16
			major-sub-version: readUI16
			minor-sub-version: readUI16
			win32-ver-value:       readUI32		;-- reserved, must be zero
			image-size:       readUI32
			headers-size:       readUI32
			checksum:        readUI32	;-- for drivers and DLL only
			sub-system: readUI16
			dll-flags: readUI16		;-- DLL only
			stack-res-size:  readUI32		;-- 8 bytes for 64-bit
			stack-com-size:  readUI32		;-- 8 bytes for 64-bit
			heap-res-size:   readUI32		;-- 8 bytes for 64-bit
			heap-com-size:   readUI32		;-- 8 bytes for 64-bit
			loader-flags:    readUI32		;-- reserved, must be zero
			data-dir-nb:     readUI32
			;-- Data Directory
			export-addr:     readUI32
			export-size:     readUI32
			import-addr:     readUI32
			import-size:     readUI32
			rsrc-addr:       readUI32
			rsrc-size:       readUI32
			except-addr:     readUI32
			except-size:     readUI32
			cert-addr:       readUI32
			cert-size:       readUI32
			reloc-addr:      readUI32
			reloc-size:      readUI32
			debug-addr:      readUI32
			debug-size:      readUI32
			arch-addr:       readUI32		;-- reserved, must be zero
			arch-size:       readUI32		;-- reserved, must be zero
			gptr-addr:       readUI32
			gptr-size:       readUI32
			TLS-addr:        readUI32
			TLS-size:        readUI32
			config-addr:     readUI32
			config-size:     readUI32
			b-import-addr:   readUI32
			b-import-size:   readUI32
			IAT-addr:        readUI32
			IAT-size:        readUI32
			d-import-addr:   readUI32
			d-import-size:   readUI32
			CLR-addr:        readUI32
			CLR-size:        readUI32
			reserved:        readUI32	;-- reserved, must be zero
			reserved2:       readUI32		;-- reserved, must be zero
		]
	]
	read-section-header: does [
		section-header: context [
			name:             trim/with as-string readBytes 8 #"^@"		;-- placeholder for an 8 bytes string
			virtual-size:     readUI32
			virtual-address:  readUI32
			raw-data-size:    readUI32
			raw-data-ptr:     readUI32
			relocations-ptr:  readUI32
			line-num-ptr:     readUI32
			relocations-nb:   readUI16
			line-num-nb:      readUI16
			flags:            readBytes 4
		]
		repend section-headers [section-header/name section-header]
		section-header
	]
	read-rsrc-table: func[
		section-header
	   /local
		num-name-entries
		num-id-entries
		rsrc-table ptr
	][
		ptr: index? inBuffer
		rsrc-table: context [
			flags:            readBytes 4
			timestamp:        readUI32
			major-version:    readUI16
			minor-version:    readUI16
			name-entries: copy []
			id-entries:   copy []
		]
		num-name-entries: readUI16
		num-id-entries:   readUI16
		loop num-name-entries [
			append rsrc-table/name-entries read-rsrc-name-entry
		]
		loop num-id-entries [
			append rsrc-table/id-entries read-rsrc-id-entry
		]
		
		foreach dir rsrc-table/id-entries [
			either dir/subdirectory [
				inBuffer: at head inBuffer (rsrc-ptr + (dir/rva and 2147483647))
				dir/subdirectory: read-rsrc-table section-header
			][
				inBuffer: at head inBuffer (rsrc-ptr + dir/rva)
				dir/data-entry: read-rsrc-data-entry section-header/virtual-address
			]
		]
		inBuffer: at head inBuffer ptr
		rsrc-table
	]
	read-rsrc-name-entry: does [
		context [
			name-rva:         readUI32
			rva:              readUI32
		]
	]
	read-rsrc-id-entry: does [
		context [
			id:               readUI32
			rva:              readUI32
			subdirectory:    0 <> (rva and -2147483648) ;high bit = 0
			data-entry:       none
		]
	]
	read-rsrc-data-entry: func[virtual-addres /local result] [
		result: context [
			data-rva: readUI32 - virtual-addres
			size:     readUI32
			codepage: readUI32
			reserved: readUI32
			data:     none
		]
		inBuffer: at head inBuffer (rsrc-ptr + result/data-rva)
		result/data: readBytes result/size
		result
	]
	parse: func[
		"Parses PE file and prints info about it's content"
		PE-file [file! url!]
		/local sh
	][
		clear section-headers
		open PE-file
		either #{4D5A} = readBytes 2 [
			probe readBytes 58
			probe PESignatureOffset: readUI32
			skipBytes PESignatureOffset - 64
			if #{50450000} <> probe readBytes 4 [
				print "PE Signature not found!"
				close PE-port
				return false
			]
			probe read-file-header
			probe file-header/opt-headers-size
			probe read-optional-header
			loop file-header/sections-nb [
				probe read-section-header
			]
			if any [
				sh: select section-headers ".rsrc"
				sh: select section-headers "rsrc"
			]	[
				print "RSRC"
				inBuffer: at head inBuffer rsrc-ptr: sh/raw-data-ptr + 1
				probe length? inBuffer
				probe read-rsrc-table sh
				;probe inBuffer
				
				
				;probe xxx: inBuffer
			]
		][
			print "Not MSDOS file"
			close PE-port
			return false
		]
		close PE-port
	]
]
echo %/d/t1.txt PE/parse %/d/hx.exe      echo none
echo %/d/t2.txt PE/parse %/d/hello2s.EXE echo none