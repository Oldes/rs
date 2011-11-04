rebol [
	title: "SWF bitmaps parse functions"
	purpose: "Functions for parsing bitmaps related tags in SWF files"
]

	parse-DefineBitsLossless: has[id BitmapFormat BitmapWidth BitmapHeight argb a rgb ZlibBitmapData][
		reduce [
			id: readID   ;bitmapID
			BitmapFormat: readUI8
			BitmapWidth:  readUI16
			BitmapHeight: readUI16
			either BitmapFormat = 3 [readUI8][none] ;BitmapColorTableSize
			(
				ZlibBitmapData: readRest
				;ImageCore/ARGB2PNG context [
				;probe 	bARGB: as-binary zlib-decompress ZlibBitmapData (4 * BitmapWidth * BitmapHeight ) 
				;	size:  as-pair BitmapWidth BitmapHeight
				;]
				ZlibBitmapData
			)
		]
	]

	parse-DefineBits: does [
		reduce [
			readID
			readRest ;JPEGData
			;It contains only the JPEG compressed image data (from the Frame Header onward).
			;A separate JPEGTables tag contains the JPEG encoding data used to encode this
			;image (the Tables/Misc segment).
		]
	]
	parse-JPEGTables: does [
		readRest ;JPEG encoding table (the Tables/Misc segment) for all JPEG images defined using the DefineBits tag.
	]
	
	parse-DefineBitsJPEG2: does [
		reduce [
			readID
			readRest ;JPEGData
		]
	]
	parse-DefineBitsJPEG3: does [
		reduce [
			readID
			readBytes readUI32 ;JPEGData
			readRest ;BitmapAlphaData
		]
	]
	parse-DefineBitsJPEG4: has[AlphaDataOffset] [
		reduce [
			readID
			(
				AlphaDataOffset: readUI32
				readUI16 ;DeblockParam
			)
			readBytes AlphaDataOffset ;JPEGData
			readRest ;BitmapAlphaData
		]
	]