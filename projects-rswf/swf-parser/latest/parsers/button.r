rebol [
	title: "SWF buttons parse functions"
	purpose: "Functions for parsing buttons related tags in SWF files"
]

	readBUTTONRECORDs: has[records reserved states] [
		records: copy []
		until [
			byteAlign
			reserved: readUB 4
			states:   readUB 4
			either all [reserved = 0 states = 0] [true][;end
				repend/only records [
					states

						readUsedID
						readUI16 ;PlaceDepth
						readMATRIX
						either tagId = 34 [readCXFORMa][none]

				
				]
				false ;continue
			]
		]
		records
	]
	readBUTTONCONDACTIONs: has [actions CondActionSize][
		actions: copy []
		byteAlign
		until [
			either any [
				tail? inBuffer
				0 = CondActionSize: readUI16
			][ true][;end
				repend actions [
					readBitLogic ;CondIdleToOverDown
					readBitLogic ;CondOutDownToIdle
					readBitLogic ;CondOutDownToOverDown
					readBitLogic ;CondOverDownToOutDown
					readBitLogic ;CondOverDownToOverUp
					readBitLogic ;CondOverUpToOverDown
					readBitLogic ;CondOverUpToIdle
					readBitLogic ;CondIdleToOverUp
					readUB 7     ;CondKeyPress
					readBitLogic ;CondOverDownToIdle
					readACTIONRECORDs
				]
				false ;continue
			]
		]
		actions
	]
	
	parse-DefineButton: does [
		reduce [
			readID
			readBUTTONRECORDs
			readACTIONRECORDs
		]
	]
	parse-DefineButton2: does [
		reduce [
			readID
			(
				readUI8  ;flags
				readUI16 ;ActionOffset
				readBUTTONRECORDs
			)
			readBUTTONCONDACTIONs
		]
	]
	parse-DefineButtonCxform: does [
		reduce [
			readUsedID
			readCXFORM
		]
	]
	parse-DefineButtonSound: has[id] [
		reduce [
			readUsedID ;ButtonId
			;ButtonSoundChar0,ButtonSoundInfo0 (OverUpToIdle)
			either 0 < id: readUsedID [reduce [id readSOUNDINFO]][none]
			;ButtonSoundChar1,ButtonSoundInfo1 (IdleToOverUp)
			either 0 < id: readUsedID [reduce [id readSOUNDINFO]][none]
			;ButtonSoundChar2,ButtonSoundInfo2 (OverUpToOverDown)
			either 0 < id: readUsedID [reduce [id readSOUNDINFO]][none]
			;ButtonSoundChar3,ButtonSoundInfo3 (OverDownToOverUp)
			either 0 < id: readUsedID [reduce [id readSOUNDINFO]][none]
		]
	]