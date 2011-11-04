rebol [
	title: "ImageCore PNG functions"
]

	readUI32le: does [to integer! readBytes 4]
	png-chunk: func[type data /local chunk][
		;probe data
		if block? data [data: rejoin data]
		rejoin [
			reverse  int-to-ui32 length? data
			chunk: rejoin [
				as-binary type
				data
			]
			crc-32 chunk
		]
	]

	PNGunFilterScanline: func[filter scanLine lastScanLine bytesPerPixel /local nbpp][
		nbpp: negate bytesPerPixel
	    ;http://jsourcery.com/api/gnu.org/classpath/0.92/gnu/javax/imageio/png/PNGFilter.source.html#jj209729464
	    switch filter [
	    	1 [
	    		scanLine: skip scanLine bytesPerPixel
	    		loop length? scanLine [
    				scanLine: change scanLine to char! ((scanLine/1 + scanLine/:nbpp)  and 255)
    			]
    		]
    		2 [
    			loop bytesPerPixel [
    				scanLine: change scanLine  to char! ((lastScanline/1 + scanLine/1) and 255)
    				lastScanline: next lastScanline
				]
    
    			until [
    				loop bytesPerPixel [
    					scanLine: change scanLine to char! ((scanLine/1 + lastScanline/1) and 255)
    					lastScanline: next lastScanline
					]
					tail? scanLine
				]
			]
			3 [
				loop bytesPerPixel [
    				scanLine: change scanLine  to char! ((scanLine/1 + ( to integer! ( lastScanline/1 / 2)))  and 255)
    				lastScanline: next lastScanline
				]
    			loop length? scanLine [
    				scanLine: change scanLine to char! ( (scanLine/1 + ( to integer! (( scanLine/:nbpp + lastScanline/1) / 2)))  and 255)
    				lastScanline: next lastScanline
    			]
			]
	    	4 [
	    		loop bytesPerPixel [
	    			scanLine: change scanLine  to char! ((scanLine/1 + PaethPredictor 0 lastScanline/1 0) and 255)
    				lastScanline: next lastScanline
				]
    			until [
    				loop bytesPerPixel [
    					scanLine: change scanLine to char! ((scanLine/1 + PaethPredictor scanLine/:nbpp lastScanline/1 lastScanline/:nbpp) and 255)
    					lastScanline: next lastScanline
					]
					tail? scanLine
				]
    		]
    	]
	    head scanLine
	]
	PNG2ARGB: func[
		/local length type header idat palette newpalette colors tRNS gAMA filter
		byteAlign width height bytesPerRow bARGB pass row col col_start col_inc row_inc
		starting_row starting_col row_increment col_increment nbpp
		scanLineWidth scanLine lastScanline sb
	][
		palette: tRNS: none
		while [not tail? inBuffer][
			length: readUI32le
			;probe
			 type:   as-string readBytes 4
			
			switch/default type [
				"IHDR" [;Image header
					header: make object! [
						size:        as-pair readUI32le readUI32le
						bitDepth:    readUI8
						colorType:   readUI8
						compression: readUI8
						filter:      readUI8
						interlace:   readUI8 > 0
					]
					? header
					idat: copy #{}
				]
				"gAMA" [gAMA: readBytes length]
				"PLTE" [
					palette: readBytes length
					colors: (length? palette) / 3
					;? palette
				]
				"tRNS" [tRNS: readBytes length]
				"IDAT" [idat: insert idat readBytes length]
				"IEND" [
					;print length?
					 idat: head idat
					break					
				]
			][		
				skipBytes length
			]
			skipBytes 4 ;crc: readUI32
		]
		unless error? try [
			idat: as-binary zlib-decompress idat (
				(alignedSize header/size/x * alignedSize header/size/y) * 5
			)
		][
			;probe idat
			
			width:  header/size/x
			height: header/size/y
			bytesPerRow: 4 * width
			bARGB: make binary! (header/size/y * bytesPerRow)
			insert/dup bARGB #{FF} (header/size/y * bytesPerRow)
			
			if tRNS [
				;a tRNS chunk may contain fewer values than there are palette entries
				insert/dup tail tRNS #{00} colors - length? tRNS
				;? tRNS
				;? palette
				newpalette: copy #{}
				until [
					newpalette: insert newpalette a: to char! first tRNS
					a: a / 255
					newpalette: insert newpalette to char! a * first  palette
					newpalette: insert newpalette to char! a * second palette
					newpalette: insert newpalette to char! a * third  palette
					palette: skip palette 3
					tail? tRNS: next tRNS
				]
				palette: copy head newpalette
				;? palette
			]
			lastScanline: copy #{} 
			
			either header/interlace [
				print "INTERLACED"
				
				starting_row:  [0 0 4 0 2 0 1]
				starting_col:  [0 4 0 2 0 1 0]
				row_increment: [8 8 8 4 4 2 2]
				col_increment: [8 8 4 4 2 2 1]
				;block_height:  [8 8 4 4 2 2 1]
				;block_width:   [8 4 4 2 2 1 1]

				repeat pass 7 [
					row:        starting_row/:pass
				    col_start:  starting_col/:pass
				    col_inc:   col_increment/:pass
				    row_inc:   row_increment/:pass
					;print ["pass:" pass "col_inc:" col_inc ]
					bytesPerPixel: switch header/colorType [2 [3] 6 [4] 3 [1] 4]
					nbpp: negate bytesPerPixel
					;probe
					 scanLineWidth:  bytesPerPixel * (1 + to integer! ( (width - col_start - 1) / col_inc))
					;print ["width:" width "col_inc" col_inc "scanLineWidth:" scanLineWidth]
					clear head lastScanline
					insert/dup lastScanline #{00} scanLineWidth
					
				    while [row < height][
					    filter: first idat
					    ;print ["row:" row "filter:" filter]
					    idat: next idat
					    ;probe
					     scanLine: copy/part idat scanLineWidth
					    idat: skip idat scanLineWidth
					    ;probe copy/part idat 10
					    scanLine: lastScanline: PNGunFilterScanline filter scanLine lastScanline bytesPerPixel

					    bARGB: at head bARGB 1 + (row * width  + col_start * 4)
					    case [
							all [
								header/colorType = 2
								header/bitDepth  = 8
							][
								sb: 4 * col_inc
								loop (scanLineWidth - (scanLineWidth // 3)) / 3 [
					    			change next bARGB copy/part scanLine 3
					    			bARGB: skip bARGB sb
									scanLine: skip scanLine 3
				    			]
							]
							all [
								header/colorType = 6
								header/bitDepth  = 8
							][
								sb: 4 * (col_inc - 1)
								loop (scanLineWidth - (scanLineWidth // 4)) / 4 [
									bARGB: change bARGB to char! a: fourth scanLine
									a: a / 255
									bARGB: change bARGB to char! (a * first  scanLine)
									bARGB: change bARGB to char! (a * second scanLine)
									bARGB: change bARGB to char! (a * third  scanLine)
									bARGB: skip bARGB sb
									scanLine: skip scanLine 4
				    			]
							]
							all [
								header/colorType = 3 ;indexed
								header/bitDepth  = 8
							][
								sb: 4 * col_inc
								either tRNS [
									loop scanLineWidth [
										change bARGB  copy/part skip palette (4 * first scanLine) 4
										bARGB: skip bARGB sb
										scanLine: next scanLine
									]
								][
									loop scanLineWidth [
										change bARGB  copy/part skip palette (3 * first scanLine) 3
										bARGB: skip bARGB sb
										scanLine: next scanLine
									]
								]
							]
						]
				        row: row + row_inc
			    	]
			    ]
			][
				bytesPerPixel: switch header/colorType [2 [3] 6 [4] 3 [1] 4 [2] ]
				nbpp: negate bytesPerPixel
				scanLineWidth: bytesPerPixel * width
				clear head lastScanline
				insert/dup lastScanline #{00} scanLineWidth
				loop height [
					filter: first idat
					idat: next idat
					scanLine: copy/part idat scanLineWidth
				    idat: skip idat scanLineWidth
				    
		    		scanLine: lastScanline: PNGunFilterScanline filter scanLine lastScanline bytesPerPixel
				    
		    		case [
						all [
							header/colorType = 2
							header/bitDepth  = 8
						][
							loop scanLineWidth / 3 [
				    			bARGB: change next bARGB copy/part scanLine 3
								scanLine: skip scanLine 3
			    			]
						]
						all [
							header/colorType = 6
							header/bitDepth  = 8
						][
							loop scanLineWidth / 4 [
								bARGB: change bARGB to char! a: fourth scanLine
								a: a / 255
								bARGB: change bARGB to char! (a * first  scanLine)
								bARGB: change bARGB to char! (a * second scanLine)
								bARGB: change bARGB to char! (a * third  scanLine)
								scanLine: skip scanLine 4
			    			]
						]
						all [
							header/colorType = 3 ;indexed
							header/bitDepth  = 8
						][
							either tRNS [
								loop scanLineWidth [
									bARGB: change bARGB  copy/part skip palette (4 * first scanLine) 4
									scanLine: next scanLine
								]
							][
								loop scanLineWidth [
									bARGB: change next bARGB  copy/part skip palette (3 * first scanLine) 3
									scanLine: next scanLine
								]
							]
						]
						all [
							header/colorType = 4 ;greyscale
							header/bitDepth  = 8
						][
							loop scanLineWidth / 2 [
								bARGB: change bARGB to char! a: second scanLine
								a: a / 255
								loop 3 [bARGB: change bARGB to char! (a * first  scanLine)]
								scanLine: skip scanLine 2
			    			]
						]
					]
				]
			]
			;probe head bARGB
			make object! compose [
				size:   (header/size)
				bARGB:  (head bARGB)
				alpha?: true
			]
		]
	]
	PaethPredictor: func[a b c /local p pa pb pc][
		p: a + b - c
		pa: abs (p - a)
		pb: abs (p - b)
		pc: abs (p - c)
		case [
			all [pa <= pb pa <= pc][a]
			pb <= pc [b]
			true [c]
		]
	]
	
	

	ARGB2PNG: func[img [object!] /local RGBA ARGB sk][
		ARGB: img/bARGB
		cols: img/size/x
		rows: img/size/y
		;sk: cols // 2
		RGBA: make binary! (rows + length? ARGB)
		loop rows [
			RGBA: change RGBA #{00}
			loop cols [
				RGBA: change RGBA copy/part next ARGB 3
				RGBA: change RGBA to char! first ARGB
				ARGB: skip ARGB 4
				;probe copy/part head rgba 4
				;probe copy/part head argb 4
				;halt
			]
		;	RGBA: skip RGBA sk
			;ARGB: skip ARGB sk
		]

		RGBA: head remove/part tail (compress head RGBA) -4 ;zlib compressed
		
		rejoin [
		 	;signature + IHDR-length(13)
			#{89504E470D0A1A0A  0000000D}
			tmp: rejoin [
				#{49484452} ;IHDR
				reverse int-to-ui32 img/size/x
				reverse int-to-ui32 img/size/y
				#{08 06 00 00 00} ;bitDepth colorType compression filter interlace
			]
			crc-32 tmp ;IHDR-crc
			
			;IDAT
			reverse int-to-ui32 length? RGBA
			tmp: join #{49444154} RGBA
			crc-32 tmp ;crc
			
			;IEND
			#{00000000 49454E44 AE426082} ;0(length) IEND crc
		]
	]
	
	PIX24-to-PNG: func[img [object!] /local cols rows sk argb width png-bitmap tmp][
		ARGB: img/bARGB
		cols: img/size/x
		rows: img/size/y
		sk: cols // 2
		
		length: length? ARGB
		case [
			length = tmp: cols * rows * 4 []
			length < tmp [
				insert/dup tail rgb #{00} tmp - length
			]
			true [
				rgb: copy/part rgb tmp
			]
		]
		width: 4 * cols

		png-bitmap: make binary! (tmp + rows)
		
		loop rows [
			png-bitmap: change png-bitmap #{00}
			loop cols [
				png-bitmap: change png-bitmap copy/part next ARGB 3
				ARGB: skip ARGB 4
			]
			png-bitmap: skip png-bitmap sk
		]

		rejoin [
			#{89504E470D0A1A0A}
			png-chunk "IHDR" [
				 reverse  int-to-ui32 cols
				 reverse  int-to-ui32 rows
				#{08}
				#{02}
				#{00}
				#{00}
				#{00}
			]
			png-chunk "IDAT" head remove/part tail compress head png-bitmap -4
			#{00000000}
			"IEND"
			#{AE426082}
		]
	]