REBOL [
    Title: "Pack-assets"
    Date: 7-Mar-2013/17:26:32+1:00
    Version: 0.3.0
    Author: "Oldes"
    Email: oldes.huhuman@gmail.com
	Home: https://github.com/Oldes/rs/blob/master/projects-rswf/pack-assets/fastmem/pack-assets.r
	require: [
		rs-project %stream-io
		rs-project %form-timeline
		rs-project %texture-packer
	]
	comment: {
		complex example where this script is used is here:
		https://github.com/Oldes/Starling-timeline-example
	}
]

with: func [obj body][do bind body obj]

ctx-pack-assets: context [
	dirBinUtils:   %./Utils/
	dirAssetsRoot: %./Assets/
	dirPacks:      join dirAssetsRoot %Packs/
	comment {
		Required utils can be found here:
			http://code.google.com/p/libgdx/wiki/TexturePacker
			http://code.google.com/p/libgdx/downloads/list
			http://pngquant.org/
	}
	texturePacker: "./Utils/gdx.jar:./Utils/gdx-tools.jar com.badlogic.gdx.tools.imagepacker.TexturePacker2"
	pngQuantExe:   dirBinUtils/pngquant
	if system/version/4 = 3 [append pngQuantExe %.exe]
	
	;charsets:
		chNotSpace: complement charset "^/^- "
		chDigits: charset "0123456789" 
	
	;Asset's commands:
		cmdUseLevel:                 1
		cmdTextureData:              2
		cmdDefineImage:              3
		cmdStartMovie:               4
		cmdEndMovie:                 5
		cmdAddMovieTexture:          6
		cmdAddMovieTextureWithFrame: 7
		
		cmdLoadSWF:                  8

		cmdTimelineData:             10
		cmdTimelineObject:           11
		cmdTimelineShape:            12
		
		cmdDefineSound:              15

		cmdWalkData:                 20
		
	;Shape's commands:
		cmdLineStyle:                1
		cmdMoveTo:                   2
		cmdCurve:                    3
		cmdLine:                     4
	;ControlTag assets:
		cmdPlace:                    1
		cmdMove:                     2
		cmdRemove:                   3
		cmdLabel:                    4
		cmdReplace:                  5
		cmdSound:                    6
		cmdShowFrame:                128
		

		
		
		
	out: make stream-io [] ;Holds output stream
	strings: copy []

	;Charsets:
	chDigit: charset "0123456789"
	
	timelineIdOffset: 0
	
	;Functions:
	write-string: func[
		"Writes string using UI16 pointer (zero based)"
		string [string!]
		/local f
	][
		out/writeUI16 -1 + either f: find strings string [
			index? f
		][
			append strings string
			length? strings
		]
	]
	write-bitmap-assets: func[
		level  [any-string!] "Lavel's name"
		name   [any-string!] "Per level texture sheet's name"
		/local
			srcDir   ;full path to directory where are bitmaps for packing
			packFile   ;file name of the output made by TexturePacker describing positions inside packed texture atlas bitmap
			rlPair     ;parse rule used to get pair value
			data       ;parsed pack data
			regions    ;block with values: [partId xy size] - describing position of each bitmap in the packed atlas bitmap
			sequences  ;block with image sequences with values: [index xy size orig offset] where sequence is multiple images with same ID
			bitmapName ;holds name of image being processed
			imgFile partId x y xy size orig offset index var value ;local values used in parse
			error
	][
		srcDir: rejoin [dirAssetsRoot %Bitmaps\ level #"/" name]
		packFile: join name %.rpack
		
		unless any [
			exists? dirPacks/:packFile
			exists? rejoin [dirPacks name %.pack]
		][
			if error? set/any 'error try [
				texture-pack srcDir dirPacks
			][
				print "Packing failed!"
				do error
			]
			comment {
			if 0 < call/wait/console probe reform [
				{java -classpath} texturePacker
					to-local-file srcDir
					to-local-file dirPacks
					packFile
			][
				print "Packing failed!"
				halt
			]
			}
		]
		
		imgFile:   none
		partId:    none
		regions:   none
		sequences: none
		data: copy []
		
		rlPair: [copy x some chDigits ", " copy y some chDigits (value: as-pair to-integer x to-integer y) #"^/"]
		
		either exists? dirPacks/:packFile [
			regions: copy []
			sequences: copy []
			foreach [xy size file] load dirPacks/:packFile [
				file: last split-path file
				parse file [
					copy partId to #"_" 1 skip copy index to #"." to end (
						sequence: select sequences partId
						if none? sequence  [
							append sequences partId
							append/only sequences sequence: copy []
						]
						repend sequence [to integer! index xy size]
					)
					|
					copy partId to #"." to end (
						repend regions [partId xy size]
					)
				]
			]
			
			foreach [partId xy size] regions [
				out/writeUI8 cmdDefineImage
				write-string partId
				out/writeUI16 xy/1
				out/writeUI16 xy/2
				out/writeUI16 size/1
				out/writeUI16 size/2
			]
			unless empty? sequences [
				foreach [id sequence] sequences [
					print ["Sequence" mold id "with length" ((length? sequence) / 5)] 
					sort/skip sequence 3
					out/writeUI8 cmdStartMovie
					write-string id
					foreach [index xy size orig offs] sequence [
						orig: load trim/all/with orig ","
						offs: load trim/all/with offs ","
						out/writeUI8 cmdAddMovieTextureWithFrame
						out/writeUI16 xy/1
						out/writeUI16 xy/2
						out/writeUI16 size/1
						out/writeUI16 size/2
					]
					out/writeUI8 cmdEndMovie
					out/writeUI16 0 ;no labels
				]
			]
		][
			;using old pack version
			parse/all read rejoin [dirPacks name %.pack] [
				some [
					#"^/" [
						copy imgFile to #"^/" 1 skip (
							probe imgFile print "========================"
							bitmapName: uppercase/part replace/all copy imgFile "." "_" 1
							regions: copy []
							sequences: copy []
							repend data [imgFile bitmapName regions sequences]
						)
						thru #"^/"
						thru #"^/"
						thru #"^/"
						some [
							some [
								"  " [
										"xy: "   copy xy     to #"^/" 1 skip 
									"  size: "   copy size   to #"^/" 1 skip
									"  orig: "   copy orig   to #"^/" 1 skip
									"  offset: " copy offset to #"^/" 1 skip
									"  index: "  copy index  to #"^/" 1 skip
									(
										index: to-integer index
										either index < 0 [
											if offset <> "0, 0" [
												ask reform ["!! Found trimed image" mold partId "offset:" offset]
											]
											repend regions [partId xy size]
										][
											sequence: select sequences partId
											if none? sequence  [
												append sequences partId
												append/only sequences sequence: copy []
											]
											repend sequence [index xy size orig offset]
										]
									)
									| copy var to #":" 2 skip copy value to #"^/" 1 skip ;(print [var value])
								]
							]
							|
							copy partId [some chNotSpace to #"^/"] thru #"^/"
						]
					]
				]
			]
			if regions [
				sort/skip/reverse regions 3
				new-line/skip regions true 3
			]
			
			foreach [imgFile bitmapName regions sequences] data [
				
				foreach [partId xy size] regions [
					xy:   load trim/all/with xy ","
					size: load trim/all/with size ","
					out/writeUI8 cmdDefineImage
					write-string partId
					out/writeUI16 xy/1
					out/writeUI16 xy/2
					out/writeUI16 size/1
					out/writeUI16 size/2
					
				]
				unless empty? sequences [
					foreach [id sequence] sequences [
						print ["Sequence" mold id "with length" ((length? sequence) / 5)] 
						sort/skip sequence 5
						out/writeUI8 cmdStartMovie
						write-string id
						foreach [index xy size orig offs] sequence [
							xy:   load trim/all/with xy   ","
							size: load trim/all/with size ","
							;either offs = "0, 0" [
								;TODO... I could use version without frame here..
							;][
								orig: load trim/all/with orig ","
								offs: load trim/all/with offs ","
								out/writeUI8 cmdAddMovieTextureWithFrame
								out/writeUI16 xy/1
								out/writeUI16 xy/2
								out/writeUI16 size/1
								out/writeUI16 size/2
								out/writeUI32 - offs/1
								out/writeUI32 size/2 - orig/2 + offs/2 ;- offs/2
								out/writeUI16 orig/1
								out/writeUI16 orig/2
							;]
						]
						out/writeUI8 cmdEndMovie
						out/writeUI16 0 ;no labels
					]
				]
			]
		]
	]
	get-atf-file: func[
		atf-type "Required ATF file extension (%dxt or %etc)"
		file     [any-string!] "Name of the bitmap file without extension"
	][
		rejoin [file #"." atf-type]
	]
	has-atf-version: func[
		atf-type "Required ATF file extension (%dxt or %etc)"
		file     [any-string!] "Name of the bitmap file without extension"
		/local
			origFile
			imageFile
			localDirBinUtils
		][
		print ["=== has-atf-version ===" mold file atf-type]
		if not any [
			exists? origFile: join file %-fs8.png
			exists? origFile: join file %.png
		][
			ask reform ["Cannot found source file for ATF:" mold file]
		]
		
		all [
			atf-type
			any [
				all [
					
					exists? probe imageFile: rejoin [file #"." atf-type]
					(modified? imageFile) > (modified? origFile)
					;false ;;<-- uncomment to force re-conversion
				]
				(
					localDirBinUtils: join to-local-file dirBinUtils #"\"
					;delete imageFile
					switch/default atf-type [
						%dxt [
							{
							call/wait/console probe rejoin [
								localDirBinUtils {PVRTexTool.exe -m -yflip0 -f DXT5 -dds}
									{ -i } to-local-file origFile
									{ -o } to-local-file file {.dds}
							]
							call/wait/console probe rejoin [
								to-local-file dirBinUtils {\dds2atf.exe -4 -q 0}
									{ -i } to-local-file file {.dds}
									{ -o } to-local-file imageFile
							]}
							call/wait/console probe rejoin [
								localDirBinUtils {png2atf.exe -c d -4}
									{ -i } to-local-file origFile
									{ -o } to-local-file imageFile
							]
							true
						]
						%etc [
							call/wait/console probe rejoin [
								localDirBinUtils {png2atf.exe -c e -4 -q 0}
									{ -i } to-local-file origFile
									{ -o } to-local-file imageFile
							]
							true
						]
						%pvr [
							call/wait/console probe rejoin [
								localDirBinUtils {png2atf.exe -c p -4 -q 0}
									{ -i } to-local-file origFile
									{ -o } to-local-file imageFile
							]
							true
						]
						%rgba [
							call/wait/console probe rejoin [
								localDirBinUtils {png2atf.exe -r -q 0}
									{ -i } to-local-file origFile
									{ -o } to-local-file imageFile
							]
							true
						]
					][ false ]
				)
			]
		]
	]
	set 'make-packs func [
		level [any-string!]   "Level's ID"
		/atf atf-type         "ATF extension which could be used for bitmap compression (dxt or etc)"
		/local
			sourceDir ;
			sourceSWF ;used for TimelineSWF file source
			sourceTXT ;used for parsed TimelineSWF source (cache)
			bin       ;used to store temporaly binary data
			indx      ;used to story temp output buffer position
			origImageFile
			imageFile
			name
			xml   ;for parsing starling's spritesheet animations
			x y width height frameX frameY frameWidth frameHeight ;variables used in starling's data xml
	][
		either dirAssetsRoot [
			dirAssetsRoot: to-file dirAssetsRoot
			if #"/" <> pick dirAssetsRoot 1 [insert dirAssetsRoot what-dir]
		][	make error! "Unspecified dirAssetsRoot" ]
		either dirBinUtils [
			dirBinUtils: to-file dirBinUtils
			if #"/" <> pick dirBinUtils 1 [insert dirBinUtils what-dir]
		][	make error! "Unspecified dirBinUtils" ]

		if all [atf-type none? find [%dxt %etc %rgba %pvr] atf-type][ atf-type: none ]
		
		out/clearBuffers
		
		
		
		;;BITMAPS:
		sourceDir: dirize rejoin [dirAssetsRoot %Bitmaps\ level]
		if exists? sourceDir [
			numExternalBitmap: 0
			foreach dir read sourceDir [
				if all [
					#"/" = last dir   ;Search for bitmaps directory (content of each dir will have it's own texture atlas)
					#"_" <> first dir ;Do not use folder with underscore prefix
				][
					remove back tail dir
					
					
					out/writeUI8 cmdTextureData
					write-string to-string dir
					;store output stream position
					indx: index? out/outBuffer 
					
					
					write-bitmap-assets level dir ;(writes only image specifications)
					out/writeUI8 0 ;end of block
					
					;set output position in front of written asssets specification;
					out/outBuffer: at head out/outBuffer indx 
					out/writeUI32  length? out/outBuffer
					out/outBuffer: tail out/outBuffer
					
					origImageFile: rejoin [dirPacks dir %.png]
					any [
						has-atf-version atf-type join dirPacks dir
						all [
							exists? imageFile: rejoin [dirPacks dir %-fs8.png]
							any [
								(modified? imageFile) > (modified? origImageFile)
								(
									delete imageFile
									call/wait/console probe rejoin [
										to-local-file pngQuantExe " "
										to-local-file join what-dir origImageFile
									]
									true
								)
							]
						]
						exists? imageFile: origImageFile
					]
					if atf-type [
						imageFile: get-atf-file atf-type join dirPacks dir
					]
					bin: read/binary probe imageFile
					
					out/outBuffer: at head out/outBuffer indx 
					either atf-type [
						;storing ATF in front of asset specifications
						;set output position in front of written asssets specification;
						out/writeUI8   1
						out/writeUI32  length? bin
						out/writeBytes bin
						
						out/outBuffer: tail out/outBuffer
						
					][
						out/writeUI8   0
						;storing PNG after assets - because we must use loader to get bitmap from bytes
						out/outBuffer: tail out/outBuffer
						out/writeUI32  length? bin
						out/writeBytes bin

					]
					;out/writeUTF dir
					
					;write/binary rejoin [%./bin/Data/ level %. numExternalBitmap ] bin
					;numExternalBitmap: numExternalBitmap + 1
					
					
					
					out/outBuffer: tail out/outBuffer ;sets output back after specifications
				]
			]
		]
		;;SOUNDS:
		sourceDir: dirize rejoin [dirAssetsRoot %Sounds\ level]
		if exists? sourceDir [
			foreach file read sourceDir [
				parse file [
					copy name to ".mp3" 4 skip end (
						print ["Sound: " file]
						bin: read/binary sourceDir/:file
						out/writeUI8   cmdDefineSound
						write-string   name
						out/writeUI32  length? bin
						out/writeBytes bin
					)
				]
			]
		]
		
		;;STARLING Sheets:
		sourceDir: dirize rejoin [dirAssetsRoot %Starling\ level]
		if exists? sourceDir [
			foreach file read sourceDir [
				if all [
					parse file [copy name to ".xml" 4 skip end]
					any [
						has-atf-version atf-type join sourceDir name
						exists? imageFile: rejoin [sourceDir name %-fs8.png]
						exists? imageFile: rejoin [sourceDir name %.png]
					]
				][
					out/writeUI8 cmdTextureData
					write-string name
					;store output stream position
					indx: index? out/outBuffer 
					
					out/writeUI8 cmdStartMovie
					write-string name
					
					xml: read/binary sourceDir/:file
					replace/all xml "^@" "" ;very dirty conversion from UTF16 codepoint - NOTE: make sure to use just Latin1 chars in names!
					use [name x y width height frameX frameY frameWidth frameHeight][
						parse/all xml [
							any [
								thru {<SubTexture name="} copy name to {"}
								thru {x="} copy x to {"}
								thru {y="} copy y to {"}
								thru {width="} copy width to {"}
								thru {height="} copy height to {"}
								thru {frameX="} copy frameX to {"}
								thru {frameY="} copy frameY to {"}
								thru {frameWidth="} copy frameWidth to {"}
								thru {frameHeight="} copy frameHeight to {"}
								(
									out/writeUI8  cmdAddMovieTextureWithFrame
									out/writeUI16 to-integer x
									out/writeUI16 to-integer y
									out/writeUI16 to-integer width
									out/writeUI16 to-integer height
									out/writeUI32 to-integer frameX
									out/writeUI32 to-integer frameY
									out/writeUI16 to-integer frameWidth
									out/writeUI16 to-integer frameHeight
								)
							]
						]
					]
					out/writeUI8 cmdEndMovie

					either all [
						exists? probe sourceTXT: rejoin [sourceDir name %.labels]
						not empty? data: load sourceTXT
					][
						out/writeUI16 (length? data) / 2
						foreach [number label] data [
							print [number tab label]
							out/writeUI16 number
							write-string  label
						]
					][
						out/writeUI16 0 ;no labels
					]
					
					out/writeUI8 0 ;end of block
					
					;set output position in front of written asssets specification;
					out/outBuffer: at head out/outBuffer indx 
					out/writeUI32  length? out/outBuffer
					out/outBuffer: tail out/outBuffer
					
					if atf-type [
						imageFile: get-atf-file atf-type join sourceDir name
					]
					bin: read/binary probe imageFile
					
					out/outBuffer: at head out/outBuffer indx 
					either atf-type [
						;storing ATF in front of asset specifications
						;set output position in front of written asssets specification;
						out/writeUI8   1
						out/writeUI32  length? bin
						out/writeBytes bin
						
						out/outBuffer: tail out/outBuffer
						
					][
						out/writeUI8   0
						;storing PNG after assets - because we must use loader to get bitmap from bytes
						out/outBuffer: tail out/outBuffer
						out/writeUI32  length? bin
						out/writeBytes bin

					]
					out/outBuffer: tail out/outBuffer ;sets output back after specifications
					
				]
			]
		]
		
		;;SWFs:
		sourceDir: dirize rejoin [dirAssetsRoot %SWFs\ level]
		if exists? sourceDir [
			foreach file read sourceDir [
				if all [
					parse file [copy name to ".swf" 4 skip end]
				][
					bin: read/binary probe rejoin [sourceDir file]
					out/writeUI8   cmdLoadSWF
					out/writeUTF   name
					out/writeUI32  length? bin
					out/writeBytes bin
				]
			]
		]
		
		;;TIMELINE OBJECTS DEFINITIONS:
		case [
			exists? sourceSWF: rejoin [dirAssetsRoot %TimelineSWFs\ level %_anims.swf][
				sourceTXT: rejoin [dirAssetsRoot %TimelineSWFs\ level %_anims.txt]
			]
			exists? sourceSWF: rejoin [dirAssetsRoot %TimelineSWFs\ level %.swf][
				sourceTXT: rejoin [dirAssetsRoot %TimelineSWFs\ level %.txt]
			]
		]

		if exists? sourceSWF [
			indx: index? out/outBuffer
			if any [
				;true ;;<-- just to force recreation every time
				not exists? sourceTXT
				(modified? sourceTXT) < (modified? sourceSWF)
				;(modified? join rs/get-project-dir 'form-timeline %form-timeline.r) > (modified? sourceTXT)
			][
				form-timeline sourceSWF
			]
			parse-timeline sourceTXT
			print ["Timeline bytes:" (index? out/outBuffer) - indx]
		]
		
		;;WALK DATA:
		sourceTXT: rejoin [dirAssetsRoot %WalkData\ level %_chuze.txt]
		if exists? sourceTXT [
			data: context load sourceTXT
			num: length? data/posX
			tmp: first data
			if all [
				num = length? data/posY
				num = length? data/scale
				num = length? data/rotate
			][
				print ["Walk DATA found.. frames:" num]
				out/writeUI8   cmdWalkData
				out/writeUI16  num
				foreach value data/posX   [ out/writeFloat value ]
				foreach value data/posY   [ out/writeFloat value ]
				foreach value data/scale  [ out/writeFloat value ]
				foreach value data/rotate [ out/writeFloat value ]
				
				out/writeUI16 (length? data/labelsAt) / 2
				foreach [num name] data/labelsAt [
					out/writeUI16 num
					out/writeUTF  name
				]
				
				out/writeUI16 (length? data/labelsLeft) / 2
				foreach [num name] data/labelsLeft [
					out/writeUI16 num
					out/writeUTF  name
				]
				
				out/writeUI16 (length? data/labelsRight) / 2
				foreach [num name] data/labelsRight [
					out/writeUI16 num
					out/writeUTF  name
				]
					
				either empty? data/sensors [
					out/writeUI8 0 ;no nodes
					out/writeUI8 0 ;no arcs
				][
					nodes: copy []
					arcs:  copy []
					foreach [name pos] data/sensors [
						parse/all to-string name [
							#"P" copy fromNode some chDigit (
								repend nodes [
									fromNode: to-integer fromNode
									pos
								]
							) any [
								#"_"
								copy arcType [#"j" | #"f" | #"b" | #"w" | #"n" | #"c" | #"v" | #"s" | none]
								copy toNode some chDigit
								(
									toNode: to-integer toNode
									if none? arcType [arcType: #"w"]
									;print [arcType fromNode toNode]
									repend arcs [arcType fromNode toNode]
								)
							]
						]
					]
					;nodes must be numbers from 0 to n
					probe new-line/skip sort/skip nodes 2 true 2
					if nodes/1 <> 0 [
						make error! "INVALID WALK NODE - Nodes must start with id 0!"
					]
					for n 3 length? nodes 2 [
						if 1 <> (nodes/(n) - nodes/(n - 2)) [
							print "!!! INVALID WALK NODEs (Nodes must be numbers from 0 to n with increment 1)!"
							print ["Found invalid sequence neer:" n mold node/(n)]
							halt
						]
					]
					out/writeUI8 (length? nodes) / 2
					foreach [node pos] nodes [
						out/writeUI16 pos/x
						out/writeUI16 pos/y
					]
					;probe new-line/skip arcs true 3
					out/writeUI8 (length? arcs) / 3
					foreach [arcType fromNode toNode] arcs [
						print rejoin [tab arcType #" " fromNode "-" toNode]
						out/writeByte arcType
						out/writeUI8  fromNode
						out/writeUI8  toNode
					]
				]
			]
		]
		
		
		out/writeUI8 0 ;end
		
		out/outBuffer: head out/outBuffer
		out/writeBytes as-binary "LVL"
		out/writeUI8 cmdUseLevel
		out/writeUTF level 
		
		print ["Writing" length? strings "strings.."]
		out/writeUI16 length? strings
		foreach string strings [
			out/writeUTF string
		]
		print ["Writing file..."]
		write/binary join %./bin/ rejoin [%Data/ level %.lvl] head out/outBuffer
		;either atf-type [
		;	[uppercase atf-type "/" level %.lvl]
		;][
		;	[%Data/ level %.lvl]
		;] head out/outBuffer
	]
	
	parse-timeline: func[
		file [file!]   "Formed timeline specification"
		/local
			type id data name ;parse variables
			indx ;used to count total bytes per sprite/movie
			startIndx
			names ;used to store names-to-id data
	][
		print ["====== parse-timeline "]
		names: copy []
		out/writeUI8  cmdTimelineData
		startIndx: index? out/outBuffer
		parse/all load file [
			any [
				set type ['Movie | 'Sprite] set id integer! set data block! (
					out/writeUI8  cmdTimelineObject
					out/writeUI16 id + timelineIdOffset
					indx: index? out/outBuffer
					parse-controlTags data
					out/writeUI8   0 ;end of timeline;
					out/outBuffer: at head out/outBuffer indx
					out/writeUI32  length? out/outBuffer
					out/outBuffer: tail out/outBuffer
				)
				|
				'Name set id integer! set name string! (
					;print [id mold name length? head out/outBuffer]
					repend names [name id + timelineIdOffset]
					;out/writeUI8  cmdTimelineName
					;out/writeUI16 id + timelineIdOffset
					;out/writeUTF  name
				)
				|
				'Shape set id integer! set data block! (
					comment {
					out/writeUI8  cmdTimelineShape
					out/writeUI16 id
					indx: index? out/outBuffer
					parse-ShapeDefinition data
					out/outBuffer: at head out/outBuffer indx
					out/writeUI32 length? out/outBuffer
					out/outBuffer: tail out/outBuffer
					}
				)
			]
		]
		out/outBuffer: at head out/outBuffer startIndx
		out/writeUI32  probe length? out/outBuffer
		
		out/outBuffer: tail out/outBuffer
		out/writeUI8   0
		out/writeUI32  0.5 * length? names 
		foreach [name id] names [
			out/writeUI16 id
			out/writeUTF  name
		]
	]

	write-transform: func[
		transform color flags
		/local
			colorMult hasColorMult removeTint alpha
	][
		if transform/3 [flags: flags or 8]
		if transform/1 [flags: flags or 16]
		if transform/2 [flags: flags or 32]
		if color [
			either block? colorMult: color/1 [
				flags: flags or 64
				alpha: colorMult/4
				if any [
					colorMult/1 <> 256
					colorMult/2 <> 256
					colorMult/3 <> 256
				][
					flags: flags or 128
					hasColorMult: true
				]
			][
				flags: flags or 128
				colorMult: [255 255 255]
				hasColorMult: true
			]
		]
		out/writeUI8  flags
		;probe transform
		if transform/3 [
			out/writeFloat transform/3/1 / 20 ;x
			out/writeFloat transform/3/2 / 20 ;y
		]
		if transform/1 [
			out/writeFloat transform/1/1 ;scaleX
			out/writeFloat transform/1/2 ;scaleY
		]
		if transform/2 [
			out/writeFloat transform/2/1 ;skewX
			out/writeFloat transform/2/2 ;skewY
		]
		if alpha [
			out/writeUI8 min 255 alpha
		]
		if hasColorMult [
			out/writeUI8 min 255 colorMult/1
			out/writeUI8 min 255 colorMult/2
			out/writeUI8 min 255 colorMult/3
		]
	]

	parse-ShapeDefinition: func[
		data
		/local
			thickness color
			points x y
			err
	][
		parse/all data [any[
			'lineStyle set thickness integer! set color tuple! (
				out/writeUI8   cmdLineStyle
				out/writeUI16  thickness
				out/writeBytes to-binary color
			)
			|
			'moveTo set x integer! set y integer! (
				out/writeUI8  cmdMoveTo
				out/writeUI16 x
				out/writeUI16 y
			)
			|
			'curve set points block! (
				out/writeUI8   cmdCurve
				out/writeUI16 (length? points) / 4 ;count
				foreach [cx cy ax ay] points [
					out/writeUI16 cx
					out/writeUI16 cy
					out/writeUI16 ax
					out/writeUI16 ay
				]
			)
			|
			'line set points block! (
				out/writeUI8  cmdLine
				out/writeUI16 (length? points) / 2 ;count
				foreach [x y] points [
					out/writeUI16 x
					out/writeUI16 y
				]
			)
			| copy err 1 skip (
				ask reform ["Invalid shape definition:" mold err]
			)
		]]
		out/writeUI8 0 ;end
	]
	parse-controlTags: func[
		data
		/local
			id depth transform type frames name colorTransform ;parse variables
			flags soundData pos
	][
		parse/all data [
			'TotalFrames set frames integer! (
				out/writeUI16 frames
			)
			any [
				pos:
				'Move set depth integer! set transform block! set color [block! | none] (
					;print ["Move: " depth]
					out/writeUI8  cmdMove
					out/writeUI16 depth - 1
					flags: 0
					write-transform transform color flags
				)
				|
				'ShowFrame (
					out/writeUI8  cmdShowFrame
				)
				|
				'Place set type word! set id integer! set depth integer! set transform block! set color [block! | none] (
					;print ["Place: " id]
					out/writeUI8  cmdPlace
					out/writeUI16 id + timelineIdOffset
					out/writeUI16 depth - 1
					flags: select [image 0 object 1 shape 2] type
					if none? flags [
						print ["Unknown place object type:" type]
						probe copy/part mold pos 200
						halt
					]
					write-transform transform color flags
				)
				|
				'Replace set type word! set id integer! set depth integer! set transform block! set color [block! | none] (
					;print ["Replace: " id]
					out/writeUI8  cmdReplace
					out/writeUI16 id + timelineIdOffset
					out/writeUI16 depth - 1
					flags: select [image 0 object 1 shape 2] type
					write-transform transform color flags
				)
				|
				'Remove set depth integer! (
					out/writeUI8  cmdRemove
					out/writeUI16 depth - 1
				)
				|
				'Label set name string! (
					out/writeUI8 cmdlabel
					out/writeUTF name
				)
				|
				'Sound set id integer! set soundData block! (
					out/writeUI8  cmdSound
					out/writeUI16 id + timelineIdOffset
					;soundData not used yet!
				)
				| pos: 1 skip (
					ask reform ["UNKNOWN COMMAND near:" mold copy/part pos 20 "..."] 
				)
			]
		]
	]
]