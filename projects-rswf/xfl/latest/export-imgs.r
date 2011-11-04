rebol []
rs/run 'imagecore

with ctx-XFL [
	rob-scale-x: round/to 724 / 1250 .001
	rob-scale-y: round/to 448 / 790  .001

	export-imgs: func[file][
		src-folder: 
		xfl-folder:
		xfl-folder-new:
		trg-folder:	file ;dirize join %/f/SVN/machinarium/XFL_ORIG/ file
	
		DOMDocument: as-string read/binary src-folder/DOMDocument.xml
		
		
		xmldom: third parse-xml+/trim DOMDocument
		;change-dir trg-folder
		if items: get-nodes xmldom %DOMDocument/media/DOMBitmapItem [
			foreach item items [
				probe item/2/("href")
				export-media-item item/2
				;img-file: probe to-rebol-file item/2/("sourceExternalFilepath")
				;print "--"
	
		
			]
		]
	]
	;export-imgs  join what-dir %tests/muchy/
	;halt
	;export-imgs  %/f/svn/machinarium/xfl_orig/02_brana/
	;halt
	xfls: %/f/svn/machinarium/xfl_orig/
	foreach d read xfls [
		if exists? join xfls/:d %DOMDocument.xml [
			export-imgs
			  xfls/:d
		]
	]
	;export-imgs  join what-dir %tests/zarovka/ ;%/f/svn/machinarium/xfl_orig/02_brana/    %07_bachar/
	
]
rs/go 'xfl
halt
