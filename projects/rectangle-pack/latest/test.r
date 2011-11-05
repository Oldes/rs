REBOL [
    Title: "Rectangle-packing Test"
    Date: 25-Oct-2010/21:53:10+2:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "Oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: none
    Purpose: none
    Comment: none
    History: none
    Language: none
    Type: none
    Content: none
    Email: none
    require: [
    	rs-project %rectangle-pack
    	rs-project %imagick 'minimal
    	rs-project 'utf8-cp1250
	]
]


unless value? 'img-files [
	img-files: copy []
]
if empty? img-files [
	foreach file read dir: %/d\RS\projects-mm\robotek\_export\15_bar.swf_export\ [
		if parse file [%tag35_ thru %.jpg end][
			probe size: get-image-size dir/:file
			repend img-files [
				size
				dir/:file
			]
		]
	]
]
new-line/skip img-files true 2

maxpair: 0x0
foreach [size id] img-files [
	maxpair: max maxpair size
]


probe maxi: max maxpair/x maxpair/y
ask ""

size: case [
	maxi < 64  [  64x64  ]
	maxi < 128 [ 128x128 ]
	maxi < 256 [ 256x256 ]
	maxi < 512 [ 512x512 ]
	true       [1024x1024]
]


size-data: copy img-files
while [not empty?  second result: rectangle-pack size-data size][
	if size/x >= 1024 [
		print "images too big to fit in one bmp"
		ask ""
		break
	] 
	size: size * 2
]

print ["using size:" size]
ask ""

combine-files: func[files size into][
	with ctx-imagick [
		start
				*pixel: NewPixelWand
				not zero? MagickNewImage *wand size/x size/y *pixel
				
				*wand2: NewMagickWand
				png?: find into %.png
				foreach [pos size file] files [
					print [pos size file]
					if block? file [parse file [to file! set file 1 skip]]
					if png? [file: replace copy file %.jpg %.png]
					unless all [
						*wand2: NewMagickWand
						not zero? MagickReadImage *wand2 utf8/encode to-local-file file
						tmp:  make image! size
				 		not zero? MagickExportImagePixels *wand2 0 0 size/x size/y "RGBO" 1 address? tmp
				 		;tmp: to-binary tmp
				 		not zero? MagickImportImagePixels *wand pos/x pos/y size/x size/y "RGBO" 1 address? tmp
			 		][
			 			errmsg: reform [
							Exception/Severity "="
							ptr-to-string tmp:  MagickGetException *wand Exception
						]
						MagickRelinquishMemory tmp
						ClearMagickWand   *wand2
						DestroyMagickWand *wand2	
						ClearPixelWand    *pixel
						DestroyPixelWand  *pixel
						end
						make error! errmsg
		 			]
			 		ClearMagickWand   *wand2
		 		]
				not zero? MagickWriteImages *wand to-local-file into
			DestroyMagickWand *wand2	
			ClearPixelWand    *pixel
			DestroyPixelWand  *pixel
		end
	]
]
combine-files result/1 size %/d/android/test/test.jpg
combine-files result/1 size %/d/android/test/test.png
;combine-files result2/1 size %/f/test2.jpg
