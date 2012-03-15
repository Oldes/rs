REBOL [
    Title:  "Xfl-clean"
    Date:   16-Feb-2012/19:33:21+1:00
	Author: "David 'Oldes' Oliva"
	Purpose: "Removes unused assets from XFL sources"
	Require: [
		rs-project 'xfl-core
	]
	Usage: [
		xfl-clean %/d/test/XFL/combine-bmps/ %/d/test/XFL/combine-bmps-clean/
	]
	Preprocess: true
]

with ctx-XFL [
	#include %rules_clean.r
	
	add-item-to-check: func[node /local atts name][
		atts: node/2
		name: any [
			select atts "name"
			select atts "href"
		]
		
		forall folders-to-check [
			if parse name compose[(folders-to-check/1/2/("name")) #"/" to end][
				remove folders-to-check
			]
		]
		folders-to-check: head folders-to-check
		
		if "true" <> select atts "linkageExportForAS" [
			append/only items-to-check node
		]
	]

	same-names?: func[name1 name2][
		all [
			not none? name1
			not none? name2
			(decode-entities name1) = (decode-entities name2)
		]
	]
	check-item: func[node /local atts name item-name href][
		atts: node/2

		name: any [
			select atts "libraryItemName"
			select atts "name"
			select atts "soundName"
			select atts "bitmapPath"
		]
		if node/1 = "DOMSymbolInstance" [
			add-file-to-parse node
		]
		if name [
			print ["CHECK-ITEM:" name]
			forall items-to-check [
				if any [
					same-names? name select items-to-check/1/2 "name"
					same-names? (select items-to-check/1/2 "href") (join name %.xml)
				][
					remove items-to-check
					break
				]
			]
			items-to-check: head items-to-check
		]
	]
	
	
	set 'xfl-clean func[src trg /local item file][
	
		folders-to-check:  copy []
		items-to-check:    copy []
		files-to-parse:    clear head files-to-parse
		if verbose > 0 [
			print "^/=================================================="
			print   "=== CLEANING XFL ================================="
			print  ["=== source:" src]
			print  ["=== target:" trg lf lf]
		]
		
		init/into-dir src trg		
		
		parse-xfl/act xmldom 'DOMDocument-clean
		
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
			][
				dom: to-DOM as-string read/binary xfl-source-dir/LIBRARY/(encode-filename file)
			]
			parse-xfl/act dom 'DOMSymbolItem-clean
			;write new-file form-xfl dom
			
		]
		folders-to-check: head folders-to-check
		forall folders-to-check [
			print ["REMOVING FOLDER:" folders-to-check/1/2/("name")]
			clear folders-to-check/1
		]
		items-to-check: head items-to-check
		forall items-to-check [
			item: items-to-check/1
			switch item/1 [
				"DOMBitmapItem" [
					print ["REMOVING BITMAP:" item/2/("name")]
					error? try [delete rejoin [xfl-target-dir %bin/ item/2/("bitmapDataHRef")]]
				]
				"DOMSoundItem" [
					print ["REMOVING SOUND:" item/2/("name")]
					error? try [delete rejoin [xfl-target-dir %bin/ item/2/("soundDataHRef")]]
				]
				"Include" [
					print ["REMOVING SYMBOL:" item/2/("href")]
					error? try [delete rejoin [xfl-target-dir %LIBRARY/ item/2/("href")]]
				]
			]
			
			clear items-to-check/1
		]

		write/binary xfl-target-dir/DOMDocument.xml form-xfl xmldom
		if verbose > 0 [print "^/--------------------------------------------------^/"]
	]
]