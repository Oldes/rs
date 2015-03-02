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
	id-offset:   0
	max-id:      0
	num-shapes:  0
	num-images:  0
	num-objects: 0

	update-id: func[id [integer!]][
		if id > max-id [ max-id: id ]
		id: id + id-offset
	]
	
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

		id: update-id id

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
			;-- TODO!
			;-- this does not look as correct condition, becase image names are not in names anymore:
			name: select names fill/2/1 ;it's known named bitmap 
		][
			ask "IS THIS HAPPENNING?"
			repend names [id name]
			repend types [id 'image]
			print ["SHAPE AS IMAGE?" mold ShapeRecords/2]
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
						LineStyles: tmp/2
						FillStyles: tmp/1
					][
						;ask mold style
						
						either all [
							style/4
							tmp: pick LineStyles style/4
						][
							;probe tmp ask "?"
							result: insert result reform ["^-lineStyle" tmp/1 tmp/4 "^/"]
						][
							;no line style found, so trying to use fillColor for line (fills are not supported)
							if all [
								style/3
								tmp: pick FillStyles style/3
							][
								print ["USING FILL INSTEAD OF LINE: " mold tmp]
								result: insert result reform ["^-lineStyle" 30 tmp/2 "^/"] ;TEMP: USING FILL COLOR AS A LINE and 1.5px width
								;reform ["^-fillStyle" tmp/2 "^/"]
							]
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
			
			if parse/all result ["^-moveTo" to end][
				probe ShapeRecords
				ask "???????????????????"
			]
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
		id: update-id id
		;print ["frames" frames]
		
		if frames = 1 [
			;sprite or image
			if tags/1/1 = 45 [tags: remove tags] ;ignore SoundStreamHead2 tag, which is inside of sprite sometimes without any reason (bug in Flashi IDE!)
			tag:     tags/1
			tagId:   tag/1
			tagData: tag/2
			matrix:  either tagData [tagData/4][reduce [none none 0x0]]
			;Test if this sprite just puts simple shape with bitmap fill so I can use Image instead of this Sprite
			if all [
				;false ;DON'T USING THIS OPTIMIZATION NOW!!
				3 = length? tags
				find [4 26 70] tagId ;placeObject
				'image = select types tagData/3
				all [
					matrix/1/1 = 1 matrix/1/2 = 1 ;no scale
					matrix/2/1 = 0 matrix/2/2 = 0 ;no rotate
					matrix/3/1 = 0 matrix/3/2 = 0 ;the image is placed on position 0x0
				]
			][
				;as image
				append replaced-sprites id
				append sprite-images   tagData/3 + id-offset
				;print ["^-Image instead of sprite:" id mold name mold tag]
				return
			]
		]
		;as movie/sprite
		repend ids-replaced [id to-string num-objects]
		num-objects: num-objects + 1
		form-sprite-tags id frames tags
	]
	
	form-sprite-tags: func[
		id frames tags
		/local
			result
			tagId tagData offset
			tmp
			depth move cid ids attributes oldAttributes colorAtts frameStart
			maxDepth depths-replaced depths-to-remove ids-at-depth currentFrame
			name numLabels
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
		numLabels: 0
		
		foreach tag tags [
			tagId:   tag/1
			tagData: tag/2
			switch/default tagId [
				26 70 [;placeObject
					set [depth move cid attributes colorAtts ]  tagData

					if integer? cid [cid: cid + id-offset]

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
						either 'shape = select types cid [
							attributes: any [
								select depth-attributes depth
								[#[none] #[none] #[none]]
							]
						][
							attributes: [#[none] #[none] #[none]]
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
					if 'shape = select types cid [
						either oldAttributes: select depth-attributes depth [
							either all [move ][
								;if 'shape = select types cid [
								;	probe reform [mold attributes mold oldAttributes]
								;	ask ""
								;]
								;comment {
								foreach att attributes [
									if att [
										change/only oldAttributes att 
									]
									oldAttributes: next oldAttributes
								];}
								attributes: oldAttributes: head oldAttributes
							][
								
								attributes: oldAttributes: head oldAttributes
							]
						][
							;if all [move none? cid][
							;	ask reform [2 mold attributes mold oldAttributes]
							;]
						;	if offset [
						;		;ask reform ["changing offset:" offset cid]
						;		attributes/3/1: attributes/3/1 + offset/1
						;		attributes/3/2: attributes/3/2 + offset/2
						;	]
							repend/only repend depth-attributes depth attributes
						]
					]
					comment {
					either oldAttributes: select depth-attributes depth [
						either all [move none? cid][
							probe reform [mold attributes mold oldAttributes]
							;comment {
							foreach att attributes [
								if att [
									change/only oldAttributes att 
								]
								oldAttributes: next oldAttributes
							];}
							attributes: oldAttributes: head oldAttributes
						][
							
							depth-attributes/(depth): attributes
						]
					][
						;if all [move none? cid][
						;	ask reform [2 mold attributes mold oldAttributes]
						;]
						if offset [
							;ask reform ["changing offset:" offset cid]
							attributes/3/1: attributes/3/1 + offset/1
							attributes/3/2: attributes/3/2 + offset/2
						]
						;repend/only repend depth-attributes depth attributes
					]
					}
					
					
					either cid [
						append usage-counter cid
						unless type: select types cid [
							probe types
							print ["!!! Unknown type for cid: " cid]
							halt
						]
						result: insert result rejoin [
							either move ["^-Replace "]["^-Place "] (select types cid)
							#" " select ids-replaced cid
							#" " realDepth
							#" " mold/all attributes
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
					if tagData/1 <> #"_" [
						;labels with underscore are special so I don't count them
						numLabels: numLabels + 1
					]
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
		
		if numLabels > 0 [
			insert find/tail head result #"^/" "^-HasLabels^/"
		]
		append usage-counter id
		repend types [id 'object]
		result: head result
		repend sprites [id reduce [frames result]]
	]
	
	do-startSound: func[data
		/local id SyncStop SyncNoMultiple InPoint OutPoint Loops Envelope p
	][
		id: data/1 + id-offset
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
		/local tags tagId tagData parsed sndDir soundDir soundMasterDir soundName mp3file tmp bin swfs n id
	][
		print "-- FormTimeline"
		clear shapes
		clear bitmaps
		clear sounds
		clear sprites
		clear names
		clear names-images
		clear names-sounds
		clear types
		clear offsets
		clear usage-counter
		clear ids-replaced
		clear replaced-sprites
		clear sprite-images
		num-images: num-objects: num-shapes: id-offset: max-id: 0

		swfs: reduce [src-swf]
		n: 2
		while [exists? tmp: head insert find copy src-swf %.swf n][
			append swfs tmp
			n: n + 1
		]

		with swf-parser/swf-tag-parser [
			verbal?: false
			parseActions: swf-parser/swfTagParseActions
		]
	
		foreach src-swf swfs [
			print ["----- parsing:" src-swf] 
			tags: extract-swf-tags src-swf [
				56   ;AVM1 - ExportAssets - used to get names of the used bitmaps and sprites
				76   ;AVM2 - DoAction3StartupClass
			]
			foreach [tagId tagData] tags [
				parsed: parse-swf-tag tagId tagData
				foreach [id name] parsed [
					replace/all name "_" "/"
					id: update-id id
					unless parse/all name [
						"Bitmaps/" copy name to end (
							;print ["Image:" id tab name]
							repend types [id 'image]
							either none? tmp: find names-images name [
								append names-images name
								repend ids-replaced [id to-string length? names-images]
							][
								repend ids-replaced [id to-string index? tmp]
							]
						)
						|
						"Sounds/" copy name to end (
							print ["Sound:" id  tab name]
							repend types [id 'sound]
							either none? tmp: find names-sounds name [
								append names-sounds to-file name
								repend ids-replaced [id to-string length? names-sounds]
							][
								repend ids-replaced [id to-string index? tmp]
							]
						)
					][
						repend names [id as-string name]
					]
					;print ["^-AssetName:" id mold as-string name]
				]
			]
			;print ["ids-replaced:" mold ids-replaced]
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
						id: parsed/1 + id-offset
						if find names id [
							unless find types id [
								print ["!!! UNKNOWN IMAGE" id]
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
						id: parsed/1 + id-offset
						tmp: pick names-sounds to-integer select ids-replaced id
						print ["SOUND: " tmp]
						bin: last parsed
						set [sndDir soundName] split-path tmp
						soundDir: rejoin [first split-path src-swf %../Sounds/ sndDir ]
						soundMasterDir: rejoin [first split-path src-swf %../Sounds_master/ sndDir ]
						;-- NOTE: named MP3 files are exported into Sounds dir which is located in SWF's parent dir 
						if all [
							not exists? rejoin [soundMasterDir soundName %.mp3]
							any [
								not exists? mp3file: rejoin [soundDir soundName %.mp3]
								(size? mp3file) <> length? bin
							]
						][
							print ["Exporting MP3:" mp3file "-" length? bin "bytes"]
							if not exists? soundDir [make-dir/deep soundDir]
							write/binary mp3file bin
						]
						repend types [id 'sound]
					]
					
					0 [;End
						;I break the loop because I noticed, that FlashPro sometimes leaves garbage after the end tag!
						break
					]
				]
			]
			id-offset: id-offset + max-id
			max-id: 0
			;print ["TYPES:" mold types]
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
		write head change find/last src-swf "." ".txt" code ;replaces swf extension with txt and saves result into this new file
	]
]
;form-timeline %/f/samorost3/temp/spici.swf