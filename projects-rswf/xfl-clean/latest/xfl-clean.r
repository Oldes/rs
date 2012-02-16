REBOL [
    Title:  "Xfl-clean"
    Date:   16-Feb-2012/19:33:21+1:00
	Author: "David 'Oldes' Oliva"
	Purpose: "Removes unused assets from XFL sources"
	Require: [
		rs-project 'xfl-core
	]
	Usage: [
		xfl-clean %/d/test/XFL/clean/ %/d/test/XFL/clean-result/
	]
	Preprocess: true
]

with ctx-XFL [
	#include %rules_clean.r
	
	folders-to-check:  copy []
	items-to-check:    copy []
	
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
	check-item: func[node /local atts name item-name href][
		atts: node/2
		name: any [
			select atts "name"
			select atts "soundName"
			select atts "libraryItemName"
			select atts "bitmapPath"
		]
		if node/1 = "DOMSymbolInstance" [
			href: join atts/("libraryItemName") ".xml"
			if none? find head files-to-parse href [
				append files-to-parse href
			]
		]
		if name [
			print ["CHECK-ITEM:" name]
			forall items-to-check [
				if any [
					(select items-to-check/1/2 "name") = name
					(select items-to-check/1/2 "href") = join name %.xml
				][
					remove items-to-check
					break
				]
			]
			items-to-check: head items-to-check
		]
	]
	
	
	set 'xfl-clean func[src trg /local item file][
	
		if verbose > 0 [
			print "^/=================================================="
			print   "=== CLEANING XFL ================================="
			print  ["=== source:" src]
			print  ["=== target:" trg lf lf]
		]
		
		init/into-dir src trg		
		
		parse-xfl/act xmldom 'DOMDocument-clean

		while [not tail? files-to-parse] [
			file: files-to-parse/1
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
				dom: to-DOM as-string read/binary xfl-source-dir/LIBRARY/(decode-filename file)
				new-file: join xfl-target-dir ["LIBRARY/" decode-filename file]
			]
			parse-xfl/act dom 'DOMSymbolItem-clean
			;write new-file form-xml dom
			files-to-parse: next files-to-parse
		]
		forall folders-to-check [
			print ["REMOVING FOLDER:" folders-to-check/1/2/("name")]
			clear folders-to-check/1
		]
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

		write xfl-target-dir/DOMDocument.xml form-xml xmldom
		print "^/--------------------------------------------------^/"
	]
]