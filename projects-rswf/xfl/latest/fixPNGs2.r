rebol []

;src: make image! [5x1 #{1900007E0000540000190000000000} #{3E3E7ED8FF}]
demultiply-img: func[file][
	img: load probe file
	;img: copy src
	alpha: img/alpha
	n: 1
	forall alpha [
		if 255 > a: alpha/1 [
			a: 256 / (255 - a)
			p: img/:n * a
			p/4: alpha/1
			img/:n: p
		]
		n: n + 1
	]
	;probe img
	save/png file img
	file
]

;demultiply-img %zarovka-1.png ;brana_1250_veci_crop_37x132_740x501.png

with ctx-XFL [
	fix-imgs: func[dir][
		print ["*******" dir]
		unless exists? dir/_fixed_ [
			
			src-folder: 
			xfl-folder:
			xfl-folder-new:
			trg-folder:	dir ;dirize join %/f/SVN/machinarium/XFL_ORIG/ file
		
			DOMDocument: as-string read/binary src-folder/DOMDocument.xml
			
			
			xmldom: third parse-xml+/trim DOMDocument
			;change-dir trg-folder
			if items: get-nodes xmldom %DOMDocument/media/DOMBitmapItem [
				foreach item items [
					probe item-file: copy any [
						select item/2 "sourceExternalFilepath"
						join "./LIBRARY/" item/2/("href")
					]
					unless find ["png" "jpg"] last parse item-file "." [append item-file %.png]
					full-file: join dir item-file
					either any [
						not exists? full-file
						13-Jan-2011/7:34:36+1:00 > modified? full-file 
					][
						;ask "upd"
						export-media-item/overwrite item/2
						import-media-img/as demultiply-img full-file item/2/("bitmapDataHRef")
						;img-file: probe to-rebol-file item/2/("sourceExternalFilepath")
						;print "--"
					][
						;ask "skip"
					]
				]
			]
			write dir/_fixed_ ""
		]
	]
	
	fix-png-names: func[dir][
		print ["*******" dir]

		src-folder: 
		xfl-folder:
		xfl-folder-new:
		trg-folder:	dir ;dirize join %/f/SVN/machinarium/XFL_ORIG/ file
	
		DOMDocument: as-string read/binary src-folder/DOMDocument.xml
		
		
		xmldom: third parse-xml+/trim DOMDocument
		;change-dir trg-folder
		if items: get-nodes xmldom %DOMDocument/media/DOMBitmapItem [
			foreach item items [
				old-img-file: join dir to-rebol-file item/2/("sourceExternalFilepath")
				if find old-img-file %.png.png [
					
					either exists? old-img-file [
						print ["rename: " old-img-file]
						new-img-file: replace copy old-img-file %.png.png %.png
						tmp: replace copy last split-path old-img-file %.png.png %.png
						if exists? new-img-file [
							delete new-img-file
						]
						rename old-img-file tmp
					][
						ask "missing file?"
					]
				]
			]
			replace/all DOMDocument ".png.png" ".png"
			write/binary trg-folder/DOMDocument.xml DOMDocument	
		]
	]
	;fix-imgs %/f/svn/machinarium/xfl/02_brana/
	;fix-png-names %/f/svn/machinarium/xfl/25_mozkovna/
	;halt
	xfls: %/F\RS\projects-mm\robotek\PlayBook\XFL\ %/f/svn/machinarium/xfl/
	foreach d read xfls [
		if exists? join xfls/:d %DOMDocument.xml [
			fix-imgs
			;fix-png-names
			  xfls/:d
		]
	]
	   ;join what-dir %tests/02_brana/ ;%/f/svn/machinarium/xfl_orig/02_brana/    %07_bachar/
]


