REBOL [
    Title: "Jpg-repair"
    Date: 23-Jul-2008/21:55:23+2:00
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
]

JPG-repair: func[
	"Tries to reorder JPG data tags to valid JPG"
	jpg-src [binary! file! url!] "File to repair"
	/local bytes jpg-head jpg-tables jpg-data tmp
][
	unless binary? jpg-src [jpg-src: read/binary jpg-src]
	;seek to jpg image start

	jpg-head:   copy #{}	
	jpg-tables: copy #{}
	jpg-data:   copy #{}

	while [jpg-src: find/tail jpg-src #{FFD8}][
		;print "SOI"
		while[all [
			not tail? jpg-src
			(bytes:  copy/part jpg-src 2) <> #{FFD9}
		]][
			jpg-src: skip jpg-src 2
			either 255 = bytes/1 [
				len: (to integer! tmp: copy/part jpg-src 2) - 2
				append bytes tmp
				jpg-src: skip jpg-src 2
				;print [bytes/2 mold to-binary to-char bytes/2 "^-len:" len]
				case [	
					find [224 192 194] bytes/2 [
						append jpg-head   join bytes copy/part jpg-src len
						jpg-src: skip jpg-src (len - 2)
					]
					find [196 219 221] bytes/2 [
						append jpg-tables join bytes copy/part jpg-src len
						jpg-src: skip jpg-src (len - 2)
					]
					true [
						append jpg-data join bytes copy jpg-src ;copy/part jpg-src len
						jpg-src: tail jpg-src
					]
				]
				
			][
				print bytes/1

			]
		]
	]
	rejoin [
		#{FFD8}
		jpg-head
		jpg-tables
		jpg-data
		#{FFD9}
		
	]
]