rebol [
	title: "JPG extractor"
	purpose: "To get the jpg images used in SWF file"
	date: 7-10-03
]

extract-jpgs: func[/local swf-file id][
	if empty? swf-file: to-file ask "SWF file:" [swf-file: %new.swf]
	swf-file-parts: split-path swf-file
	
	swf-bin: read/binary swf-file
	swf-bin: skip swf-bin 21
	
	foreach-tag swf-bin [
		tagid: tag
		tag-bin: data
		switch tagid [
			21	[
				;saving the tag to file
				print [tabs "Found JPG with ID:" id: tag-bin-part/rev 2]
				write/binary rejoin [last swf-file-parts "." id ".jpg"] tag-bin
			]
		]
	]
]

extract-fonts: func[/file fl /local swf-file id][
	either file [swf-file: to-rebol-file fl][
		if empty? swf-file: to-file ask "SWF file:" [swf-file: %new.swf]
	]
	probe swf-file-parts: split-path swf-file
	
	swf-stream: open/direct/read/binary swf-file
	

	
	foreach-stream-tag  [
		tagid: tag
		tag-bin: data
		probe tagid
		switch tagid [
			46	[
				;saving the tag to file
				print [tabs "Found font with ID:" id: tag-bin-part/rev 2]
				;write/binary rejoin [last swf-file-parts "." id ".jpg"] tag-bin
			]
		]
	]
]

extract-fonts/file  "D:\rss\projects-web\miss3\podklady\!spacefx\www.spacefx.co.uk\spacefxhome.swf"