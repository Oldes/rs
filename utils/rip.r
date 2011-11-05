REBOL [
    Title: "RIP - Standard File Archiver"
    Date:   23-June-2000
    File:   %rip.r
    Author: "Carl Sassenrath"
    Email:  carl@rebol.com
    Version: 1.3.1
    Purpose: {
        A file archiver that works across 37 platforms.
        Compresses all files and subdirectories into a
        single binary, self-extracting archive file.
        (Similar to ZIP programs, but only 3KB.)
    }
    Note: {Overwrites files by default!}
    History: [
        1.0.0 22-Feb-2000 "Carl Sassenrath" {Original code.}
        1.1.0 24-Feb-2000 "Cal Dixon" {Added subdirectoy support}
        1.2.0 20-May-2000 "Carl Sassenrath" {Standard security is better}
        1.3.0  9-Jun-2000 {Various cleanup.}
        1.3.1 23-Jun-2000 {Merged Cal's code back.}
    ]
    Category: [util file 4]
]

rip-pack: func[path filename install-dir /verbose][
	if empty? path [path: %./]
	if (last path) <> #"/" [append path #"/"]
	if not exists? path [print [path "does not exist"] return false]

	file-list: []
	archive: make binary! 32000

	if verbose [print "Archiving:"]
	foreach file files: read path [
	    either dir? path/:file [
	        append file-list reduce [file 'DIR ]
	        foreach newfile read path/:file [append files file/:newfile]
	    ][
	        if verbose [prin [tab file " "]]
	        data: read/binary path/:file
	        if verbose [prin [length? data " -> "]]
	        data: compress data
	        if verbose [print [length? data]]
	        append archive data
	        append file-list reduce [file length? data]
	    ]
	]

	if verbose [
	    print [newline "Total size:" length? archive "Checksum:" checksum archive newline]
	]

	;filename: to-file ask "Output archive file name? "
	if empty? filename [filename: %archive.rip]
	if not find filename "." [append filename ".rip"]
	if all [exists? filename not confirm reform ["Overwrite file" filename "? "]] [
	    print "stopped" halt
	]
	set [ignore file] split-path filename
	file: to-file file  ; for 2.2 compat
	
	header: mold compose/deep [
	    REBOL [
	        Title: "REBOL Self-extracting Binary Archive (RIP)"
	        Date: (now)
	        File: (file)
	        Note: (reform [{To extract, type REBOL} file {or run REBOL and type: do} file])
	    ]
	    file: (file)
	    size: (length? archive)
	    path: (install-dir)
	    verbose: not all [system/script/args system/script/args = 'quiet]
	    files: (reduce [file-list])
	    check: (checksum archive)
	    if not exists? path [make-dir/deep path]
	    archive: read/binary file
	    archive: next find/case/tail archive to-binary join "!DATA" ":"
	    if check <> checksum archive [print ["Checksum failed" check checksum archive] halt]
	    foreach [file len] files [
	        if verbose [print [tab file]]
	        either len = 'DIR [
	           if not exists? path/:file [make-dir/deep path/:file]
	        ][
	           data: decompress copy/part archive len
	           archive: skip archive len
	           either any [
	               not exists? path/:file
	               confirm reform [file "already exists - overwrite? "]
	           ][
			   		write/binary path/:file data
			   ][	print "skipped"]
	       ]
	    ]
	    none
	]
	head insert archive reduce [header newline "!DATA:" newline]
]


