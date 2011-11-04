rebol [
	title: "SWF sprites and movie clip related parse functions"
	purpose: "Functions for parsing sprites and movie clip related tags in SWF files"
]

	parse-DefineSprite: has[][
		reduce [
			readID
			readUI16 ;FrameCount
			readSWFTAGs inBuffer
		]
	]
	parse-PlaceObject: does [
		reduce [
			readUsedID   ;ID of character to place
			readUI16     ;Depth of character
			readMATRIX   ;Transform matrix data
			either tail? inBuffer [none][readCXFORM]   ;Color transform data
		]
	]
	parse-PlaceObject2: has[flags] [reduce [
		(
			;print ["placeO2" mold inBuffer]
			flags: readUI8
			readUI16 ;depth
		)
		isSetBit? flags 1 ;Move?
		either isSetBit? flags 2 [readUsedID ][none] ;HasCharacter
		either isSetBit? flags 3 [readMATRIX ][none] ;HasMatrix
		either isSetBit? flags 4 [byteAlign readCXFORMa][none] ;HasCxform
		either isSetBit? flags 5 [byteAlign readUI16   ][none] ;HasRatio
		either isSetBit? flags 6 [byteAlign readString ][none] ;HasName
		either isSetBit? flags 7 [byteAlign readUI16   ][none] ;HasClipDepth
		either isSetBit? flags 8 [byteAlign readCLIPACTIONS][none]
	]]
		
	parse-PlaceObject3: has[flags flags2] [reduce [
		(
			;print "parse-PlaceObject3"
			flags:  readUI8
			flags2: readUI8
			readUI16 ;depth
		)
		(
		isSetBit? flags 1 ;Move?
		)
		either isSetBit? flags 2 [readUsedID ][none] ;HasCharacter
		either isSetBit? flags 3 [readMATRIX ][none] ;HasMatrix

		either isSetBit? flags 4 [readCXFORMa][none] ;HasCxform

		either isSetBit? flags 5 [readUI16   ][none] ;HasRatio
		either isSetBit? flags 6 [readString ][none] ;HasName
		either isSetBit? flags 7 [readUI16   ][none] ;HasClipDepth
		
		either isSetBit? flags2 1 [readFILTERS   ][none] ;HasFilters
		either isSetBit? flags2 2 [readUI8       ][none] ;HasBlendMode
		either isSetBit? flags2 3 [readUI8       ][none] ;BitmapCaching
		either isSetBit? flags 8 [readCLIPACTIONS][none]
	]]
	
	readFILTERS: has[filters type columns rows][
		filters: copy []
		loop readUI8 [
			byteAlign
			repend filters [
				type: readUI8
				
				reduce case [
					type = 1 [
						;BLUR
						[
					 		readULongFixed ;f_blur_horizontal
							readULongFixed ;f_blur_vertical
							readUB 5 ;f_passes : 5
							;readUB 3 ;reserved
						]
					]
					find [0 2 3] type [
						;Drop Shadow, Glow, Bevel
						inBuffer
						[
							readRGBA ;color
							;if type = 3 [readRGBA];highlight
							
							readSLongFixed ;blur_horizontal
							readSLongFixed ;blur_vertical
							either type <> 2 [
								reduce [
									readSLongFixed ;radian_angle
									readSLongFixed ;distance
								]
							][none]
							readSShortFixed ;strength
							readBitLogic   ;inner_shadow
							readBitLogic   ;knock_out
							readBitLogic   ;composite_source
							readBitLogic   ;on_top
						
						]
					]
					find [4 7] type [
						;Gradient Glow and Gradient Bevel
						count: readUI8
						[
							readRGBAArray count ;colors
							;if 7 = type [readRGBAArray count] ;highlight_rgba
							readUI8Array count  ;positions
							readSLongFixed ;blur_horizontal
							readSLongFixed ;blur_vertical
							readSLongFixed ;radian_angle
							readSLongFixed ;distance
							readSShortFixed ;strength
							readBitLogic   ;inner_shadow
							readBitLogic   ;knock_out
							readBitLogic   ;composite_source
							(skipBits 1 ;reserved
							readUB 4    ;passes
							)
							
						]
					]
					
					type = 5 [
						;Convolution
						[
							columns: readUI8
							rows: readUI8
							readLongFloat ;divisor
							readLongFloat ;bias
							readLongFloatArray (columns * rows) ;weights
							readRGBA      ;default_color
							skipBits 6    ;reserved
							readBitLogic  ;clamp?
							readBitLogic  ;preserve_alpha?
								
						]
					]
					
					type = 6 [
						;Color Matrix
						readLongFloatArray 20
					]
				]
			]
		]
		filters
	]
	parse-RemoveObject: does [
		reduce [
			readUsedID ;charID
			readUI16   ;depth
		]
	]
	parse-RemoveObject2: does [
		 readUI16 ;depth
	]
	
	parse-SWT-CharacterName: does [
		reduce [
			readID
			readSTRING
		]
	]

	readCLIPACTIONS: does [reduce[
		readUI16 ;reserved
		readUI32 ;CLIPEVENTFLAGS
		readCLIPACTIONRECORDs
	]]
	
	readCLIPACTIONRECORDs: has[records flags][
		records: copy []
		until [
			insert/only tail records reduce[
				flags: readUI32 ;CLIPEVENTFLAGS
				readUI32        ;ActionRecordSize
				either isSetBit? flags 10 [readUI8][none] ;KeyCode
				readACTIONRECORDs
			]
			0 = either swfVersion > 5 [readUI32][readUI16]
		]
		records
	]
	