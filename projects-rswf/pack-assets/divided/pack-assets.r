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
		rs-project %triangulator 'shrink
		rs-project %zlib
		rs-project %mp3
	]
	comment: {
		complex example where this script is used is here:
		https://github.com/Oldes/Starling-timeline-example
		warning: the timeline example is not updated so it will be probably not compatible with this version
	}
	
	note-to-myself: {
		Should I try this ATF packing once iOS will be more important for us?
		
		from http://forum.starling-framework.org/topic/i-got-my-game-to-60fps-with-an-iphone4-on-ios7
		<i>
		Here are some snippets from my applescripts

		For PVRTC (Alpha Compressed)
		do script "PVRTexToolCLI -f PVRTC1_4 -potcanvas + -q pvrtcbest -l -m 2 -i " & file_name & ".png -o " & file_name & ".pvr"
		do script "pvr2atf -n 0,0 -p " & file_name & ".pvr -o " & file_name & ".atf" in first window

		For DXT (RGBA) Works on desktop and iOS
		do script "PVRTexToolCLI -f r8g8b8a8,UBN,lRGB -potcanvas + -m 1 -q pvrtcbest -dither -l -i " & file_name & ".png -o " & file_name & ".pvr"
		do script "pvr2atf -r " & file_name & ".pvr -c p -n 0,0 -o " & file_name & ".atf" in first window
		</i>
		
		or maybe from:
		http://forum.starling-framework.org/topic/atf-observations-ymmv
		Since this post has been useful to some, I'll add another tidbit. The best quality PVR compression I've found for iOS is attained using the PVRTexTool utility from PowerVR. I think you have to sign up for their developer program to download the PowerVR GraphicsSDK, but it's free, though maybe you can find the tool itself elsewhere. Anyway, this commandline gives better PVR compression quality than Adobe's tool*:

		PVRTexToolCL -i atlas.png -o atlas.pvr -m -l -f PVRTC1_4 -q pvrtcbest -mfilter cubic
		This creates a .pvr file, and you then use Adobe's pvr2atf to create the atf file:

		pvr2atf -p atlas.pvr -o atlas.atf
		* - this is interesting, since it seems that Adobe's tool (png2atf) uses PVRTexTool libraries under the hood (same stdout while encoding). PVRTexTool also has more options for quality and encoding - play around with them in the GUI, but the above setting represents the best quality (albeit fairly slow to encode) for iOS compatibility.
	}

	preprocess: true
]

with: func [obj body][do bind body obj]

