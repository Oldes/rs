REBOL [
    Title: "Read-stripped-jpg"
    Date: 28-Oct-2007/17:29:43+1:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "David Oliva (commercial)"
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
    Email: oliva.david@seznam.cz
]

read-stripped-jpg: func[
	jpgfile [file! url!]
	/remove tags-to-remove [block!]	{If not specified these tags are removed:
			["Photoshop 3.0" "ICC_PROFILE" "Adobe" "Ducky" "JFIF" "Exif"] if presents}
	/local stream bytes jpg length lbin originalLength identifier app?
][
	unless remove [
		tags-to-remove: [
			"Photoshop 3.0"
			"ICC_PROFILE"
			"Adobe"
			"Ducky"
			"JFIF"
			"Exif"
		]
	]
	jpg: context [
		binary: make binary! (originalLength: size? jpgfile)
		size:   none
		progressive?: false
	]
	stream: open/read/binary/seek jpgfile
	;seek to jpg image start
	while [#{FFD8} <> copy/part stream 2][
		if tail? stream: skip stream 2 [
			;no Start Of Image marker found
			close stream return none
		]
	]
	stream: skip stream 2
	append jpg/binary #{FFD8}
	
	while[not tail? stream] [
		bytes: copy/part stream 2
		stream: skip stream 2
		either 255 = bytes/1 [
			id: next bytes
			;print [mold id]
			switch/default id [
				#{D9} [;End Of Image
					append jpg/binary #{FFD9}
					close stream
					return jpg
				]
				#{DD} [;Define Restart Interval
					length: 2
				]
			][
				length: (to integer! lbin: copy/part stream 2) - 2
				stream: skip stream 2
			] 
			data: copy/part stream length
			stream: skip stream length
			case [
				id = #{C0} [;Start Of Frame
					jpg/size: as-pair
						(to-integer copy/part at data 4 2)
						(to-integer copy/part at data 2 2)
				]
				id = #{C2} [;Start Of Frame
					jpg/progressive?: true
					jpg/size: as-pair
						(to-integer copy/part at data 4 2)
						(to-integer copy/part at data 2 2)
				]
				app?: (#{E0} = (id and #{F0})) [;Application-specific
					identifier: as-string copy/part data find data #{00}
					;probe data
				]
			]
			unless any [
				#{FE} = id ;remove comments
				all [
					app?
					find tags-to-remove identifier
				]
			][
				append jpg/binary rejoin [bytes lbin data]
			]
		][
			append jpg/binary bytes
		]
	]
	close stream
	;? jpg
	;print ["jpgSize:" jpg/size "removed:" (originalLength - length? jpg/binary) "bytes"]
	jpg
]
;jpg: read-stripped-jpg to-rebol-file "I:\fotky\DSCN7716.JPG"
;write/binary %x.jpg jpg/binary