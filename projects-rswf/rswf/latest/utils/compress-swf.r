rebol [
	title: "SWF compressor"
	file: %compress-swf.r
	name: 'compress-swf
	purpose: "To compress uncompressed swf files"
	comment: "SWF files with version < 6 will be converted to version 6!"
	author: "oldes"
	date: 24-9-2003
]

compress-swf: func[file /local swf-bin version new-swf original-size][
	if not exists? file [
		print ["Cannot find file" mold file "!"]
		return none
	]
	swf-bin: read/binary file
	original-size: length? swf-bin
	return either parse/all swf-bin ["FWS" copy version 1 skip to end][
		version: to-integer to-binary version
		if version < 6 [version: 6]
		swf-bin: copy skip swf-bin 8
		new-swf: rejoin [
			#{435753}
			load rejoin ["#{0" version "}"]
			int-to-ui32 8 + length? swf-bin
			compress swf-bin
		]
		either original-size <= length? new-swf [
			print ["Compressed file (" file ") is not smaller!"]
			none
		][	new-swf ]
	][
		print ["File:" mold file "is not an uncompressed SWF file!"]
		none
	]
]