ctx-pack-assets: context [
	dirBinUtils:   %./Utils/
	dirAssetsRoot: %./Assets/
	dirPacks:      join dirAssetsRoot %Packs/

	pngQuantExe:   dirBinUtils/pngquant

	usePngQuant?:  true

	if system/version/4 = 3 [append pngQuantExe %.exe]
	
	;charsets:
		chNotSpace: complement charset "^/^- "
		chDigits: charset "0123456789" 
	
	;Asset's commands:
		cmdUseLevel:                 1
		cmdTextureData:              2
		cmdPackedAssets:              102
		cmdUseTexture:                103
		cmdDefineImage:              3
		cmdStartMovie:               4
		cmdEndMovie:                 5
		cmdAddMovieTexture:          6
		cmdAddMovieTextureWithFrame: 7
		
		cmdLoadSWF:                  8

		cmdTimelineData:             10
		cmdTimelineObject:           11
		cmdTimelineShape:            12
		cmdTimelineShape2:           13
		
		cmdTimelineData2:            40
		cmdShapeBuffers:             41
		cmdShapeVertexBuffer:        42
		cmdShapeIndexBuffer:         43
		
		cmdDefineSound:              15
		cmdDefineSoundOgg:           16
		cmdDefineSoundLoop:          17
		cmdDefineSoundRAW:			 18

		cmdWalkData:                 20
		cmdPathData:                 25

		cmdImageNames:               30
		cmdStringPool:               31
	;Shape's commands:
		cmdLineStyle:                1
		cmdMoveTo:                   2
		cmdCurve:                    3
		cmdLine:                     4
	;ControlTag assets:
		cmdPlace:                    1
		cmdPlaceNamed:               10
		cmdMove:                     2
		cmdRemove:                   3
		cmdLabel:                    4
		cmdReplace:                  5
		cmdSound:                    6
		cmdLabelCallback:            7
		cmdSoundVBR:                 8
		cmdSoundLNG:                 9
		cmdRemoveAnd:                11
		cmdFPS:                      30
		cmdFPSRange:                 31
		cmdSlowFPS:                  32
		cmdStop:                     33
		cmdRelease:                  34
		cmdTouchable:                35
		cmdHide:                     36
		cmdShow:                     37
		cmdShowFrame:                128
		

	usedTimelineImages: none
	usedTimelineSounds: none
	level-images: copy []  ;Storing list of all defined level images
	pack-files:   copy []
	out: make stream-io [] ;Holds output stream
	outTextures: make stream-io [] ;Holds textures stream - textures are separated because they may be reloaded when a context is lost
	strings: copy []
	sound-groups: copy []
	noATFfiles: []   ;Add names of packs where just PNG must be used (no ATF)
	needsMipmaps: [] ;Add names of packs where mipmaping is required
	;Charsets:
	chDigit: charset "0123456789"
	
	offsetSoundId:
	offsetImageId:
	offsetShapeId:
	offsetObjectId:
	offsetStringId: 0
	maxSoundId:
	maxImageId:
	maxShapeId:
	maxObjectId: 0
	
	currentLevel: none;
	;Functions:


	write-string: func[
		"Writes string using UI16 pointer (zero based)"
		string [string!]
		/local f id
	][
		id: offsetStringId - 1 + either f: find strings string [
			index? f
		][
			append strings string
			length? strings
		]
		either id < 256 [
			out/writeUI8 id
		][
			print "*** StringPool max size (255) reached! So 1 byte per ID will not be enough."
			halt
		]
	]

	pack-bitmaps: func[
		level  [any-string!] "Lavel's name"
		name   [any-string!] "Per level texture sheet's name"
		/local
			srcDir packFile
			result-files
	][
		ctx-texture-packer/max-size: 2048x2048
		srcDir: rejoin [dirAssetsRoot %Bitmaps\ level #"/" name]
		packFile: join name %.rpack
		result-files: copy []
		
		either any [
			exists? dirPacks/:packFile
		][
			append result-files dirPacks/:name
			n: 1
			while [exists? rejoin [dirPacks name %_ n %.rpack]][
				append result-files rejoin [dirPacks name %_ n]
				n: n + 1
			]
		][
			if error? set/any 'error try [
				result-files: texture-pack srcDir dirPacks
			][
				print "Packing failed!"
				do error
			]
		]
		result-files
	]
	
	pack-bitmaps-4096: func[
		level  [any-string!] "Lavel's name"
		/local
			srcDir packFile
			result-files
	][
		ctx-texture-packer/max-size: 4096x4096
		srcDir: rejoin [dirAssetsRoot %Bitmaps\ level #"/"]
		packFile: join level %.rpack
		result-files: copy []
		
		either any [
			exists? dirPacks/4096/:packFile
		][
			append result-files dirPacks/4096/:level
			n: 1
			while [exists? rejoin [dirPacks %4096/ level %_ n %.rpack]][
				append result-files rejoin [dirPacks %4096/ level %_ n]
				n: n + 1
			]
		][
			if error? set/any 'error try [
				result-files: texture-pack srcDir join dirPacks %4096/
			][
				print "Packing failed!"
				do error
			]
		]
		result-files
	]
	write-rpack-assets: func[
		rpack-file
		/local
			indx file partId index
			regions sequences
	][
		indx: index? out/outBuffer 
		regions: copy []
		sequences: copy []
		foreach [xy size file] load rpack-file [
			parse file [
				thru "Bitmaps/" [
					copy partId to #"_" 1 skip copy index to #"." to end (
						sequence: select sequences partId
						if none? sequence  [
							append sequences partId
							append/only sequences sequence: copy []
						]
						repend sequence [to integer! index xy size]
					)
					|
					copy partId to ".png" to end (
						if find partId %MesicekNoraPozadi/Pozadi [size: size - 0x2]
						repend regions [partId xy size]
					)
				]
			]
		]
		foreach [partId xy size] regions [
			out/writeUI8 cmdDefineImage
			out/writeUI16 offsetImageId - 1 + index? find level-images partId
			out/writeUI16 xy/1
			out/writeUI16 xy/2
			out/writeUI16 size/1
			out/writeUI16 size/2
		]
		unless empty? sequences [
			foreach [id sequence] probe sequences [
				print ["Sequence" mold id "with length" ((length? sequence) / 3)] 
				sort/skip sequence 3
				out/writeUI8 cmdStartMovie
				out/writeUTF id
				foreach [index xy size] sequence [
					out/writeUI8 cmdAddMovieTexture
					out/writeUI16 xy/1
					out/writeUI16 xy/2
					out/writeUI16 size/1
					out/writeUI16 size/2
				]
				out/writeUI8 cmdEndMovie
				out/writeUI16 0 ;no labels
			]
		]
		
		out/writeUI8 0 ;end of block
		;set output position in front of written asssets specification;
		out/outBuffer: at head out/outBuffer indx 
		out/writeUI32  length? out/outBuffer
		out/outBuffer: tail out/outBuffer
	]

	not-excluded-atf?: func[file][
		none? find noATFfiles last parse file "/"
	]
	needs-mipmaps?: func[file][none? find noATFfiles last parse file "/"]
	
	get-atf-file: func[
		atf-type "Required ATF file extension (%dxt or %etc)"
		file     [any-string!] "Name of the bitmap file without extension"
	][
		rejoin either all [
			atf-type
			not-excluded-atf? file
		][
			[file #"." atf-type]
		][
			[file #"." %png]
		]
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
			all [usePngQuant? exists? origFile: join file %-fs8.png]
			exists? origFile: join file %.png
		][
			ask reform ["Cannot found source file for ATF:" mold file]
		]
		all [
			atf-type
			not-excluded-atf? file
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
							either parse file [thru "./Assets/Packs/" ["HoubarKrabicka" | "MustekMain"] end] [
								;this version is correct when some of images is used with BlemdMode.MULTIPLY
								call/console probe rejoin [
									localDirBinUtils {png2atf.exe -c d -4}
										{ -i } to-local-file origFile
										{ -o } to-local-file imageFile
								]
							][
								;this method should have in theory better result, but have issue when used with MULTIPLY blend mode.
								call/console probe rejoin [
									localDirBinUtils {PVRTexTool.exe -m -yflip0 -q 5 -dither -l -f DXT5 -dds}
										{ -i } to-local-file origFile
										{ -o } to-local-file file {.dds}
								]
								call/console probe rejoin [
									to-local-file dirBinUtils {\dds2atf.exe -4 -q 0 -f 0} either needs-mipmaps? file [" -n 0,0"][""]
										{ -i } to-local-file file {.dds}
										{ -o } to-local-file imageFile
								]
							]
							true
						]
						%etc [
							either find file "Kniha" [
								call/console probe rejoin [
									localDirBinUtils {PVRTexToolCLI.exe -f r8g8b8a8,UBN,lRGB -q pvrtcbest -dither -l}
										{ -i } to-local-file origFile
										{ -o } to-local-file file {.pvr}
								]	
								call/console probe rejoin [
									to-local-file dirBinUtils {\pvr2atf.exe -c e -4 -q 0 -f 0}
										{ -r } to-local-file file {.pvr}
										{ -o } to-local-file imageFile
								] ;;[LOG][7409] ALL PRELOADED (preloadFile) 6461ms, v2
							][
								call/console probe rejoin [
									localDirBinUtils {png2atf.exe -c e -4 -q 0} either needs-mipmaps? file [" -n 0,0"][""] { -f 0}
										{ -i } to-local-file origFile
										{ -o } to-local-file imageFile
								] ;;prasivka: [LOG][7229] ALL PRELOADED (preloadFile) 6134ms, v1
							]
							
							
							{
							call/console probe rejoin [
								localDirBinUtils {png2atf.exe -c e -4 -q 0 -f 0}
									{ -i } to-local-file origFile
									{ -o } to-local-file imageFile
							] ;;prasivka:
							}
							{
							call/console probe rejoin [
								localDirBinUtils {PVRTexToolCLI.exe -f r8g8b8a8,UBN,lRGB -potcanvas + -m 1 -q pvrtcbest -dither -l}
									{ -i } to-local-file origFile
									{ -o } to-local-file file {.pvr}
							]
							call/console probe rejoin [
								to-local-file dirBinUtils {\pvr2atf.exe -c e -n 0,0}
									{ -r } to-local-file file {.pvr}
									{ -o } to-local-file imageFile
							] ;;[LOG][7409] ALL PRELOADED (preloadFile) 6461ms, v2
						}
							{
							call/console probe rejoin [
								localDirBinUtils {PVRTexToolCLI.exe -f ETC1,UBN,lRGB -potcanvas + -m 2 -q etcslowperceptual -dither -l}
									{ -i } to-local-file origFile
									{ -o } to-local-file file {.pvr}
							]
							call/console probe rejoin [
								to-local-file dirBinUtils {\pvr2atf.exe -c e -n 0,0}
									{ -e } to-local-file file {.pvr}
									{ -o } to-local-file imageFile
							] ;;[LOG][7409] ALL PRELOADED (preloadFile) 6461ms, v2
							}
							{
							call/console probe rejoin [
								localDirBinUtils {png2atf.exe -c e2 -4 -q 0 -n 0,0 -f 0}
									{ -i } to-local-file origFile
									{ -o } to-local-file imageFile
							] ;;prasivka: [LOG][7228] ALL PRELOADED (preloadFile) 6222ms v etc2
							}
							true
						]
						%pvr [
							call/console probe rejoin [
								localDirBinUtils {png2atf.exe -c p -4 -q 0}
									{ -i } to-local-file origFile
									{ -o } to-local-file imageFile
							]
							true
						]
						%rgba [
							{call/console probe rejoin [
								localDirBinUtils {png2atf.exe -4 -r -q 0}
									{ -i } to-local-file origFile
									{ -o } to-local-file imageFile
							]}
							;this method seems to be without edge issues, but on old machines slower probably
							call/console probe rejoin [
								localDirBinUtils {PVRTexToolCLI.exe -f r8g8b8a8,UBN,lRGB -potcanvas + -m 1 -q pvrtcbest -dither -l}
									{ -i } to-local-file origFile
									{ -o } to-local-file file {.pvr}
							]
							call/console probe rejoin [
								to-local-file dirBinUtils {\pvr2atf.exe -c p -n 0,0}
									{ -r } to-local-file file {.pvr}
									{ -o } to-local-file imageFile
							]
							true
						]
					][ false ]
				)
			]
		]
	]
	
	;-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	;-- !!!!!!!!!!!!!!! HARDOCDED VALUES !!!!!!!!!!!!!!!!!!!!!
	;--                 [objects images shapes sounds strings]
	idOffsetData: [
		%Univerzal         [0       0      0      0     10]
		%UniverzalPrasivka [100     260    100    331   27]
		%PlanetaDomovska   [600     1300   100    390   50]
		%PlanetaZluta      [600     1300   100    390   50]
		%PlanetaTermiti    [600     1300   100    390   50]
		%PlanetaMnisi      [600     1300   100    390   50]
		
		;%Konstrukter   [11      34     0      0     ]
		;%Prasivka      [195     1805   2      3     ]
		;%Domek         [632     4514   997    3     ]
		;%Mustek        [1364    7509   997    48    ]
		;%Houbar        [1464    8025   2160   48    ]
	]
	;-- !!!!!!!!!!!!!!! HARDOCDED VALUES !!!!!!!!!!!!!!!!!!!!!
	get-imageIdOffset: func[level [any-string!] /local tmp][
		tmp: select idOffsetData to-file level
		either tmp [tmp/2][1300]
	]
	;-- !!!!!!!!!!!!!!! HARDOCDED VALUES !!!!!!!!!!!!!!!!!!!!!
	set-timelineIdOffset: func[level [any-string!]][
		;if level <> %Univerzal [level: none]
		set [offsetObjectId offsetImageId offsetShapeId offsetSoundId offsetStringId] any[
			select idOffsetData to-file level
			[600 1300 100 400 50]
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
			files ;holds temporary data for farther processing
	][
		currentLevel: to string! level ;uppercase/part lowercase to string! level 1
		;-- Check if main directories are specifield...
		either dirAssetsRoot [
			dirAssetsRoot: to-file dirAssetsRoot
			if #"/" <> pick dirAssetsRoot 1 [insert dirAssetsRoot what-dir]
		][	make error! "Unspecified dirAssetsRoot" ]
		either dirBinUtils [
			dirBinUtils: to-file dirBinUtils
			if #"/" <> pick dirBinUtils 1 [insert dirBinUtils what-dir]
		][	make error! "Unspecified dirBinUtils" ]
		
		;-- Validate atf-type if there is any...
		if all [atf-type none? find [%dxt %etc %rgba %pvr] atf-type][ atf-type: none ]
		
		;-- Init ouput buffer...
		out/clearBuffers
		outTextures/clearBuffers
		clear pack-files
		clear level-images
		clear sound-groups
		clear strings
		
		set-timelineIdOffset level
		maxSoundId:
		maxImageId:
		maxShapeId:
		maxObjectId: 0

		;== BITMAPS:
		sourceDir: dirize rejoin [dirAssetsRoot %Bitmaps/ level]
		if exists? sourceDir [
			use-4096?: off
			either use-4096? [
				append pack-files  pack-bitmaps-4096 level
			][
				foreach dir read sourceDir [
					if all [
						#"/" = last dir   ;Search for bitmaps directory (content of each dir will have it's own texture atlas)
						#"_" <> first dir ;Do not use folder with underscore prefix
					][
						remove back tail dir
						append pack-files pack-bitmaps level dir
					]
				]
			]
			foreach pack pack-files [
				foreach [ofs size file] load join pack %.rpack [
					parse/all file [
						thru %Bitmaps/ copy name to %.png (
							append level-images name
						)
					]
				]
			]
			maxImageId: length? level-images
			new-line/all level-images true
			;probe level-images
			save rejoin [dirAssetsRoot %Bitmaps/ level %/images.txt] level-images
			
			foreach packName pack-files [
				probe origImageFile: rejoin [packName %.png]
				;-- Generate ATF versions if required...
				any [
					has-atf-version atf-type packName
					all [
						usePngQuant?
						exists? imageFile: rejoin [packName %-fs8.png]
						any [
							(modified? imageFile) > (modified? origImageFile)
							(
								delete imageFile
								call/console probe rejoin [
									to-local-file pngQuantExe " "
									to-local-file join what-dir origImageFile
								]
								true
							)
						]
					]
					exists? imageFile: origImageFile
				]
				;-- Write bitmaps data into result stream
				bin: read/binary get-atf-file atf-type packName
				
				outTextures/writeUI8 cmdTextureData
				outTextures/writeUTF to-string find/tail packName dirPacks

				out/writeUI8 cmdPackedAssets
				out/writeUTF to-string find/tail packName dirPacks
				write-rpack-assets join packName %.rpack
				
				either all [
					atf-type
					not-excluded-atf? packName
				][
					outTextures/writeUI8   1 ;is compressed
					outTextures/writeUI32  length? bin
					outTextures/writeBytes bin
				][
					outTextures/writeUI8   0 ;not compressed
					outTextures/writeUI32  length? bin
					outTextures/writeBytes bin
				]
			]
			
			if exists? tmp: rejoin [dirAssetsRoot %Bitmaps/ level %/images-named.txt][
				n: 0
				indx: index? out/outBuffer 
				foreach image load tmp [
					if tmp: find level-images image [
						out/writeUTF  image
						out/writeUI16 offsetImageId - 1 + index? tmp
						n: n + 1
					]
				]
				if n > 0 [
					out/outBuffer: at head out/outBuffer indx
					out/writeUI8   cmdImageNames
					out/writeUI16  n
					out/outBuffer: tail out/outBuffer
				]
			]
		]
		
		;;TIMELINE - form timeline before sound because it exports MP3 files
		case [
			exists? sourceSWF: rejoin [dirAssetsRoot %TimelineSWFs\ level %_anims.swf][
				sourceTXT: rejoin [dirAssetsRoot %TimelineSWFs\ level %_anims.txt]
			]
			exists? sourceSWF: rejoin [dirAssetsRoot %TimelineSWFs\ level %.swf][
				sourceTXT: rejoin [dirAssetsRoot %TimelineSWFs\ level %.txt]
			]
		]
		if exists? sourceSWF [
			if any [
				;true ;;<-- just to force recreation every time
				not exists? sourceTXT
				(modified? sourceTXT) < (modified? sourceSWF)
				;(modified? join rs/get-project-dir 'form-timeline %form-timeline.r) > (modified? sourceTXT)
			][
				form-timeline sourceSWF
			]
		]
		
		;;SOUNDS:
		soundsDir: dirize rejoin [dirAssetsRoot %Sounds\ level]
		level-sounds: copy []
		if exists? soundsDir [
			n: 0
			soundsToImport: read soundsDir
			forall soundsToImport [
				probe file: soundsToImport/1
				either #"/" = last file [
					parse file [copy tmp to #"/"]
					unless find sound-groups tmp [append sound-groups tmp]
					foreach subFile read soundsDir/:file [
						append soundsToImport rejoin [file subFile]
					]
				][
					parse file [
						copy name to ".mp3" 4 skip end (
							print ["Sound: " file]
							append level-sounds rejoin [to-string level %"/" name]
							bin: read/binary soundsDir/:file
							out/writeUI8   cmdDefineSound
							out/writeUTF   name
							out/writeUI16  offsetSoundId + n
							out/writeUI32  length? bin
							out/writeBytes bin
							n: n + 1
						)
						|
						copy name to ".loop" 5 skip end (
							bin: read/binary soundsDir/:file
							mp3/parse/file soundsDir/:file
							out/writeUI8   cmdDefineSoundLoop
							out/writeUTF   name
							out/writeUI32  mp3/num_frames
							out/writeUI32  length? bin
							out/writeBytes bin
						)
						|
						copy name to ".snd" 4 skip end (
							print ["Sound RAW: " file]
							bin: read/binary soundsDir/:file
							out/writeUI8   cmdDefineSoundRAW
							out/writeUTF   name
							out/writeUI32  b: length? bin
								;-- test for same length in level Mloci
								;	if (b / 5292) <> round(b / 5292) [
								;		ask "blby snd"
								;	]
								;--
							;while [not tail? bin][
							;	out/writeBytes head reverse copy/part bin 2
							;	bin: skip bin 2
							;]
							out/writeBytes bin
						)
						;|
						;copy name to ".ogg" 4 skip end (
						;	print ["Sound: " file]
						;	append level-sounds rejoin [to-string level %"/" name]
						;	bin: read/binary soundsDir/:file
						;	out/writeUI8   cmdDefineSoundOgg
						;	out/writeUTF   name
						;	out/writeUI16  offsetSoundId + n
						;	out/writeUI32  length? bin
						;	out/writeBytes bin
						;	n: n + 1
						;)
					]
				]
			]
			maxSoundId: n
			new-line/all level-sounds true
			save soundsDir/sounds.txt level-sounds
		]

		;;STARLING Sheets:
		sourceDir: dirize rejoin [dirAssetsRoot %Starling\ level]
		if exists? sourceDir [
			foreach file read sourceDir [
				if all [
					parse file [copy name to ".xml" 4 skip end]
					any [
						has-atf-version atf-type join sourceDir name
						all [usePngQuant? exists? imageFile: rejoin [sourceDir name %-fs8.png]]
						exists? imageFile: rejoin [sourceDir name %.png]
					]
				][
					print ["using:" imageFile]
					outTextures/writeUI8 cmdTextureData
					outTextures/writeUTF name
					
					out/writeUI8 cmdPackedAssets
					out/writeUTF name
					;store output stream position
					indx: index? out/outBuffer 
					
					out/writeUI8 cmdStartMovie
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
						exists? probe sourceLabels: rejoin [sourceDir name %.labels]
						not empty? data: load sourceLabels
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
					
					out/writeUI8 0 ;end of block
					
					;set output position in front of written asssets specification;
					out/outBuffer: at head out/outBuffer indx 
					out/writeUI32  length? out/outBuffer
					out/outBuffer: tail out/outBuffer
					
					if all [
						atf-type
						not-excluded-atf? join sourceDir name
					][
						imageFile: get-atf-file atf-type join sourceDir name
					]
					bin: read/binary probe imageFile
					
					;out/outBuffer: at head out/outBuffer indx 
					either all [
						atf-type
						not-excluded-atf? join sourceDir name
					][
						;storing ATF in front of asset specifications
						;set output position in front of written asssets specification;
						outTextures/writeUI8   1
						outTextures/writeUI32  length? bin
						outTextures/writeBytes bin
						
						;out/outBuffer: tail out/outBuffer
						
					][
						outTextures/writeUI8   0
						;storing PNG after assets - because we must use loader to get bitmap from bytes
						;outTextures/outBuffer: tail outTextures/outBuffer
						outTextures/writeUI32  length? bin
						outTextures/writeBytes bin

					]
					;out/outBuffer: tail out/outBuffer ;sets output back after specifications
					
				];END OF CLASIC STARLING
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
		
		;;TIMELINE OBJECTS DEFINITIONS (continue)
		if exists? sourceSWF [
			indx: index? out/outBuffer
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
				
				;Reflections:
				either all [
					find first data 'rPosX
					0 < num: length? data/rPosX
				][
					out/writeUI16  num
					foreach value data/rPosX   [ out/writeFloat value ]
					foreach value data/rPosY   [ out/writeFloat value ]
					foreach value data/rRotate [ out/writeFloat value ]
				][
					out/writeUI16  0
				]
				
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
						parse/all/case to-string name [
							#"P" copy fromNode some chDigit (
								repend nodes [
									fromNode: to-integer fromNode
									pos
								]
							) any [
								#"_"
								copy arcType [#"j" | #"f" | #"b" | #"w" | #"n" | #"c" | #"v" | #"s" | #"r" | #"k" | #"S" | none]
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
						probe nodes
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
		
		;;PATH DATA:
		sourceTXT: rejoin [dirAssetsRoot %Paths\ level %_paths.txt]
		if exists? sourceTXT [
			data: context load sourceTXT
			num: length? data/posX
			tmp: first data
			if all [
				num = length? data/posY
				num = length? data/scaleX
				num = length? data/scaleY
				num = length? data/rotate
			][
				print ["Path DATA found.. frames:" num]
				out/writeUI8   cmdPathData
				out/writeUI16  num
				foreach value data/posX   [ out/writeFloat value ]
				foreach value data/posY   [ out/writeFloat value ]
				foreach value data/scaleX [ out/writeFloat value ]
				foreach value data/scaleY [ out/writeFloat value ]
				foreach value data/rotate [ out/writeFloat value ]
				
				out/writeUI16 (length? data/labelsAt) / 2
				foreach [num name] data/labelsAt [
					out/writeUI16 num
					out/writeUTF  name
				]
			]
		]

		;;RAW data:
		RAWDir: dirize rejoin [dirAssetsRoot %Raw\ level]
		if exists? RAWDir [
			n: 0
			filesToImport: read RAWDir
			forall filesToImport [
				probe file: filesToImport/1
				parse file [
					copy name to ".bin" 4 skip end (
						print ["RAW:" file]
						bin: read/binary RAWDir/:file
						out/writeUI8   cmdDefineSoundRAW
						out/writeUTF   name
						out/writeUI32  b: length? bin
						out/writeBytes bin
					)
					|
					copy name to ".path" 5 skip end (
						print ["RAW Path:" file]
						data: make object! load RAWDir/:file

						out/writeUI8   cmdDefineSoundRAW
						out/writeUTF   name
						tmp: out/outBuffer
						if (length? data/x) <> (length? data/y) [
							print "Number of X positions is not same as Y!!"
							halt
						]
						;path data..
						out/writeUI16 length? data/x
						foreach x data/x [out/writeFloat x]
						foreach y data/y [out/writeFloat y]
						out/writeUI16 0.5 * length? data/labels
						foreach [num label] data/labels [
							out/writeUI16 num
							out/writeUTF label
						]
						;..path data end
						out/outBuffer: tmp
						out/writeUI32 length? out/outBuffer ;size of path data in the raw block
						out/outBuffer: tail out/outBuffer
					)

				]
			]
		]
		
		outTextures/writeUI8 0 ;end
		outTextures/outBuffer: head outTextures/outBuffer
		outTextures/writeBytes as-binary "LVL"
		outTextures/writeUI8 cmdUseLevel
		outTextures/writeUTF level 
		
		print ["Writing textures file..."]
		write/binary join %./bin/ rejoin [%Data/ target #"/" level %.lvl] head outTextures/outBuffer
		
		out/writeUI8 0 ;end
		
		out/outBuffer: head out/outBuffer
		out/writeBytes as-binary "LVL"
		out/writeUI8 cmdUseLevel
		out/writeUTF level 

		out/writeUI8  cmdStringPool
		out/writeUI16 length? probe strings
		n: 0
		foreach string strings [
			out/writeUI16 offsetStringId + n
			out/writeUTF string
			n: n + 1
		]
		
		print ["Writing file..."]
		write/binary join %./bin/ rejoin [%Data/ level %.lvl] head out/outBuffer

		reduce [
			maxObjectId
			maxImageId
			maxShapeId
			maxSoundId
			length? strings
		]
	]
	
	parse-timeline: func[
		file [file!]   "Formed timeline specification"
		/local
			type id data name ;parse variables
			indx ;used to count total bytes per sprite/movie
			startIndx
			names ;used to store names-to-id data
	][
		print ["====== parse-timeline " file]

		ctx-triangulator/init
		parse file [
			any [
				thru "Mesicek1.txt" end (
					ctx-triangulator/_minLineWidth: 20
					ask "???"
				)
			]
		]


		names: copy []
		out/writeUI8  cmdTimelineData2
		startIndx: index? out/outBuffer
		parse/all load file [
			any [
				set type ['Movie | 'Sprite] set id integer! set data block! (
					out/writeUI8  cmdTimelineObject
					out/writeUI16 id + offsetObjectId
					indx: index? out/outBuffer
					parse-controlTags data
					out/writeUI8   0 ;end of timeline;
					out/outBuffer: at head out/outBuffer indx
					out/writeUI32  length? out/outBuffer
					out/outBuffer: tail out/outBuffer
					if maxObjectId < id [maxObjectId: id]
				)
				|
				'Name set id integer! set name string! (
					print [id mold name length? head out/outBuffer]
					repend names [name id + offsetObjectId]
				)
				|
				'Shape set id integer! set data block! (
					{
					out/writeUI8  cmdTimelineShape
					out/writeUI16 id + offsetShapeId
					indx: index? out/outBuffer
					parse-ShapeDefinition data
					out/outBuffer: at head out/outBuffer indx
					out/writeUI32 length? out/outBuffer
					out/outBuffer: tail out/outBuffer
					if maxShapeId < id [maxShapeId: id]
					}
					out/writeUI8  cmdTimelineShape2
					out/writeUI16 id + offsetShapeId
					data: triangulate-shape data ;main result is stored in shared vertex and index buffers inside triangulator
					out/writeUI8  data/1 ;buffer number
					out/writeUI32 data/2 ;firstIndex
					out/writeUI32 data/3 ;numTriangles
					
					if maxShapeId < id [maxShapeId: id]
				)
				|
				'Images set usedTimelineImages block!
				|
				'Sounds set usedTimelineSounds block!
			]
		]
		
		outTextures/writeUI8 cmdShapeBuffers
		outTextures/writeBytes ctx-triangulator/get-buffers-binary
		
		
		out/outBuffer: at head out/outBuffer startIndx
		out/writeUI32  probe length? out/outBuffer
		out/outBuffer: tail out/outBuffer
		out/writeUI8   0
		
		out/writeUI32  0.5 * length? names 
		foreach [name id] names [
			out/writeUI16 id
			out/writeUTF  name
			;print ["Named TO:" id name]
		]
		
		out/writeUI32  length? sound-groups 
		id: 0
		foreach name sound-groups [
			id: id + 1
			out/writeUI8  id
			out/writeUTF  name
			print ["Sound Group:" id name]
		]
	]

	write-transform: func[
		transform color flags
		/local
			colorMult colorAdd hasColorMult removeTint alpha useColorMatrix
	][
		if transform/3 [flags: flags or 8]
		if transform/1 [flags: flags or 16]
		if transform/2 [flags: flags or 32]
		if color [
			set [colorMult colorAdd] color
			either any [
				block? colorAdd
				all [
					block? colorMult
					any [
						colorMult/1 <> 256
						colorMult/2 <> 256
						colorMult/3 <> 256
					]
				]
			][
				flags: flags or 64
				useColorMatrix: true
				print ["ColorMatrix.." mold color mold transform]
			][
				if block? colorMult [
					flags: flags or 128
					alpha: colorMult/4
				]
			]
			comment {
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
			]}
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
		either useColorMatrix [
			out/writeFloat colorMult/1 / 256
			out/writeFloat colorMult/2 / 256
			out/writeFloat colorMult/3 / 256
			out/writeFloat colorMult/4 / 256
			if none? colorAdd [colorAdd: [0 0 0 0]]
			out/writeFloat colorAdd/1 / 256
			out/writeFloat colorAdd/2 / 256
			out/writeFloat colorAdd/3 / 256
			out/writeFloat colorAdd/4 / 256
			{if hasColorMult [
				out/writeUI8 min 255 colorMult/1
				out/writeUI8 min 255 colorMult/2
				out/writeUI8 min 255 colorMult/3
			]}
		][
			if alpha [
				out/writeUI8 min 255 alpha
			]
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
					;print ["curve" cx cy ax ay]
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
			id depth transform type frames name colorTransform value value2 ;parse variables
			flags soundData pos imageName externalLevel soundGroup temp
	][
		place-command: does [
			;print ["Place: " id]
			switch/default type [
				image  [
					imageName: usedTimelineImages/:id
					if error? try [
						id: -1 + offsetImageId + index? find level-images imageName
					][
						if error? try [
							parse imageName [copy externalLevel to #"/" to end]
							;TODO: optimize this part!!
							id: index? find load rejoin [dirAssetsRoot %Bitmaps/ externalLevel %/images.txt] imageName
							id: id - 1 + get-imageIdOffset externalLevel
							;print ["External image:" imageName]
						][
							ask ["!!! Unknown timeline image!" id imageName]
							;probe level-images
							id: 0
						]

					]
					out/writeUI16 id 
				]
				object [ out/writeUI16 id + offsetObjectId ]
				shape  [ out/writeUI16 id + offsetShapeId ]
			][
				make error! reform ["!!! UNKNOWN TYPE:" type]
			]
			out/writeUI16 depth - 1
			flags: select [image 0 object 1 shape 2] type
			if none? flags [
				print ["Unknown place object type:" type]
				probe copy/part mold pos 200
				halt
			]
			write-transform transform color flags
		]

		parse/all data [
			'TotalFrames set frames integer! (
				out/writeUI16 frames
			)
			opt ['HasLabels (
				out/writeUI8 cmdLabelCallback
			)]
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
				'Place 
					set type word!
					set id integer!
					set depth integer!
					set transform block!
					set color [block! | none]
					set name [string! | none]
				(
					either name [
						out/writeUI8 cmdPlaceNamed
						write-string name
						;ask ["NAMED.." name]
					][
						out/writeUI8 cmdPlace
					]
					place-command
				)
				|
				'Replace set type word! set id integer! set depth integer! set transform block! set color [block! | none] (
					; ["Replace: " id]
					out/writeUI8  cmdReplace
					switch/default type [
						image  [ out/writeUI16 id + offsetImageId ]
						object [ out/writeUI16 id + offsetObjectId ]
						shape  [ out/writeUI16 id + offsetShapeId ]
					][
						make error! reform ["!!! UNKNOWN TYPE:" type]
					]
					out/writeUI16 depth - 1
					flags: select [image 0 object 1 shape 2] type
					write-transform transform color flags
				)
				|
				'Remove set depth integer! temp: (
					;I'm testing there if next command is 'Place' and into same depth, if so, I do cmdReplace instead so I avoid 'splice' call in runtime
					either all [
						temp/1 = 'Place
						depth = temp/4
						not any [                              ;I don't use replace command when there is name
							all [block? temp/6 string? temp/7] ;temp/7 is place object's name (if color is not used)
							string? temp/6                     ;temp/6 is place object's name (if color is used) 
						]
					][ 
						parse/all temp [
							'Place 
							set type word!
							set id integer!
							set depth integer!
							set transform block!
							set color [block! | none]
							set name [string! | none]
							temp:
							to end
						]
						out/writeUI8  cmdReplace
						place-command
					][
						out/writeUI8  cmdRemove
						out/writeUI16 depth - 1
					]
				) :temp
				|
				'Label set name string! (
					unless parse name [
						"_fps" copy value some chDigit end (
							out/writeUI8 cmdFPS
							out/writeUI8 to-integer value
						) |
						"_fps" copy value some chDigit "-" copy value2 some chDigit end (
							out/writeUI8 cmdFPSRange
							out/writeUI8 to-integer value
							out/writeUI8 to-integer value2
						)
						|
						"_stop" end (
							out/writeUI8 cmdStop
						)
						|
						"_hide" end (
							out/writeUI8 cmdHide
						)
						|
						"_show" end (
							out/writeUI8 cmdShow
						)
						|
						"_release" end (
							out/writeUI8 cmdRelease
						)
						|
						"_slowFps" copy value some chDigit end (
							;will set FPS to: 1 + Math.random()*value
							out/writeUI8 cmdSlowFPS
							out/writeUI8 to-integer value
						)
						|
						"_touchable" end (
							out/writeUI8 cmdTouchable
						)
						|
						"_snd" opt ["_"] copy name to #"_" 1 skip copy value some chDigit end (
							out/writeUI8 cmdSoundVBR
							write-string rejoin [currentLevel #"/" name]
							out/writeUI8 to-integer value
							either parse name [copy group to #"/" to end][
								out/writeUI8 1
								write-string group
							][
								out/writeUI8 0
							]
						)
						|
						"_snd" opt ["_"] [copy name to "_L" end | copy name to end] (
							out/writeUI8 cmdSoundLNG
							write-string rejoin [currentLevel #"/" name]
							either parse name [copy group to #"/" to end][
								out/writeUI8 1
								write-string group
							][
								out/writeUI8 0
							]
						)
					][
						out/writeUI8 cmdlabel
						write-string name
					]
				)
				|
				'Sound set id integer! set soundData block! (
					name: to string! usedTimelineSounds/:id
					if error? try [
						id: -1 + index? find level-sounds name
					][
						print ["!!! Unknown timeline sound!" id name]
						halt
					]
					out/writeUI8  cmdSound
					out/writeUI16 id + offsetSoundId
					out/writeUI16 soundData/1 ;repeat
					either parse name [thru #"/" copy id to #"/" to end][
						either tmp: find sound-groups id [
							out/writeUI8 index? tmp
						][
							append sound-groups id
							out/writeUI8 length? sound-groups
						]
					][
						out/writeUI8 0 ;no soundGroup
					]
					;not using all values from envelope, just first one
					out/writeUI16 soundData/2/2 ;leftVolume
					out/writeUI16 soundData/2/3 ;rightVolume
					
				)
				| pos: 1 skip (
					ask reform ["UNKNOWN COMMAND near:" mold copy/part pos 20 "..."] 
				)
			]
		]
	]

	#include %test-assets.r
]