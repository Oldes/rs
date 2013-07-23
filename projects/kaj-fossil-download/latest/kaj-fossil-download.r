REBOL [
    Title: "Kaj-fossil-download"
    Date: 23-Jul-2013/18:18:25+2:00
    Name: none
    Version: 0.0.1
	Comment: "just very fast written version so far!"
    File: none
    Home: none
    Author: "Oldes"
]

;Fossil server does not serve JS without this:
system/schemes/http/user-agent: {Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.10) Gecko/20100914 Firefox/3.6.10}

download-fossil-dir: func[dir url /local page wasDir subdir][
	print ["!!!!!!!!!!!!! " url]
	page: read url
	
	if not exists? dir [make-dir dir]
	
	wasDir: what-dir
	change-dir dir
	parse/all page [
		any [
			thru {gebi("} copy id to {"} thru {).href="} copy path to {";} (
				;print [id tab path]
				if path/1 = #"/" [
					tmp: rejoin [{a id='} id {'>}]
					if parse page [thru tmp copy name to {</a>} to end][
						print [id tab name tab path]
						parse path [
							thru "artifact/" copy artifact to end (
								file: to file! name
								if not exists? file [
									if not error? try [
										bin: read/binary rejoin [http://red.esperconsultancy.nl/ dir {raw/} name {?name=} artifact]
									][
										write/binary file bin
									]
								]
							)
							|
							thru {dir?ci=} copy dirId to "&" thru {name=} copy dirName to end (
								subdir: to-file dirName
								if not exists? subdir [
									download-fossil-dir subdir rejoin [http://red.esperconsultancy.nl/ dir {dir?ci=} dirId {&name=} dirName]
								]
								print [dirId dirName]
								ask ""
							)
						]					

					]
				]
			)
		]
	]
	change-dir wasDir
]
foreach dir [
	%Red-C-library
	%Red-common
][
	dir: dirize dir
	download-fossil-dir dir rejoin [http://red.esperconsultancy.nl/ dir {dir?ci=tip}]
]


