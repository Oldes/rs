rebol [
	title: "SWF basic datatypes parse functions"
	purpose: "Functions for parsing basic datatypes used in SWF's tags"
]

	readMATRIX: does [
		byteAlign
		;print ["readMATRIX" copy/part inBuffer 20 bitBuffer availableBits]
		reduce [
			either readBitLogic [ readPair ][none] ;scale
			either readBitLogic [ readPair ][none] ;rotate
			readSBPair ;translate
		]
	]
	writeMATRIX: func[m][
		either m/1 [
			writeBitLogic true
			writePair m/1
		][
			writeBitLogic false
		]
		either m/2 [
			writeBitLogic true
			writePair m/2
		][
			writeBitLogic false
		]
		writeSBPair m/3
	]
	carryMATRIX: does [
		alignBuffers
		if carryBitLogic [;scale
			carryPair
		]
		if carryBitLogic [;rotate
			carryPair
		]
		carrySBPair 
		alignBuffers
	]


	readCXFORM: has [HasAddTerms? HasMultTerms? nbits tmp][
		HasAddTerms?:  readBitLogic
		HasMultTerms?: readBitLogic
		nbits: readUB 4
		tmp: reduce [
			either HasMultTerms? [
				reduce [
					readSB nbits ;R
					readSB nbits ;G
					readSB nbits ;B
				]
			][	none ]
			either HasAddTerms? [
				reduce [
					readSB nbits ;R
					readSB nbits ;G
					readSB nbits ;B
				]
			][	none ]
		]
		byteAlign
		tmp
	]
	
	readCXFORMa: has [HasAddTerms? HasMultTerms? nbits tmp][
		HasAddTerms?:  readBitLogic
		HasMultTerms?: readBitLogic
		nbits: readUB 4
		tmp: reduce [
			either HasMultTerms? [
				reduce [
					readSB nbits ;R
					readSB nbits ;G
					readSB nbits ;B
					readSB nbits ;A
				]
			][	none ]
			either HasAddTerms? [
				reduce [
					readSB nbits ;R
					readSB nbits ;G
					readSB nbits ;B
					readSB nbits ;A
				]
			][	none ]
		]
		byteAlign
		tmp
	]