rebol[
	title: "ico-parser2"
	purpose: "To get data from the windows *.ico files"
	author: "Oldes"
	email: oldes.huhuman@gmail.com
	date: 28-May-2006/17:12:05+2:00
	version: 0.0.6
	history: [
		28-5-2006 "oldes" "Added support for 32bit icons"
		14-8-2001 "oldes" "Fixed bug in the transparency of small (16x16) and large (64x64) icons"
		8-8-2001  "oldes" "Improved - now should support even 4 and 8 bit color depth icons" 
		30-7-2001 "oldes" "initial version"
	]
	comment: {This is a little bit different from the ico-parser script (instead of mask there is only block of key (transparent) colors in the image.
		(this is probably working only for icons in 24bits color depth!)
		
		Windows system icons are stored in C:\WINDOWS\System32\shell32.dll
	}
	usage: {
		ico-parser/load-ico http://sweb.cz/desold/icons/Icon21.ico ;or %Icon21.ico
		icon: ico-parser/get-icon	;returns image
		or
		icon: ico-parser/get-icon/asFace	;returns face
		transparent color is in the parser object (ico-parser/key-color)
		;--->see script %ico-view2.r how to use it}
	require: [
		lib %gunzip.r
		rs-project %error-handler
		rs-project %bmp-parser
		rs-project %binary-conversions
	]
]

ico-parser: make object! [
	
	reversed: func[w][copy head reverse w]
	
	ico: none
	icon: none
	filename:	none
	
	key-color: none
	flipedicAnd: icXor: icAnd: img: maskBits: none
	size: none
	
	specs: make object! [
		icon: [
		;name			bytes	comment
			'Reserved  		2		;Reserved (always 0)
			'ResourceType	2		;Resource ID (always 1)
			'IconCount		2		;Number of icon bitmaps in file
		]
		iconDir: [
			'Width		1		;Width of icon in pixels
			'Height		1		;Height of icon in pixels
			'NumColors	1		;Maximum number of colors - If the bitmap contains 256 or more colors the value of NumColors will be 0. 
			'Reserved	1		;Not used (always 0)
			'NumPlanes	2		;Not used (always 0)
			'BitsPerPixel	2	;Not used (always 0)
			'DataSize	4		;Length of icon bitmap in bytes 
			'DataOffset	4		;Offset position of icon bitmap in file
		]
		BITMAPINFOHEADER: [
			'biSize 	4		;size of the BITMAPINFOHEADER structure, in bytes. 
			'biWidth 	4		;width of the image, in pixels. 
			'biHeight	4		;height of the image, in pixels. 
			'biPlanes	2		;number of planes of the target device, must be set to zero. 
			'biBitCount	2		;number of bits per pixel. 
			'biCompression	4	;type of compression, usually set to zero (no compression). 
			'biSizeImage	4	;size of the image data, in bytes. If there is no compression, it is valid to set this member to zero. 
			'biXPelsPerMeter	4	;horizontal pixels per meter on the designated targer device, usually set to zero. 
			'biYPelsPerMeter	4	;vertical pixels per meter on the designated targer device, usually set to zero. 
			'biClrUsed		4		;number of colors used in the bitmap, if set to zero the number of colors is calculated using the biBitCount member. 
			'biClrImportant	4
		]
	]

	get-data-by-spec: func[
		"Returns block of word and values and rest of the data file"
		data	[binary!]	"Binary data for examination"
		spec	[block!]	"Specification block of words and length in bytes"
	][
		values: make block! []
		foreach [name bytes] spec [
			repend values [name b: to-integer reversed copy/part data bytes]
			;print [name b]
			data: skip data bytes
		]
		;print "--------------"
		reduce [values data]
	]
	
	get-color-table: func [bData /local color-table][
		color-table: make hash! ((length? bData) / 4)
		print "!!!" probe bData
		until [
			insert tail color-table head reverse copy/part bData 3
			tail? bData: skip bData 4
		]
		bData: head bData
		color-table
	]
	
	init: does [
		ico: make object! [
			icons:	0
			dirs: make block! []
			bitmapinfoheaders: make block! []
		]
	]
	get-headers: func[/local tmp tmp2  ][
		init
		tmp: get-data-by-spec icon specs/icon
		ico/icons: tmp/1/IconCount
		loop ico/icons [
			;First I get IconDir data:
			tmp: get-data-by-spec copy tmp/2 specs/iconDir
			append/only ico/dirs tmp/1
			;Then Bitmap info header:
			tmp2: get-data-by-spec skip icon tmp/1/DataOffset specs/BITMAPINFOHEADER
			append/only ico/bitmapinfoheaders tmp2/1
		]
		ico
	]

	load-ico: func[file /verbose /local i][
		filename: file
		icon: either url? file [
			read-thru   file
		][	read/binary file	]
		if #{1F8B08} = copy/part icon 3 [
			;compressed file
			attempt [icon: gunzip icon]
		]
		
		if #{00000100} <> copy/part icon 4 [
			make error! "not an ico file"
		]
		get-headers
		if verbose [
			i: 1
			foreach dir ico/dirs [
				print rejoin [i tab dir/width "x" dir/height "  Colors:" dir/NumColors "  BitsPerPixel:"  dir/BitsPerPixel]
				i: i + 1
			]
		]
		true
	]
	
	get-icon-num-by-width: func[
		"Returns id of icon with specified width (or none if not found)"
		width [integer!] "Required width of icon (usually 16,24,32,48,64,128)"
	][
		;going backwards to have a better chance to get the one with the most colors
		for i length? ico/dirs 1 -1 [
			if ico/dirs/(i)/width = width [ return i ]
		]
		none
	]
	
	flip-vertical: func[imgBin width /local newImg nwidth][
		newImg: copy imgBin
		imgBin: tail imgBin
		nwidth: negate width
		until [
			tail? newImg: change newImg copy/part  imgBin: skip imgBin nwidth  width
		]
		head newImg
	]
	
	get-icon-bll: func[
		/num i	"Which icon from the ico file (if not specified, the last one is used)"
	][
		if ico/icons = 0 [print "No ico file loaded" return]
		if any [not num i > ico/icons] [i: ico/icons]
		;probe
		 icoDir: ico/dirs/:i
		;probe
		 icoHeader: ico/bitmapinfoheaders/:i
		width:  icoDir/width
		height: icoDir/height

		size: to-pair reduce [width height]
		pixels: width * height

		bOffset: icoDir/DataOffset + icoHeader/biSize ;data start
		;The next process depends on the color resolution of the bitmap
		;that's in biBitCount value:
		print ["icoHeader/biBitCount = " icoHeader/biBitCount]
		switch icoHeader/biBitCount [
			4 [
				colorTableLength: 64
				image-data-length: pixels / 2
				colorTable: get-color-table colorTdata: copy/part (skip icon bOffset) colorTableLength
			]
			8 [
				colorTableLength: 1024
				image-data-length: pixels
				colorTable: get-color-table colorTdata: copy/part (skip icon bOffset) colorTableLength
			]
			24 [
				colorTableLength: 0
				image-data-length: 3 * pixels
			]
			32 [
				colorTableLength: 0
				image-data-length: 4 * pixels
			]
		]
		bOffset: bOffset + colorTableLength
		icXor: 	copy/part ( skip head icon bOffset) image-data-length
		bOffset: bOffset + image-data-length
		icAnd: copy/part (skip head icon bOffset) (icoDir/DataSize - icoHeader/biSize - image-data-length)
		;print ["icAnd:" length? icAnd mold icAnd]
		;print ["icXor:" length? icXor mold icXor]

		;geting bmp pixels
		icBin:   make binary! 2 + (pixels * 4)
		insert/dup icBin #{FF} (pixels * 4)
		icAlpha: make binary! 2 +  pixels

		switch icoHeader/biBitCount [
			44 [
				until [
					c: ((240 and icxor/1) / 16)
					insert tail icBin  to-char c
					c: (15 and icxor/1)
					insert tail icBin  to-char c
					tail? icXor: next icXor
				]
			]
			4 [
				until [
					c: 1 + ((240 and icxor/1) / 16)
					icBin: change next icBin colorTable/:c 
					c: 1 + (15 and icxor/1)
					icBin: change next icBin colorTable/:c 
					icXor: next icXor
					tail? icBin
				]
			]
			8 [
				until [
					icBin: change next icBin colorTable/(1 + icXor/1)
					icXor: next icXor
					tail? icBin
				]
			]
			24 [
				until [
					icBin: change next icBin head reverse copy/part icXor 3
					icXor: skip icXor 3
					tail? icBin
				]
			]
			32 [
				until [
					icBin: change icBin  head reverse copy/part icXor 4
					icXor: skip icXor 4
					tail? icBin
				]
			]
		]
		probe icBin: head icBin
		;comment {
		if icoHeader/biBitCount < 32 [
	
				width8: to-integer width / 8
				sk: width8 // 4

				until [
					loop width8 [
						
						b: icAnd/1
						p: 0
						loop 8 [
							;insert tail icAlpha either 128 = (128 and b) [#{FF}][#{00}]
							change icBin either 128 = (128 and b) [#{00}][#{FF}]
							icBin: skip icBin 4
							if tail? icBin [print "!@@@@@@@@@@@@" break]
							b: b * 2
						]
						icAnd: next icAnd
					]

					icAnd: skip icAnd sk
					any [tail? icBin tail? icAnd]
				]
		
		]
		;}
		{
		probe colorTdata
		palette: make binary! length? colorTdata
		until [
			insert tail palette  join head reverse copy/part colorTdata 3 #{FF}  
			tail? colorTdata: skip colorTdata 4
		]
		colorTdata: head colorTdata
		
		prin "palette: " probe palette
		}
		;probe icAlpha
		;probe head icBin
		
		reduce [
			as-pair width height
			rejoin [
				#{05}
				int-to-ui16 width 
				int-to-ui16 height
				;int-to-ui8  icoDir/NumColors - 1 ;BitmapColorTableSize
				;head remove/part tail compress join palette head icBin -4 ;ZLIBBITMAPDATA
				head remove/part tail compress flip-vertical head icBin ( 4 * width) -4 ;ZLIBBITMAPDATA
				;head remove/part tail compress head icBin -4 ;ZLIBBITMAPDATA
			]
		]
	]
	get-icon: func[
		"Gets the icon image from the ico loaded with 'load-ico"
		/num i	"Which icon from the ico file (if not specified, the last one is used)"
		/asFace "Returns icon as face instead of image"
		;/nosafeTransparency "Not Using safe transparency (faster - not all colors are tested)"
		/local pixels row bOffset biHeight icXor icAnd flipedicAnd icAlpha width8
	][
		if ico/icons = 0 [print "No ico file loaded" return]
		if any [not num i > ico/icons] [i: ico/icons]
		;probe
		 icoDir: ico/dirs/:i
		;probe
		 icoHeader: ico/bitmapinfoheaders/:i
		width:  icoDir/width
		height: icoDir/height

		size: to-pair reduce [width height]
		pixels: width * height

		bOffset: icoDir/DataOffset + icoHeader/biSize ;data start
		;The next process depends on the color resolution of the bitmap
		;that's in biBitCount value:
		;print ["icoHeader/biBitCount = " icoHeader/biBitCount]
		switch icoHeader/biBitCount [
			4 [
				colorTableLength: 64
				image-data-length: pixels / 2
				colorTdata: copy/part (skip icon bOffset) colorTableLength
				colorTable: get-color-table colorTdata
			]
			8 [
				colorTableLength: 1024
				image-data-length: pixels
				colorTdata: copy/part (skip icon bOffset) colorTableLength
				colorTable: get-color-table colorTdata
			]
			24 [
				colorTableLength: 0
				image-data-length: 3 * pixels
			]
			32 [
				colorTableLength: 0
				image-data-length: 4 * pixels
			]
		]
		
		
		

		bOffset: bOffset + colorTableLength
		icXor: 	copy/part ( skip head icon bOffset) image-data-length
		bOffset: bOffset + image-data-length
		icAnd: copy/part (skip head icon bOffset) (icoDir/DataSize - icoHeader/biSize - image-data-length)
		;print ["icAnd:" length? icAnd]
		;print ["icXor:" length? icXor]

		;geting bmp pixels
		icBin:   make binary! 2 + (pixels * 3)
		icAlpha: make binary! 2 +  pixels
		
		
		
		switch icoHeader/biBitCount [
			4 [
				until [
					c: 1 + ((240 and icxor/1) / 16)
					insert tail icBin   colorTable/:c
					c: 1 + (15 and icxor/1)
					insert tail icBin colorTable/:c
					tail? icXor: next icXor
				]
			]
			8 [
				until [
					c: 1 + icXor/1
					insert tail icBin colorTable/:c
					tail? icXor: next icXor
				]
			]
			24 [
				while [not tail? icXor][
					loop width [
						insert tail icBin head reverse copy/part icXor 3
						icXor: skip icXor 3
					]
				]
			]
			32 [
				until [
					insert tail icBin  head reverse copy/part icXor 3
					icXor: skip icXor 3
					insert tail icAlpha icXor/1
					tail? icXor: next icXor
				]
			]
		]

		
		if icoHeader/biBitCount < 32 [
	
				width8: to-integer width / 8
				sk: width8 // 4

				until [
					loop width8 [
						
						b: icAnd/1
						p: 0
						loop 8 [
							insert tail icAlpha either 128 = (128 and b) [#{FF}][#{00}]
							b: b * 2
						]
						icAnd: next icAnd
					]

					tail? icAnd: skip icAnd sk
				]
		
		]
				
		img: make image! reduce [to-pair reduce [width height] icBin]
		img/alpha: icAlpha
		
	
		either asFace [
			make face compose/deep [
				color: 255.255.255
				size: ( img/size )
				effect: [flip 0x1]
				image: (img)
				edge: none
			]
		][
			img
		]
	]
]


change-file-extension: func[file ext][
	join head clear find/last/tail copy form file "." ext
]


icons-to-png: func[icons-dir /local pngs-dir img-file bin err img ][

	used-checksums: copy []
	
	if not exists? pngs-dir: join icons-dir %pngs/ [make-dir pngs-dir]
	
	foreach ico-file read icons-dir [
		if parse form ico-file [ thru ".ico" end] [
			print ico-file
			bin: read/binary icons-dir/:ico-file
			either find used-checksums chck: checksum/secure bin [
				print ["---------> skipping"]
			][
				append used-checksums chck

				attempt [
					if error? set/any 'err try [
						ico-parser/load-ico icons-dir/:ico-file
						img-file: change-file-extension ico-file "png"
						save/png pngs-dir/:img-file to-image ico-parser/get-icon/num/asFace 4
					][
						err: disarm err
						;probe err
						
						
						
						parse/all bin [
							 
								"‰PNG" to end (
									write/binary pngs-dir/:img-file bin
								)
								|
								"GIF" to end (
									img-file: change-file-extension ico-file "gif"
									write/binary pngs-dir/:img-file bin
								)
								|
								"BM" to end (
									prin ["BMP?"]
									attempt [
										img-file: change-file-extension ico-file "png"
										print either image? img: bmp-parser/loadBMPicon bin [
											save/png pngs-dir/:img-file img
											".... jo"
										][ ".... ne"]
									]
								)
								|
								"ÿØÿà" to end (
									img-file: change-file-extension ico-file "jpg"
									write/binary pngs-dir/:img-file bin
								)
								#{1F8B} to end (
									print ["!! ERROR !!!!!!!!! GZiped file not supported yet!"]
								)
								| thru {<html>} to end (
									delete icons-dir/:ico-file
								)
								| to end (
									print ["!! ERROR !!!!!!!!![" err/code "]" err/type err/id mold err/arg1]
								)
			
							
						]
					]
				]
			]
		]
	]
	
	all-icons-image: make image! [640x640 255.255.255]
	pos: 0x0
	foreach img-file read pngs-dir [
		attempt [
			img: load pngs-dir/:img-file
			if image? img [
				
				draw all-icons-image reduce either img/size <> 16x16 [
					['image img pos pos + 16x16]
				][	['image img pos] ]
				pos: pos + 16x0
				if pos/x >= 640 [pos/x: 0 pos/y: pos/y + 16]
			]
		]
	]
	save/png icons-dir/all-icons.png all-icons-image
	view center-face layout [image all-icons-image]
]



;icons-to-png %/m/___icons___/ ;%test/ %. ;	to-rebol-file "I:\images\icons\"


;ico-parser/load-ico to-rebol-file "www.webtvorba.cz.ico"  ;biSize 40 biWidth 16 biHeight 32 biPlanes 1 biBitCount 8 biCompression 0 biSizeImage 320 biXPelsPerMeter 0 biYPelsPerMeter 0 biClrUsed 0 biClrImportant 0]
;ico-parser/load-ico %1.im.cz.ico ;32
;ico-parser/load-ico/verbose %www.penize.cz.ico
;ico-parser/load-ico/verbose %community.livejournal.com.ico
;ico-parser/load-ico/verbose %vancouver-webpages.com.ico ;%www.toplist.cz.ico <-error
;"dev.mysql.com.ico"
ico-parser/load-ico to-rebol-file "www.rebol.com.ico"
probe ico-parser/get-headers
;probe ico-parser/get-icon-bll/num 1

;view center-face ico-parser/get-icon/num/asFace 3
;save/png %test.png ico-parser/get-icon/num 1

;ico-parser/load-ico to-rebol-file "www.informacezbrna.cz.ico"
