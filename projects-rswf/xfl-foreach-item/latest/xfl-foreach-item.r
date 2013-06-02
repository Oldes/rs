REBOL [
    Title:  "xfl-foreach-item"
    Date:   8-Mar-2013/23:49:05+1:00
	Author: "David 'Oldes' Oliva"
	Purpose: "Script for per item manipulations - like batch renaming"
	Require: [
		rs-project 'xfl-core
	]
	Usage: [
		;xfl-clean %/d/test/XFL/combine-bmps/ %/d/test/XFL/combine-bmps-clean/
	]
	Preprocess: true
]

with ctx-XFL [
	#include %rules_foreachItem.r

	onItemCallback: none
	onNodeCallback: none
	
	set 'xfl-foreach-item func[src [file!] trg [file! none!]  /local item file][
		if verbose > 0 [
			print "^/=================================================="
			print   "=== FOREACH LIBRARY ITEM ========================="
			print  ["=== source:" src]
			print  ["=== target:" trg lf lf]
		]
		files-to-parse:    clear head files-to-parse
		init/into-dir src trg
		
		verbose: 0
		if verbose > 0 [print "Processing DOMDocument..."]
		parse-xfl/act xmldom 'DOMDocument-foreachItem
		
		
		files-to-parse: head files-to-parse
		verbose: 1
		
		if verbose > 0 [print reform ["Processing" length? files-to-parse "files..."]]
		
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
			parse-xfl/act dom 'DOMSymbolItem-foreachItem
			if file-modified? [write new-file form-xfl dom]
			
		]

		write/binary xfl-target-dir/DOMDocument.xml form-xfl xmldom
		if verbose > 0 [
			print "^/--------------------------------------------------"
			print [ "-- Renames:" (length? newNames)]
			clear-values
		]
	]
	
	
]

bmpNum: 0
oldNames: copy []
newNames: copy []
PATH: "Bitmaps/Domek/DomekAnimace/"
renameBitmaps: func[node /local libDir atts name extFile newName f][
	libDir: join ctx-XFL/xfl-target-dir %LIBRARY/
	atts: node/2
	switch node/1 [
		"DOMBitmapItem" [
			name: select atts "name"
			parse/all name [
				thru PATH copy oldName to end (
					extFile: select atts "sourceExternalFilepath"
					append oldNames name
					append newNames newName: join PATH bmpNum
					atts/("sourceExternalFilepath"): rejoin [PATH bmpNum %. last parse extFile "."]
					atts/("name"): newName
					
					className: replace/all copy newName "/" "_" 
					either find atts "linkageExportForAS" [
						atts/("linkageExportForAS"): "true"
					][
						repend atts ["linkageExportForAS" "true"]
					]
					either find atts "linkageClassName" [
						atts/("linkageClassName"): className
					][
						repend atts ["linkageClassName" className]
					]
					
					bmpNum: bmpNum + 1
				)
			]
		]
		"DOMBitmapInstance" [
			if f: find oldNames atts/("libraryItemName") [
				atts/("libraryItemName"): newNames/(index? f)
				ctx-xfl/file-modified?: true
			]
		]
		"BitmapFill" [
			if f: find oldNames atts/("bitmapPath") [
				atts/("bitmapPath"): newNames/(index? f)
				ctx-xfl/file-modified?: true
			]
		]
	]
]
onItemCallback: 
onNodeCallback: :renameBitmaps
xfl-foreach-item %/d/Domek_r/ %/d/Domek_anims/
;xfl-foreach-item %/d/assets/TimelineSWFs/Klicnice_anims_normal_d/ %/d/assets/TimelineSWFs/Klicnice_anims_normal_r/