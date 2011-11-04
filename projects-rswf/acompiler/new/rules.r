REBOL [
	title: "ACompiler parse rules"
]
RESERVED-WORDS: [
	  'or | 'and | '= | '== | '!= | '!== | '** | '* | 'band | 'xor | '&& | '& | '|| | '.
	| slash | dslash | rShift | UrShift | _greater | _less | _noteql | _lesseql | _greatereql | lShift
	| 'func | 'while | 'do | 'if | 'else | 'foreach | 'for | 'switch | 'switch-default | 'make | 'new | 'fscommand
	| 'rejoin | 'reform | 'Modulo | 'InstanceOf | 'pick | 'poke | 'set | 'catch | 'throw | 'StopDrag | 'if | 'either | 'case
	| 'goto | 'gotoLabel | 'gotoFrame | 'stop | 'date? | 'string? | 'MovieClip? | 'block? | 'color? | 'sound? | object?
	| 'on | 'off | 'true | 'false | 'integer? | 'number? | 'logic? | 'function? | 'loop | 'repeat | 'any | 'all
]	
ELEMENT: [
	pos: (debug ["....element?" mold pos])
    set mv1 [integer! | string! | issue! | binary! | decimal! | tuple! | file!] (push reduce [mv1]) ;was: if string? mv1 [count-str mv1])
    | 'rebol set mv1 block! set mv2 opt [block! | none] (
    	unless mv2 [mv2: copy []]
    	push translate-value reduce [(use mv2 mv1)] "REBOL include"
    )
    | set mv1 block! (push trans-block mv1)
    | set mv1 date! (push trans-make-object 'Date mv1)
	| ['true  | 'on ] (push copy [true ])
	| ['false | 'off] (push copy [false])
	| ['none | 'null] (push copy [#{02}])
	| 'undefined (push copy [#{03}])
	| 'newline (push copy ["^/"])
	| 'GetTime (push copy [aGetTime])
	| 'comment string!
	| 'StopDrag (push copy [aEndDrag])
	| 'poke copy mv1 [word! | paren! | path!] copy mv2 any-type! copy mv3 any-type! (push trans-poke mv1 mv2 mv3)
	| 'pick copy mv1 any-type! copy mv2 any-type! (push trans-pick mv1 mv2)
	| set mv1 lit-word! (
		push reduce [
			either none? tmp: select local-constants to-word mv1 [
				make-warning! reform ["Unknown local constant [" mold mv1 "]"] pos
				#{03}
			][	tmp  ]
		]
	)
	| 'all set mv1 block! ( push trans-all mv1 )
	| 'any set mv1 block! ( push trans-any mv1 )
	| 'set 'color set mv1 word! opt ['to] set mv2 tuple! (
	  		make-error! "set Color not supported anymore" pos
		;	form-act-tag #{96} rejoin [
		;		#{07} reverse to binary! v2 #{00070100000000} v #{00}
		;	]
		;	ins-act #{1C}
		;	form-act-tag #{96} #{0073657452474200}
		;	ins-act #{5217}
		;)
		;]
	   	)
	   	| 'trace set mv1 paren! (
	   		if trace? [
	   			switch/default trace? [
	   				cmsg [
	   					push trans-callFunction 'cmsg to-paren reduce [to-paren reduce ['reform to-block mv1]]
   					]
				][
	   				push join trans-paren to-paren reduce ['reform to-block mv1] 'aTrace
   				]
	   			
	   		]
	   	)
	| [
		set mv1 RESERVED-WORDS (
			make-error! reform ["Unrecognized/reserved word [" form mv1 "]"] pos
		)
    	|
    	 set mv1 [word! | path! | get-word!] set mv2 opt [paren! | none] (
        	either none? mv2 [
        		push trans-GetWordOrPath mv1
    		][	push trans-callFunction mv1 mv2 ]
         )
     ]

    | set mv1 paren! ( push trans-paren mv1 )
	| set mv1 any-type?  (
		make-error! reform ["Unrecognized datatype [" form mv1 "]"] pos
	)
]

