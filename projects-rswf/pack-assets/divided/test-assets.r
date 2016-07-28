REBOL [
	title: "Test LVL assets"
	purpose: {Parse LVL file and display some info}
	comment: {This is included in the 'ctx-pack-assets context from %pack-assets.r script!}
]


test: func[
	level [any-string!]   "Level's ID"
	/async
	/local file bytes num name info s
][
	info: context [
		sound-bytes: 0
		RAW-bytes: 0
	]
	s: make stream-io [] ;Holds input stream

	foreach [type file] reduce [
		;"BASE"     join %./bin/ rejoin [%Data/ either async ["univerzal/"][""] level %.lvl]
		"TEXTURES" join %./bin/ rejoin [%Data/ target #"/" level %.lvl]
	][
		print ["^/===========" type "FILE =============^/"]

		s/setStreamBuffer read/binary probe file
		unless "LVL" <> s/readBytes 3 [
			print ["*** Invalid LVL file" file]
			return
		]
		while [0 <> cmd: s/readUI8][
			prin ["CMD:" cmd tab]
			switch/default cmd reduce [
				cmdUseLevel [
					print "cmdUseLevel"
					print ["  activeLevel:" s/readUTF]
				]
				cmdTextureData [
					print "cmdTextureData"
					print ["  activeTextureName:" s/readUTF]
					either 1 = s/readUI8 [
						print ["  isATF: true bytes:" bytes: s/readUI32]
					][
						print ["  isATF: false bytes:" bytes: s/readUI32]
						
					]
					s/skipBytes bytes
				]
				cmdUseTexture [
					print "cmdUseTexture"
					print ["  activeTextureName:" s/readUTF]
				]
				cmdPackedAssets [
					print "cmdPackedAssets"
					print ["  activeTextureName:" s/readUTF]
					print ["  bytes:" bytes: s/readUI32]
					while [0 <> cmd: s/readUI8][
						switch/default cmd reduce [
							cmdDefineImage [
								print ["    defineImage:" s/readUI16 "rect:" s/readUI16 s/readUI16 s/readUI16 s/readUI16]
							]
							cmdStartMovie [
								print ["    startMovie:" s/readUTF]
							]
							cmdEndMovie [
								print ["    endMovie labels:"]
								loop s/readUI16 [
									print ["        " s/readUI16 tab s/readUTF]
								]
							]
							cmdAddMovieTexture [
								print ["    addMovieTexture: region:" s/readUI16 s/readUI16 s/readUI16 s/readUI16]
							]
							cmdAddMovieTextureWithFrame [
								print ["    addMovieTexture: region:" s/readUI16 s/readUI16 s/readUI16 s/readUI16]
								print ["                      frame:" s/readUI32 s/readUI32 s/readUI16 s/readUI16]
							]
						][
							s/inBuffer: back s/inBuffer
							print ["*** Invalid texture data definition command at" index? s/inBuffer mold copy/part s/inBuffer 10]
							return
						]
					]
				]
				cmdImageNames [
					print "cmdImageNames"
					loop s/readUI16 [
						name: s/readUTF
						print ["    " s/readUI16 tab name]
					]
				]
				cmdStringPool [
					print "cmdStringPool"
					loop s/readUI16 [
						print ["    " s/readUI16 tab s/readUTF]
					]
				]
				cmdLoadSWF [
					print "cmdLoadSWF"
					print ["  id:" s/readUTF]
					print ["  bytes:" bytes: s/readUI32]
					s/skipBytes bytes
				]
				cmdDefineSound [
					print "cmdDefineSound"
					print ["  id:" s/readUTF "numId:" s/readUI16 "bytes:" bytes: s/readUI32]
					s/skipBytes bytes
					info/sound-bytes: info/sound-bytes + bytes
				]
				cmdDefineSoundLoop [
					print "cmdDefineSoundLoop"
					print ["  id:" s/readUTF "numId:" s/readUI16 "bytes:" bytes: s/readUI32]
					s/skipBytes bytes
					info/sound-bytes: info/sound-bytes + bytes
				]
				cmdDefineSoundRAW [
					print "cmdDefineSoundRAW"
					print ["  id:" s/readUTF "bytes:" bytes: s/readUI32]
					s/skipBytes bytes
					info/RAW-bytes: info/RAW-bytes + bytes
				]
				cmdShapeBuffers [
					print "cmdShapeBuffers"
					num: s/readUI8
					if num > 0 [
						loop num [
							print ["    VertexBuffer3D" bytes: s/readUI32 * 6 * 4]
							s/skipBytes bytes
						]
						loop num [
							print ["    IndexBuffer3D" bytes: s/readUI32 * 2]
							s/skipBytes bytes
						]

					]
				]
				cmdShapeVertexBuffer [
					print "cmdShapeVertexBuffer"
					bytes: s/readUI32
					print ["  id:" s/readUI8 "bytes:" bytes]
					s/skipBytes bytes - 1
				]
				cmdShapeIndexBuffer [
					print "cmdShapeIndexBuffer"
					bytes: s/readUI32
					print ["  id:" s/readUI8 "bytes:" bytes]
					s/skipBytes bytes - 1
				]
				cmdTimelineData2
				cmdTimelineData [
					print "cmdTimelineData" 
					print ["  bytes:" bytes: s/readUI32]
					while [0 <> cmd: s/readUI8][
						switch/default cmd reduce [
							cmdTimelineObject [
								print ["    cmdTimelineObject:" s/readUI16 "bytes:" bytes: s/readUI32]
								s/skipBytes bytes
							]
							cmdTimelineShape2 [
								print ["    cmdTimelineShape2:" s/readUi16 "bufferNumber:" s/readUI8 "firstIndex:" s/readUI32 "triangles:" s/readUI32]
							]
						][
							s/inBuffer: back s/inBuffer
							print ["*** Invalid Timeline command at" index? s/inBuffer mold copy/part s/inBuffer 10]
							return
						]
					]
					loop s/readUI32 [
						print ["    NameDefinition:" s/readUI16 s/readUTF]
					]
					loop s/readUI32 [
						print ["    SoundGroupDefinition:" s/readUI8 s/readUTF]
					]
				]
				cmdWalkData [
					print "cmdWalkData"
					print ["    normal bytes: " num: s/readUI16]
					if num > 0 [ s/skipBytes num * 4 * 4 ] ;posX posY scaleX rotation
					print ["    reflec bytes: " num: s/readUI16]
					if num > 0 [ s/skipBytes num * 4 * 3 ] ;posX posY rotation

					loop s/readUI16 [
						print ["  at" s/readUI16 mold s/readUTF]
					]
					loop s/readUI16 [
						print ["  left" s/readUI16 s/readUTF]
					]
					loop s/readUI16 [
						print ["  right" s/readUI16 s/readUTF]
					]
					repeat i s/readUI8 [
						print ["  addPathFinderNode" i s/readUI16 s/readUI16]
					]
					loop s/readUI8 [
						print ["  addPathFinderSingleArc" s/readUI8 s/readUI8 s/readUI8]
					]
				]
				cmdPathData [
					print "cmdPathData"
					num: s/readUI16
					if num > 0 [ s/skipBytes num * 4 * 5 ]
					loop s/readUI16 [
						print ["   " s/readUI16 tab s/readUTF]
					]
				]
			][
				s/inBuffer: back s/inBuffer
				print ["*** Unknown command at" index? s/inBuffer mold copy/part s/inBuffer 10]
				return
			]
		]
	]
	? info
]

convert-to-async: func[
	level [any-string!]   "Level's ID"
	/local file bytes num name info s outA outB start end i
][
	info: context [
		sound-bytes: 0
		RAW-bytes: 0
	]
	s:    make stream-io [] ;Holds input stream
	outA: make stream-io [] 
	outB: make stream-io [] 

	print "-- A ------------------ TEXTURES ---------------------"
	file: join %./bin/ rejoin [%Data/ target #"/" level %.lvl]
	s/setStreamBuffer read/binary probe file

	
	unless "LVL" <> s/readBytes 3 [
		print ["*** Invalid LVL file" file]
		return
	]

	while [0 <> cmd: s/readUI8][
		prin ["CMD:" cmd tab]

		switch/default cmd reduce [
			cmdUseLevel [
				print "cmdUseLevel"
				print ["  activeLevel:" name: s/readUTF]
				outA/writeUI8 cmd
				outA/writeUTF name
			]
			cmdTextureData [
				print "cmdTextureData"
				start: s/inBuffer
				print ["  activeTextureName:" s/readUTF]
				either 1 = s/readUI8 [
					print ["  isATF: true bytes:" bytes: s/readUI32]
				][
					print ["  isATF: false bytes:" bytes: s/readUI32]
					
				]
				s/skipBytes bytes
				outA/writeUI8 cmd
				outA/writeBytes copy/part start s/inBuffer
			]
			cmdShapeBuffers [
				print "cmdShapeBuffers"
				num: s/readUI8
				if num > 0 [
					repeat i num [
						print ["    VertexBuffer3D" bytes: s/readUI32 * 6 * 4]
						outA/writeUI8 cmdShapeVertexBuffer
						outA/writeUI32 bytes + 1
						outA/writeUI8 i - 1
						outA/writeBytes s/readBytes bytes
					]
					repeat i num [
						print ["    IndexBuffer3D" bytes: s/readUI32 * 2]
						outA/writeUI8 cmdShapeIndexBuffer
						outA/writeUI32 bytes + 1
						outA/writeUI8 i - 1
						outA/writeBytes s/readBytes bytes
					]

				]
			]
			
		][
			s/inBuffer: back s/inBuffer
			print ["*** Unknown command at" index? s/inBuffer mold copy/part s/inBuffer 10]
			return
		]
	]


	print "-- B ------------------ UNIVERZAL ---------------------"
	file: join %./bin/ rejoin [%Data/ level %.lvl]
	s/setStreamBuffer read/binary probe file

	
	unless "LVL" <> s/readBytes 3 [
		print ["*** Invalid LVL file" file]
		return
	]

	while [0 <> cmd: s/readUI8][
		prin ["CMD:" cmd tab]
		switch/default cmd reduce [
			cmdUseLevel [
				print "cmdUseLevel"
				print ["  activeLevel:" name: s/readUTF]
				outB/writeUI8 cmd
				outB/writeUTF name
			]
			cmdStringPool [
				print "cmdStringPool"
				start: s/inBuffer
				loop s/readUI16 [
					print ["    " s/readUI16 tab s/readUTF]
				]
				outB/writeUI8 cmd
				outB/writeUI32 (index? s/inBuffer) - (index? start)
				outB/writeBytes copy/part start s/inBuffer
			]

			cmdUseTexture [
								print "cmdUseTexture"
								print ["  activeTextureName:" s/readUTF]
			]

			cmdPackedAssets [
				print "cmdPackedAssets"
				start: s/inBuffer

				print ["  activeTextureName:" name: s/readUTF]
				print ["  bytes:" bytes: s/readUI32]
				
				outB/writeUI8 cmd
				outB/writeUI32 (index? s/inBuffer) - (index? start) - 4 + bytes
				outB/writeUTF name
				outB/writeUI32 bytes
				outB/writeBytes s/readBytes bytes
			]
			cmdImageNames [
				print "cmdImageNames"
				start: s/inBuffer
				loop s/readUI16 [
					name: s/readUTF
					print ["    " s/readUI16 tab name]
				]
				outB/writeUI8 cmd
				outB/writeUI32 (index? s/inBuffer) - (index? start)
				outB/writeBytes copy/part start s/inBuffer
			]
			
			cmdLoadSWF [
				print "cmdLoadSWF"
				start: s/inBuffer
				print ["  id:" name: s/readUTF]
				print ["  bytes:" bytes: s/readUI32]
				s/skipBytes bytes
				outB/writeUI8 cmd
				outB/writeUI32 (index? s/inBuffer) - (index? start)
				outB/writeBytes copy/part start s/inBuffer
			]
			cmdDefineSound [
				print "cmdDefineSound"
				start: s/inBuffer
				print ["  id:" s/readUTF "numId:" s/readUI16 "bytes:" bytes: s/readUI32]
				s/skipBytes bytes
				outB/writeUI8 cmd
				outB/writeUI32 (index? s/inBuffer) - (index? start)
				outB/writeBytes copy/part start s/inBuffer
			]
			cmdDefineSoundLoop [
				print "cmdDefineSoundLoop"
				start: s/inBuffer
				print ["  id:" s/readUTF "numId:" s/readUI16 "bytes:" bytes: s/readUI32]
				s/skipBytes bytes
				outB/writeUI8 cmd
				outB/writeUI32 (index? s/inBuffer) - (index? start)
				outB/writeBytes copy/part start s/inBuffer
			]
			cmdDefineSoundRAW [
				print "cmdDefineSoundRAW"
				start: s/inBuffer
				print ["  id:" s/readUTF "bytes:" bytes: s/readUI32]
				s/skipBytes bytes
				outB/writeUI8 cmd
				outB/writeUI32 (index? s/inBuffer) - (index? start)
				outB/writeBytes copy/part start s/inBuffer
			]
			cmdTimelineData2
			cmdTimelineData [
				print "cmdTimelineData" 
				outB/writeUI8 cmd
				start: s/inBuffer

				print ["  bytes:" bytes: s/readUI32]
				
				while [0 <> cmd: s/readUI8][
					switch/default cmd reduce [
						cmdTimelineObject [
							s/readUI16
							s/skipBytes s/readUI32
						]
						cmdTimelineShape2 [
							s/skipBytes 11
						]
					][
						s/inBuffer: back s/inBuffer
						print ["*** Invalid Timeline command at" index? s/inBuffer mold copy/part s/inBuffer 10]
						return
					]
				]
				loop s/readUI32 [
					print ["    NameDefinition:" s/readUI16 s/readUTF]
				]
				loop s/readUI32 [
					print ["    SoundGroupDefinition:" s/readUI8 s/readUTF]
				]
				outB/writeUI32 (index? s/inBuffer) - (index? start)
				outB/writeBytes copy/part start s/inBuffer
			]
			cmdWalkData [
				print "cmdWalkData"
				start: s/inBuffer
				print ["    normal bytes: " num: s/readUI16]
				if num > 0 [ s/skipBytes num * 4 * 4 ] ;posX posY scaleX rotation
				print ["    reflec bytes: " num: s/readUI16]
				if num > 0 [ s/skipBytes num * 4 * 3 ] ;posX posY rotation

				loop s/readUI16 [
					print ["  at" s/readUI16 mold s/readUTF]
				]
				loop s/readUI16 [
					print ["  left" s/readUI16 s/readUTF]
				]
				loop s/readUI16 [
					print ["  right" s/readUI16 s/readUTF]
				]
				repeat i s/readUI8 [
					print ["  addPathFinderNode" i s/readUI16 s/readUI16]
				]
				loop s/readUI8 [
					print ["  addPathFinderSingleArc" s/readUI8 s/readUI8 s/readUI8]
				]
				outB/writeUI8 cmd
				outB/writeUI32 (index? s/inBuffer) - (index? start)
				outB/writeBytes copy/part start s/inBuffer
			]
			cmdPathData [
				print "cmdPathData"
				start: s/inBuffer
				num: s/readUI16
				if num > 0 [ s/skipBytes num * 4 * 5 ]
				loop s/readUI16 [
					print ["   " s/readUI16 tab s/readUTF]
				]
				outB/writeUI8 cmd
				outB/writeUI32 (index? s/inBuffer) - (index? start)
				outB/writeBytes copy/part start s/inBuffer
			]
		][
			s/inBuffer: back s/inBuffer
			print ["*** Unknown command at" index? s/inBuffer mold copy/part s/inBuffer 10]
			return
		]
	]
	outA/writeUI8 0 ;end
	outA/outBuffer: head outA/outBuffer
	outA/writeBytes as-binary "LVL"
	print ["Writing textures file..."]
	if not exists? dir: rejoin [%./bin/Data/A_ target #"/"][ make-dir/deep dir ]
	write/binary rejoin [dir level %.lvl] head outA/outBuffer

	outB/writeUI8 0 ;end
	outB/outBuffer: head outB/outBuffer
	outB/writeBytes as-binary "LVL"
	print ["Writing univerzal file..."]
	if not exists? dir: %./bin/Data/univerzal/ [ make-dir/deep dir ]
	write/binary rejoin [dir level %.lvl] head outB/outBuffer
]

split-sound-assets: func[
	level [any-string!]   "Level's ID"
	/local file bytes num name info s outA outB start end i
][
	info: context [
		sound-bytes: 0
		RAW-bytes: 0
	]
	s:    make stream-io [] ;Holds input stream
	outA: make stream-io []
	outB: make stream-io [] 

	print "-- B ------------------ UNIVERZAL ---------------------"
	file: join %./bin/ rejoin [%Data/ level %.lvl]
	s/setStreamBuffer read/binary probe file

	
	unless "LVL" <> s/readBytes 3 [
		print ["*** Invalid LVL file" file]
		return
	]

	while [0 <> cmd: s/readUI8][
		prin ["CMD:" cmd tab]
		switch/default cmd reduce [
			cmdUseLevel [
				print "cmdUseLevel"
				print ["  activeLevel:" name: s/readUTF]
				outA/writeUI8 cmd
				outA/writeUTF name
			]
			cmdStringPool [
				print "cmdStringPool"
				start: s/inBuffer
				loop s/readUI16 [
					print ["    " s/readUI16 tab s/readUTF]
				]
				outA/writeUI8 cmd
				outA/writeBytes copy/part start s/inBuffer
			]

			cmdUseTexture [
								print "cmdUseTexture"
								print ["  activeTextureName:" s/readUTF]
								ask "*** This command should not be in this file! ***"
			]

			cmdPackedAssets [
				print "cmdPackedAssets"
				start: s/inBuffer

				print ["  activeTextureName:" name: s/readUTF]
				print ["  bytes:" bytes: s/readUI32]
				
				outA/writeUI8 cmd
				outA/writeUTF name
				outA/writeUI32 bytes
				outA/writeBytes s/readBytes bytes
			]
			cmdImageNames [
				print "cmdImageNames"
				start: s/inBuffer
				loop s/readUI16 [
					name: s/readUTF
					print ["    " s/readUI16 tab name]
				]
				outA/writeUI8 cmd
				outA/writeBytes copy/part start s/inBuffer
			]
			
			cmdLoadSWF [
				print "cmdLoadSWF"
				start: s/inBuffer
				print ["  id:" name: s/readUTF]
				print ["  bytes:" bytes: s/readUI32]
				s/skipBytes bytes
				outA/writeUI8 cmd
				outA/writeBytes copy/part start s/inBuffer
			]
			cmdDefineSound [
				print "cmdDefineSound"
				start: s/inBuffer
				print ["  id:" s/readUTF "numId:" s/readUI16 "bytes:" bytes: s/readUI32]
				s/skipBytes bytes
				outB/writeUI8 cmd
				outB/writeBytes copy/part start s/inBuffer
			]
			cmdDefineSoundLoop [
				print "cmdDefineSoundLoop"
				start: s/inBuffer
				print ["  id:" s/readUTF "numId:" s/readUI16 "bytes:" bytes: s/readUI32]
				s/skipBytes bytes
				outB/writeUI8 cmd
				outB/writeBytes copy/part start s/inBuffer
			]
			cmdDefineSoundRAW [
				print "cmdDefineSoundRAW"
				start: s/inBuffer
				print ["  id:" s/readUTF "bytes:" bytes: s/readUI32]
				s/skipBytes bytes
				outB/writeUI8 cmd
				outB/writeBytes copy/part start s/inBuffer
			]
			cmdTimelineData2
			cmdTimelineData [
				print "cmdTimelineData" 
				outA/writeUI8 cmd
				start: s/inBuffer

				print ["  bytes:" bytes: s/readUI32]
				
				while [0 <> cmd: s/readUI8][
					switch/default cmd reduce [
						cmdTimelineObject [
							s/readUI16
							s/skipBytes s/readUI32
						]
						cmdTimelineShape2 [
							s/skipBytes 11
						]
					][
						s/inBuffer: back s/inBuffer
						print ["*** Invalid Timeline command at" index? s/inBuffer mold copy/part s/inBuffer 10]
						return
					]
				]
				loop s/readUI32 [
					print ["    NameDefinition:" s/readUI16 s/readUTF]
				]
				loop s/readUI32 [
					print ["    SoundGroupDefinition:" s/readUI8 s/readUTF]
				]
				outA/writeBytes copy/part start s/inBuffer
			]
			cmdWalkData [
				print "cmdWalkData"
				start: s/inBuffer
				print ["    normal bytes: " num: s/readUI16]
				if num > 0 [ s/skipBytes num * 4 * 4 ] ;posX posY scaleX rotation
				print ["    reflec bytes: " num: s/readUI16]
				if num > 0 [ s/skipBytes num * 4 * 3 ] ;posX posY rotation

				loop s/readUI16 [
					print ["  at" s/readUI16 mold s/readUTF]
				]
				loop s/readUI16 [
					print ["  left" s/readUI16 s/readUTF]
				]
				loop s/readUI16 [
					print ["  right" s/readUI16 s/readUTF]
				]
				repeat i s/readUI8 [
					print ["  addPathFinderNode" i s/readUI16 s/readUI16]
				]
				loop s/readUI8 [
					print ["  addPathFinderSingleArc" s/readUI8 s/readUI8 s/readUI8]
				]
				outA/writeUI8 cmd
				outA/writeBytes copy/part start s/inBuffer
			]
			cmdPathData [
				print "cmdPathData"
				start: s/inBuffer
				num: s/readUI16
				if num > 0 [ s/skipBytes num * 4 * 5 ]
				loop s/readUI16 [
					print ["   " s/readUI16 tab s/readUTF]
				]
				outA/writeUI8 cmd
				outA/writeBytes copy/part start s/inBuffer
			]
		][
			s/inBuffer: back s/inBuffer
			print ["*** Unknown command at" index? s/inBuffer mold copy/part s/inBuffer 10]
			return
		]
	]
	outA/writeUI8 0 ;end
	outA/outBuffer: head outA/outBuffer
	outA/writeBytes as-binary "LVL"
	print ["Writing textures file..."]
	if not exists? dir: %./bin/Data/ [ make-dir/deep dir ]
	write/binary rejoin [dir level %_A.lvl] head outA/outBuffer

	outB/writeUI8 0 ;end
	outB/outBuffer: head outB/outBuffer
	outB/writeBytes as-binary "LVL"
	print ["Writing univerzal file..."]
	if not exists? dir: %./bin/Data/ [ make-dir/deep dir ]
	write/binary rejoin [dir level %_B.lvl] head outB/outBuffer
]

split-texture-assets: func[
	level [any-string!]   "Level's ID"
	/local file bytes num name info s outA outB start end i
][
	info: context [
		sound-bytes: 0
		RAW-bytes: 0
	]
	s:    make stream-io [] ;Holds input stream
	outA: make stream-io [] 
	outB: make stream-io [] 

	print "-- A ------------------ TEXTURES ---------------------"
	file: join %./bin/ rejoin [%Data/ target #"/" level %.lvl]
	s/setStreamBuffer read/binary probe file

	
	unless "LVL" <> s/readBytes 3 [
		print ["*** Invalid LVL file" file]
		return
	]

	while [0 <> cmd: s/readUI8][
		prin ["CMD:" cmd tab]

		switch/default cmd reduce [
			cmdUseLevel [
				print "cmdUseLevel"
				print ["  activeLevel:" name: s/readUTF]
				outA/writeUI8 cmd
				outA/writeUTF name

				outB/writeUI8 cmd
				outB/writeUTF name
			]
			cmdTextureData [
				print "cmdTextureData"
				start: s/inBuffer
				print ["  activeTextureName:" s/readUTF]
				either 1 = s/readUI8 [
					print ["  isATF: true bytes:" bytes: s/readUI32]
				][
					print ["  isATF: false bytes:" bytes: s/readUI32]
					
				]
				s/skipBytes bytes
				outA/writeUI8 cmd
				outA/writeBytes copy/part start s/inBuffer
			]
			cmdShapeBuffers [
				print "cmdShapeBuffers"
				start: s/inBuffer
				num: s/readUI8
				if num > 0 [
					repeat i num [
						print ["    VertexBuffer3D" bytes: s/readUI32 * 6 * 4]
						s/skipBytes bytes
					]
					repeat i num [
						print ["    IndexBuffer3D" bytes: s/readUI32 * 2]
						s/skipBytes bytes
					]
				]
				outB/writeUI8 cmd
				outB/writeBytes copy/part start s/inBuffer
			]
			
		][
			s/inBuffer: back s/inBuffer
			print ["*** Unknown command at" index? s/inBuffer mold copy/part s/inBuffer 10]
			return
		]
	]

	outA/writeUI8 0 ;end
	outA/outBuffer: head outA/outBuffer
	outA/writeBytes as-binary "LVL"

	outB/writeUI8 0 ;end
	outB/outBuffer: head outB/outBuffer
	outB/writeBytes as-binary "LVL"

	print ["Writing textures file..."]
	if not exists? dir: rejoin [%./bin/Data/ target #"/"][ make-dir/deep dir ]

	write/binary rejoin [dir level %_A.lvl] head outA/outBuffer
	write/binary rejoin [dir level %_B.lvl] head outB/outBuffer
]