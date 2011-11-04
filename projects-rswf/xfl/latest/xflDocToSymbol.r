rebol [
	title:   "XFL Document to Symbol item converter"
	name:    'xflDocToSymbol
	purpose: {Converts content of all root layers of the XFL doc into new MovieClip symbol item}
	date:    30-05-2011
]



with ctx-XFL [
	default-atributes: context [
		include: context [
			href:          none
			itemId:        "4DE36393-00000000"
			loadImmediate: "false"
		]
	]
	
	to-atts: func[obj [object!] /local atts][
		atts: third obj
		while [not tail? atts][
			change atts to-string first atts
			atts: skip atts 2
		]
		head atts
	]
	create-symbol: func[spec /local href itemID lastModified content][
		href:         ajoin [spec/name ".xml"]
		itemID:       make-id
		lastModified: to-timestamp now
		insert/only dom-symbols compose/deep[
			"Include" [
				"href"          (href)
				"loadImmediate" "false"
				"itemID"        (itemID)
				"lastModified"  (lastModified)
			] #[none]
		]
		content: ajoin [
			{<DOMSymbolItem xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://ns.adobe.com/xfl/2008/" name="} spec/name {" itemID="} itemID {" lastModified="} lastModified {">
  <timeline>
    <DOMTimeline name="} spec/name {">
      <layers/>
    </DOMTimeline>
  </timeline>
</DOMSymbolItem>}
		]
		write/binary rejoin [xfl-folder-new %LIBRARY/ href] content
		content
	]

	xflDocToSymbol: func[dir /local n][
		print ["*******" dir]
		src-folder: 
		xfl-folder: dirize dir
		xfl-folder-new:
		probe trg-folder:	head insert find/last copy dirize dir #"/" %_new
		
		either exists? xfl-folder-new [
			call/wait probe rejoin ["del /Q /S /A:-S /A:-H /A:-R " to-local-file xfl-folder-new "\*"]
		][	make-dir/deep xfl-folder-new ]
		copy-dir xfl-folder xfl-folder-new
	
		DOMDocument: as-string read/binary src-folder/DOMDocument.xml
		

		xmldom: third parse-xml+/trim DOMDocument
		dom-symbols: get-node-content xmldom %DOMDocument/symbols
		;change-dir trg-folder

		n: 1
		if timelines: get-nodes xmldom %DOMDocument/timelines/DOMTimeline [
			newName: join "newSymbol" n
			dom-newSymbol: third parse-xml+/trim create-symbol reduce ['name newName]

			tmp: get-node-content dom-newSymbol %DOMSymbolItem/timeline/DOMTimeline

			tmp/1/3: copy timelines/1/3/1/3

			write/binary rejoin [xfl-folder-new %LIBRARY/ newName %.xml] xmltree-to-str dom-newSymbol
			
			clear get-node-content xmldom %DOMDocument/timelines
			insert get-node-content xmldom %DOMDocument/timelines  third parse-xml+/trim ajoin [{
			<DOMTimeline name="Scene 1">
               <layers>
                    <DOMLayer name="} newName {" color="#FF4FFF" current="true" isSelected="true">
                         <frames>
                              <DOMFrame index="0" keyMode="9728">
                                   <elements>
                                        <DOMSymbolInstance libraryItemName="} newName {"/>
                                   </elements>
                              </DOMFrame>
                         </frames>
                    </DOMLayer>
               </layers>
			</DOMTimeline>}]
			
			n: n + 1

		]
		print "========="
		unless exists? trg-folder [make-dir/deep trg-folder]
		write/binary trg-folder/DOMDocument.xml xmltree-to-str xmldom
	]

	print {xflDocToSymbol %tests/test_1/}
]


