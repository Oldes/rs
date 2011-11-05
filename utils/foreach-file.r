REBOL [
	Title: "Foreach-file"
	Date:   12-7-2001
	File:   %foreach-file.r
	Author: "Oldes"
	Email:  oldes@bigfoot.com
	Version: 0.1.1
	Category: [util file 4]
]

foreach-file: func [
	path 	[file!] "Starting directory"
	action 	[block!]	"Block with action what to do with the file"
	/local total-files file files
][
	file: none
	bind action 'file
	total-files: 0
	if not exists? path [print [path "does not exist"] return false]
	
	foreach f files: read path [
		file: f 
		either dir? path/:file [
	        foreach newfile read path/:file [append files file/:newfile]
	    ][
			total-files: total-files + 1
			do action
		]
	]
	clear files
]
