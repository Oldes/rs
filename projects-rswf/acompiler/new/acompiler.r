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
    	rs-project 'utf8-cp1250
		;rs-project 'utf-8
		;rs-project 'ieee
	]
	preprocess: true

]


;utf8-encode: func[
; 	"Encodes the string data to UTF-8"
;	str [any-string!] "string to encode"
;	/local c
;][
;	utf-8/encode-2 ucs2/encode str
;]

acompiler: context [

	;#include %conversions.r
	#include %actionids.r
	
	utf8-encode?: true
	swf-version: 8
	;used-strings: make hash! 400
	constantPool: copy []
	strConstantPool: copy []
	useConstantPool?:  true ;false ;true
	
	noFunc2?: true useRegisters?: false
	;noFunc2?: false useRegisters?: true
	
	trace?:   true ;turn off to disable inserting trace function calls
		
	slash:    to-lit-word first [/]
	dslash:   to-lit-word "//"
	rShift:   to-lit-word ">>"
	UrShift:  to-lit-word ">>>"
	_greater: to-lit-word ">"
	_less:    to-lit-word "<"
	_noteql:  to-lit-word "<>"
	_lesseql: to-lit-word "<="
	_greatereql: to-lit-word ">="
	lShift: ['left 'shift] ;to-lit-word "<<"
	
	
	;rules for string based parsing of paths
	ch_digits:      charset "0123456789"
	ch_paren-start: charset "("
	ch_paren-end:   charset ")"
	ch_parens:      union ch_paren-start ch_paren-end
	ch_separator:   charset [#"/" #"."]
	ch_label:       complement union ch_separator ch_parens
	ch_content:     complement ch_parens
	rl_path-expression: [ch_paren-start  any [ch_content | rl_path-expression] ch_paren-end]
	;---------------------------------------	
		
	debug:  none ;:print
	
	labels: 0
	with-depth: 0 ;used to know, if we are inside 'with' block
	telltarget-depth: 0 ;used to know, if we are inside 'tellTarget' block
	break-labels: copy []
	
	flat-block: func["Makes from array of blocks a flat one" b [block!]][
		while [not tail? b][b: change/part b b/1 1]
		b: head b
	]
	
	setLocalConstant: func[constant [word!] value /local f][
		;print ["setLocalConstant:" constant mold value]
		change/only any [
	        find/skip/tail local-constants constant 2
	        insert tail local-constants constant
	    ] :value
	]
	
	localVars: copy []
	
	preloadVars: ["this" "arguments" "super" "_root" "_parent" "_global"]
	defineLocals: func[locals][
		if useRegisters? [
			;print ["defineLocals:" mold localVars mold locals]
			insert/only tail localVars locals
		]
	]
	clearLocals: does [
		if useRegisters? [
			;print ["clearLocals:" mold localVars]
			remove back tail localVars
		]
	]
	setRegister: func[reg][
		either empty? registers [
			insert/only registers reduce [reg]
		][
			unless find last registers reg [insert tail last registers reg]
		]
		reg
	]
	isLocal?: func[var][all [
		not empty? localVars
		find last localVars to-string var
	]]
	setLocal: func[var][
		error? try [unless isLocal? var [insert tail last localVars form var]]
	]
	preloadVar?: func[var][
		either all [
			telltarget-depth = 0
			with-depth = 0
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
	
    ; funkce pro manipulaci se zásobníkem
    push: func ["pøidej na zásobník" mv] [
    	;print ["PUSH" mv]
    	insert/only tail stack mv]
    pop: func ["vyber ze zásobníku" /local vysl] [
        vysl: last stack
        clear back tail stack
       ; print ["POP" vysl "stack:" mold stack]
        vysl
    ]

	finishExpression: func[/local res][
		either error? try [res: pop][res: none][
			;print ["finish:" mold res]
			unless empty? res [
				unless store [
					switch last res [
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
				unless any [
					do-not-pop
					find [aSetVariable aSetMember aSetProperty aDefineLocal aDefineLocal2 aStop aReturn aPop] last res
					find [end aJump aSetTarget] pick tail res -2
					'aGetURL = pick tail res -3
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
    addPostAct: func[Act /local mv1][
    	;print ["addPostAct" mold act mold stack]
    	mv1: pop
	    insert insert tail last stack mv1 act
	   ; print ["addPostAct=" mold stack]
	]
	addUnaryAct: func[Act][
		;print ["addUnaryAct:" mold stack]
	    insert tail last stack Act
	  ;  print ["addUnaryAct=" mold stack]
	]
	
	new-label: does[ to-word join "L" labels: labels + 1]
	
	;count-str: func[str /local n][
	;	either n: find/tail/case used-strings str [
	;		change n (n/1 + 1)
	;	][	repend used-strings [str 1] ]
	;	str
	;]
	#include %rules.r
	#include %trans-functions.r
		    
	translate: func [
		[catch]
	    code [block!]
	    /do-not-pop
	    /flat "returns result as a one block even if there is more of them"
	    /store "do not remove stored register so the value can be reused" 
	    /local
	     stack
	     expr codepos results mv1 mv2 mv3 pos
	] [
		;print ["^/PARSUJU VYRAZ:" mold code]
	
		if empty? code [return copy []]	
	    ; inicializace zásobníku
	    stack:   copy []
	    results: copy []

	    bind second :push 'stack
	    bind second :pop  'stack
	    bind second :finishExpression 'stack
	    bind second :addPostAct  'stack
	    bind second :addUnaryAct 'stack
	    bind second :new-label   'stack
	   ; bind second :count-str   'stack
		bind second :trans-poke  'stack
		bind second :trans-pick  'stack
		bind second :trans-class 'stack
		bind second :trans-callFunction 'stack
		bind second :trans-paren       'stack
		bind second :trans-if          'stack
		bind second :trans-either      'stack
		bind second :trans-case        'stack
		bind second :trans-switch      'stack
		bind second :trans-break       'stack
		bind second :trans-continue    'stack
		bind second :trans-while       'stack
		bind second :trans-do-while    'stack
		bind second :trans-for         'stack
		bind second :trans-for-in      'stack
		bind second :trans-foreach     'stack
		bind second :trans-loop        'stack
		bind second :trans-with        'stack
		bind second :trans-tellTarget  'stack
		bind second :trans-rejoin      'stack
		bind second :trans-func        'stack
		bind second :trans-func2       'stack
		bind second :trans-block       'stack
		bind second :trans-fscommand   'stack
		bind second :trans-make-object 'stack
		bind second :trans-loadmovie 'stack
		bind second :trans-any 'stack
		bind second :trans-all 'stack

		bind second :trans-SetWordOrMember 'stack
		bind second :trans-SetEvalWord     'stack
		bind second :trans-GetWordOrPath   'stack
	    bind [
	    	ELEMENT RESERVED-WORDS EXPRESSION LOGICAL_OR
	    	LOGICAL_AND BITWISE_OR BITWISE_XOR BITWISE_AND
	    	EQUALITY RELATIONAL BITWISE_SHIFT
	    	ADDITIVE MULTIPLICATIVE POW UNARY EITHERRULE IFRULE SETWORD
	    ] 'stack
		parse code EXPRESSION
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
		
		if all [utf8-encode? swf-version > 5 ][v: utf8/encode v]
		;print ["pushstr" mold v mold strConstantPool]
		
		either all [
			useConstantPool?
			swf-version > 4
		][
			either p: find/case strConstantPool v [
				p: -1 + index? p
			][
				p: length? strConstantPool
				append strConstantPool v
			]
			rejoin either p > 255 [
				[#{09} int-to-ui16 p]
			][	[#{08} int-to-ui8 p] ]
		][
			rejoin [#{00} v #{00}]
		]
	]
	
	form-push-values: func[values /local v result][
		;print ["form-push-values:" mold values ]
		result: copy #{}
		parse values [some [
			  set v integer! (insert tail result either v = 0 [#{060000000000000000}][join #{07} int-to-ui32 v])
			| set v decimal! (insert tail result join #{06} to-ieee64f v)
			| set v string!  (insert tail result push-str-value v)
			;| set v string!  (insert tail result push-str-value as-string v)
			| set v logic!   (insert tail result join #{05} either v [#{01}][#{00}])
			| set v binary!  (insert tail result v)
			| set v tuple!   (
				insert tail result  either 2147483647 < v: tuple-to-decimal v [
					join #{06} to-ieee64f v
				][
					rejoin [#{07} int-to-ui32 to integer! v ]
				]
			)
			| set v issue! (
				insert tail result  either 2147483647 < v: issue-to-decimal v [
					join #{06} to-ieee64f v
				][
					rejoin [#{07} int-to-ui32 to integer! v ]
				]
			)
			| 'true  (insert tail result #{0501})
			| 'false (insert tail result #{0500})
			| 'none  (insert tail result #{0000})
			| 'null  (insert tail result #{02})
			;| 'undefined  (insert tail result #{03})
			| 'aGetRegister set v string! (
				
				if error? try [insert tail result join #{04} int-to-ui8 index? find last registers v][
					print ["!!! aGetRegister not found !!!" mold v mold registers]
					halt
				]
			)
			| set v any-type! (insert tail result push-str-value to string! v)
		]]
		result
	]
	
	get-CP-tag: has[constantPool tmp] [
		constantPool: make binary! 10000
		foreach string acompiler/strConstantPool [
			insert tail constantPool abin [string #"^@"]
		]
		constantPool: abin [
			#{88}
			int-to-ui16 length? tmp: abin [int-to-ui16 length? acompiler/strConstantPool constantPool]
			tmp
		]
		clear acompiler/strConstantPool
		constantPool
	]
	
	registers: copy []	
	;ttxt: 0
	
	
	append-action-tag: func[id [binary!] data [binary! string!]][
		insert tail bytecode rejoin [id int-to-ui16 length? data data]
	]
	
	compile-rules: [
		any [
			pos:
			copy mv1 some [
				string! | number! | tuple! | hash! | issue! | 'true | 'false | 'null | 'undefined | 'none | binary! | file!
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
				if empty? registers [insert/only registers reduce [mv1]]
				if error? set/any 'err try [
					insert tail bytecode rejoin [
						#{870100}
						int-to-ui8 either tmp: find last registers mv1 [index? tmp][
							insert tail last registers mv1
							length? last registers
						]
					]
				][
					print ["!!!!!:" mold mv1 mold registers]
					probe disarm err
				]
				)
			| 'aGreaterEquals (insert tail bytecode either swf-version > 4 [#{4812}][#{0F12}])
			| 'aStoreSetGetVariable (insert tail bytecode #{87010000 1D 9602000400})
			| 'aStoreSetLocalGetVariable (insert tail bytecode #{87010000 3C 9602000400})
			| 'aSetLocalGetVariable (insert tail bytecode #{3C 9602000400})
			| 'aSetGetVariable      (insert tail bytecode #{1D 9602000400})
			| 'aStoreSetGetMember   (insert tail bytecode #{87010000 4F 9602000400})
			| 'aSetGetMember        (insert tail bytecode #{4F 9602000400})
			| 'aStoreSetGetProperty (insert tail bytecode #{87010000 23 9602000400})
			| 'aSetGetProperty        (insert tail bytecode #{23 9602000400})
			| 'aSetTarget set mv1 string! (append-action-tag #{8B} join mv1 #{00} )
			| 'aGotoFrame set mv1 integer! (insert tail bytecode rejoin [#{810200} int-to-ui16 mv1])
			| 'aGoToLabel set mv1 string! (append-action-tag #{8C} join mv1 #{00})
			| 'aGotoFrame2 set mv1 ['stop | 'play] (append-action-tag #{9F} either mv1 = 'stop [#{00}][#{01}])
			| 'aFunc set mv1 string! set mv2 integer! set mv3 string! set mv4 word! (
				append-action-tag #{9B} rejoin [as-binary mv1 #{00} int-to-ui16 mv2 mv3 #{0000}]
				;print ["--aFunc:" mold mv1]
				repend branchesToSet [length? bytecode mv4]
			)
			| 'aFunc2 set mv1 string! set mv2 block! set mv3 block! set mv4 word! (
				use [flags f preload params n][
					preload: copy []
					flags: 42 ;to-integer reverse 2#{0010101000000000}
					foreach var preloadVars [
						if f: find mv3 var [
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
					
					;print ["mv3:" mv3]
					n: length? preload
					params: make binary! 100
					while [not tail? mv2][
						n: n + 1
						if error? try [
							insert tail params rejoin [int-to-ui8 n as-binary first mv3 #{00}]
							mv3: next mv3
						][
							;probe mv2
							halt
						]
						mv2: next mv2
					]
					;print ["N:" n]
					;probe mv2
					;probe
					 mv2: head mv2

					insert/only tail registers (head insert tail preload head mv3)
					append-action-tag #{8E} rejoin [
						as-binary mv1 #{00}
						int-to-ui16 length? mv2
						int-to-ui8  1 + (length? mv2) + (length? mv3) + (length? preload) ;;;;?????? 1 + length? mv3
						int-to-ui16 flags
						params
						#{0000}
					]
					;print ["params:" mold as-string params]
					;print ["bytecode:" length? bytecode mold mv4]
					;probe bytecode
					repend branchesToSet [length? bytecode mv4]
				]
			)
			| 'aGetURL set mv1 string! set mv2 string! (
				append-action-tag #{83} rejoin [ mv1 #"^@" mv2  #"^@"]
			)
			|
			set mv1 word! (
				either tmp: select actionIds mv1 [
					insert tail bytecode tmp
				][	print ["!!Unknown action:" mv1 "^/!!near:" copy/part mold pos 100] ]
			)
			| any-type! (
				make-error! "Compile error" pos
			)
		]
	]
		
	set 'compile-actions func[
		[catch]
		code
		/local mv1 mv2 mv3 mv4 tmp bytecode translated label pos err ;xt xt1
	][
		;print "compile-actions"
		;xt: now/time/precise
	
		if empty? code [ return copy #{} ]
		labels: with-depth: 0
		break-labels: copy []
		clear registers
		bytecode: copy #{}
		;used-strings: make hash! 400
		
		bind second :append-action-tag 'bytecode
		
		translated: translate/flat code
		;xt1: now/time/precise - xt
		;debug ["TRANSLATED:" mold translated]
		;used-strings: sort/skip/compare/reverse to-block used-strings 2 2
		;print ["used-strings:" mold used-strings]
		
		branchesToSet:  copy []
		branchesLabels: make hash! 30
		;clear constantPool
		clear localVars
		;print ["useConstantPool:" length? used-strings]
		comment{
		if all [
			useConstantPool?
			swf-version > 4
			;not empty? used-strings
			;used-strings/2 > 1
		][
			;prepare constant pool
			
			if 131070 < length? used-strings [;maximum is 65535 constants in pool
				used-strings: copy/part used-strings 131070
			]
			use [cp][
				cp: make binary! 1000
				;probe used-strings 
				foreach [string count] used-strings [
					;if all [count > 1 not find ["this" "_global" "_super"] string] [
					;if count > 1 [
					;if all [not find ["this" "_global" "_super"] string] [
						insert tail constantPool string
						insert tail cp join either all [swf-version > 5 utf8-encode?][utf8/encode string][string] #"^@"
					;]
				]
				append-action-tag #{88} rejoin [int-to-ui16 (length? used-strings) / 2 cp]
			]
		]
		}
		
		;debug ["constantPool:" mold constantPool]
		;probe translated
		
		parse translated bind compile-rules 'bytecode
		
		;print ["=== fixing brachnes ==="]
		;print ["branchesToSet: " mold branchesToSet]
		;print ["branchesLabels:" mold branchesLabels] 
		
		foreach [pos label ] branchesToSet [
			;print ["---" pos label]
			change/part (at bytecode (pos - 1)) (int-to-ui16 ((select branchesLabels label) - pos )) 2
		]
		
		;debug ["RESULT:" mold bytecode]
		
		;print ["ACTION times:" (ttxt: ttxt + xt: (now/time/precise - xt)) xt xt - xt1]
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


