rebol []

if empty? swf-file: to-file ask "SWF file:" [swf-file: %new.swf]
swf-bin: read/binary swf-file

swf-bin: skip swf-bin 21

bitmaps: make block! 50
names: make block! 50

foreach-tag swf-bin [
	tagid: tag
	tag-bin: data
	switch tagid [
		20	[
			;saving the tag to file
			id: tag-bin-part/rev 2
			insert bitmaps copy tag-bin
			insert bitmaps id
		]
		40 [
			ID: tag-bin-part/rev 2
			name: to-file copy/part tag-bin find tag-bin #{00}
			insert names reduce [id name]
		]
	]
]

foreach [id bmp] bitmaps [
	either none? name: select names id [
		print ["neznam jmeno pro" id]
	][
		print [Name "..." length? bmp]
		write/binary rejoin [%bitmaps/ name ".20"] bmp 
	]
]