REBOL [
	title: "Rebol/Flash Dialect (RSWF) main rules"
	author: "Oldes"
	email: oliva.david@seznam.cz
]

any [

;### Display list

	;## ShowFrame (display list)
	;** Inserts ShowFrame tag which instructs Flash Player to display the contents of the display list.
	'showFrame
	(
		showFrame
	)
	|
	;## Show number! frames (display list)
	;** Inserts one or more ShowFrame tags which instructs Flash Player to display the contents of the display list.
	'show set arg1 opt [integer! | none] ['frames | 'frame]
	(
		loop any [arg1 1] [showFrame]
	)
	|
	;## End (display list)
	;** End of SWF file or sprite
	'end
	(
		unless including [ins #{0000}]
	)
	|
	;## Place (display list)
	;** Adds character to the display list, or modifies the attributes of a character that is already on the display list.
	['Place | 'PlaceObject2]
		set arg1 [integer! | word! | block!] ;* ID or block with IDs of a character/s
		[
			  'at set arg2 pair!           ;* Position
			| set arg2 opt [block! | none] ;* or block with position and transform spec.
			;- position spec can contain:
			;-   at pair!   - new position
			;-   multiply [integer! | tuple! | block!] - Multiplication Transforms
			;-   add      [integer! | tuple! | block!] - Addition Transforms
			;-   rotate   [number! | pair | block!]    - Rotation
			;-   scale    [number! | pair | block!]    - Scale
			;-   skew     [number! | pair | block!]    - Skew
			;-   reflect  [number! | pair | block!]    - Reflect
			;-   blend [
			;-		  Normal
			;-		| Layer
			;-		| Darken
			;-		| Multiply
			;-		| Lighten
			;-		| Screen
			;-		| Overlay 
			;-		| HardLight
			;-		| Add 
			;-		| Subtract
			;-		| Diference"
			;-		| Invert
			;-		| Alpha
			;-		| Erase
			;-   ]
			;-  actions block!    - block with clip event actions
		]
	(
		ins-place arg1 arg2
	)
	|
	;## MoveDepth (display list)
	;** Moves character on specified depth to new position
	'MoveDepth
		set arg1 opt [integer!]             ;* Depth
		[
			  'at set arg2 pair!            ;* New position
			| set arg2 opt [block! | none]  ;* Or block with position spec.
			;- position spac can contain:
			;-   at pair!   - new position
			;-   multiply [integer! | tuple! | block!] - Multiplication Transforms
			;-   add      [integer! | tuple! | block!] - Addition Transforms
			;-   rotate   [number! | pair | block!]    - Rotation
			;-   scale    [number! | pair | block!]    - Scale
			;-   skew     [number! | pair | block!]    - Skew
			;-   reflect  [number! | pair | block!]    - Reflect
		] 
	(
		use [bin flags m a][
			bin: make binary! 40
			flags: make string! "00000001"
			case [
				pair? arg2 [arg2: reduce ['at arg2]]
				none? arg2 [arg2: reduce ['at 0x0 ]]
			]
			m: select arg2 'multiply
			a: select arg2 'add
			if any [not none? a	not none? m	][
				insert bin bits-to-bin create-cxform/withalpha m a
				flags/5: #"1"
			]
			if pos: select arg2 'at [
				pos: either block? pos [
					to pair! reduce [to integer! 20 * pos/1 to integer! 20 * pos/2]
				][	pos * 20]
				insert bin bits-to-bin create-matrix pos arg2
				flags/6: #"1"
			]
			insert bin int-to-ui16 either integer? arg1 [arg1][last-depth]
			insert bin load rejoin ["2#{" flags "}"]
 			ins form-tag 26 bin
		]
	)
	|
	;## Remove (display list)
	;** Removes the specified character (at the specified depth) from the display list.
	['remove | 'RemoveObject | 'odstranit | 'odstraò | 'destituir | 'liquidar]
	 some [
		set arg1 [integer! | word!] ;* ID of character to remove
		set arg2 integer!           ;* Depth of character
		(
			ins form-tag 5 rejoin [
				int-to-ui16 get-id arg1
				int-to-ui16 arg2
			]
		)
	]
	|
	;## RemoveDepth (display list)
	;** Removes the character at the specified depth from the display list.	
	['RemoveDepth | 'RemoveDepths]
		[set arg1 block! | copy arg1 some [integer!]] ;* Depths to remove (block or integer list)
	(	foreach tmp arg1 [ins form-tag 28 int-to-ui16 tmp] )
	|
	;## Layout (display list)
	;** Places one or more GUI objects on stage
	'Layout
		set arg1 block!  ;* Block with layout dialect
	(	compile-layout arg1  )
	|

;
;
;
;### Sprite

	;## Sprite (sprite)
	;** Defines a sprite character	
	['sprite | 'sprajt | 'DefineSprite | 'MovieClip]
		set arg1 opt [integer! | none]            ;* Optional sprite ID
		set arg2 [
			  binary!                             ;* Precompiled binary data
			| block!                              ;* Block with sprite content
			| word!                               ;* Existing shape which will be placed to the first sprite frame
			| file!                               ;* Imports another SWF file as a sprite
			| url!                                ;* Imports another SWF file as a sprite
		]
		opt ['init] set arg3 opt [block! | none]  ;* Optional Init actions for new sprite
	(
		if any [file? arg2 url? arg2][arg2: reduce ['import-swf arg2]]
		compile-sprite arg1 arg2 arg3
	)
	|
	;## EmptySprite (sprite)
	;** Creates empty sprite
	['EmptySprite | 'prázdný 'sprajt]
		set arg1 [integer! | none] ;* Optional ID of the new sprite
	(
		ins-def form-tag 39 rejoin [set-id arg1 #{010040000000}]
	)
	|
	;## Image stream (bitmaps)
	;** Creates a Sprite with sequence of images on each frame
	'ImageStream
		set arg1  [integer! | none]   ;* Optional ID of the new sprite
		set arg2 opt [file! | block!] ;* Image file, directory with images or block with image files or urls
		set arg3 opt [pair! | none]   ;* Specify size for all images so the size will not be auto detected (slower)
		                              ;- note that there is no resizing done on images is the size is different
		set arg4 opt [block! | none]  ;* now with 'onFirstFrame, 'onEachFrame and 'onLastFrame action's blocks,
								      ;* 'name and 'noPlace ('exportOnly) directive
		                              ;- for example: [onLastFrame [stop()]]
	(
		compile-imageStream arg1 arg2 arg3 arg4
	)
	|
;
;
;
;### Shapes

	;## Shape (shapes)
	;** Defines a shape character
	['Shape | 'tvar | 'DefineShape]
		set arg1 opt [integer! | none] ;* Shape id
		set arg2 block! ;* Block with ShapeDialect
	(	create-shape arg1 arg2 )
	|
		
	;## Image (shapes)
	;** Defines a shape character from an existing bitmap
	['image | 'bitmap-to-image]
		set arg1 [word! | file! | url!] ;* ID of the existing bitmap character or image file
;		set arg2 ['as 'sprite | none]   ;* Automatically creates a sprite as well
	(
		
		use [size id][
			if any [file? arg1 url? arg1][
				insert set-word-buff id: to-word join 'bmp_ either empty? set-word-buff [
					get-new-id
				][	first set-word-buff	]
				load-img arg1 none
				arg1: id
			]
			size: select placed-images get-id arg1	

			parse/all compose/deep [
				Shape [
					Bounds 0x0 (size)
					smoothing   on
					image      (arg1)
				]
			] tag-rules
		]
	)
	|
	;## Multi-image (shapes)
	;** Defines multiple shapes from an existing bitmap
	'multi-image
		set arg1 [integer! | word!] ;* ID of the existing bitmap character
		set arg2 block!             ;* Specifications of new shapes
		;- The spec can be:
		;-   clipped [on | off | true | false]  - Sets if the image fill should be clipped
		;-   [no smoothing | smoothing off]     - turns off bitmap smoothing
		;-   smoothing opt [on]                 - turns on bitmap smoothing
		;-   set-word! pair! pair! opt [pair!]  - id of the new image,
		;-                                        ofset to image position in bitmap
		;-                                        size of the new image
		;-                                        optional final size
	(
		use [bmp w ofs sz sz2 clip sm][
			bmp: arg1
			sm: 'off
			clip: "clipped"
			parse/all arg2 [any[
				  'clipped ['off | 'false] (clip: "")
				| 'clipped ['on  | 'true ] (clip: "clipped")
				| ['no 'smoothing | 'smoothing 'off] (sm: 'off)
				| ['smoothing opt 'on] (sm: 'on)
				|
				set w set-word! ;id of the new image
				set ofs pair!	;ofset to image position
				set sz pair!	;size of the new image
				set sz2 opt [pair!] ;optimal final size 
				(
;print ["smoothing: " sm]
					compile load rejoin [{
						} w {: shape [
							bounds 0x0 } sz {
							with transparency
							smoothing } sm {
							fill-style [bitmap } bmp { at } 0x0 - ofs { } clip {]
							box 0x0 } either none? sz2 [sz][sz2] {
						]
					}]
				)
				| arg1: any-type! (make-warning! arg1)
			]]
		]
	)
	|
;	'DefineShape set arg1 integer! set arg2 binary! (
;		ins-def form-tag 2 join set-id arg1 arg2
;	)
;	|
;	'DefineShape2 set arg1 integer! set arg2 binary! (
;		ins-def form-tag 22 join set-id arg1 arg2
;	)
	
;
;
;
;### Bitmaps
	
	;## Bitmap (bitmaps)
	;** Defines a bitmap character from image file
	['bitmap | 'bitmapa | 'DefineBits]
		set arg1 opt [integer! | none]          ;* The result bitmap ID
		set arg2 [file! | url!]                 ;* Image file to use
		(arg3: none) opt ['size set arg3 pair!] ;* Optional image size if needed
	(
		either none? arg3 [
			load-img arg2 arg1
		][	load-img/size arg2 arg1 arg3]
	)
	|
	;## Alpha bitmap (bitmaps)
	;** Defines bitmap with support for transparency (alpha values)	
	['alpha 'bitmap | 'DefineBitsLossless2]
		set arg1 opt [integer! | none] ;* Bitmap id
		set arg2     [file!    | url!] ;* Image file to use
	(
		load-img/alpha arg2 arg1
	)
	|
	;## JPEG (DefineBitsJPEG2 or DefineBitsJPEG3)
	;** Defines a bitmap character with JPEG compression adding alpha channel (opacity) data.
	'JPEG
		set arg1 opt [integer! | none] ;* Bitmap id
		set arg2     [file!    | url!] ;* Image file to use
	(
		ins-bitmap-jpeg  arg1 arg2
	)
	|
	;## Bitmaps (bitmaps)
	;** Defines multiple bitmaps
	['bitmaps | 'bitmapy]
		set tmp opt ['images | 'obrázky | none] ;* Creates equivalent shapes as well
		set arg1 block!                         ;* Bitmaps minidialect code:
		;- from [file! | url!] - specifies base dir for files
		;- key  tuple!         - color which should be used as transparent
		;- no key              - turns key color off
		;- make sprites        - creates not only shapes but sprites as well
		;- precise             - creates bitmaps with one pixel transparent edge
		;- [smoothing | smoothing on]     - turns bitmap smoothing on
		;- [no smoothing | smoothing off] - turns bitmap smoothing off
		;- opt [word! | set-word! | none] [file! | url!] - optional bitmap id and source file 
	(
		ins-bitmaps arg1 not none? tmp
	)
	|
	;## Bitmap layout (bitmaps)
	;** Creates bitmap using Rebol's LAYOUT function
	['bitmap 'layout | 'bitmapové 'rozložení]
		set arg1 opt [integer! | none] ;* The result bitmap ID
		set arg2 block!                ;* Block with Rebol's layout code
		set arg3 opt [block!   | none] ;* Create-img args [key tuple!]
	(
		ins-bitmap-layout arg1 arg2 arg3
	)
	|
;	'DefineBitsLossless2 set arg1 integer! set arg2 binary! (
;		ins-def form-tag 36 join set-id arg1 arg2
;	)
;	| 'DefineSprite set arg1 opt [integer! | none] set arg2 binary! (
;		ins-def form-tag 39 join set-id arg1 arg2
;	)
;
;
;
;### Fonts and text

	;## Font (fonts and text)
	;** Defines the shape outlines of each glyph used in a particular font.
	['Font | 'DefineFont2]
		(arg2: arg3: none)
		set arg1 [
			  block!      ;* Block with font specification (system font = no outlines)
			  ;- possible args in font spec are:
			  ;-  name string!  - Name of the font, default "_sans"
			  ;-  italic        - Font is italic
			  ;-  bold          - Font is bold
			  ;-  small         - Font is small. Character glyphs are aligned on pixel boundaries for dynamic and input text.
			  ;-  encoding [ShiftJIS | Unicode | ANSI] ;Used encoding (not needed for SWF6 and later), default ANSI
			| string!     ;* Name of the system font (no outlines)
			| [
				  binary! ;* Binary data with font specification
				| file!   ;* Binaty data with font specification in external file
				| url!    ;* --//--
			]
				opt 'as set arg2 opt [string! | none] ;* Optional way how to change font name before import
				copy arg3 any [;* OPTIONS:
					  'bold    ;* Sets the BOLD flag
					| 'italic  ;* Sets the ITALIC flag
					| 'normal  ;* Resets both BOLD and ITALIC flags to zero
					| 'pixel   ;* Sets SmallText flag - glyphs are aligned on pixel boundaries for dynamic and input text.
					| 'noAlign ;* Included font file doesn't have alignZones part
					           ;- if omitted, the compiler tries to find the .align file for this font
				]
		]
	(
		ins-DefineFont2 arg1 arg2 arg3
	)
	|
	;## Font3 (fonts and text)
	;** Defines the shape outlines of each glyph used in a particular font using align zones data.
	['Font3 | 'DefineFont3]
		set arg1 [binary! | file! | url!]                  ;* Precompiled binary data of the font3 tag
		(arg2: none)
		opt ['alignZone set arg2 [binary! | file! | url!]] ;* Precompiled binary data of align zones 
	(
		unless binary? arg1 [arg1: read/binary get-filepath arg1]
		ins-def form-tag 75 join (set-id none) arg1
		if arg2 [
			unless binary? arg2 [arg2: read/binary get-filepath arg2]
			ins-def form-tag 73 join (int-to-ui16 last-id) arg2
		]
	)
	|
	;## AntiAliasing (fonts and text)
	;** Defines continuous stroke modulation (CSM) settings for existing font
	['AntiAliasing | 'CSMTextSettings]
		set arg1 [integer! | word!]            ;* Font ID to use settings with
		set arg2 opt [block! | binary! | none] ;*CSM settings in binary format
	(
		ins-def form-tag 74 join (int-to-ui16 get-id arg1) either binary? arg2 [arg2][#{48000048430000A74300}] ;#{48000080410000004100}
	)
	|
	;## EditText (fonts and text)
	;** defines a dynamic text object, or text field.
	['EditText | 'Text]
		set arg1 opt [string! | word! | lit-word! | none] ;* Name of the variable where the contents of the text field are stored.
		set arg2 pair!  ;* Size of the text field
		set arg3 block! ;* EditText specification.
		;- the spec can contain:
		;-   maxLength integer!                           - maximum length of string
		;-   color [tuple! | issue!]                      - color of the text
		;-   font [[integer! | word! | string!] integer!] - existing font ID and font height
		;-   wordWrap       - text will wrap automatically when the end of line is reached
		;-   multiline      - text field is multi-line and will scroll automatically
		;-   password       - all characters are displayed as an asterisk
		;-   readOnly       - text editing is disabled
		;-   noSelect       - disables interactive text selection
		;-   border         - causes a border to be drawn around the text field
		;-   HTML           - HTML content
		;-   useOutlines    - use glyph font
	(
		ins-EditText arg1 arg2 arg3
	)
	|
	
;
;
;
;### Buttons	
	
	;## Button (buttons)
	;** Defines button character
	['Button | 'DefineButton2]
		set arg1 block! ;* Button definition block
	(
		use [bin tmp buff v key menu? old-act-bin i actions? ofs id st][
			bin: make binary! 20
			insert bin set-id select arg1 'id
			menu?: either any [none? tmp: select arg1 'as tmp <> 'push][#{01}][#{00}]
			insert tail bin menu?
			menu?: menu? = #{01}
			;button shapes:
			tmp: select arg1 'shapes
			buff: make string! 100
			foreach [states facets] tmp [
				st: make string! "00000000"
				if word? states [states: join copy [] states]
				foreach state states [
					if found? v: find [hit down over up] state [
						poke st 4 + index? v #"1"
					]
				]
				ofs: either none? ofs: select facets 'at [0x0][ofs * 20]
				if none? id: select facets 'id [id: first facets]
				append buff st
				append buff enbase/base rejoin [
					int-to-ui16 get-id id	;character
					int-to-ui16 either none? v: select facets 'layer [1][v]		;layer
				] 2
				append buff create-matrix ofs facets
				buff: byte-align buff
				append buff create-cxform/withalpha
					select facets 'multiply
					select facets 'add
				buff: byte-align buff
			]
			buff: bits-to-bin buff
			append buff #{00}
			
			;button actions:
			tmp: select arg1 'actions
			actions?: (block? tmp) and (not empty? tmp)
			insert tail bin either actions? [int-to-ui16 (length? buff) + 2][#{0000}]
			insert tail bin buff
			if actions? [
				old-act-bin: copy action-bin
				i: 0
				foreach [states actions] tmp [
					i: i + 2
					unless block? states [states: join copy [] states]
					st: make string! "000000000"
					key: make string! "0000000"
					buff: make binary! 10
					parse states [
						some [
							'DragOut (either menu? [st/1: #"1"][st/5: #"1"])
							| 'DragOver (either menu? [st/2: #"1"][st/4: #"1"])
							| 'ReleaseOutside (unless menu? [st/3: #"1"])
							| 'Release (st/6: #"1")
							| 'Press (st/7: #"1")
							| 'RollOut (st/8: #"1")
							| 'RollOver  (st/9: #"1")
							| 'key set v [char! | string!] (
								if string? v [v: v/1]
								key: next enbase/base to binary! v 2
							)
						] to end
					]
					unless empty? st [
						insert buff join compile-actions actions #{00}
						insert buff reverse load rejoin ["2#{" key st "}"]
						insert buff either i = length? tmp [#{0000}][
							int-to-ui16 (length? buff) + 2
						]
						;insert buff int-to-ui16 (length? buff) + 2
						insert tail bin buff
					]
				]
				action-bin: copy old-act-bin
		
			]
			ins-def form-tag 34 bin
		]
	)
	|

;
;
;
;### Actions

	;## Actions (actions)
	;** Instructs Flash Player to perform a list of actions when the current frame is complete.
	['Actions | 'DoAction | 'DoActions]
		set arg1 [block! | binary! | file! | url!] ;* Block with actions or precompiled binary
	(
		if any [file? arg1 url? arg1][arg1: read/binary arg1]
		either binary? arg1 [
			insert tail action-bin arg1
		][	insert tail action-bin compile-actions arg1]
	)
	|
	;## InitAction (actions)
	;** Same like Actions but these actions are executed earlier, and are executed only once
	['InitAction | 'InitActions | 'DoInitAction]
		set arg1 [word! | integer!] ;* ID of sprite to which these actions apply
		set arg2 [block! | binary!] ;* block of actions to parse or precompiled actions
	(
;probe arg2
		doInitAction arg1 arg2
	)
	|
	;## Class (actions)
	;** Defines a custom class, which lets you instantiate objects that share methods and properties that you define.
	'Class (arg2: arg3: arg4: none)
		opt ['extends set arg2 word!] ;* Name of existing super class
		set arg1 block!	              ;* Block with methods and properties of the new class
		                              ;- use 'init' function as a constructor
		opt ['with set arg3 block!]   ;* Additional actions to provide after init (not part of class)
	(
		create-class arg1 arg2 arg3
	)
	|
	;## Extends (actions)
	;** Just a shortcut for Class definition
	'Extends (arg3: none)
		set arg2 word!              ;* Name of existing super class
		set arg1 block!	            ;* Block with methods and properties of the new class
		opt ['with set arg3 block!] ;* Additional actions to provide after init (not part of class)
	(
		create-class arg1 arg2 arg3
	)
	|
	;## DoAction3 (actions)
	;** Compiles ActionScript3 file using Flex compiler (!! just for a testing !!)
	['Actions3 | 'DoAction3 | 'DoActions3]
		set arg1 [file! | url!] ;* ActionScript3 source file
	(
		use [fileParts name ext][
			fileParts: split-path arg1
			set [name ext] parse last fileParts "."
			if ext = "as" [
				call/wait rejoin [
					"java -jar " to-local-file rswf-root-dir/bin/asc.jar " -optimize " to-local-file arg1
				]
			]
			if exists? arg1: to-file rejoin [name ".abc"][
				probe arg1: read/binary arg1
				;ins form-tag 43 as-binary join name #{00}
				;ins form-tag 72 arg1
				ins form-tag 82 rejoin [
					int-to-ui32 10 "frame1" #{00}
					arg1
				]
				ins form-tag 76 rejoin [int-to-ui32 10 name #{00}]
			]
		]
	)
	|
	;## Stop (actions)
	;** Just a shortcut for DoAction [stop] (inserts Stop action)
	'stop
		set arg1 opt ['end] ;*And optionaly ends the movie
	(
		insert tail action-bin #{07}
		if arg1 = 'end [
			showFrame ins #{0000}
		]
	)
	|

;
;
;
;### Sound
	
	;## Sound (sound)
	;** Defines sound
	['sound | 'defineSound]
		set arg1 [file! | url!]  ;* Sound file to use
	(	create-defineSound arg1 )
	|
	;## Sounds (sound)
	;** Defines multiple sounds
	'sounds
		set arg1 block! ;* Block with sound files to use
	(
		foreach file arg1 [
			insert set-word-buff to-word rejoin ['snd_ last parse file "/"]
			;probe file
			create-defineSound file
		]
	)
	|
	;## StartSound (sound)
	;** Starts (or stops) playing a sound defined by DefineSound.
	['StartSound | 'play]
		set arg1 [word! | integer! | string!] ;* Sound ID to play
		set arg2 opt [block!]                 ;* Sound options
		  ;- Sound options can be:
		  ;-   noMultiple    - Don’t start the sound if already playing
		  ;-   loop          - How many times it loops
	(
		use [info loop][
			unless block? arg2 [arg2: make block! []]
			info: #{00}
			if find arg2 'noMultiple [info: info or #{10}]
			loop: either select arg2 'loop [info: info or #{04} int-to-ui16 select arg2 'loop][#{}]
			ins form-tag 15 rejoin [
				int-to-ui16 get-id arg1
				info
				loop
			]
		]
	)
	|
	;## StopSound (sound)
	;** Stops playing the specified sound
	'StopSound
		set arg1 [word! | integer!] ;* Sound ID to stop playing
	(
		ins form-tag 15 join int-to-ui16 get-id arg1 #{20}
	)
	|
	;## MP3Stream (sound)
	;** Starts inserting MP3 file as a stream, (on each ShowFrame is inserted part of the MP3 file)
	'mp3Stream
		set arg1 [file! | url!] ;* Path to MP3 file
	(
;print ["mp3stream" arg1]
		use [file][
			either any [
				not none? file: get-filepath arg1
			][
				stream: make object! [
					type: 'mp3
					port: open/direct/binary file
					MakeHead?: true
					samplesPerFrame: 0
					delay: 0
					length: 0
					idealFrames: 0
					mp3frames: 0
					frame: 0
				]
			][
				print ["Mp3Stream file or url (" arg1 ") doesn't exists!"]
			]
		]
	)
	|
	;## Finish stream (sound)
	;** Inserts frames until the end of the MP3 file started with MP3Stream
	'finish 'stream (
		while [not none? stream][showFrame]
		remove/part skip tail body -2 2
	)
	|
	
;
;
;
;### Video	
	
	;## Video (video)
	;** Creates VIDEO object	
	'video
		set arg1 [integer! | none] ;* Optional ID of the video object
	(
		ins-def form-tag 60 rejoin [set-id arg1 #{0000A00078000000}]
	)
	|
	
;	['DefineVideo | 'DefineMovie] set arg1 opt [integer! | none] set arg2 [string! | url! | file!] (
;		ins-def form-tag 38 rejoin [set-id arg1 arg2 #{00}]
;	)
;	|
;
;
;
;### Control
	
	;## Background (control)
	;** Sets the background color of the display.
	['background | 'pozadí | 'fondo | 'SetBackgroundColor]
		set arg1 [tuple! | issue!] ;* Color of the movie background
	(
		unless including [
			ins form-tag 9 reduce either tuple? arg1 [to binary! arg1][issue-to-binary arg1]
		]
		
	)
	|
	;## Rebol (control)
	;** Evaluates Rebol code
	'Rebol
		set arg1 [block! | file! | url!] ;* Rebol code to evaluate
	(
		if error? tmp: try [do arg1][probe disarm tmp]
	)
	|
	;## Include (control)
	;** Includes and evaluates other RSWF script	
	['Include | 'zahrnout | 'obsahuje | 'incluir]
		set arg1 [file! | url! | block!] ;* RSWF file to include
	(	include-files arg1 )
	|
	;## Require (control)
	;** Includes and evaluates other RSWF script but only once
	['require | 'needs | 'vyžaduje | 'požaduje | 'requise]
		set arg1 [file! | url! | block!] ;* RSWF file to include
	(	include-files/unique arg1 )
	|
	;## Export (control)
	;** Makes portions of a SWF file available for import by other SWF files
	['Export | 'ExportAssets]
		set arg1 block! ;* Block with one or more id and name pairs to export
	(
		ExportAssets arg1
	)
	|
	;## Import (control)
	;** Imports exported characters from another SWF file (while runtime).
	['Import | 'ImportAssets]
		set arg1 block! ;* Block with one or more id and name pairs to import
		opt ['from] set arg2 [url! | path! | word! | string! | file!] ;* path to the exporting SWF
	(
		ins-import-assets arg1 arg2
	)
	|
	;## Import-swf (control)
	;** Inserts almost all SWFtags from other SWF file (recounting used IDs)
	;** NOTE: this is not complete yet so there may be a problem with some files
	'import-swf
		(arg2: none)
		set arg1 [file! | url!]    ;* SWF file to insert
		opt ['no set arg2 ['end | 'show]] ;* Used if to set that END tag should not be included
	(
		ins-swf-file arg1 arg2
	)
	|
	;## Label (control)
	;** Gives the specified Name to the current frame. This name is used by ActionGoToLabel to identify the frame.
	['label | 'FrameLabel]
		set arg1 [string! | word! | lit-word!] ;* Name of the label
	(
		ins form-tag 43 rejoin [#{} arg1 #{00}]
	)
	|

;
;
;
;### Special

	;## Set-word! (special)
	;** Stores set-word for use with named IDs
	set arg1 set-word!
	(
		insert set-word-buff arg1: to word! arg1
		if find names-ids-table arg1 [
			make-warning!/msg none reform ["Reusing word: " arg1]
		]
;print ["TSW" mold set-word-buff]
	)
	|
	;## Get-word! (special)
	;** Used with set-word! to give another name to existing character ID
	set arg1 get-word! (
		either all [
			not none? set-word
			not none? tmp: select names-ids-table to-word arg1
		] [	do-set-word tmp ][
			make-warning! arg1
		]
	)
	|
	;## Comment (special)
	;** Ignores the argument value (used to insert large comments or comment out block of code)
	'comment
		set arg any-type! ;* Argument values which is not evaluated
	|
	;## SWFTag (special)
	;** Inserts any precompiled SWF tag
	['SWFtag | 'prepared]
		set arg1 integer!  ;* SWF tag ID
		set arg2 binary!   ;* Precompiled binary data
	(
		ins-def form-tag arg1 arg2
	)
;	|
;	'ScalingGrid set arg1 [integer! | word!] set arg2 pair! set arg3 pair! (
;	
;	)
	|
	;## MetaData (special)
	;** Inserts MetaData in XML format into file
	'MetaData
		set arg1 [string! | block!] ;* metadata
	(
		ins-def form-metadata arg1
	)
	|
	;## FileAttributes (special)
	;** NOTE: to be done, now just used with binary
	'FileAttributes
		set arg1 [binary! | integer!] ;* 8Bytes or integer with FileAttributes
	(
		;ins-def
		FileAttributes: form-tag 69 probe either binary? arg1 [copy/part arg1 4][int-to-ui32 arg1]
	)
	|
	;## UseNetwork (special)
	;** Sets file attributes to enable networking on local or not
	['UseNetwork | 'network 'privileges | 'local-with-networking | 'allow 'networking]
		set arg1 ['off | 'false | 'on | 'off | none]
	(
		;ins-def
		FileAttributes: form-tag 69 either find [off false] arg1 [#{00000000}][#{01000000}]
	)
	|
	;## ScriptLimits (special)
	;** Overrides the default settings for maximum recursion depth and Actions time-out
	'ScriptLimits
		set arg1 integer!	;* maximum recursion (default probably 256)
		set arg2 integer!	;* Actions time-out in seconds (default is between 15 to 20 seconds)
	(
		;ins-def
		ScriptLimits: form-tag 65 join int-to-ui16 (max 1 min 65535 arg1) int-to-ui16 (max 1 min 65535 arg2)
	)
	|
	;## SerialNumber (special)
	;** Sets info about compiler (do not use it if you don't know what it does)
	'SerialNumber
	set arg1 opt [binary! | none] ;* 26Bytes of binary data as a serialNumber
	(
		ins-def form-tag 41 either arg1 [copy/part arg1 26][#{01000000000000000200965F0200000000006B68088212010000}]
	)
	|
	
	;## Units (special)
	;** Sets if used position units are in twips or pixels
	'Units ['twips (twips?: true) | 'pixels (twips?: false)]
	|
	

;
;
;
;### Undocumented or obsolete

;	copy arg3 any ['vertical | 'horizontal | 'v | 'h] 'extended 'image set arg1 file! copy arg2 any [integer!] (
;		extended-image arg1 arg2 arg3
;	)
;	| ['ex-vertical-image | 'extendedVerticalImage] set arg1 [block!] (
;		makeVerticalExtendedImage arg1
;	)
;	| ['ex-horizontal-image | 'extendedHorizontalImage] set arg1 [block!] (
;		makeHorizontalExtendedImage arg1
;	)
;	| 'make 'window set arg1 block! (
;		make-window arg1
;	)
;	|
	'animation set arg1 block! (
		;print ["animation" mold arg1]
		use [i fr-pos to-pos frms step-x step-y pos positions][
			parse/all arg1 [any [
				'move set arg1 [word! | lit-word! | integer!]
					opt 'from set fr-pos pair!
					opt 'to set to-pos pair!
					opt 'in set frms integer! opt 'frames
					(
						step-x: (to-pos/x - fr-pos/x) / frms
						step-y: (to-pos/y - fr-pos/y) / frms
						;print ["move" arg1 fr-pos to-pos frms step-x step-y]
						positions: make block! frms
						pos: make block! reduce [fr-pos/x fr-pos/y]
						insert positions 20 * fr-pos
						repeat i frms [
							pos/1: pos/1 + step-x
							pos/2: pos/2 + step-y
							;pos/2: (pos/2 + (i * step-y)) * (sine (90 / frms ) * i))
							;print ["pos" mold pos]
							insert tail positions to pair! reduce [
								to integer! 20 * pos/1
								to integer! 20 * pos/2
							]
						]
							
						insert/only animations reduce [arg1 positions]
					) 
			]]
			;probe animations
		]
	)

	| arg1: any-type! (make-warning! arg1)
]
to end
