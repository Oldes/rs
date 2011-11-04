rebol [
	title:   "XFL joiner"
	name:    'xflJoin
	purpose: {Joins XFL files together}
	date:    30-05-2011
]



with ctx-XFL [

	
	xflJoin: func[xfl-target-dir [file!] xfl-dirs [block!] /local n][
		xfl-target-dir: dirize xfl-target-dir
		forall xfl-dirs [xfl-dirs/1: dirize xfl-dirs/1]
		
		either exists? xfl-target-dir [
			ask "Target dir exists! Are you sure? (ESC = exit, ENTER = continue)"
			call/wait probe rejoin ["del /Q /S /A:-S /A:-H /A:-R " to-local-file xfl-target-dir "\*"]
		][	make-dir/deep xfl-target-dir ]
		
		copy-dir xfl-dirs/1 xfl-target-dir
		
		remove xfl-dirs
		
		DOMDocument: as-string read/binary xfl-target-dir/DOMDocument.xml
		xmldom: third parse-xml+/trim DOMDocument
		
		probe dom-folders: get-node-content xmldom %DOMDocument/folders
		probe dom-media:   get-node-content xmldom %DOMDocument/media
		probe dom-symbols: get-node-content xmldom %DOMDocument/symbols
		
		get-medium-by-id: func[id][
			foreach node dom-media [
				if node/2/("itemID") = id [return node]
			]
			none
		]
		
		itemIDs: copy []
		replaces: copy [
			{libraryItemName="level_01/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_02/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_03/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_04/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_05/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_06/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_07/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_08/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_09/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_10/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_11/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_12/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_13/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_14/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_15/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_16/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_17/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_18/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_19/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_20/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_21/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_22/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_23/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_24/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_25/KLIKADLO} {libraryItemName="KLIKADLO}
			{libraryItemName="level_26/KLIKADLO} {libraryItemName="KLIKADLO}
		]
		classNames: copy []
		
		if dom-folders [ foreach node dom-folders [ append itemIDs select node/2 "itemID" ] ]
		if dom-media   [ foreach node dom-media   [ append itemIDs select node/2 "itemID" ] ]
		if dom-symbols [ foreach node dom-symbols [ append itemIDs select node/2 "itemID" ] ]
		
		probe itemIDs
		;change-dir trg-folder
		
		n: 0
		f: 1
		foreach xfl-dir xfl-dirs [
			
			dom: third parse-xml+/trim as-string read/binary xfl-dir/DOMDocument.xml
			if folders: get-node-content dom %DOMDocument/folders [
				foreach node folders [
					switch/default node/1 [
						"DOMFolderItem" [
							unless exists? dir: rejoin [ xfl-target-dir %LIBRARY/  select node/2 "name" ][
								print ["... making dir:" mold dir]
								make-dir/deep dir
							]
						]
					][	ask reform ["Unknown media node:" mold node] ] 
					append/only dom-folders node
				]
			]
			;probe dom-folders
			;ask "."
			if media: get-node-content dom %DOMDocument/media [
				foreach node media [
					newid: none
					print [">>>" node/1]
					switch/default node/1 [
						"DOMBitmapItem" [
							href: select node/2 "bitmapDataHRef"
							if find itemIDs oldid: node/2/("itemID") [
								print "... Bitmap ID duplicate"
								node/2/("itemID"): newid: make-id
							]
							src: rejoin [ xfl-dir %bin/ href ]
							continue?: true
							case/all [
								newid [
									currentNode: get-medium-by-id oldid
									trg: rejoin [ xfl-target-dir %bin/ currentNode/2/("bitmapDataHRef") ]
									if ((probe size? src) = (probe size? trg) false) [
										print "... reusing bitmap"
										repend replaces [
											ajoin [{bitmapPath="} node/2/("name") {"}]
											ajoin [{bitmapPath="} currentNode/2/("name") {"}]
											
											ajoin [{libraryItemName="} node/2/("name") {"}]
											ajoin [{libraryItemName="} currentNode/2/("name") {"}]
										]
										continue?: false
									]
								]
								continue? [
									print ["... copying bitmap:" mold src]
									trg: rejoin [ xfl-target-dir %bin/ href ]
									if exists? trg [
										n: n + 1
										href: node/2/("bitmapDataHRef"): ajoin ["NewMedia " n ".dat"]
										trg: rejoin [ xfl-target-dir %bin/ href ]
										print ["... changed DAT name" href]
									]
									write/binary trg read/binary src
									
									append/only dom-media node
								]
							]
						]
						
						"DOMSoundItem" [
							href: select node/2 "soundDataHRef"
							if find itemIDs oldid: node/2/("itemID") [
								print "... Sound ID duplicate"
								node/2/("itemID"): newid: make-id
							]
							src: rejoin [ xfl-dir %bin/ href ]
							continue?: true
							
							case/all [
								newid [
									currentNode: get-medium-by-id oldid
									trg: rejoin [ xfl-target-dir %bin/ currentNode/2/("soundDataHRef") ]
									;if (probe size? src) = (probe size? trg) [
									;	print "... reusing sound"
									;	repend replaces [
									;		ajoin [{soundName="} node/2/("name") {"}]
									;		ajoin [{soundName="} currentNode/2/("name") {"}]
									;	]
									;	continue?: false
									;]
								]
								continue? [
									print ["... copying sound:" mold src]
									trg: rejoin [ xfl-target-dir %bin/ href ]
									if exists? trg [
										n: n + 1
										href: node/2/("soundDataHRef"): ajoin ["NewMedia " n ".dat"]
										trg: rejoin [ xfl-target-dir %bin/ href ]
										print ["... changed DAT name" href]
									]
									write/binary trg read/binary src
									
									append/only dom-media node
								]
							]
						]
					][	ask reform ["Unknown media node:" mold node] ] 
					
				]
			]
			if symbols: get-node-content dom %DOMDocument/symbols [
				foreach node symbols [
					switch node/1 [
						"Include" [
							newid: none
							if find itemIDs oldid: node/2/("itemID") [
								print "... Symbol ID duplicate"
								node/2/("itemID"): newid: make-id
							]
							href: select node/2 "href"
							
							if exists? src: rejoin [ xfl-dir %LIBRARY/ href ][
								trg: rejoin [xfl-target-dir %LIBRARY/ href]
								print ["... copying symbol:" mold src]
								tmp: read/binary src
								if newid [replace tmp oldid newid]
								replace tmp {linkageClassName="KLIKADLO} ajoin [{linkageClassName="KLIKADLO_} f "_"]
								foreach [old new] replaces [
									replace/all tmp old new
								]								
								write/binary trg tmp
							]
						]
					][	ask reform ["Unknown symbol node:" mold node] ] 
					append/only dom-symbols node
				]
			]
			f: f + 1
		]
		delete xfl-target-dir/bin/SymDepend.cache
		write/binary xfl-target-dir/DOMDocument.xml xmltree-to-str xmldom
		print "========="
		;unless exists? trg-folder [make-dir/deep trg-folder]
		
	]

	;xflJoin %tests/spoj_final/ [%tests/spoj1 %tests/spoj2]
]


