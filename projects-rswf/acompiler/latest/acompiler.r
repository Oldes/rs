REBOL [
    Title: "Acompiler"
    Date: 13-Apr-2007/14:26:36+2:00
    Name: none
    Version: 0.5.0
    File: none
    Home: none
    Author: "David Oliva"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: none
    Purpose: none
    Comment: {
    	Special thanks to Ladislav Meèíø for the initial help with the parse rules
    	
    	SWF spec: http://sswf.sourceforge.net/SWFalexref.html
    }
    History: none
    Language: none
    Type: none
    Content: none
    Email: oliva.david@seznam.cz
    require: [
    	rs-project 'binary-conversions
    	rs-project 'ucs2cp1250
		rs-project 'utf-8
		rs-project 'ieee
	]
	preprocess: true

]

utf8-encode: func[
 	"Encodes the string data to UTF-8"
	str [any-string!] "string to encode"
	/local c
][
	utf-8/encode-2 ucs2/encode str
]

acompiler: context [

	#include %conversions.r
	#include %actionids.r
	
	utf8-encode?: true
	swf-version: 8
	used-strings: make hash! 400
	constantPool: copy []
	useConstantPool?: true
	
	slash: to-lit-word first [/]
	dslash: to-lit-word "//"
	rShift: to-lit-word ">>"
	UrShift: to-lit-word ">>>"
	_greater: to-lit-word ">"
	_less: to-lit-word "<"
	_noteql: to-lit-word "<>"
	_lesseql: to-lit-word "<="
	_greatereql: to-lit-word ">="
	lShift: ['left 'shift] ;to-lit-word "<<"
	
	
	;rules for string based parsing of paths
	ch_digits: charset "0123456789"
	ch_paren-start: charset "("
	ch_paren-end: charset ")"
	ch_parens: union ch_paren-start ch_paren-end
	ch_separator: charset [#"/" #"."]
	ch_label: complement union ch_separator ch_parens
	ch_content: complement ch_parens
	rl_path-expression: [ch_paren-start  any [ch_content | rl_path-expression] ch_paren-end]
	;---------------------------------------	
	recursion-depth:  0
	debug: none ; :print
	
	noFunc2?: true
	
	labels: 0
	break-labels: copy []
	
	flat-block: func["Makes from array of blocks a flat one" b [block!]][
		while [not tail? b][b: change/part b b/1 1]
		b: head b
	]
	
	
	localVars: copy []
	
	preloadVars: ["this" "arguments" "super" "_root" "_parent" "_global"]
	defineLocals: func[locals][
		if useRegisters? [
			print ["defineLocals:" mold localVars mold locals]
			insert/only tail localVars locals
		]
	]
	clearLocals: does [
		if useRegisters? [
			print ["clearLocals:" mold localVars]
			remove back tail localVars
		]
	]
	isLocal?: func[var][all [
		not empty? localVars
		find last localVars to-string var
	]]
	setLocal: func[var][
		error? try [if none? isLocal? var [insert tail last localVars form var]]
	]
	preloadVar?: func[var][
		either all [
			not empty? localVars
			find preloadVars var
		] [setLocal var true][false]
	]
	
	make-error!: func[errmsg pos][
		throw make error! reform [errmsg "^/** Code:" copy/part mold pos 100]
	]
	make-warning!: func[msg pos][
		print reform ["** WARNING:" msg "^/** Code:" copy/part mold pos 100]
	]
	
	useRegisters?: false
	
	#include %translate-fce.r
	
	translate: func [
		[catch]
	    code [block!]
	    /do-not-pop
	    /flat "returns result as a one block even if there is more of them"
	    /store "do not remove stored register so the value can be reused" 
	    /local
	    ; stack
	     expr codepos results mv1 mv2 mv3 pos
		pop
		push
		addPostAct
		addUnaryAct
		new-label
		count-str
		trans-SetWordOrMember
		trans-GetWordOrPath
		trans-paren
		trans-callFunction
		trans-if
		trans-either
		trans-switch
		trans-break
		trans-while
		trans-do-while
		trans-for
		trans-with
		trans-tellTarget
		trans-rejoin
		trans-func
		trans-func2
		trans-block
		trans-fscommand
		trans-make-object
		trans-poke
		trans-pick
	] [
		recursion-depth:  recursion-depth + 1
		;print ["^/PARSUJU VYRAZ:" mold code]
	
		if empty? code [return copy []]	
	    ; inicializace zásobníku
		results: copy []
		;stack:   copy []
		
	    set [
			pop
			push
			addPostAct
			addUnaryAct
			new-label
			count-str
			trans-SetWordOrMember
			trans-GetWordOrPath
			trans-paren
			trans-callFunction
			trans-if
			trans-either
			trans-switch
			trans-break
			trans-while
			trans-do-while
			trans-for
			trans-with
			trans-tellTarget
			trans-rejoin
			trans-func
			trans-func2
			trans-block
			trans-fscommand
			trans-make-object
			trans-poke
			trans-pick
    	] translate-functions
	
    	finishExpression: func[/local res p][
			;print ["FINISH" mold stack] 
			either error? try [res: pop][res: none][
				probe res
				if not empty? res [
					if none? store [
						p: last res
						switch p [
							aStoreSetGetVariable [change back tail res 'aSetVariable ]
							aStoreSetLocalGetVariable [change back tail res 'aDefineLocal ]
							aStoreSetGetMember   [change back tail res 'aSetMember   ]
							aStoreSetGetProperty [change back tail res 'aSetProperty ]
							
							aSetGetVariable      [change back tail res 'aSetVariable ]
							aSetLocalGetVariable [change back tail res 'aDefineLocal ]
							aSetGetMember        [change back tail res 'aSetMember   ]
							aSetGetProperty      [change back tail res 'aSetProperty ]
							aGetRegister         [clear back tail res]
						]
					]
					if all[
						not do-not-pop
						none? find [aSetVariable aSetMember aSetProperty aDefineLocal aDefineLocal2 aStop aReturn] last res
						none? find [end aJump aSetTarget] pick tail res -2
						'aGetURL <> pick tail res -3
					][
						insert tail res 'aPop
					]
				]
				either flat [
	    			insert tail results res
				][	insert/only tail results res ]
			]
			;probe res
			res
		]
	    ; funkce pro manipulaci se zásobníkem
		
		RESERVED-WORDS: [
			  'or | 'and | '= | '== | '!= | '!== | '** | '* | 'band | 'xor | '&& | '& | '|| | '.
			| slash | dslash | rShift | UrShift | _greater | _less | _noteql | _lesseql | _greatereql | lShift
			| 'func | 'while | 'do | 'if | 'else | 'foreach | 'for | 'switch | 'switch-default | 'make | 'new | 'fscommand
			| 'rejoin | 'reform | 'Modulo | 'InstanceOf | 'pick | 'poke | 'set | 'catch | 'throw
		]
		
	    ELEMENT: [
	    	pos: (debug ["....element?" mold pos])
	        set mv1 [integer! | string! | issue! | binary! | decimal! | tuple!] (push reduce [mv1] if string? mv1 [count-str mv1])
	        | set mv1 block! (push trans-block mv1)
	        | set mv1 date! (push trans-make-object 'Date mv1)
			| 'true  (push copy [true ])
			| 'false (push copy [false])
			| ['none | 'null] (push copy [#{02}])
			| 'undefined (push copy [#{03}])
			| 'newline (push copy ["^/"])
			| 'GetTime (push copy [aGetTime])
			| 'comment string!
			| set mv1 lit-word! (
				push reduce [
					either none? tmp: select local-constants to-word mv1 [
						make-warning! reform ["Unknown local constant [" mold mv1 "]"] pos
						#{03}
					][	tmp  ]
				]
			)
			| [
				set mv1 RESERVED-WORDS (
					make-error! reform ["Unrecognized/reserved word [" form mv1 "]"] pos
				)
	        	|
	        	 set mv1 [word! | path!] set mv2 opt [paren! | none] (
		        	either none? mv2 [
		        		push trans-GetWordOrPath mv1
		    		][	push trans-callFunction mv1 mv2 ]
		         )
	         ]
	        | set mv1 paren! ( push trans-paren mv1 )
			| 'stop (push copy [aStop])
			| 'play (push copy [aPlay])
			| set mv1 any-type?  (
				make-error! reform ["Unrecognized datatype [" form mv1 "]"] pos
			)
	    ]
	    
	    SETWORD: [
	    	(debug "....02 setword?")
	 	   	copy mv1 some ['var | set-word! | set-path!] ( push mv1
	 	   		;print ["!!!!!!!!!!" mold mv1]
	 	   		;push length? stack  push mv1
	 	   	) LOGICAL_OR ( trans-SetWordOrMember	)
		]
		
		IFRULE: [
			'if copy mv1 to block! set mv2 block! (
				;print ["======IF" mold stack]
				;either empty? stack [
			       push trans-if mv1 mv2
				;][	addUnaryAct trans-if mv1 mv2 ]
			)
			;any ['else IFRULE ]
			;(print ["-----if end?" mold stack])
		]
		
		EITHERRULE: [
			'either copy mv1 to block! set mv2 block! set mv3 block! (
				;print ["======EITHER" mold stack]
				;either empty? stack [
					       push trans-either mv1 mv2 mv3
				;][	addUnaryAct trans-either mv1 mv2 mv3 ]
			)
		]
	    ; right to left (p1)
	    UNARY: [
	    	pos: (debug ["....03 unary?" mold pos])
	    	  '- UNARY ( push head insert tail (insert pop [0]) 'aSubtract )
	    	| '+ UNARY ;;;no change
	        | 'random     UNARY (addUnaryAct 'aRandomNumber)  
			| ['not | '!] UNARY (addUnaryAct 'aNot)
			| 'eval       UNARY (addUnaryAct 'aGetVariable)
			| 'return     UNARY (addUnaryAct 'aReturn)
			| 'delete     UNARY (
				mv1: pop
				switch/default last mv1 [
					aGetVariable [change back tail mv1 'aDelete2]
				 	aGetMember   [change back tail mv1 'aDelete]
				][	insert tail mv1 'aDelete2 ]
				push head mv1 )
			| 'typeOf     UNARY (addUnaryAct 'aTypeOf)
			| 'to-integer UNARY (addUnaryAct 'aToInteger)
			| 'to-number  UNARY (addUnaryAct 'aToNumber)
			| 'to-string  UNARY (addUnaryAct 'aToString)
			| 'to-char    UNARY (addUnaryAct 'aAsciiToChar)
			| 'to-mbchar  UNARY (addUnaryAct 'aMBAsciiToChar)
			| 'to-ord     UNARY (addUnaryAct 'aCharToAscii)
			| 'to-mbord   UNARY (addUnaryAct 'aMBCharToAscii)
			| 'length?    UNARY (addUnaryAct 'aStringLength)
			| 'mblength?  UNARY (addUnaryAct 'aMBStringLength)
			| 'TargetPath UNARY (addUnaryAct 'aTargetPath)
			| ['make | 'new] set mv1 word! [set mv2 block! | set mv2 date! | copy mv2 opt [paren! | word! | string! | none]] (
				push trans-make-object mv1 mv2
			)
			| 'break ( push trans-break )
			| IFRULE
			| EITHERRULE
			| 'func set mv1 block! set mv2 block! (
				push either any [noFunc2? swf-version < 7] [trans-func mv1 mv2][trans-func2 mv1 mv2]
			)
			| ['switch | 'switch-default] copy mv1 to block! set mv2 block! set mv3 block! (trans-switch/default mv1 mv2 mv3)
			| 'switch copy mv1 to block! set mv2 block! (push trans-switch mv1 mv2)
			| 'while set mv1 block! set mv2 block! (push trans-while mv1 mv2)
			| 'do set mv1 block! 'while set mv2 block! (push trans-do-while mv1 mv2)
			| 'for set mv1 word!
				  copy mv2 [number! | word! | paren!]
				  copy mv3 [number! | word! | paren!]
				  set  mv4 number! ;[number! | word! | paren!]
				  set  mv5 block! (push trans-for mv1 mv2 mv3 mv4 mv5)
			;| 'for opt ['var (local?: true) ] set v word! 'in set v2 word! set v3 block! (
			;	trans-for-in v v2 v3
			;)
			;| 'foreach set v [word! | block!] set v2 [word! | path!] set v3 block! (
			;	trans-foreach v v2 v3
			;)
			| 'with copy mv1 to block! set mv2 block! (push trans-with mv1 mv2)
			| 'tellTarget copy mv1 to block! set mv2 block! (push trans-tellTarget mv1 mv2)
			| 'rejoin set mv1 block! (push trans-rejoin mv1)
			| 'reform set mv1 block! (push trans-rejoin/with mv1 " ")
			| 'fscommand set mv1 block! (push trans-fscommand mv1)
			| 'nextFrame (push copy [aNextFrame])
			| 'previousFrame (push copy [aPrevFrame])
			| 'toggleQuality (push copy [aToggleQuality])
			| 'stopSounds (push copy [aStopSounds])
			| 'poke copy mv1 [word! | paren! | path!] copy mv2 any-type! copy mv3 any-type! (push trans-poke mv1 mv2 mv3)
			| SETWORD
			| ELEMENT
	
		]
	    ; umocòování a vyšší
	    ; right to left (2)
	    POW: [
	    	pos: (debug ["....04 pow?" mold pos])
	        UNARY any [
	        	'** POW (
	        		addPostAct [2 "Math" aGetVariable "pow" aCallMember]
	        	)
	        ]
	    ]
	
	    MULTIPLICATIVE: [
	    	pos: (debug ["....05 multiplicative?" mold pos])
	    	'Modulo POW POW (addPostAct 'aModulo)
	    	| POW any [
	              '*    POW ( addPostAct 'aMultiply )
	            | slash POW ( addPostAct 'aDivide)
	        ]
	    ]
	    
	    ADDITIVE: [
	    	pos: (debug ["....06 aditive?" mold pos])
			MULTIPLICATIVE any [
				  '+ MULTIPLICATIVE ( addPostAct 'aAdd )
				| '- MULTIPLICATIVE ( addPostAct 'aSubtract )
				| ['add | '.] MULTIPLICATIVE (addPostAct 'aStringAdd)
	        ]
		]
		
		BITWISE_SHIFT: [
			(debug "....07 bshift?")
			ADDITIVE any [
				  rShift  ADDITIVE (addPostAct 'aBitRShift)
				| lShift  ADDITIVE (addPostAct 'aBitLShift)
				| UrShift ADDITIVE (addPostAct 'aBitURShift)
			]
		]
		
		RELATIONAL: [
			(debug "....08 relational")
			BITWISE_SHIFT opt [
				  _less       BITWISE_SHIFT (addPostAct 'aLess)
				| _greater    BITWISE_SHIFT (addPostAct 'aGreater)
				| _lesseql    BITWISE_SHIFT (addPostAct 'aLessEquals)
				| _greatereql BITWISE_SHIFT (addPostAct 'aGreaterEquals)
				| 'InstanceOf BITWISE_SHIFT (addPostAct 'aInstanceOf) 
			]
		]
		
		EQUALITY: [
			(debug "....09 equality?")
			RELATIONAL any [
				  ['= | '==]      RELATIONAL (addPostAct 'aEquals)
				| ['!= | _noteql] RELATIONAL (addPostAct [aEquals aNot])
				| '===            RELATIONAL (addPostAct 'aStrictEquals)
				| '!==            RELATIONAL (addPostAct [aStrictEquals aNot])
			]
		]
		BITWISE_AND: [EQUALITY    any [ ['& | 'band]  EQUALITY    (addPostAct 'aBitAnd) ]]
		BITWISE_XOR: [BITWISE_AND any [ 'xor          BITWISE_AND (addPostAct 'aBitXor) ]]
		BITWISE_OR:  [BITWISE_XOR any [ '|            BITWISE_XOR (addPostAct 'aBitOr)  ]]
		LOGICAL_AND: [BITWISE_OR  any [ ['&& | 'and]  BITWISE_OR  (addPostAct 'aAnd)    ]]
		LOGICAL_OR:  [LOGICAL_AND any [ ['|| | 'or]   LOGICAL_AND (addPostAct 'aOr)     ]]
	
		EXPRESSION: [
	    	LOGICAL_OR (
	    		;print ["SEQ1" mold stack]
	    		finishExpression ) any [ LOGICAL_OR (
	    			;print ["SEQ2" mold stack]
	    			finishExpression ) ] end 
	    	| pos:
	        (
	        	;print ["!!!!!!!!! invalid expression !!!!!!!!!!!!"]
	        	;print ["pos: " mold pos]
	        	;print ["stack: " mold stack]
	        	make-error! "Invalid expression" pos
	        )
		]
	
		parse code EXPRESSION
	
		;probe stack
		;either flat [
		;	print ["VYSLEDEK" mold results]
		;][
		;    forall results [
		;    	print ["VYSLEDEK" index? results mold results/1]
		;	]
		;]
		recursion-depth:  recursion-depth - 1
	    head results
		
	]
	
	translate-value: func[value errname /local value-translated][
		value-translated: translate/flat/store value
		either 'aPop = last value-translated [
			head remove back tail value-translated
		][
			make-error! reform [errname " has no value"] pos
		]
	]
	
	push-str-value: func[v /local p r][
		;print ["pushstr" mold v mold constantPool]
		either none? p: find/case constantPool v [
			if all [swf-version > 5 utf8-encode?][v: utf8-encode v]
			rejoin [#{00} v #{00}]
		][
			rejoin either (v: (-1 + index? p)) > 255 [
				[#{09} int-to-ui8 v]
			][	[#{08} int-to-ui8 v] ]
		]
	]
	
	form-push-values: func[values /local v result][
		;print ["form-push-values:" mold values ]
		result: make binary! 200
		parse values [some [
			  set v integer! (insert tail result either v = 0 [#{060000000000000000}][join #{07} int-to-ui32 v])
			| set v decimal! (insert tail result join #{06} to-ieee64/flash v)
			| set v string!  (insert tail result push-str-value v)
			| set v logic!   (insert tail result join #{05} either v [#{01}][#{00}])
			| set v binary!  (insert tail result v)
			| set v tuple!   (
				insert tail result  either 2147483647 < v: tuple-to-decimal v [
					join #{06} to-ieee64/flash v
				][
					rejoin [#{07} int-to-ui32 v ]
				]
			)
			| set v issue! (
				insert tail result  either 2147483647 < v: issue-to-decimal v [
					join #{06} to-ieee64/flash v
				][
					rejoin [#{07} int-to-ui32 v ]
				]
			)
			| 'true  (insert tail result #{0501})
			| 'false (insert tail result #{0500})
			| 'none  (insert tail result #{0000})
			| 'null  (insert tail result #{02})
			;| 'undefined  (insert tail result #{03})
			| 'aGetRegister set v string! (
				
				if error? try [insert tail result join #{04} int-to-ui8 index? find last registers v][
					print ["!!!" mold v mold registers]
					halt
				]
			)
			| set v any-type! (insert tail result push-str-value to string! v)
		]]
		result
	]
	
	registers: copy []	
	
	set 'compile-actions func[
		[catch]
		code
		/local mv1 tmp bytecode translated label pos
	][
	
	
		if empty? code [ return copy #{} ]
		labels: with-depth: 0
		break-labels: copy []
		clear registers
		bytecode: make binary! 10000
		used-strings: make hash! 400
		
		append-action-tag: func[id [binary!] data [binary! string!]][
			insert tail bytecode rejoin [id int-to-ui16 length? data data]
		]
		translated: translate/flat code
		debug ["TRANSLATED:" mold translated]
		;used-strings: sort/skip/compare/reverse to-block used-strings 2 2
		;print ["used-strings:" mold used-strings]
		
		branchesToSet:  copy []
		branchesLabels: make hash! 30
		clear constantPool
		
		if all [
			useConstantPool?
			swf-version > 4
			not empty? used-strings
			used-strings/2 > 1
		][
			;prepare constant pool
			if 131070 < length? used-strings [;maximum is 65535 constants in pool
				used-strings: copy/part used-strings 131070
			]
			use [cp][
				cp: make binary! 1000
				foreach [string count] used-strings [
					;if none? find ["this" "_global" "_super"] string [
						insert tail constantPool string
						insert tail cp join either all [swf-version > 5 utf8-encode?][utf8-encode string][string] #"^@"
					;]
				]
				append-action-tag #{88} rejoin [int-to-ui16 (length? used-strings) / 2 cp]
			]
		]
		
		debug ["constantPool:" mold constantPool]
	
		
		
		parse translated [
			any [
				pos:
				  'aIf set mv1 word! (
				  	insert tail bytecode #{9D02000000}
				  	;print ["--aIf:" mold mv1]
				  	repend branchesToSet [length? bytecode mv1]
				  )
				| ['end | 'label | 'endFunc2 (remove back tail registers)] set mv1 word! (
					;print ["--end:" mold mv1]
					repend branchesLabels [mv1 length? bytecode])
				| 'aJump set mv1 word! (
					insert tail bytecode #{9902000000}
					;print ["--aJumpd:" mold mv1]
				  	repend branchesToSet [length? bytecode mv1]
				)
				| 'aWith set mv1 word! (
					insert tail bytecode #{9402000000}
					;print ["--width:" mold mv1]
				  	repend branchesToSet [length? bytecode mv1]
				)
				| 'aAdd    (insert tail bytecode either swf-version > 4 [#{47}][#{0A}])
				| 'aLess   (insert tail bytecode either swf-version > 4 [#{48}][#{0F}])
				| 'aEquals (insert tail bytecode either swf-version > 4 [#{49}][#{0E}])
				| 'aLessEquals (	
					insert tail bytecode either swf-version > 5 [#{6712}][
						either swf-version = 5 [#{4D4812}][
							;using ActionStackSwap for SWF5 to swap the order of argument and ActionLess
							;for SWF4 I'm not going to support this as I would have to swap args during translation,
							;do I really need this? No
							make-error! "The LessOrEqual (<=) action is not supported for SWF4" pos
						]
					]		
				)
				| 'aSetRegister set mv1 string! (
					if error? try [
						insert tail bytecode rejoin [#{870100} int-to-ui8 index? find last registers mv1]
					][	print ["!!!!!:" mold mv1 mold registers]]
					)
				| 'aGreaterEquals (insert tail bytecode either swf-version > 4 [#{4812}][#{0F12}])
				| 'aStoreSetGetVariable (insert tail bytecode #{87010000 1D 9602000400})
				| 'aSetGetVariable      (insert tail bytecode #{1D 9602000400})
				| 'aStoreSetGetMember   (insert tail bytecode #{87010000 4F 9602000400})
				| 'aStoreSetGetProperty (insert tail bytecode #{87010000 23 9602000400})
				| 'aSetGetMember        (insert tail bytecode #{4F 9602000400})
				| 'aSetTarget set mv1 string! (append-action-tag #{8B} join mv1 #{00} )
				| 'aFunc set mv1 string! set mv2 integer! set mv3 string! set mv4 word! (
					append-action-tag #{9B} rejoin [as-binary mv1 #{00} int-to-ui16 mv2 mv3 #{0000}]
					;print ["--aFunc:" mold mv1]
					repend branchesToSet [length? bytecode mv4]
				)
				| 'aFunc2 set mv1 string! set mv2 integer! set mv3 block! set mv4 word! (
					use [flags f preload params n][
						preload: copy []
						flags: 42 ;to-integer reverse 2#{0010101000000000}
						foreach var preloadVars [
							if not none? f: find mv3 var [
								remove f
								insert tail preload var
								switch var [
									"this"      [flags: (flags and 253) or 1 ]
									"arguments" [flags: (flags and 247) or 8 ]
									"super"     [flags: (flags and 223) or 32]
									"_root"     [flags:  flags or 64]
									"_parent"   [flags:  flags or 128]
									"_global"   [flags:  flags or 256]
								]
							]
						]
						
						n: length? preload
						params: make binary! 100
						while [not tail? mv3][
							n: n + 1
							if error? try [
								insert tail params rejoin [int-to-ui8 n as-binary first mv3 #{00}]
							][
								probe mv3
								halt
							]
							mv3: next mv3
						]
						mv3: head mv3
						insert/only tail registers (head insert tail preload head mv3)
						append-action-tag #{8E} rejoin [
							as-binary mv1 #{00}
							int-to-ui16 mv2
							int-to-ui8  1 + length? mv3
							int-to-ui16 flags
							params
							#{0000}
						]
						repend branchesToSet [length? bytecode mv4]
					]
				)
				| 'aGetURL set mv1 string! set mv2 string! (
					append-action-tag #{83} rejoin [ mv1 #"^@" mv2  #"^@"]
				)
				|
				copy mv1 some [
					string! | number! | tuple! | hash! | issue! | 'true | 'false | 'null | 'undefined | 'none | binary!
					| 'aGetRegister string! 
				] (
					either swf-version > 4 [ 
						append-action-tag #{96} form-push-values mv1
					][
						forall mv1 [
							append-action-tag #{96} form-push-values reduce [mv1/1]
						]
					]
				)
				|
				set mv1 word! (
					either none? tmp: select actionIds mv1 [
						print ["!!Unknown action:" mv1 "^/!!near:" copy/part mold pos 100]
					][	insert tail bytecode tmp ]
				)
				| any-type! (
					make-error! "Compile error" pos
				)
			]
		]
		
		;print ["=== fixing brachnes ==="]
		;print ["branchesToSet: " mold branchesToSet]
		;print ["branchesLabels:" mold branchesLabels] 
		
		foreach [pos label ] branchesToSet [
			;print ["---" pos label]
			change/part (at bytecode (pos - 1)) (int-to-ui16 ((select branchesLabels label) - pos )) 2
		]
	
		;insert tail bytecode #{00}
		
		debug ["RESULT:" mold bytecode]
		bytecode
	]

	set 'test func[code][
		probe x: compile-actions code
		rswf/parse-ActionRecord x
	]
]
;test [a: 1 + b]


;translate [x: 1 + 23 + random 10]
;translate [x: 1 * (y: 23 + 2)]
;translate [x: 1 + 2 < 3]
;translate [x: 1 + y: 2 + 3]
;translate [1 + 2]
;translate [x: 1 + a.b]


