rebol [
	title: "JPG analyse"
	email: oliva.david@seznam.cz
	author: "Oldes"
	purpose: {To remove some data from the JPG files to make them smaller.
	For example files from Adobe contains so many other informations that the file is twice bigger than may be.}
	usage: {NEWjpg: jpg-analyse %/e/testjpg.jpg}
	date: 4-Jan-2002/18:22:48+1:00
]

jpg-analyse: func[
	"Analyses the JPG file and tries to remove some unnecessary infos from file"
	file [file! url! binary!]	"JPG file to analyse"
	/remove tags-to-remove [block!]	{If not specified these tags are removed:
			["Photoshop 3.0" "ICC_PROFILE" "Adobe" "Ducky" "Exif"] if presents}
	/quiet "Will not print informations"
	/local
		img to-int buf newimg jfif version units Xdensity Ydensity
		Xthumbnail Ythumbnail rgb length lng identifier data APP0 msg
][
	if not remove [
		tags-to-remove: [
			"Photoshop 3.0"
			"ICC_PROFILE"
			"Adobe"
			"Ducky"
			"Exif"
		]
	]
	img: either binary? file [file][read/binary file]
	newimg: make binary! length? img
	
	to-int: func[i][to-integer to-binary i]
	msg: func[m][if not quiet [print m]]
	JFIF: [
		["JFIF^@"
			copy version 2 skip (
				version: (to-int version/1) + ((to-int version/2) / 100)
			)
			copy units 1 skip (units: to-int units)
			copy Xdensity 2 skip
			copy Ydensity 2 skip
			copy Xthumbnail 1 skip
			copy Ythumbnail 1 skip
			copy rgb to end
		] (
			
			print "JFIF HEADER:"
			print ["^-  version:" version]
			print ["^-    units:" pick [
				"no units, X and Y specify the pixel aspect ratio"
				"X and Y are dots per inch"
				"X and Y are dots per cm"
				] 1 + units
			]
			print ["^-  density:" to-pair reduce [to-int Xdensity to-int Ydensity]]
			print ["^-thumbnail:" to-pair reduce [
				to-int Xthumbnail
				to-int Ythumbnail]
			]
		)
	]
	parse/all img [
		copy buf thru "ÿØ" (insert tail newimg buf)
		some [
			"ÿ"
			copy APP0 1 skip
			copy length 2 skip (lng: (to-int length) - 2)
			copy data lng skip (
				identifier: none
				either APP0 = "à" [
					if not quiet [parse/all data JFIF]
				][
					if not none? data [
					parse/all data [
						copy identifier to "^@" 1 skip
						to end
					]
					]
				]
				either any [
					found? find tags-to-remove identifier
					APP0 = "þ"	;info about the creator's program
				][
					msg either none? identifier [
						["Removed data:" data]
					][
						["Removed tag" mold identifier "lenght:" lng + 4]
					]
				][
					insert tail newimg rejoin ["ÿ" APP0 length data]
				]
			)
		]
		copy buf to end (insert tail newimg buf)
	]
	msg ["Original  image:" length? img "B"]
	msg ["Optimised image:" length? newimg "B"]
	newimg
]

replace-jpgs: func[
	"Replaces all JPG files"
	/local path tsz1 tsz2 sz1 sz2 ext img newimg modes
][
	path: to-file ask {Directory? }
	if empty? path [path: %./]
	if (last path) <> #"/" [append path #"/"]
	if not exists? path [print [path "does not exist"] halt]
	tsz1: 0
	tsz2: 0
	foreach file files: read path [
	    either dir? path/:file [
	        foreach newfile read path/:file [append files file/:newfile]
	    ][
			ext: last (parse mold path/:file ".")
			if ext = "jpg" [
				if error? try [
				img: read/binary path/:file
				modes: get-modes path/:file [modification-date owner-write]
				if not last modes [
					;change back tail modes true
					;set-modes path/:file modes
					;uncomment if you want to replace locked files
				]
				sz1: length? img
				newimg: jpg-analyse/quiet img
				sz2: length? newimg
				tsz1: tsz1 + sz1
				tsz2: tsz2 + sz2
				if sz1 > sz2 [
					write/binary path/:file newimg
					set-modes path/:file modes
					print [path/:file sz1 sz2]
				]
				][	print ["ERROR: " path/:file]]
			]
		]
	]
	print ["Before: " tsz1]
	print ["Now:    " tsz2]
	print ["Removed:" tsz1 - tsz2]
]