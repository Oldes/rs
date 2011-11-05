REBOL [
	;require: [
	;	rs-project 'memory-tools
	;]
	note: {To find libmagickwand.so location on linux: find / -iname libmagickwand*}
]

unless value? 'with [
	with: func[obj body][do bind body obj]
]

unless any [
	all [value? 'dir_imagemagick exists? dir_imagemagick]
	all [value? 'rs exists? dir_imagemagick: dirize rs/home/lib]
	exists? dir_imagemagick: %/c/utils/imagemagick/
	exists? dir_imagemagick: %"/c/Program Files/ImageMagick/"
][
	print "Set imagick/dir_imagemagick variable to directory where is CONVERT exe!"
]



ctx-imagick: context [
	unless value? 'debug [
		debug: func[msg /print][system/words/print msg]
	]
	if error? system/words/try [
		lib_ImageMagickWand: load/library either system/version/4 = 3 [
			dir_imagemagick/CORE_RL_wand_.dll
		][	%/usr/lib/libMagickWand.so ]
	][
		debug/print "IMAGICK: Unable to load the library!"
	]
	
	RedChannel:	GrayChannel: CyanChannel: 1
  	GreenChannel: MagentaChannel: 2
  	BlueChannel:  YellowChannel:  4
  	AlphaChannel: OpacityChannel: 8
	BlackChannel: IndexChannel:  32
 	AllChannels: 255
 	
 	*wand: *pixel: none
 	
 	CompressionTypes: [
 	  Undefined
	  No
	  BZip
	  DXT1
	  DXT3
	  DXT5
	  Fax
	  Group4
	  JPEG
	  JPEG2000
	  LosslessJPEG
	  LZW
	  RLE
	  Zip
	]
	
	ctJPEG: 8
	ilm_MergeLayer:   13
	ilm_FlattenLayer: 14
	
	

	make-routine: func[routine specs /local r][
		either error? system/words/try [
			r: make routine! bind specs '*wand lib_ImageMagickWand routine
		][
			debug/print ["IMAGICK: Cannot create routine:" routine]
			none
		][  :r ]
	]
MagickWandGenesis: make-routine "MagickWandGenesis" [
    "Initializes the MagickWand environment"
]
MagickWandTerminus: make-routine "MagickWandTerminus" [
    "Terminates the MagickWand environment"
]
NewMagickWand: make-routine "NewMagickWand" [
    {Returns a wand required for all other methods in the API.} 
    return: [integer!]
]
MagickSetOption: make-routine "MagickSetOption" [
    {associates one or options with the wand (.e.g MagickSetOption wand "jpeg:perserve" "yes").}
    *wand [integer!] 
    *key    [string!] 
    *value  [string!] 
    return: [integer!]
]
MagickQueryConfigureOptions: make-routine "MagickQueryConfigureOptions" [
    {returns any configure options that match the specified pattern (e.g. "*" for all)} 
    *pattern [string!] 
    *number_options [integer!] 
    return: [string!]
]
MagickQueryFonts: make-routine "MagickQueryFonts" [
    {returns any font that match the specified pattern (e.g. "*" for all).} 
    *pattern [string!] 
    *number_options [integer!] 
    return: [string!]
]
MagickPingImage: make-routine "MagickPingImage" [
    "Returns the image width, height, size, and format." 
    *wand [integer!] 
    filename [string!] 
    return: [integer!]
]
MagickPingImageBlob: make-routine "MagickPingImageBlob" [
    "pings an image or image sequence from a blob." 
    *wand [integer!] 
    *blob [integer!] 
    length [integer!] 
    return: [integer!]
]
MagickReadImage: make-routine "MagickReadImage" [
    "Reads an image or image sequence." 
    *wand [integer!] 
    filename [string!] 
    return: [integer!]
]
MagickReadImageBlob: make-routine "MagickReadImageBlob" [
    "reads an image or image sequence from a blob." 
    *wand [integer!] 
    *blob [integer!] 
    length [integer!] 
    return: [integer!]
]
MagickAddImage: make-routine "MagickAddImage" [
    "adds the specified images at the current image location" 
    *wand [integer!] 
    *add_wand [integer!] 
    return: [integer!]
]
MagickResizeImage: make-routine "MagickResizeImage" [
    {Associates the next image in the image list with a magick wand.} 
    *wand [integer!] 
    width [integer!] 
    height [integer!] 
    filter [integer!] 
    blur [decimal!] "the blur factor where > 1 is blurry, < 1 is sharp." 
    return: [integer!]
]
MagickCropImage: make-routine "MagickCropImage" [
    "extracts a region of the image" 
    *wand [integer!] 
    width [integer!] 
    height [integer!] 
    x [integer!] 
    y [integer!] 
    return: [integer!]
]
MagickWriteImage: make-routine "MagickWriteImage" [
    "Writes an image to the specified filename." 
    *wand [integer!] 
    filename [string!] 
    return: [integer!]
]
MagickWriteImages: make-routine "MagickWriteImages" [
    "Writes an image to the specified filename." 
    *wand [integer!] 
    filename [string!] 
    return: [integer!]
]
ClearMagickWand: make-routine "ClearMagickWand" [
    "Clears resources associated with the wand." 
    *wand [integer!]
]
CloneMagickWand: make-routine "CloneMagickWand" [
    "Makes an exact copy of the specified wand." 
    *wand [integer!] 
    return: [integer!]
]
DestroyMagickWand: make-routine "DestroyMagickWand" [
    "Deallocates memory associated with an MagickWand." 
    *wand [integer!]
]
MagickGetException: make-routine "MagickGetException" [
    *wand [integer!] 
    *severity [struct! [i [int]]] 
    return: [integer!]
]
MagickRelinquishMemory: make-routine "MagickRelinquishMemory" [
    "Relinquishes memory resources" 
    *resource [integer!] 
    return: [long]
]
MagickNewImage: make-routine "MagickNewImage" [
    {Adds a blank image canvas of the specified size and background color to the wand.} 
    *wand [integer!] 
    columns [integer!] 
    rows [integer!] 
    *pixelWand [integer!] 
    return: [integer!]
]
MagickUnsharpMaskImage: make-routine "MagickUnsharpMaskImage" [
    {sharpens an image. We convolve the image with a Gaussian operator of the given radius and standard deviation (sigma). For reasonable results, radius should be larger than sigma. Use a radius of 0 and UnsharpMaskImage() selects a suitable radius for you.} 
    *wand [integer!] 
    radius [decimal!] {of the Gaussian, in pixels, not counting the center pixel.} 
    sigma [decimal!] "the standard deviation of the Gaussian, in pixels." 
    amount [decimal!] {the percentage of the difference between the original and the blur image that is added back into the original.} 
    threshold [decimal!] {the threshold in pixels needed to apply the diffence amount.} 
    return: [integer!]
]
MagickSharpenImage: make-routine "MagickSharpenImage" [
    "sharpens an image." 
    *wand [integer!] 
    radius [decimal!] {of the Gaussian, in pixels, not counting the center pixel.} 
    sigma [decimal!] "the standard deviation of the Gaussian, in pixels." 
    return: [integer!]
]
MagickBlurImage: make-routine "MagickBlurImage" [
    "blurs an image." 
    *wand [integer!] 
    radius [decimal!] {of the Gaussian, in pixels, not counting the center pixel.} 
    sigma [decimal!] "the standard deviation of the Gaussian, in pixels." 
    return: [integer!]
]
MagickCharcoalImage: make-routine "MagickCharcoalImage" [
    "Simulates a charcoal drawing." 
    *wand [integer!] 
    radius [double] {of the Gaussian, in pixels, not counting the center pixel.} 
    sigma [double] "the standard deviation of the Gaussian, in pixels." 
    return: [integer!]
]
MagickTrimImage: make-routine "MagickTrimImage" [
	"remove edges that are the background color from the image"
	*wand [integer!] 
	fuzz [double] "defines how much tolerance is acceptable to consider two colors as the same"
    return: [integer!] "*background_color PixelWand"
]
MagickGetImageHeight: make-routine "MagickGetImageHeight" [
    "Returns the image height." 
    *wand [integer!] 
    return: [integer!]
]
MagickGetImageWidth: make-routine "MagickGetImageWidth" [
    "Returns the image width." 
    *wand [integer!] 
    return: [integer!]
]
MagickGetImageFormat: make-routine "MagickGetImageFormat" [
    {Returns the format of a particular image in a sequence.} 
    *wand [integer!] 
    return: [string!]
]
MagickSetImageFormat: make-routine "MagickSetImageFormat" [
    {sets the format of a particular image in a sequence} 
    *wand [integer!] 
    format [string!]
    return: [integer!]
]
MagickIdentifyImage: make-routine "MagickIdentifyImage" [
    *wand [integer!] 
    return: [string!]
]
MagickMergeImageLayers: make-routine "MagickMergeImageLayers" [
	{composes all the image layers from the current given image onward to produce a single image of the merged layers.}
    *wand [integer!] 
    method [integer!]
    return: [integer!]
]
MagickImportImagePixels: make-routine "MagickImportImagePixels" [
    *wand [integer!] 
    x [integer!] 
    y [integer!] 
    columns [integer!] 
    rows [integer!] 
    map [string!] 
    storage [integer!] 
    *pixels [integer!] 
    return: [integer!]
]
MagickExportImagePixels: make-routine "MagickExportImagePixels" [
    {extracts pixel data from an image and returns it to you} 
    *wand [integer!] 
    x [integer!] 
    y [integer!] 
    columns [integer!] 
    rows [integer!] 
    map [string!] 
    storage [integer!] 
    *pixels [integer!] 
    return: [integer!]
]
MagickSetImageCompression: make-routine "MagickSetImageCompression" [
    "sets the image compression type" 
    *wand [integer!] 
    type  [integer!] 
    return: [integer!]
]
MagickSetImageCompressionQuality: make-routine "MagickSetImageCompressionQuality" [
    "sets the image compression quality" 
    *wand [integer!] 
    quality [integer!] 
    return: [integer!]
]
MagickGetImageType: make-routine "MagickGetImageType" [
	"gets the image type"
	*wand [integer!]
	return: [integer!]
]
MagickSetImageType: make-routine "MagickSetImageType" [
    "sets the image type" 
    *wand [integer!] 
    image_type [integer!] "the image type: UndefinedType, BilevelType, GrayscaleType, GrayscaleMatteType, PaletteType, PaletteMatteType, TrueColorType, TrueColorMatteType, ColorSeparationType, ColorSeparationMatteType, or OptimizeType" 
    return: [integer!]
]
MagickSetImageMatte: make-routine "MagickSetImageMatte" [
    "sets the image matte channel" 
    *wand  [integer!] 
    *matte [integer!] "(1/0) - Set to MagickTrue to enable the image matte channel otherwise MagickFalse." 
    return: [integer!]
]
MagickSetImageMatteColor: make-routine "MagickSetImageMatteColor" [
    "sets the image matte color" 
    *wand  [integer!] 
    *matte [integer!] "matte pixel wand" 
    return: [integer!]
]
MagickSetImageDepth: make-routine "MagickSetImageDepth" [
    "sets the image depth" 
    *wand [integer!] 
    depth [integer!] "the image depth in bits: 8, 16, or 32." 
    return: [integer!]
]
MagickGetImageDepth: make-routine "MagickGetImageDepth" [
	"gets the image depth."
	*wand [integer!] 
    return: [integer!]
]
MagickSetImageBackgroundColor: make-routine "MagickSetImageBackgroundColor" [
	"sets the image background color"
	*wand [integer!] 
	*background_color [integer!] "the background pixel wand."
    return: [integer!] "*background_color PixelWand"
]

MagickGetImageBackgroundColor: make-routine "MagickGetImageBackgroundColor" [
	"returns the image background color"
	*wand [integer!] 
    return: [integer!] "*background_color PixelWand"
]

ClearPixelWand: make-routine "ClearPixelWand" [
    "clears resources associated with the wand." 
    *PixelWand [integer!]
]
DestroyPixelWand: make-routine "DestroyPixelWand" [
    "makes an exact copy of the specified wand." 
    *PixelWand [integer!] 
    return: [integer!]
]
NewPixelWand: make-routine "NewPixelWand" [
    "returns a new pixel wand." 
    return: [integer!]
]
PixelSetAlpha:  make-routine "PixelSetAlpha" [
    "sets the normalized alpha color of the pixel wand" 
    *PixelWand [integer!] 
    alpha   [decimal!] "level of transparency: 1.0 is fully opaque and 0.0 is fully transparent"
]
PixelGetAlpha: make-routine "PixelSetAlpha" [
    "returns the normalized alpha color of the pixel wand" 
    *PixelWand [integer!] 
    return: [decimal!]
]
PixelSetColor: make-routine "PixelSetColor" [
    {sets the color of the pixel wand with a string (e.g. "blue", "#0000ff", "rgb(0,0,255)", "cmyk(100,100,100,10)", etc.)} 
    *PixelWand [integer!] 
    color   [string!] "pixel wand color"
    return: [integer!]
]
PixelSetBlack: make-routine "PixelGetBlack" [
    {sets the normalized black color of the pixel wand} 
    *PixelWand [integer!] 
    black   [double]
]
PixelGetBlack: make-routine "PixelGetBlack" [
    {returns the normalized black color of the pixel wand} 
    *PixelWand [integer!] 
    return: [double]
]
PixelGetColorAsString: make-routine "PixelGetBlack" [
    {returnsd the color of the pixel wand as a string.} 
    *PixelWand [integer!] 
    return: [string!]
]
MagickSetImagePage: make-routine "MagickSetImagePage" [
	"sets the page geometry of the image."
	*wand   [integer!]
	width   [integer!]
	height  [integer!]
	x       [integer!]
	y       [integer!]
	return: [integer!]
]


	unset 'make-routine
	
	;## Helper functions
	Exception: make struct! [Severity [integer!]] none
	s_int:  make struct! [value [integer!]] none
	s_str:  make struct! [value [string! ]] none
	
	address?: func [
		{get the address of a string}
		s [series!]
	][
		s_str/value: s
		change third s_int third s_str
		s_int/value
	]
	ptr-to-string: func[
		{get string from pointer}
		ptr [integer!]
		/local m
	][
		s_int/value: ptr
		change third s_str third s_int
		s_str/value
	]
	
	;### image-save
	set 'image-save func[
		filename [file! ]
		image	[image!]
		/local
			rgba width height *wand p desc errmsg
	][
		rgba: to-binary image
		width:  image/size/x
		height: image/size/y
		
		if #"/" <> first filename [
			insert filename what-dir
		]
		
		start
		*pixel: NewPixelWand
		unless all [
			not zero? MagickNewImage *wand width height *pixel
			not zero? probe MagickImportImagePixels *wand 0 0 width height "BGRO" 1 address? rgba
			not zero? MagickWriteImages *wand to-local-file filename
		][
			errmsg: reform [
				Exception/Severity "="
				ptr-to-string desc: MagickGetException *wand Exception
			]
			MagickRelinquishMemory desc
			end
			make error! errmsg
		]
		ClearPixelWand    *pixel
		DestroyPixelWand  *pixel
		end
		filename
	]
	
	set 'image-load func [
		"Load an image using Imagemagick's library"
		imgsrc [url! file! string! binary!] "Image file to load or raw binary data"
		/local tmp *wand width height errmsg
	][
		MagickWandGenesis
		*wand:   NewMagickWand
		
		unless any [url? imgsrc binary? imgsrc] [
			if #"/" <> first imgsrc: to-rebol-file imgsrc [
				insert imgsrc what-dir
			]
		]
		
		unless all [
			not zero? case [
					url? imgsrc [
						tmp:  read/binary imgsrc
						MagickReadImageBlob *wand address? tmp length? tmp
					]
					binary? imgsrc [
						MagickReadImageBlob *wand address? imgsrc length? imgsrc
					]
					true [
						MagickReadImage *wand to-local-file imgsrc
					]
			]
			width:  MagickGetImageWidth  *wand
			height: MagickGetImageHeight *wand
			tmp:     make image! as-pair width height
			not zero? MagickExportImagePixels *wand 0 0 width height "RGBO" 1 address? tmp
		][
			errmsg: reform [
				Exception/Severity "="
				ptr-to-string tmp:  MagickGetException *wand Exception
			]
			MagickRelinquishMemory tmp
			MagickWandTerminus
			make error! errmsg
		]
		ClearMagickWand   *wand
		DestroyMagickWand *wand
		MagickWandTerminus
		tmp
	]
	set 'image-get-pixels func [
		img [binary! file! string!]
		map [string!] "This string reflects the expected ordering of the pixel array. It can be any combination or order of R = red, G = green, B = blue, A = alpha (0 is transparent), O = opacity (0 is opaque), C = cyan, Y = yellow, M = magenta, K = black, I = intensity (for grayscale), P = pad."
		;storage [word!] "CharPixel, DoublePixel, FloatPixel, IntegerPixel, LongPixel, QuantumPixel, or ShortPixel"
		/local width height bytes bin
	][
		start
			either binary? img [
				try MagickReadImageBlob *wand address? img length? img
			][
				try MagickReadImage *wand utf8/encode to-local-file img
			]
			width:  MagickGetImageWidth  *wand
			height: MagickGetImageHeight *wand
			bin:    make binary! bytes: (width * height * length? map)
			
			insert/dup bin #{00} bytes
			print ["image-get-pixels:" width height mold map length? bin]
			try MagickExportImagePixels *wand 0 0 width height map 1 address? bin
		end
		print length? bin
		bin
	]
	
	
	crop-image: func[src trg width height ofsx ofsy ][
		if #"/" <> first src: to-rebol-file src [insert src what-dir]
		if #"/" <> first trg: to-rebol-file trg [insert trg what-dir]
		start
			try MagickReadImage *wand as-string utf8/encode to-local-file src
			try MagickSetImagePage *wand 0 0 0 0
			origw: MagickGetImageWidth *wand 
			origh: MagickGetImageHeight *wand
			try MagickCropImage *wand width height ofsx ofsy
			try MagickWriteImages *wand as-string utf8/encode to-local-file trg
			ClearMagickWand   *wand
		end
	]	
	set 'crop-images func[[catch] files x y width height /local origw origh tmp result][
		unless block? files [files: reduce [files]]
		result: none
		start
		foreach file files [
			try MagickReadImage *wand file: as-string utf8/encode to-local-file file
			try MagickSetImagePage *wand 0 0 0 0
			origw: MagickGetImageWidth *wand
			origh: MagickGetImageHeight *wand
			type: MagickGetImageType *wand
			print ["imagetype:" type]
			unless any [
				all [
					any [
						origh < height
						origw < width
					]
					(print ["!! Crop out of bounds!" mold file origh "<" height	"or" origw "<" width] break)
				]
				all [
					x = 0
					y = 0
					origh = height
					origw = width
					(print ["!! Crop not needed!" mold file] break)
				]
			][
				try MagickCropImage *wand width height x y
				if default/CompressionQuality [
					try MagickSetImageCompressionQuality *wand default/CompressionQuality
				]
			;	if default/ImageType [
			;		try MagickSetImageType *wand  default/ImageType
			;	]
				try MagickWriteImages *wand result: head insert find/last copy file "." rejoin [%_crop_ x #"x" y #"_" width #"x" height]
			]
			ClearMagickWand   *wand

		]
		end
		result
	]
	set 'resize-image func[[catch] file file-sc percent  [block! number!] /local type width height ][
		if number? percent [percent: reduce [percent percent]]
		start
			try MagickReadImage *wand utf8/encode to-local-file file
			
			probe type:   MagickGetImageFormat *wand; ask ""
			width:  MagickGetImageWidth  *wand
			height: MagickGetImageHeight *wand
			
			try MagickResizeImage *wand round/ceiling(percent/1 * width) round/ceiling(percent/2 * height) 4 1 ;default/blur
			try MagickUnsharpMaskImage *wand 1 2.0 0.3 .05
			if default/CompressionQuality [
				try MagickSetImageCompressionQuality *wand default/CompressionQuality
			]
			
			try MagickSetOption *wand "png:include-chunk" "none"
			try MagickSetOption *wand "png:exclude-chunk" "bkgd"
			try MagickWriteImage *wand probe join either probe type = "PNG" ["PNG32:"][""] utf8/encode to-local-file file-sc
		end
	]
	set 'get-image-size func[[catch] file /local width height ][
		start
			try MagickPingImage *wand utf8/encode to-local-file file
			width:  MagickGetImageWidth  *wand
			height: MagickGetImageHeight *wand
		end
		as-pair width height
	]
	
	
	query: func[
		/options
		/fonts
		/local ret res num
	][
		num: address? third s_int 
		either fonts [
			ret: last third :MagickQueryFonts
			insert clear ret [integer!]
			     MagickQueryFonts "*" num ;this one just to get the number of results
			insert clear ret [struct!]
			append/only ret (head insert/dup copy [] [. [string!]] s_int/value)
			res: MagickQueryFonts "*" num 
		][
			ret: last third :MagickQueryConfigureOptions
			insert clear ret [integer!]
				 MagickQueryConfigureOptions "*" num
			insert clear ret [struct!]
			append/only ret (head insert/dup copy [] [. [string!]] s_int/value)
			res: MagickQueryConfigureOptions "*" num 
		]
		clear  ret
		second res
	]
	info: has [result][
		result: copy []
		foreach option query [
			repend result [
				option MagickQueryConfigureOption option
			]
		
		]
		new-line/skip result true 2
	]
	FilterTypes: [
		Bessel Blackman Box Catrom Cubic Gaussian Hanning Hermite Lanczos Mitchell Point Quandratic Sinc Triangle
	]

	default: context [
		quality: 80
		filter: 5
		radius: 1.2
		sigma:  1.0
		blur:   0.9
		CompressionQuality: 90
		ImageType: 7 ;6 = TrueColor
		MergeBGColor: "black"
	]
	
	start: does [
		if none? *wand [
			MagickWandGenesis
			*wand:  NewMagickWand
		]
	]
	end: does [
		ClearMagickWand   *wand
		DestroyMagickWand *wand
		MagickWandTerminus
		*wand: none
	]

	try: func[res [block! integer!] /local errmsg tmp][
		either block? res [
			system/words/try res
		][
			if zero? res [
				errmsg: reform [
					Exception/Severity "="
					ptr-to-string tmp: MagickGetException *wand Exception
					;"^/*** near:" join copy/part form pos 60 "..."
				]
				MagickRelinquishMemory tmp
				end
				make error! errmsg
			]
		]
	]
	
]


;do %test.r