SETWORD: [
	(debug "....02 setword?")
	   	  copy mv1 some ['var | set-word! | set-path!] ( push mv1 ) LOGICAL_OR ( trans-SetWordOrMember )
	   	| 'set set mv1 block! opt '= (push translate/do-not-pop mv1 "SET variable" mv1)  LOGICAL_OR (trans-SetEvalWord)
	   	| 'set set mv1 lit-word! set mv2 any-type! (setLocalConstant to-word mv1 mv2)
]

IFRULE: [
	'if copy mv1 to block! set mv2 block! opt [(mv3: none) 'else copy mv3 thru block!] (
		;print ["======IF" mold stack]
		;either empty? stack [
		push either none? mv3 [
			trans-if mv1 mv2
		][	trans-either mv1 mv2 mv3 ]
		;][	addUnaryAct trans-if mv1 mv2 ]
	)
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

CASERULE: [
	'case set mv1 block! (push trans-case mv1)
	|
	'case/all set mv1 block! (push trans-case/all mv1)
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
	| set mv1 ['string? | 'integer? | 'number? | 'logic? | 'object?  | 'function? | 'MovieClip?]
		(push mv1)
	    UNARY (
	    	mv1: pop 
	    	mv2: pop
	    	push append mv1 'aTypeOf
	    	addUnaryAct reduce [(select [
			string?    "string"
			function?  "function"
			integer?   "number"
			number?    "number"
			logic?     "boolean"
			object?    "object"
			MovieClip? "movieclip"
		] mv2) 'aEquals]
	)
	| set mv1 ['date? | 'block? | 'color? | 'sound?]
		(push mv1)
	    UNARY (
	    	mv1: pop 
	    	mv2: pop
	    	push mv1
	    	addUnaryAct reduce [(select [
				date?      "Date"
				block?     "Array"
				color?     "Color"
				sound?     "Sound"
				
			] mv2) 'aGetVariable 'aInstanceOf]
	)
	| 'context set mv2 block! ( push trans-make-object 'object! mv2	)
	| ['make | 'new] set mv1 word! [set mv2 block! | set mv2 date! | copy mv2 opt [paren! | word! | string! | none]] (
		push trans-make-object mv1 mv2
	)
	| 'break    ( push trans-break )
	| 'continue ( push trans-continue )
	| IFRULE
	| EITHERRULE
	| CASERULE
	| 'func set mv1 block! set mv2 block! (
		push either any [noFunc2? swf-version < 7 find mv2 'with] [trans-func mv1 mv2][trans-func2 mv1 mv2]
	)
	| 'does set mv1 block! (
		push either any [noFunc2? swf-version < 7  find mv1 'with] [trans-func copy [] mv1][trans-func2 copy [] mv1]
	)
	| 'class opt [(mv2: none) 'extends set mv2 word!] set mv1 block! (push trans-class mv1 mv2)
	| 'extends set mv2 word! set mv1 block! (push trans-class mv1 mv2)
	| ['switch | 'switch-default] copy mv1 to block! set mv2 block! set mv3 block! (push trans-switch/default mv1 mv2 mv3)
	| 'switch copy mv1 to block! set mv2 block! (push trans-switch mv1 mv2)
	| 'while set mv1 block! set mv2 block! (push trans-while mv1 mv2)
	| 'do set mv1 block! 'while set mv2 block! (push trans-do-while mv1 mv2)
	| 'for set mv1 word!
		  copy mv2 [number! | word! | paren!]
		  copy mv3 [number! | word! | paren!]
		  set  mv4 number! ;[number! | word! | paren!]
		  set  mv5 block! (push trans-for mv1 mv2 mv3 mv4 mv5)
	| 'for (mv4: false) opt ['var (mv4: true)] copy mv1 [word! | paren!] 'in copy mv2 [word! | paren!] set mv3 block! (
		;make-warning! "FOR..IN is not well tested yet!" pos
		push trans-for-in mv1 mv2 mv3 mv4
	)
	| 'foreach set v [word! | block!] copy v2 to block! set v3 block! (
		push trans-foreach v v2 v3
	)
	| 'repeat set v word! copy v2 to block! set v3 block! (
		push trans-repeat v v2 v3
	)
	| 'loop copy v to block! set v2 block! (
		push trans-loop v v2
	)
	| 'with copy mv1 to block! set mv2 block! (push trans-with mv1 mv2)
	| 'tellTarget copy mv1 to block! set mv2 block! (push trans-tellTarget mv1 mv2)
	| 'rejoin set mv1 block! (push trans-rejoin mv1)
	| 'reform set mv1 block! (push trans-rejoin/with mv1 " ")
	| 'fscommand set mv1 block! (push trans-fscommand mv1)
	| 'LoadMovie
		set mv1 [string! | url! | file! | word!]
		opt ['to | 'into]
		set mv2 [string! | word! | path!] (mv3: 'none)
		opt [opt ['method]
		set mv3 ['post | 'get]] (
			;push trans-loadmovie mv1 mv2 mv3
			make-warning! "loadMovie not supported anymore use target.loadMovie(url) instead" pos
		)
	| 'GotoFrame set mv1 integer! (push reduce ['aGotoFrame  mv1])
	| 'GotoLabel set mv1 string!  (push reduce ['aGotoLabel  mv1])
	| ['GotoFrame2 | 'goto opt ['frame] ] set mv1 [integer! | word! | string!] opt ['and] set mv2 ['play | none] (
		if word? mv1 [
			mv1: either none? mv3: select rswf/names-ids-table mv1 [
				make-warning! reform ["Unknown frame [" mold mv1 "]"] pos
				form mv1
			][	mv3 ]
		]
		push reduce [mv1 'aGotoFrame2 either none? mv2 ['stop]['play] ]
	)
	| set mv1 [
		;if there is a paren after these words, compile them as functions
		;even that these are reserver dialect words
		'stop | 'play | 'nextFrame | 'prevFrame | 'previousFrame |
		'toggleQuality | 'stopSounds
	] set mv2 paren! (
			push trans-callFunction mv1 mv2
	)
	| 'stop (push copy [aStop])
	| 'play (push copy [aPlay])
	| 'nextFrame (push copy [aNextFrame])
	| ['previousFrame | 'prevFrame] (push copy [aPrevFrame])	
	| 'toggleQuality (push copy [aToggleQuality])
	| 'stopSounds (push copy [aStopSounds])
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
		finishExpression) any [ LOGICAL_OR (
			;print ["SEQ2" mold stack]
			finishExpression) ] end 
	| pos:
    (
    	;print ["!!!!!!!!! invalid expression !!!!!!!!!!!!"]
    	;print ["pos: " mold pos]
    	;print ["stack: " mold stack]
    	make-error! "Invalid expression" pos
    )
]