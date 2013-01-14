REBOL [
    Title: "Pack-assets"
    Date: 15-Nov-2012/11:03:26+1:00
    Version: 0.1.2
    Author: "Oldes"
    Email: oldes.huhuman@gmail.com
	Home: https://github.com/Oldes/rs/blob/master/projects-rswf/pack-assets/latest/pack-assets.r
	require: [
		rs-project %stream-io
		rs-project %form-timeline
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
		cmdLoadTexture:              2
		cmdInitTexture:              3
		cmdDefineImage:              4
		cmdStartMovie:               5
		cmdAddMovieTexture:          6
		cmdAddMovieTextureWithFrame: 7
		cmdEndMovie:                 8
		cmdLoadSWF:                  9
		cmdInitSWF:                  10
		cmdATFTexture:               11
		cmdATFTextureMovie:          12
		cmdTimelineObject:           13
		cmdTimelineName:             14
		cmdTimelineShape:            15
		cmdStartMovie2:              16
		cmdWalkData:                 17
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
	
	;Charsets:
	chDigit: charset "0123456789"
	
	;Functions:
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
	][
		srcDir: rejoin [dirAssetsRoot %Bitmaps\ level #"/" name]
		packFile: join name %.pack
		
		unless exists? dirPacks/:packFile [
			if 0 < call/wait/console probe reform [
				{java -classpath} texturePacker
					to-local-file srcDir
					to-local-file dirPacks
					packFile
			][
				print "Packing failed!"
				halt
			]
		]
		
		imgFile:   none
		partId:    none
		regions:   none
		sequences: none
		data: copy []
		
		rlPair: [copy x some chDigits ", " copy y some chDigits (value: as-pair to-integer x to-integer y) #"^/"]
		
		parse/all read dirPacks/:packFile [
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
				out/writeUTF partId
				out/writeUI16 xy/1
				out/writeUI16 xy/2
				out/writeUI16 size/1
				out/writeUI16 size/2
				
			]
			unless empty? sequences [
				foreach [id sequence] sequences [
					print ["Sequence" mold id "with length" ((length? sequence) / 5)] 
					sort/skip sequence 5
					out/writeUI8 cmdStartMovie2
					out/writeUTF id
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
							out/writeUI16 - offs/1
							out/writeUI16 size/2 - orig/2 + offs/2 ;- offs/2
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
		print ["=== has-atf-version ===" mold file]
		if not any [
			probe exists? probe origFile: join file %-fs8.png
			probe exists? probe origFile: join file %.png
		][
			ask reform ["Cannot found source file for ATF:" mold file]
		]
		
		all [
			atf-type
			any [
				all [
					exists? probe imageFile: rejoin [file #"." atf-type]
					(modified? imageFile) > (modified? origFile)
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
								localDirBinUtils {png2atf.exe -c e -4}
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

		if all [atf-type none? find [%dxt %etc] atf-type][ atf-type: none ]
		
		out/clearBuffers
		out/writeBytes as-binary "LVL"
		out/writeUI8 cmdUseLevel
		out/writeUTF probe level 
		
		;;BITMAPS:
		sourceDir: dirize rejoin [dirAssetsRoot %Bitmaps\ level]
		if exists? sourceDir [
			foreach dir read sourceDir [
				if all [
					#"/" = last dir   ;Search for bitmaps directory (content of each dir will have it's own texture atlas)
					#"_" <> first dir ;Do not use folder with underscore prefix
				][
					remove back tail dir
					
					;store output stream position
					indx: index? out/outBuffer 
					
					write-bitmap-assets level dir ;(writes only image specifications)
					
					;set output position in front of written asssets specification;
					out/outBuffer: at head out/outBuffer indx 
					
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
					either atf-type [
						out/writeUI8   cmdATFTexture
						out/writeUI32  length? bin
						out/writeBytes bin
					][
						out/writeUI8   cmdLoadTexture
						out/writeUI32  length? bin
						out/writeBytes bin
						out/writeUI8   cmdInitTexture
					]
					out/writeUTF dir
					
					out/outBuffer: tail out/outBuffer ;sets output back after specifications
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
					if atf-type [
						imageFile: get-atf-file atf-type join sourceDir name
					]
					bin: read/binary probe imageFile
					either atf-type [
						out/writeUI8   cmdATFTextureMovie
						out/writeUI32  length? bin
						out/writeBytes bin
					][
						out/writeUI8   cmdLoadTexture
						out/writeUI32  length? bin
						out/writeBytes bin
						out/writeUI8   cmdStartMovie
					]
					out/writeUTF name
					
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
									out/writeUI16 to-integer frameX
									out/writeUI16 to-integer frameY
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
							out/writeUTF  label
						]
					][
						out/writeUI16 0 ;no labels
					]
					
					
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
					out/writeUI8   cmdInitSWF
				]
			]
		]
		
		;;TIMELINE OBJECTS DEFINITIONS:
		sourceSWF: rejoin [dirAssetsRoot %TimelineSWFs\ level %.swf]
		sourceTXT: rejoin [dirAssetsRoot %TimelineSWFs\ level %.txt]
		if exists? sourceSWF [
			indx: index? out/outBuffer
			if any [
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
	][
		print ["====== parse-timeline "]
		parse/all load file [
			any [
				set type ['Movie | 'Sprite] set id integer! set data block! (
					out/writeUI8  cmdTimelineObject
					out/writeUI16 id
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
					out/writeUI8  cmdTimelineName
					out/writeUI16 id
					out/writeUTF  name
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
	]

	write-transform: func[
		transform color flags
		/local
			colorMult hasColorMult removeTint alpha
	][
		if transform/1 [flags: flags or 8]
		if transform/2 [flags: flags or 16]
		if color [
			either block? colorMult: color/1 [
				flags: flags or 32
				alpha: colorMult/4
				if any [
					colorMult/1 <> 256
					colorMult/2 <> 256
					colorMult/3 <> 256
				][
					flags: flags or 64
					hasColorMult: true
				]
			][
				flags: flags or 64
				colorMult: [255 255 255]
				hasColorMult: true
			]
		]
		out/writeUI8  flags
		;probe transform
		either transform/3 [
			out/writeFloat transform/3/1 / 20 ;x
			out/writeFloat transform/3/2 / 20 ;y
		][
			out/writeFloat 0 ;x
			out/writeFloat 0 ;y
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
			flags soundData
	][
		parse/all data [
			'TotalFrames set frames integer! (
				out/writeUI16 frames
			)
			any [
				'Move set depth integer! set transform block! set color [block! | none] (
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
					out/writeUI8  cmdPlace
					out/writeUI16 id
					out/writeUI16 depth - 1
					flags: select [image 0 object 1 shape 2] type
					write-transform transform color flags
				)
				|
				'Replace set type word! set id integer! set depth integer! set transform block! set color [block! | none] (
					out/writeUI8  cmdReplace
					out/writeUI16 id
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
					out/writeUI16 id
					;soundData not used yet!
				)
				| pos: 1 skip (
					ask reform ["UNKNOWN COMMAND near:" mold copy/part pos 20 "..."] 
				)
			]
		]
	]
]