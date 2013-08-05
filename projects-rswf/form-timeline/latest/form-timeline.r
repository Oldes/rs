REBOL [
    Title: "form-timeline"
    Date: 21-Mar-2013/15:05:26+1:00
    Name: none
    Version: 0.3.0
    File: none
    Home: none
    Author: "Oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: none
    Purpose: {SWF parser which creates simplified timeline structure as a middle step for creating
	data for my special timeline format used to render nested animations under Starling framework}
    Comment: {This is still work in progress and early prototype. It can be changed any time.}
    History: {
		0.1.0 11-Nov-2012 {First public release}
	}
    Language: none
    Type: none
    Content: none
    Email: oldes.huhuman@gmail.com
	require: [
		rs-project %swf-parser
	]
]

system/options/binary-base: 16

ctx-form-timeline: context [
	shapes:  copy []
	bitmaps: copy []
	sounds:  copy []
	sprites: copy []
	names:   copy [] ;used to store names of objects per ID
	names-images: copy []
	names-sounds: copy []
	types:   copy [] ;used to store types of objects per ID
	offsets: copy [] ;used to offset sprite images where registration point is not 0x0
	replaced-sprites: copy []
	sprite-images: copy []
	usage-counter: copy []
	
	ids-replaced:  copy []
	num-shapes:  0
	num-images:  0
	num-objects: 0
	
	analyse-shape: func[
		data [block!] "Parsed SWF Shape data"
		/local
			id bounds edge shape ;main shape definition
			FillStyles LineStyles ShapeRecords ;shape definition variables
			fill  ;used for first fill style
			name  ;used as an bitmap alias
			style ;holds temporaly style block
	][
		;print ["analyse-shape" mold data]
		set [id bounds edge shape] data
		set [FillStyles LineStyles ShapeRecords] shape

		forall FillStyles [
			style: FillStyles/1
			if style/2/1 = 65535 [;invalid fill ID
				;print ["removing invalid fill id"]
				remove FillStyles
			]
		]
		FillStyles: head FillStyles
		
		forall LineStyles [
			style: LineStyles/1
			if style/2/1 = 65535 [;invalid style ID
				remove LineStyles
			]
		]
		LineStyles: head LineStyles
		
		fill: FillStyles/1 ;checking only for the first fill style, maybe I should clear undefined fills first!
		
		either all [
			fill
			fill/1 >= 64 ;there is a bitmap fill
			name: select names fill/2/1 ;it's known named bitmap 
		][
			repend names [id name]
			repend types [id 'image]
			;print ["SHAPE AS IMAGE?" mold ShapeRecords/2]
			either all [
				ShapeRecords/2/1
				ShapeRecords/2/1/1 = fill/2/2/3/1
				ShapeRecords/2/1/2 = fill/2/2/3/2
			][
				;print "???" probe ShapeRecords probe bounds
				repend/only repend offsets id reduce [bounds/1 bounds/3] 
			][
				;print "offseting"
				repend/only repend offsets id fill/2/2/3
			]
			
			print ["^-Image instead of shape:" id mold name]
			;ask ""
		][
			;classic shape
			result: copy "" 
			parse/all ShapeRecords [any [
				'style set style block! (
					;probe lineStyles
					either tmp: style/5 [
						;probe tmp
						LineStyles: tmp/2
					][
						if all [
							style/4
							tmp: pick LineStyles style/4
						][
							result: insert result reform ["^-lineStyle" tmp/1 tmp/4 "^/"]
						]
						if tmp: style/1 [
							result: insert result reform ["^-moveTo" tmp/1 tmp/2 "^/"]
						]
					]
				)
				|
				'curve copy tmp some integer! (
					result: insert result reform ["^-curve" mold tmp "^/"]
				)
				|
				'line copy tmp some integer! (
					result: insert result reform ["^-line" mold tmp "^/"]
				)
			]]
			result: head result
			repend types [id 'shape]
			repend shapes [id result]
			
			repend ids-replaced [id to-string num-shapes]
			num-shapes: num-shapes + 1
		]
	]
	
	analyse-sprite: func[
		data [block!] "Parsed SWF Sprite data"
		/local
			id frames tags ;main sprite variables
			tag tagId tagData matrix  ;temp variables for storing control tag
			name        ;used as an bitmap alias
			result      ;used to store sprite pseudo-code
			offset
	][
		set [id frames tags] data
		;print ["frames" frames]
		
		either frames = 1 [
			;sprite or image
			tag:     tags/1
			tagId:   tag/1
			tagData: tag/2
			matrix:  either tagData [tagData/4][reduce [none none 0x0]]
			;Test if this sprite just puts simple shape with bitmap fill so I can use Image instead of this Sprite
			either all [
				false ;DON'T USING THIS OPTIMIZATION NOW!!
				3 = length? tags
				tagId = 26 ;placeObject
				name: select names tagData/3
				all [
					none? matrix/1 ;no scale
					none? matrix/2 ;no rotate
					matrix/3/1 = 0
					matrix/3/2 = 0 ;the image is placed on position 0x0
				]
			][
				;as image
				repend names [id name]
				repend types [id 'image]
				
				if offset: select offsets tagData/3 [
					repend/only repend offsets id offset
				]
				
				print ["^-Image instead of sprite:" id mold name mold tag]
			][
				;as sprite
				repend ids-replaced [id to-string num-objects]
				num-objects: num-objects + 1
				form-sprite-tags id frames tags
			]
		][
			;as movie
			repend ids-replaced [id to-string num-objects]
			num-objects: num-objects + 1
			form-sprite-tags id frames tags
		]
	]
	
	form-sprite-tags: func[
		id frames tags
		/local
			result
			tagId tagData offset
			tmp
			depth move cid ids attributes oldAttributes colorAtts frameStart
			maxDepth depths-replaced depths-to-remove ids-at-depth currentFrame
			name
	][
		frameStart: result: tail rejoin ["^-TotalFrames " frames "^/"]
		maxDepth: 0
		currentFrame: 1
		depth-offsets: copy []
		depth-to-id: copy []
		depth-attributes: copy []
		ids: copy []
		ids-at-depth: copy []
		depths: copy [] ;stores depth values as are placed in the list
		
		foreach tag tags [
			;probe tag
			tagId:   tag/1
			tagData: tag/2
			switch/default tagId [
				26 70 [;placeObject
					set [depth move cid attributes colorAtts ]  tagData
					name: tagData/7
					
					if tmp: find replaced-sprites cid [
						cid: sprite-images/(index? tmp)
					]
					either tmp: find depths depth [
						realDepth: index? tmp
					][
						realDepth: none
						forall depths [
							if depths/1 > depth [
								realDepth: index? depths
								insert depths depth
								break
							]
						]
						depths: head depths
						if none? realDepth [
							append depths depth
							realDepth: length? depths
						]
					]
					
					if none? attributes [
						attributes: any [
							select depth-attributes depth
							[#[none] #[none] #[none]]
						]
					]
					either cid [
						offset: select offsets cid
						either tmp: find/tail depth-offsets cid [
							change tmp offset
						][
							repend depth-offsets [depth offset]
						]
					][
						offset: select depth-offsets depth
					]

					
					;print "------------"
					;either oldAttributes: select depth-attributes depth [
					;	either all [move none? cid][
					;		probe reform [mold attributes mold oldAttributes]
					;		;comment {
					;		foreach att attributes [
					;			if att [
					;				change/only oldAttributes att 
					;			]
					;			oldAttributes: next oldAttributes
					;		];}
					;		attributes: oldAttributes: head oldAttributes
					;	][
					;		
					;		depth-attributes/(depth): attributes
					;	]
					;][
						if all [move none? cid][
							;ask reform [2 mold attributes mold oldAttributes]
						]
						if offset [
							;ask reform ["changing offset:" offset cid]
							attributes/3/1: attributes/3/1 + offset/1
							attributes/3/2: attributes/3/2 + offset/2
						]
						;repend/only repend depth-attributes depth attributes
					;]

					
					
					either cid [
						append usage-counter cid
						unless type: select types cid [
							print ["!!! Unknown type for cid: " cid]
							halt
						]
						result: insert result rejoin [
							either move ["^-Replace "]["^-Place "] (select types cid)
							#" " select ids-replaced cid
							#" " realDepth
							mold/all attributes
							either colorAtts [mold/all colorAtts][""]
							either all [name #"$" = name/1] [mold as-string next name][""] ;only names which beggins with char $  
							#"^/"
						]
					][
						;-- A new character (with ID of CharacterId) is placed on the display list at the specified
						;-- depth. Other fields set the attributes of this new character.
						result: insert result rejoin [
							"^-Move "
							realDepth #" "
							mold/all attributes
							either colorAtts [mold/all colorAtts][""]
							#"^/"
						]
					]
				]
				28 [;removeDepth
					;print "---"
					
					depth: tagData
					realDepth: index? tmp: find depths depth
					;print ["remove" depth realDepth mold depths]
					remove tmp
					remove/part find depth-offsets depth 2
					remove/part find depth-attributes depth 2
					;probe depth-attributes
					result: insert result rejoin [
						"^-Remove " realDepth #"^/"
					]
				]
				1 [;showFrame
					frameStart: result: insert result ajoin ["^-ShowFrame ;" currentFrame "^/"]
					;frameStart: index? result
					currentFrame: currentFrame + 1
				]
				43 [
					;frameLabel
					insert frameStart rejoin ["^-Label " mold as-string tagData "^/"]
					result: tail result
				]
				45 [;SoundStreamHead2, not used
				]
				15 [;StartSound
					result: insert result do-startSound tagData
				]
				12 [
					;actions
				]
				0 [] ;end of sprite
			][
				ask reform ["Unknown tag" tagId "!"]
			]
		]
		either all [
		false
			1 = frames
			1 = length? depths
			'image = (select types cid)
			none? attributes/1
			none? attributes/2
			0 = attributes/3/1
			0 = attributes/3/2
			none? colorAtts
		][
			;name: select names cid
			;repend names [id name]
			;repend types [id 'image]
			append replaced-sprites id
			append sprite-images   cid
			;if offset: select offsets tagData/3 [
			;	repend/only repend offsets id offset
			;]
			
			print ["^-Image instead of sprite:" id mold name cid]
			;ask "?"
		][
			append usage-counter id
			repend types [id 'object]
			result: head result
			repend sprites [id reduce [frames result]]
		]
	]
	
	do-startSound: func[data
		/local id SyncStop SyncNoMultiple InPoint OutPoint Loops Envelope p
	][
		id: data/1
		set [
			SyncStop
			SyncNoMultiple
			InPoint
			OutPoint
			Loops
			Envelope
		] next data/2
		if block? envelope [
			;flash is leaving multiple sound envelop values for same sample frames,
			;so I first clean it up and leave just the last values for samples with same number
			p: none
			forskip envelope 3 [
				if all [p p = envelope/1][
					envelope: remove/part skip envelope -3 3
				]
				p: envelope/1
			]
		]
		append usage-counter id
		rejoin ["^-Sound " select ids-replaced id " " mold reduce [any [loops 0] any [envelope reduce [0 32768 32768]]] "^/"]
	]
	set 'form-timeline func[
		src-swf [file!]
		/local tags tagId tagData parsed
	][
		clear shapes
		clear bitmaps
		clear sprites
		clear names
		clear names-images
		clear names-sounds
		clear types
		clear offsets
		clear usage-counter
		clear ids-replaced
		num-images: num-objects: num-shapes: 0
		
		with swf-parser/swf-tag-parser [
			verbal?: false
			parseActions: swf-parser/swfTagParseActions
		]
		tags: extract-swf-tags src-swf [
			56   ;AVM1 - ExportAssets - used to get names of the used bitmaps and sprites
			76   ;AVM2 - DoAction3StartupClass
		]
		foreach [tagId tagData] tags [
			parsed: parse-swf-tag tagId tagData
			foreach [id name] parsed [
				replace/all name "_" "/"
				unless parse/all name [
					"Bitmaps/" copy name to end (
						;print ["Image:" id tab name]
						repend types [id 'image]
						append names-images name
						repend ids-replaced [id to-string length? names-images]
					)
					|
					"Sounds/" copy name to end (
						print ["Sound:" id tab name]
						repend types [id 'sound]
						append names-sounds name
						repend ids-replaced [id to-string length? names-sounds]
					)
				][
					repend names [id as-string name]
				]
				;print ["^-AssetName:" id mold as-string name]
			]
		]

		tags: extract-swf-tags src-swf [
			2 22 32 67 83 ;shape definitions
			;4 26 70 ;placeObject - not used as I'm not analysing root timeline, only exported Sprites
			;5 28 ;removeObject - --//--
			20 21 35 36 ;bitmap definitions
			39   ;defineSprite - this one is important!
			;43   ;frameLabel
			;56   ;ExportAssets - used to get names of the used bitmaps and sprites
			14   ;defineSound
			0    ;end
		]
		
		foreach [tagId tagData] tags [
			;print ["===TAG[" tagId "]==="]
			parsed: parse-swf-tag tagId tagData
			switch tagId [
				2 22 32 67 83 [;DefineShape
					analyse-shape parsed
				]
				;4 26 [;PlaceObject
				;]
				;5 28 [;RemoveObject
				;]
				20 21 35 36 [;DefineBitsLossless DefineBitsJPEG2 DefineBitsJPEG3 DefineBitsLossless2 	
					if find names parsed/1 [
						unless find types parsed/1 [
							print ["!!! UNKNOWN IMAGE" parsed/1]
							ask "continue?"
						]
						;repend types [parsed/1 'image]
					]
					;repend names [id name]
					;repend types [id 'image]
					;halt
				]
				39 [;DefineSprite
					analyse-sprite parsed
				]
				43 [;framelabel
					print ""
					probe as-string parsed
				]
				;70 [;PlaceObject3
				;]
				14 [;DefineSound
					tmp: pick names-sounds to-integer select ids-replaced parsed/1
					print ["SOUND: " tmp]
					bin: last parsed
					if any [
						;;NOTE: named MP3 files are exported into Sounds dir which is located in SWF's parent dir 
						not exists? mp3file: rejoin [first split-path src-swf %../Sounds/ tmp %.mp3]
						(size? mp3file) <> length? bin
					][
						print ["Exporting MP3:" mp3file "-" length? bin "bytes"]
						write/binary mp3file bin
					]
					repend types [parsed/1 'sound]
				]
				
				0 [;End
					;I break the loop because I noticed, that FlashPro sometimes leaves garbage after the end tag!
					break
				]
			]
		]
		;probe new-line/skip names true 2
		
		code: copy ""
		foreach [id name] names [
			if find usage-counter id [
				append code reform ["Name" select ids-replaced id mold name "^/"]
			]
		]
		
		repend code [
			"^/Images "
			mold new-line/all names-images true
			"^/^/"
		]
		repend code [
			"^/Sounds "
			mold new-line/all names-sounds true
			"^/^/"
		]

		foreach [id def] shapes [
			;print ["!!! shape" id]
			append code ajoin ["Shape " select ids-replaced id " [^/" def "]^/"]
		]
		
		foreach [id def] sprites [
			;print ["sprite" id]
			append code rejoin [
				either def/1 = 1 ["Sprite "]["Movie "]
				select ids-replaced id " [^/" def/2 "]^/"
			]
			;if name: select names id [
			;	append code reform ["Asset" id mold name "^/"]
			;]
		]
		print "---------------------"
		print [" images:" length? names-images]
		print [" shapes:" num-shapes]
		print ["objects:" num-objects]
		print [" sounds:" length? names-sounds]
		print "---------------------"
		;probe ids-replaced
		;print code
		write head change find/last src-swf "." ".txt"code ;replaces swf extension with txt and saves result into this new file
	]
]
;form-timeline %/f/samorost3/temp/spici.swf