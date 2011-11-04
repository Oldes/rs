REBOL [
    Title: "Imagick"
    Date: 25-Oct-2007/15:40:53+2:00
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

imagick: context [
	error: copy ""
	 any [
		exists? dir_imagemagick: %/c/utils/imagemagick/
		exists? dir_imagemagick: %"/c/Program Files/ImageMagick/"
	]
	mask: "*.jpg"
	resize: func[
		input
		size [pair! string!] {you can use for example "x100" to create thumbnails with height 100 and variable width}
		/into dir [file!]    {output directory}
		/local uniqueName files i
	][
		clear error
		dir: either into [dirize to-rebol-file dir][
			rejoin [dirize to-rebol-file input size "/"]
		]
		if not exists? dir [make-dir/deep dir]
		uniqueName: join "~tmp" form checksum form now
		files: sort read to-rebol-file input
		if file? into [into: to-local-file to-rebol-file into]
		call/error/wait/console reform [
			to-local-file dir_imagemagick/convert
			rejoin [to-local-file input "/" mask]
			"-resize" size
			"-quality" 90
			"-sharpen 0x0.8"
			rejoin [to-local-file dir #"/" uniqueName %.jpg]
		] error 
		either empty? error [
			i: 0
			foreach file files [
				if find/any file mask [
					probe dir/:file
					if exists? dir/:file [delete dir/:file]
					rename rejoin [dir uniqueName "-" i %.jpg] file
					i: i + 1
				]
			]
			true
		][
			print ["!!!" error]
			false
		]
	]
	
	resize-jpg: func[
		jpg-src
		jpg-trg
		size
		/into dir [file!]    {output directory}
		/local uniqueName files i
	][
		clear error
		print "???????"
		call/error/wait/console probe reform [
			to-local-file dir_imagemagick/convert
			to-local-file jpg-src
			"-filter Catrom"
			"-resize" size
			"-unsharp .5x2+.6+.05"
			"-quality" 95
			;"-sharpen 0x0.7"
			to-local-file jpg-trg
		] error 
		either empty? error [
			true
		][
			print ["!!!" error]
			false
		]
		wait 0:0:2
	]
]