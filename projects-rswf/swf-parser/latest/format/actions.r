rebol [
	title: "SWF Actions formater"
]

actionFormater: context [
	bin-to-int: func[bin][to-integer reverse as-binary bin]
	str-to-int: func[str][bin-to-int as-binary str]
	bin-to-si:  func[bin [binary!] /local i][
		i: to integer! reverse bin
		if i > 32767 [
			i: (i and 32767) - 32768
		]
		i
	]

	cp: ["^H" copy v 1 skip
		(append vals rejoin ["CP:" pick ConstantPool v: 1 + str-to-int v])
	]
	i32: ["^G" copy v 4 skip
		(append vals v: str-to-int v)
	]
	pstr: ["^@" copy v to "^@" 1 skip
		(append vals v)
	]
	logic: ["^E" copy v 1 skip
		(append vals pick [false true] 1 + str-to-int v)
	]
	null: ["^B" ( append vals 'null )]
	undefined: ["^C" (append vals 'undefined )]
	dec: ["^F" copy v 8 skip
		(append vals from-ieee64f as-binary v)
	]
	reg: ["^D" copy v 1 skip
		(append vals to-path join "R:" str-to-int v)
	]
	str: [copy v to "^@" 1 skip (append vals v) ]
	word: [copy v 2 skip (append vals str-to-int v)	]
	
	ConstantPool: copy []
	
	;stream: make stream-io []
	parseDefineFunc: func[data /local s params][
		s: make stream-io [inBuffer: data]
		context [
			name:   s/readStringP
			params: (
				params: copy []
				loop s/readShort [
					repend params [
						s/readStringP	;param_name
					]
				]
				params
			)
			length: s/readShort
		]
	]
	parseDefineFunc2: func[data /local s params][
		s: make stream-io [inBuffer: data]
		context [
			name:               s/readStringP
			arg_count:          s/readShort
			reg_count:          s/readUI8
			preload_parent:     s/readBitLogic
			preload_root:       s/readBitLogic
			suppress_super:     s/readBitLogic
			preload_super:      s/readBitLogic
			suppress_arguments: s/readBitLogic
			preload_arguments:  s/readBitLogic
			suppress_this:      s/readBitLogic
			preload_this:       s/readBitLogic
			preload_global:    (s/skipBits 7 s/readBitLogic)
			
			params: (
				params: copy []
				loop arg_count [
					repend params [
						s/readUI8     ;param_register
						s/readStringP	;param_name
					]
				]
				params
			)
			length: s/readShort
		]
	]

	fieldsACTIONRECORDs: func[
		actionRecords
		/indents ind
		/local result val aTagName data tabs tabsinner tmp indentStack index aTagId aTagData ofs
	][
		result: copy ""
		tabs: either indents [head insert/dup copy "" "^-" int]["^-"]
		tabsinner: ""
		indentStack: copy []
		
		while [not tail? actionRecords][
			set [index aTagId aTagData] copy/part actionRecords 3
			
			actionRecords: skip actionRecords 3
			unless empty? indentStack [
				while [
					all [
						not empty? indentStack
						indentStack/1 <= index
					]
				][	
					remove/part tabsinner 4
					remove indentStack
				]
			]
			unless aTagName: select actionids aTagId [
				"UnknownTag"
			]
			
			result: ajoin [result tabs to-hex index tab aTagId " " tabsinner aTagName]
			
			unless empty? aTagData [
				attempt [
					append result join " " switch/default aTagName [
						"aGetURL" [parse/all as-string aTagData "^@"]
						"aConstantPool" [
							clear ConstantPool
							parse/all aTagData [
								2 skip
								any [copy val to "^@" 1 skip (insert tail ConstantPool val)]
							]
							;ajoin [lf tabs "^-^-^-" mold ConstantPool]
							mold ConstantPool
						]
						"aPush" [
							vals: make block! []
							parse/all aTagData [some [cp | i32 | dec | pstr | logic | reg | null | undefined]]
							mold vals
						]
						"aDefineFunction" [
							tmp: parseDefineFunc aTagData
							data: copy ""
							foreach [sw val] third tmp [
								if val [
									data: ajoin [data lf tabs "                    " tabsinner sw tab mold val]
								]
							]
							insert indentStack (actionRecords/1 + tmp/length)
							sort   indentStack
							append tabsinner "    "
							data
						]
						"aDefineFunction2" [
							tmp: parseDefineFunc2 aTagData
							data: copy ""
							foreach [sw val] third tmp [
								if val [
									data: ajoin [data lf tabs "                    " tabsinner sw tab mold val]
								]
							]
							insert indentStack (actionRecords/1 + tmp/length)
							sort   indentStack
							append tabsinner "    "
							data
						]
						"aIf" [
							ofs: actionRecords/1 + bin-to-si aTagData
							if ofs > 0 [
								insert indentStack ofs
								sort   indentStack
								append tabsinner "    "
							]
							ajoin ["jumpTo " to-hex ofs]
						]
						"aJump" [
							ofs: actionRecords/1 + bin-to-si aTagData
							ajoin ["to " to-hex ofs]
						]
						"aStoreRegister" [
							to-integer aTagData
						]
					][	mold aTagData ]
				]
			]
			append result lf
			
		]
		;print "..."
		result
	]
	
	actionids: make hash! [
		#{00} "END of aRecord"
		;SWF3 as
		#{04} "aNextFrame"
		#{05} "aPrevFrame"
		#{06} "aPlay"
		#{07} "aStop"
		#{08} "aToggleQuality"
		#{09} "aStopSounds"	
		#{81} "aGotoFrame"
		#{83} "aGetURL"
		#{8A} "aWaitForFrame"
		#{8B} "aSetTarget"
		#{8C} "aGoToLabel"
		;Stack Operations
		#{96} "aPush"
		#{17} "aPop"
		;Arithmetic Operators
		#{0A} "aAdd"
		#{0B} "aSubtract"
		#{0C} "aMultiply"
		#{0D} "aDivide"
		;Numerical Comparison
		#{0E} "aEquals"
		#{0F} "aLess"
		;Logical Operators
		#{10} "aAnd"
		#{11} "aOr"
		#{12} "aNot"
		;String Manipulation
		#{13} "aStringEquals"
		#{14} "aStringLength"
		#{21} "aStringAdd"
		#{15} "aStringExtract"
		#{29} "aStringLess"
		#{31} "aMBStringLength"
		#{35} "aMBStringExtract"
		;Type Conversion
		#{18} "aToInteger"
		#{32} "aCharToAscii"
		#{33} "aAsciiToChar"
		#{36} "aMBCharToAscii"
		#{37} "aMBAsciiToChar"
		;Control Flow
		#{99} "aJump"
		#{9D} "aIf"
		#{9E} "aCall"
		;Variables
		#{1C} "aGetVariable"
		#{1D} "aSetVariable"
		;Movie Control
		#{9A} "aGetURL2"
		#{9F} "aGotoFrame2"
		#{20} "aSetTarget2"
		#{22} "aGetProperty"
		#{23} "aSetProperty"
		#{24} "aCloneSprite"
		#{25} "aRemoveSprite"
		#{27} "aStartDrag"
		#{28} "aEndDrag"
		#{8D} "aWaitForFrame2"
		;Utilities
		#{26} "aTrace"
		#{34} "aGetTime"
		#{30} "aRandomNumber"
		;SWF 5
		;ScriptObject as
		#{3D} "aCallFunction"
		#{52} "aCallMethod"
		#{88} "aConstantPool"
		#{9B} "aDefineFunction"
		#{3C} "aDefineLocal"
		#{41} "aDefineLocal2"
		#{43} "aDefineObject" ;this was not in the specification!
		#{3A} "aDelete"
		#{3B} "aDelete2"
		#{46} "aEnumerate"
		#{49} "aEquals2"
		#{4E} "aGetMember"
		#{42} "aInitArray/Object"
		#{53} "aNewMethod"
		#{40} "aNewObject"
		#{4F} "aSetMember"
		#{45} "aTargetPath"
		#{94} "aWith"
		;Type as
		#{4A} "aToNumber"
		#{4B} "aToString"
		#{44} "aTypeOf"
		;Math as
		#{47} "aAdd2"
		#{48} "aLess2"
		#{3F} "aModulo"
		;Stack Operator as
		#{60} "aBitAnd"
		#{63} "aBitLShift"
		#{61} "aBitOr"
		#{64} "aBitRShift"
		#{65} "aBitURShift"
		#{62} "aBitXor"
		#{51} "aDecrement"
		#{50} "aIncrement"
		#{4C} "aPushDuplicate"
		#{3E} "aReturn"
		#{4D} "aStackSwap"
		#{87} "aStoreRegister"
		
		;flashMX as
		#{54} "aInstanceOf"
		#{55} "aEnumerate2"
		#{66} "aStrictEqual"
		#{67} "aGreater"
		#{68} "aStringGreater"
		#{69} "aExtends"
		
		;flashMX2004 as ( guessing )
		#{2A} "aThrow"
		#{2B} "aCastOp"
		#{2C} "aImplementsOp"
		#{8E} "aDefineFunction2"
		#{8F} "aTry"
	]
]