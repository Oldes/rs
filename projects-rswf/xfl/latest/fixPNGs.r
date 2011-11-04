rebol []

with ctx-XFL [
	rob-scale-x: round/to 724 / 1250 .001
	rob-scale-y: round/to 448 / 790  .001

	fixPNGs: func[file][
		src-folder: dirize join %/f/SVN/machinarium/XFL/ file
		xfl-folder:
		xfl-folder-new:
		trg-folder:	dirize join %/f/rs/projects-mm/robotek/wii-final/XFL/ file
	
		DOMDocument: as-string read/binary trg-folder/DOMDocument.xml
		
		
		xmldom: third parse-xml+/trim DOMDocument
		change-dir trg-folder
		
		foreach item get-nodes xmldom %DOMDocument/media/DOMBitmapItem [
			probe item/2/("bitmapDataHref")
			probe item/2/("sourceExternalFilepath")
			img-file: probe to-rebol-file item/2/("sourceExternalFilepath")
			print "--"
			if find img-file %.png.png [
				if exists? img-file [
					tmp-img-file: replace copy img-file %.png.png %.png
					probe tmp: replace copy last probe split-path img-file %.png.png %.png
					if exists? tmp-img-file [
						delete probe tmp-img-file
					]
					rename img-file probe tmp
				]
				img-file: replace img-file %.png.png %.png
			]

			either exists? join src-folder img-file [
				;probe get-image-size join src-folder item/2/("sourceExternalFilepath")
				
				src-size: get-image-size join src-folder img-file
				;trg-size: get-image-size join trg-folder img-file
				either 0 = call/wait probe ajoin [
					"C:\UTILS\ImageMagick\convert.exe"
					{ "} to-local-file join src-folder img-file {"}
					;" -resize " trg-size "!"
					" -resize " form (round/ceiling(rob-scale-x * src-size/x)) "x" form (round/ceiling(rob-scale-y * src-size/y)) "!"
					" -unsharp 1x2.0+.3+0.05"
					" -strip"
					{ png32:"} to-local-file join trg-folder img-file {"}
				][
					import-media-img/as join trg-folder img-file item/2/("bitmapDataHref")
				][
					ask "*** problem with resizing!"
				]
			][
				ask "*** src file not found!"
			]
	
		]
		
		replace/all DOMDocument ".png.png" ".png"
		write/binary trg-folder/DOMDocument.xml DOMDocument	
	]
	
	fixPNGs %02_brana %07_bachar/
	
]
rs/go 'xfl
halt
