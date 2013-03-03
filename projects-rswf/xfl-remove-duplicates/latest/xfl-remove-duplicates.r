REBOL [
    Title:  "xfl-remove-duplicates"
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
	#include %rules_removeDuplicates.r

	bitmap-hashes: make hash! 1000
	bitmap-duplicates: make hash! 100 
	
	store-bitmap-hash: func[node /local hash file bmpNode name][
		name: node/2/("name")
		if verbose > 1 [print ["store-bitmap-hash -->" mold name]]
		hash: checksum/secure read/binary file: rejoin [xfl-target-dir %bin/ select node/2 "bitmapDataHRef"]
		either bmpNode: select bitmap-hashes hash [
			if verbose > 0 [print ["BITMAP DUPLICATE FOUND" mold name]]
			repend bitmap-duplicates [name to-file bmpNode/2/("name")]
			clear node
			delete file
		][
			repend bitmap-hashes [hash node]
		]
		
	]
	
	
	set 'xfl-remove-duplicates func[src trg /local item file][
		files-to-parse:    clear head files-to-parse
		if verbose > 0 [
			print "^/=================================================="
			print   "=== REMOVING DUPLICATED BITMAPS =================="
			print  ["=== source:" src]
			print  ["=== target:" trg lf lf]
		]
		
		clear bitmap-hashes
		clear bitmap-duplicates
		
		init/into-dir src trg		
		
		parse-xfl/act xmldom 'DOMDocument-removeDuplicates
		
		files-to-parse: head files-to-parse

		while [not tail? files-to-parse] [
			file: files-to-parse/1
			files-to-parse: next files-to-parse
			recycle
			current-symbol: either file? file [
				current-symbol: form last split-path file 
				copy/part current-symbol find/last current-symbol "."
			][  copy/part file find/last file "." ]
			if verbose > 1 [print ["Processing file:" file mold current-symbol]]

			either file? file [
				dom: to-DOM as-string read/binary file
				new-file: file
			][
				dom: to-DOM as-string read/binary xfl-source-dir/LIBRARY/(encode-filename file)
				new-file: join xfl-target-dir ["LIBRARY/" encode-filename file]
			]
			file-modified?: false
			parse-xfl/act dom 'DOMSymbolItem-removeDuplicates
			if file-modified? [write new-file form-xfl dom]
			
		]


		write/binary xfl-target-dir/DOMDocument.xml form-xfl xmldom
		if verbose > 0 [
			print "^/--------------------------------------------------"
			print [ "-- Removed duplicated bitmaps:" (length? bitmap-duplicates) / 2]
			clear-values
		]
	]
]