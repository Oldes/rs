REBOL [
    Title: "Replace-in-all-files"
    Date:   12-7-2001
    File:   %replace-in-all-files.r
    Author: "Oldes"
    Email:  "oliva.david at seznam.cz"
    Version: 0.1.1
    Purpose: {To do recursive replace in all files in the directory}
    Usage:  {replace-in-all-files ["new/homes" "homes"]}
    History: []
    Category: [util file 4]
]

verbose: on  ; turn off for less info
replace-in-all-files: func [
    replacements    [block!]    "Block of replacements pairs"
	/rules parse-rules  [block!]
    /path p         [file! string! url!]     "Starting directory"
    /only extensions       	[block!]
    /only-html  "HTML + PHP files only"
	/case
    /local
     changed?   "If there was same replace in the file"
     data       "file content"
     do-replace "replacing function"
     total-files replaced-files "counters"
	 s e x
][
    total-files: 0
    replaced-files: 0 
    changed?: false
    do-replace: func[data][
        foreach [s t] replacements [
			either case [
				if found? find/case data s [
					changed?: true
					replace/all/case head data s t
				]
			][
				if found? find data s [
					changed?: true
					replace/all head data s t
				]
			]
        ]
		if rules [
			foreach rule bind parse-rules 'changed? [
				parse/all head data rule
			]
		]
        head data
    ]
    if only-html [extensions: ["html" "htm" "php"]]
    either path [
    	path: either string? p [to-rebol-file p][p]
	][
        path: dirize to-rebol-file ask {Directory? }
        if empty? path [path: %./]
    ]
    if not exists? path [print [path "does not exist"] halt]
    
    foreach file files: read path [
    	;probe path/:file
        either all [#"/" = last form path/:file dir? path/:file] [
        	attempt [
           	 foreach newfile read path/:file [append files file/:newfile]
       		]
        ][
        	if any [
        		not block? extensions
        		all [
        			not none? ext: last parse form file "."
        			find extensions ext
    			]
    		][
    			attempt [
    				;print "?"
		            total-files: total-files + 1
		            changed?: false
		            data: copy do-replace read/binary path/:file
		            if changed? [
		                replaced-files: replaced-files + 1
		                if verbose [print join path/:file " ....changed"]
		                write/binary path/:file data
		            ]
	            ]
            ]
        ]
    ]
    if verbose [print rejoin ["Replaced " replaced-files " from " total-files " files."]]
]

;replace-in-all-files ["new/homes" "homes"]