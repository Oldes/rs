rebol []

	dat-io: make stream-io []
	to-timestamp: func[date [date!] /local time][
		time: any [date/time 0:0:0]
		first parse form ((date - 1-1-1970) * 86400)
	     + (time/hour * 3600)
	     + (time/minute * 60)
	     +  time/second
	     - to integer! (any [date/zone 0])
	     "."
	]
	make-id: has [date time][
		date: now
		time: any [date/time 0:0:0]
		join enbase/base head reverse int-to-ui32 ((date - 1-1-1970) * 86400)
	     + (time/hour * 3600)
	     + (time/minute * 60)
	     +  time/second
	     - to integer! (any [date/zone 0])
	     16
	     ["-" enbase/base head reverse int-to-ui32 num-imported: num-imported + 1 16]
	]
	
	import-media-img: func[
		"Imports media item into DAT file"
		source-file
		/dom "updates DOMDocument.xml file as well"
		/as dat-file
		/smoothing smVal
		/local node imgFormat width height ARGB buf name tmp
	][
		if verbose > 0 [print ["IMPORTING DOMBitmapItem::" mold source-file]]
		source-file: to-rebol-file source-file
		if #"/" <> first source-file [insert source-file what-dir]
		unless as [dat-file: rejoin [%My " 1 " checksum source-file %.dat]]
		with ctx-imagick [
			start
			unless zero? MagickReadImage *wand to-local-file source-file [

				either find ["JPG" "JPEG"] imgFormat: MagickGetImageFormat *wand [
					write/binary xfl-source-dir/bin/:dat-file read/binary source-file
				][
					;img: imageCore/load source-file
					;ARGB: img/bARGB
					;width: img/size/x
					;height: img/size/y

					width:  MagickGetImageWidth  *wand
					height: MagickGetImageHeight *wand
					ARGB: make binary! (width * height * 4)
					insert/dup ARGB #{00} (width * height * 4)
					try MagickExportImagePixels *wand 0 0 width height "ARGB" 1 address? ARGB
					
					premultiply ARGB
					comment {
					while [not tail? ARGB][
						a: ARGB/1
						ARGB: next ARGB
						ARGB: change ARGB to char! ((a * ARGB/1) / 255)
						ARGB: change ARGB to char! ((a * ARGB/1) / 255)
						ARGB: change ARGB to char! ((a * ARGB/1) / 255)
					]
					ARGB: head ARGB
					}
					
					;write/binary probe to-file join source-file %.argb argb
					with dat-io [
						clearOutBuffer
						writeBytes #{0305}
						writeUI16  width * 4
						writeUI16  width
						writeUI16  height
						writeBytes #{00000000}
						writeUI32  width * 20
						writeBytes #{00000000}
						writeUI32  height * 20
						writeBytes #{01}
						
						writeBytes #{010200}
						ARGB: zlib/compress/level ARGB 1 ;;head clear skip tail compress ARGB -4
						writeBytes copy/part ARGB 2
						remove/part ARGB 2
						while [not empty? ARGB][
							buf: copy/part ARGB 2048
							remove/part ARGB 2048
							writeUI16 length? buf
							writeBytes buf
						]
						writeBytes #{0000}
						write/binary xfl-target-dir/bin/:dat-file head outBuffer
					]
					if dom [
						name: encode-entities decode-filename form last split-path source-file
						if find name #"." [name: head clear find/last name #"."]
						unless find Media name [
							;print "---"
							insert/only Media-content node: reduce [
								"DOMBitmapItem" tmp: reduce [
									"name" name
									"itemID" make-id 
									"sourceExternalFilepath" join ".\LIBRARY\" [name "." imgFormat]
									"externalFileSize" mold size? source-file
									"sourceLastImported" to-timestamp now
									"href" join ".\LIBRARY\" [name "." imgFormat]
									"bitmapDataHRef" to-string dat-file
									"allowSmoothing" either any [smVal = true smVal = "true"] ["true"]["false"]
									"frameRight"  20 * width
									"frameBottom" 20 * height
								]
							]
							append tmp either imgFormat = "JPG" [
								["isJPEG" "true"]
							][
								["useImportedJPEGData" "false" "compressionType" "lossless" "originalCompressionType" "lossless"]
							]
							new-line/all tmp false
							new-line/all Media-content true
							;probe Media-content
							;ask "-imp-done-"
						]
					]
				]
			]
			end
		]
		node
	]
	
	export-media-item: func[
		"Exports media item from dat file to the Library folder"
		item
		/into-file item-file
		/overwrite
		/local  len-decompressed width height argb chunk-length *pixel ext-file errmsg dat-id a
	][
		if verbose > 0 [print ["EXPORTING MediaItem::" mold item-file]]
		if verbose > 1 [probe item]
		
		unless into-file [
			item-file: join "./LIBRARY/" last parse/all any [
				select item "sourceExternalFilepath"
				item/("href")
			] "/\"
		]

		unless find ["png" "jpg"] last parse item-file "." [append item-file %.png]
		
		item/("sourceExternalFilepath"):	item/("href"): item-file
		
		if all [
			exists? xfl-source-dir/bin/(item/("bitmapDataHRef"))
			any [
				(
					ext-file: join xfl-target-dir to-rebol-file item-file
					overwrite
				)
				not exists? ext-file
			]
		][
			with dat-io [
				setStreamBuffer read/binary xfl-source-dir/bin/(item/("bitmapDataHRef"))
				switch/default dat-id: readBytes 2 [;bitmap identifier?
					#{FFD8} [;jpeg
						if verbose > 1 [print ["as JPEG"]]
						inBuffer: head inBuffer
						with ctx-imagick [
							start
							unless all [
								MagickReadImageBlob *wand address? inBuffer length? inBuffer
								not zero? MagickWriteImages *wand to-local-file ext-file
							][
								errmsg: reform [
									Exception/Severity "="
									ptr-to-string desc: MagickGetException *wand Exception
								]
								MagickRelinquishMemory desc
								end
								make error! errmsg
							]
							end
						]
						;write/binary ext-file head inBuffer
					]
					#{0303} [;???
						print ["Exporting unknown IMG?" item-file]
						probe len-decompressed: readUI16
						width:  readUI16
						height: readUI16
						print ["size:" as-pair width height]
						probe readBytes 4
						probe readUI32 4
						probe readBytes 4
						probe readUI32 4
						probe readBytes 1
						;probe xx: readBytes 17 ;???
						argb: none
						probe readRest
						ask ""
					]
					#{0305} [;raw image
						if verbose > 1 [print ["as RAW"]]
						len-decompressed: readUI16
						width:  readUI16
						height: readUI16
						if verbose > 1 [print ["size:" as-pair width height]]
						readBytes 17 ;???
						argb: none
						switch/default readBytes 1 [
							#{00} [
								argb: readRest
							]
							#{01} [
								argb: make binary! (width * height * 4)
								while [0 < chunk-length: readUI16][
									insert tail argb readBytes chunk-length 
								]
								argb: as-binary zlib/decompress/l argb (width * height * 4)
								
							]
						][
							ask "!!! UNKNOWN DAT IMG STRUCT !!!"
						]
						
						if argb [
							if (length? argb) <> (width * height * 4) [
								ask ["Inbalid ARGB length?" (length? argb) "<>" (width * height * 4)]
							]

							demultiply argb

							with ctx-imagick [
								start
									*pixel: NewPixelWand
									unless all [
										not zero? MagickNewImage *wand width height *pixel
										not zero? MagickSetImageBackgroundColor *wand *pixel
										
										not zero? MagickImportImagePixels *wand 0 0 width height "ARGB" 1 address? ARGB
										
										not zero? MagickSetImageDepth *wand 8
										not zero? MagickWriteImages *wand to-local-file ext-file
									][
										errmsg: reform [
											Exception/Severity "="
											ptr-to-string desc: MagickGetException *wand Exception
										]
										MagickRelinquishMemory desc
										end
										make error! errmsg
									]
									if *pixel [
										ClearPixelWand    *pixel
										DestroyPixelWand  *pixel
									]
								end
							]
						]
					]
				][
					print ["UNKNOWN DAT TYPE:" dat-id (item/("bitmapDataHRef"))]
				]
			]
		]
		if verbose > 1 [probe ext-file]
		either all [
			not none? ext-file
			exists? ext-file: to-rebol-file ext-file
		][
			ext-file
		][	none]
	]
	export-media: func[
		"Exports images from dat files to the Library folder"
		/local
	][
		foreach [name item] media [
			export-media-item item
		] 
	]
	
	export-sound: func[
		item
		/local dat-file sz wav0file sampleRate SignificantBitsPerSample NumChannels BlockAlign
	][
		probe item
		probe dat-file: join xfl-source-dir [%bin/ item/("soundDataHRef")] 
		probe sz: size? dat-file
		wav-file: join xfl-target-dir [%LIBRARY/ item/("name")]
		unless parse item/("format") [
			copy tmp some ch_digits "kHz" (
				unless sampleRate: select [
					"8"  8000
					"11" 11025
					"16" 16000
					"22" 22050
					"32" 32000
					"44" 44100
					"48" 48000
					"96" 96000
					"192" 192000
				] tmp [
					ask ["!!! Unknown sampleRate:" mold item/("format")]
				]
			)
			SP
			copy SignificantBitsPerSample some ch_digits "bit" (
				SignificantBitsPerSample: to-integer SignificantBitsPerSample
			)
			SP
			[
				"stereo" (NumChannels: 2) |
				"mono" (NumChannels: 1)
			]
			to end
		][
			ask ["!!! UNKNOWN SoundItem format" mold item/("format")]
		] 
		BlockAlign: SignificantBitsPerSample / 8 * NumChannels
		if "wav" <> last parse wav-file "." [append wav-file %.wav]
		with dat-io [
			clearOutBuffer
			writeBytes "RIFF"
			writeUI32 (sz  + 36) 
			writeBytes "WAVE"
			writebytes "fmt "
			writeUI32 16 ;chunk size!
			writeUI16 1 ;Compression code, 1 = PCM
			writeUI16 2 ;Num channels
			writeUI32 sampleRate
			writeUI32 sampleRate * BlockAlign ;176400 ;bytes per sec
			writeUI16 BlockAlign
			writeUI16 SignificantBitsPerSample
			
			writeBytes "data"
			writeUI32 sz
			write/binary wav-file head outBuffer
			write/binary/append wav-file read/binary dat-file
		]
	]
	
