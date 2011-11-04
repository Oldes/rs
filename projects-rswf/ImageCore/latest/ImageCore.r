REBOL [
    Title: "Img-to-bll"
    Date: 26-Dec-2007/23:17:28+1:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "David Oliva (commercial)"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: [
   		;img2bll/parse %opetmuzem.cz.ico
		;img2bll/parse %uchoko.ffa.vutbr.cz.ico.bmp
		img2bll/parse %png24t-13x16.png ;%testi.png ;%w01.png
	]
    Purpose: none
    Comment: none
    History: none
    Language: none
    Type: none
    Content: none
    Email: oliva.david@seznam.cz
    require: [
		rs-project 'stream-io
		rs-project 'binary-conversions
		rs-project 'zlib-decompress
		rs-project 'crc32
		;lib %gunzip.r
	]
	preprocess: true
]

ImageCore: make stream-io [
	file: pixels: header: img-type: none
	
	open: func["Reads image file into buffer" img-file][
		setStreamBuffer either binary? img-file [file: none img-file][read/binary file: img-file]
	]

	#include %ImageCore-ICO-BMP.r
	#include %ImageCore-PNG.r
	
	
	alignedSize: func[size /local r][
		either 0 = r: size // 2 [size][size + 2 - r]
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
	
	byt16Vals: make block! [
   		     0  16 24 32 40 48 56 64
     		72 80 88 96 104 112 120 128
     		136 144 152 160 168 176 184 192
     		200 208 216 224 232 240 248 255
	]
	short-to-rgb: func[b16 "16 bits of color value"][
		r: 1 + to integer! ((b16 and 31744) / 1024) ; 31744 = 2#{0111110000000000}
		g: 1 + to integer! ((b16 and 992  ) / 32  ) ; 2016  = 2#{0000001111100000}
		b: 1 + to integer!  (b16 and 31   )         ; 31    = 2#{0000000000011111}
		;print reduce [r g b]
		to-tuple reduce [byt16Vals/:r byt16Vals/:g byt16Vals/:b]
	]
	
	ARGB2BLL: func[img [object!]][
		rejoin [
			#{05}
			int-to-ui16 img/size/x
			int-to-ui16 img/size/y
			head remove/part tail compress head img/bARGB -4 ;ZLIBBITMAPDATA
		]
	]
	ARGB2RGBA: func[img [object!] /local RGBA ARGB sk cols rows][
		ARGB: img/ARGB
		RGBA: copy ARGB
		sk: alignedSize img/size/width
		cols: img/size/x
		rows: img/size/y
		loop rows [
			loop cols [
				RGBA: change RGBA copy/part next ARGB 3
				RGBA: change RGBA first ARGB
				ARGB: skip ARGB 4
			]
			RGBA: skip RGBA sk
			ARGB: skip ARGB sk
		]
		head RGBA
	]

	
	requiredICOwidth: 16
	
	load: func[img-file /local icoDir FILEHEADER header palette tmp][
		open img-file
		if #{1F8B08} = copy/part inBuffer 3 [
			;compressed file
			print "compressed file"
			attempt [inBuffer: gunzip inBuffer]
		]
		case [
			#{00000100} = copy/part inBuffer 4 [
				img-type: %ICO
				;print ["ICO file" ]
				skipBytes 4
				tmp: inBuffer
				;probe index? tmp
				loop readUI16 [
					;First I get IconDir data:
					icoDir: readICONDIR
					;? icoDir
					if icoDir/width = requiredICOwidth [
						return readICOBMP icoDir
						;? icoBMP
					]
				]
				;print ["Icon is missing required width!"]
				return none
				inBuffer: tmp
				loop readUI16 [
					
					return readICOBMP readICONDIR
					break
				]
				
			]
			#{424D} = copy/part inBuffer 2 [
				img-type: %BMP
				;print ["BMP file" ]
				skipBytes 2
				FILEHEADER: readBITMAPFILEHEADER
				header:     readBITMAPINFOHEADER
				return BMP2ARGB header/biWidth header/biHeight header inBuffer
			]
			
			#{89504E470D0A1A0A} = copy/part inBuffer 8 [
				img-type: %PNG
				;print ["PNG file"]
				skipBytes 8
				header:  none
				return PNG2ARGB

			]
			#{474946} = copy/part inBuffer 3 [
				img-type: %GIF
				;print "!!! GIF image not supported yet"
				return none
			]
			true [
				img-type: none
				make error! reform ["Unknown image file:" mold img-file]
			]
		]
	]
	loadAsBLL: func[img-file][ARGB2BLL load img-file]
]

