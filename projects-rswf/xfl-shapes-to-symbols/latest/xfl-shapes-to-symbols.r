REBOL [
    Title:  "Xfl-shapes-to-symbols"
    Date:   3-Mar-2013/18:45:59+1:00
	Author: "David 'Oldes' Oliva"
	Purpose: "Removes unused assets from XFL sources"
	Require: [
		rs-project 'xfl-core
	]
	Usage: [
		;xfl-clean %/d/test/XFL/combine-bmps/ %/d/test/XFL/combine-bmps-clean/
	]
	Preprocess: true
]

with ctx-XFL [
	#include %rules_shapesUpd.r

	remove-dom-formating: func[dom [block!]][
		forall dom [
			either string? dom/1 [
				clear dom/1
			][
				if block? dom/1/3 [
					remove-dom-formating dom/1/3
				]
			]
		]
		head dom
	]
	
	clear-edges: func[edges [string!] /local _s _e pos rlPos][
		;print ["clearing edges..." mold edges]
		rlPos: [
			[rl_edgNumber | rl_hexNum]   SP
			[rl_edgNumber | rl_hexNum] 
		]
		parse/all edges [
			any [
				SP [
					#"!" rlPos 
					;remove optional "select" information
					opt [_s: #"S" ch_digits _e: (_e: remove/part _s _e) :_e]
					|
					[#"|" | #"/"] rlPos
				]
				|
				SP [#"[" | #"]"] rlPos SP rlPos SP
				|
				pos: skip 1  (probe copy/part pos 100 ask "~~~ unknown edge value!") rlPos
			]
		]
		edges
	]
	set 'xfl-shapes-to-symbols func[src trg /local item file][
		files-to-parse:    clear head files-to-parse
		if verbose > 0 [
			print "^/=================================================="
			print   "=== SHAPES TO SYMBOLS of XFL ================================="
			print  ["=== source:" src]
			print  ["=== target:" trg lf lf]
		]
		
		init/into-dir src trg		
		
		parse-xfl/act xmldom 'DOMDocument-shapesUpd
		
		files-to-parse: head files-to-parse

		while [not tail? files-to-parse] [
			file: files-to-parse/1
			files-to-parse: next files-to-parse
			recycle
			current-symbol: either file? file [
				current-symbol: form last split-path file 
				copy/part current-symbol find/last current-symbol "."
			][  copy/part file find/last file "." ]
			print ["Processing file:" file mold current-symbol]

			either file? file [
				dom: to-DOM as-string read/binary file
				new-file: file
			][
				dom: to-DOM as-string read/binary xfl-source-dir/LIBRARY/(encode-filename file)
				new-file: join xfl-target-dir ["LIBRARY/" encode-filename file]
			]
			file-modified?: false
			parse-xfl/act dom 'DOMSymbolItem-shapesUpd
			if file-modified? [write new-file form-xfl dom]
			
		]


		write/binary xfl-target-dir/DOMDocument.xml form-xfl xmldom
		if verbose > 0 [print "^/--------------------------------------------------^/"]
	]
]