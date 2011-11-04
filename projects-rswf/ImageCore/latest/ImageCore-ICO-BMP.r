rebol [
	title: "ImageCore ICO and BMP functions"
]

	readICONDIR: does [context[
		Width:        readUI8  ;Width of icon in pixels
		Height:       readUI8  ;Height of icon in pixels
		NumColors:    readUI8  ;Maximum number of colors - If the bitmap contains 256 or more colors the value of NumColors will be 0.
		Reserved:     readUI8  ;Not used (always 0)
		NumPlanes:    readUI16 ;Not used (always 0)
		BitsPerPixel: readUI16 ;Not used (always 0)
		DataSize:     readUI32 ;Length of icon bitmap in bytes 
		DataOffset:   readUI32 ;Offset position of icon bitmap in file
	]]
	
	readBITMAPFILEHEADER: does[context[
		bfSize:    readUI32
		bfOffBits: (skipBytes 4 readUI32)
	]]
	readBITMAPINFOHEADER: does[context[
		biSize:          readUI32
		biWidth:         readUI32
		biHeight:        readUI32
		biPlanes:        readUI16
		biBitCount:      readUI16
		biCompression:   readUI32
		biSizeImage:     readUI32
		biXPelsPerMeter: readUI32
		biYPelsPerMeter: readUI32
		biClrUsed:       readUI32
		biClrImportant:  readUI32
	]]
	readICOBMP: func[icoDir /local buf icoBMP][
		buf: inBuffer
		inBuffer: at head inBuffer icoDir/DataOffset + 1
		bmpHeader: readBITMAPINFOHEADER
		;? bmpHeader
		bmpData:   copy/part inBuffer (icoDir/DataSize - bmpHeader/biSize)
		;? bmpData
		inBuffer: buf
		BMP2ARGB/withAlpha icoDir/width icoDir/height bmpHeader bmpData
	]
	readRGBATable: func[colors /local RGBATable][
		RGBATable: make block! colors
		loop colors [insert tail RGBATable reverse readBytes 4]
		RGBATable
	]
	readRGBTable: func[colors /local RGBTable][
		RGBTable: make block! colors
		loop colors [insert tail RGBTable reverse readBytes 3 skipByte]
		RGBTable
	]
	BMP2ARGB: func[
		width height bmpHeader bmpData
		/withAlpha
		/local buf pixels imageDataSize colorTable b c icXor icAnd bARGB width8 sk][
		;store previous stream buffer state	
		buf: inBuffer
		inBuffer: bmpData
		pixels: width * height
		bARGB:  make binary! (pixels * 4)
		insert/dup bARGB #{FF} (pixels * 4)
		;? bmpHeader
		switch bmpHeader/biBitCount [
			4 [
				colorTable: readRGBATable either bmpHeader/biClrUsed = 0 [16][bmpHeader/biClrUsed]
				until [
					b: readUI8
					c: 1 + ((240 and b) / 16)
					bARGB: change bARGB colorTable/:c 
					c: 1 + (15 and b)
					bARGB: change bARGB colorTable/:c 
					tail? bARGB
				]
			]
			8 [
				colorTable: readRGBATable either bmpHeader/biClrUsed = 0 [256][bmpHeader/biClrUsed]
				until [
					bARGB: change bARGB head change colorTable/(1 + readUI8) #{FF}
					tail? bARGB
				]
			]
			16 [
				until [
					bARGB: change next bARGB to-binary short-to-rgb readUI16
					tail? bARGB
				]
			]
			24 [
				until [
					bARGB: change next bARGB reverse readBytes 3
					tail? bARGB
				]
			]
			32 [
				until [
					bARGB: change bARGB  reverse readBytes 4
					tail? bARGB
				]
			]
		]
		bARGB: head bARGB

		if all [withAlpha bmpHeader/biBitCount < 32] [
			width8: to-integer width / 8
			sk: width8 // 4
			until [
				loop width8 [
					b: readUI8
					loop 8 [
						change bARGB either 128 = (128 and b) [#{00}][#{FF}]
						bARGB: skip bARGB 4
						if tail? bARGB [break]
						b: b * 2
					]
				]
				skipBytes sk
				tail? bARGB
			]
		]
		
		make object! compose [
			size:   (as-pair width height)
			bARGB:  (flip-vertical head bARGB ( 4 * width))
			alpha?: (withAlpha)
		]
	]
	
	
