rebol[
	title: "ico-parser2"
	purpose: "To get data from the windows *.ico files"
	author: "Oldes"
	email: oldes@bigfoot.com
	date: 14-Aug-2001/14:09:44+2:00
	version: 0.0.5
	history: [
		14-8-2001 "oldes" "Fixed bug in the transparency of small (16x16) and large (64x64) icons"
		8-8-2001  "oldes" "Improved - now should support even 4 and 8 bit color depth icons" 
		30-7-2001 "oldes" "initial version"
	]
	comment: {This is a little bit different from the ico-parser script (instead of mask there is only block of key (transparent) colors in the image.
		(this is probably working only for icons in 24bits color depth!)}
	usage: {
		ico-parser/load-ico http://sweb.cz/desold/icons/Icon21.ico ;or %Icon21.ico
		icon: ico-parser/get-icon	;returns image
		or
		icon: ico-parser/get-icon/asFace	;returns face
		transparent color is in the parser object (ico-parser/key-color)
		;--->see script %ico-view2.r how to use it}
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
	
	find-key-color: func[
		"Finds color that's not used in the image for transparency"
		img-colors
		/local key "The key color"
	][
		while [found? find img-colors key: random 255.255.255][]
		key
	]
	
	get-color-table: func [bData /noflip /local color-table][
		color-table: make block! ((length? bData) / 4)
		foreach [B G R null] bData [
			insert tail color-table to-binary reduce either noflip [[B G R]][[R G B]]
		]
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

	load-ico: func[file][
		init
		filename: file
		icon: either url? file [
			read-thru   file
		][	read/binary file	]
		get-headers
	]
		
	get-icon: func[
		"Gets the icon image from the ico loaded with 'load-ico"
		/num i	"Which icon from the ico file (if not specified, the last one is used)"
		/asFace "Returns icon as face instead of image"
		/nosafeTransparency "Not Using safe transparency (faster - not all colors are tested)"
;		/local pixels row crow bOffset icXor icAnd flipedicAnd
	][
		if ico/icons = 0 [print "No ico file loaded" return]
		if any [not num i > ico/icons] [i: ico/icons]
		icoDir: ico/dirs/:i
		icoHeader: ico/bitmapinfoheaders/:i
		width:  icoDir/width
		height: icoDir/height
		size: to-pair reduce [width height]
		pixels: width * height

		bOffset: icoDir/DataOffset + icoHeader/biSize ;data start
		;The next process depends on the color resolution of the bitmap
		;that's in biBitCount value:
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
				colorTable: get-color-table/noflip colorTdata
			]
			24 [
				colorTableLength: 0
				image-data-length: 3 * pixels
			]
		]
		
		
		

		bOffset: bOffset + colorTableLength
		icXor: 	copy/part ( skip head icon bOffset) image-data-length
		bOffset: bOffset + image-data-length
		icAnd: copy/part (skip head icon bOffset) (icoDir/DataSize - icoHeader/biSize - image-data-length)

		;geting bmp pixels
		icBin: make binary! (pixels * 3)
		switch icoHeader/biBitCount [
			4 [
				i: 0
				while [not tail? icXor][
					b: enbase/base copy/part icxor 1 2
					c: 1 + to-integer load rejoin [
						"2#{0000" copy/part b 4 "}"
					]
					if none? colorTable/:c [probe c]
					insert tail icBin colorTable/:c
					c: 1 + to-integer load rejoin [
						"2#{0000" skip b 4 "}"
					]
					insert head icBin colorTable/:c
					icXor: next icXor
					i: i + 2
				]
			]
			8 [
				while [not tail? icXor][
					row: copy/part icXor width
					crow: make binary! #{}
					foreach c row [
						c: 1 + to-integer c
						append crow colorTable/:c
					]
					insert head icBin crow
					icXor: skip icXor width
				]
			]
			24 [
				while [not tail? icXor][
					insert head icBin copy/part icXor (width * 3)
					icXor: skip icXor (width * 3)
				]
			]
		]
			
		img: make image! reduce [to-pair reduce [width height] icBin]
		flipedicAnd: make binary! length? icAnd
		loop height [
			insert head flipedicAnd copy/part icAnd (width / 8)
			icAnd: skip icAnd either width <= 32 [4][8];width / 8 ]
		]
		maskBits: (enbase/base flipedicAnd 2)
		
		;there are two ways how to do the transparency
		;1. to find color that's not in the image and replace all colors
		;   in the img where the mask bitis 0 to this color (used for 'key effect)
		;2. to find first transparent pixel (bit in the 'maskBits) and surmis
		;   that all (and only) this colors are transparent [this is faster]
		key-color: either nosafeTransparency [
			either found? i: find maskBits #"0" [
				pick img index? i
			][
				none
			]
		][
			key-color: find-key-color icBin
			for i 1 (width * height) 1 [
				if #"1" = maskBits/:i [poke img i key-color]
			]
			key-color
		]
		either asFace [
			make face compose [size: ( img/size ) image: (img) edge: none]
		][
			img
		]
	]
]
