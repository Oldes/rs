REBOL [
    Title: "Texture-packer"
    Date: 11-Mar-2013/17:41:33+1:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "Oldes"

	require: [
		rs-project %rectangle-pack
		rs-project %imagick 'minimal
	]
]

ctx-texture-packer: context [

	size-imgs: copy []
	padding: 2x2
	max-size: 2048x2048
	
	verbose: 1
	
	
	
	combine-files: func[files size into /local tmp png? *wand2 *pixel][
		if verbose > 0 [print ["COMBINE" (length? files) / 3 "images to size:" size "INTO:" mold to-local-file into]]
		with ctx-imagick [
			start
					*pixel: NewPixelWand
					PixelSetAlpha *pixel 0
					MagickNewImage *wand size/x size/y *pixel
					*wand2: NewMagickWand
					
					foreach [pos size file] files [
						if verbose > 1 [print [tab pos size file]]
						
						if block? file [parse file [to file! set file 1 skip]]
					
						unless all [
							not zero? MagickReadImage *wand2 utf8/encode to-local-file file
							tmp:  make image! size
							not zero? MagickExportImagePixels *wand2 0 0 size/x size/y "RGBO" 1 address? tmp
							not zero? MagickImportImagePixels *wand pos/x pos/y size/x size/y "RGBO" 1 address? tmp
						][
							errmsg: reform [
								Exception/Severity "="
								ptr-to-string tmp:  MagickGetException *wand2 Exception
							]
							MagickRelinquishMemory tmp
							if *wand2 [
								ClearMagickWand   *wand2
								DestroyMagickWand *wand2
								*wand2: none
							]               
							if *pixel [
								ClearPixelWand    *pixel
								DestroyPixelWand  *pixel
								*pixel: none
							]
							end
							make error! errmsg
						]
						ClearMagickWand   *wand2
					]
				not zero? MagickWriteImages *wand to-local-file into
				if *wand2 [
					ClearMagickWand   *wand2
					DestroyMagickWand *wand2
					*wand2: none
				]               
				if *pixel [
					ClearPixelWand    *pixel
					DestroyPixelWand  *pixel
					*pixel: none
				]
			end
		]
	]               

	
	set 'texture-pack func[
		sourceDir [file!] "Directory with images to pack"
		targetDir [file!] "Directory where to save result"
		/local
			imgs pack target-name
			size data
			result-files
			tmp n
	][
		clear size-imgs
		result-files: copy []
		
		if verbose > 0 [
			print ["Texture-packing:" mold sourceDir]
			print ["           into:" mold targetDir]
		]
		
		sourceDir: dirize sourceDir
		unless exists? targetDir: dirize targetDir [ make-dir/deep targetDir ]
		
		imgs: read sourceDir		
		
		ctx-rectangle-pack/max-size: max-size
		ctx-rectangle-pack/padding:  padding
		ctx-rectangle-pack/verbose:   verbose
		
		foreach img imgs [
			if find ["png" "jpg" "bmp"] last parse img "." [
				img-path: sourceDir/:img
				
				repend size-imgs [
					get-image-size img-path
					img-path
				]
			]
		]
		set [size data] pow2-rectangle-pack size-imgs
		target-name: join targetDir head remove back tail last split-path sourceDir
		save join target-name %.rpack data/1 
		append result-files target-name
		
		combine-files data/1 size join target-name %.png
		n: 0
		while [not empty? data/2][
			set [size data] pow2-rectangle-pack data/2
			n: n + 1
			combine-files data/1 size rejoin [target-name %_ n %.png]
			save tmp: rejoin [target-name %_ n %.rpack] data/1
			append result-files tmp
		]
		clear size-imgs
		result-files
	]

	;texture-pack %/d/assets/Bitmaps/Domek/DomekPopredi/ %/d/
]