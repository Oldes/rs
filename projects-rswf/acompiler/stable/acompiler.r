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
    	rs-project 'utf8-cp1250
		;rs-project 'utf-8
		rs-project 'ieee
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

	#include %conversions.r
	#include %actionids.r
	
	utf8-encode?: true
	swf-version: 8
	used-strings: make hash! 400
	constantPool: copy []
	useConstantPool?: true
	
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
	
	
	
	translate: func [
		[catch]
	    code [block!]
	    /do-not-pop
	    /flat "returns result as a one block even if there is more of them"
	    /store "do not remove stored register so the value can be reused" 
	    /local
	     stack
	     push pop expr codepos results mv1 mv2 mv3 pos
	] [
		;print ["^/PARSUJU VYRAZ:" mold code]
	
		if empty? code [return copy []]	
	    ; inicializace zásobníku
	    stack:   copy []
	    results: copy []
	
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
	    
	    addPostAct: func[Act][
			mv2: pop mv1: pop
		    push head insert tail insert tail mv1 mv2 Act
		]
		addUnaryAct: func[Act][
			;print ["addUnaryAct:" mold stack]
		    push head insert tail pop Act
		  ;  print ["addUnaryAct=" mold stack]
		]
		
		new-label: func[][ to-word join "L" labels: labels + 1]
		
		count-str: func[str /local n][
			either none? n: find/tail/case used-strings str [
				repend used-strings [str 1]
			][	change n (n/1 + 1) ]
		]
		
		finishExpression: func[/local res p][
			either error? try [res: pop][res: none][
				;print ["finish:" mold res]
				if not empty? res [
					unless store [
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
						none? find [aSetVariable aSetMember aSetProperty aDefineLocal aDefineLocal2 aStop aReturn aPop] last res
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
		
		trans-SetWordOrMember: func[/local pre tmp mv1 mv2 word first? asLocal][
			mv2: pop
			mv1: reverse pop
			;print ["trans-SetWordOrMember:" mold mv1 mold mv2]
			
			pre: copy []
			first?: true
			parse mv1 [
				some [
					(asLocal: false)
					set word [set-word! | set-path!] opt ['var (
						setLocal first parse form word "./"
						asLocal: true
					)] (
						tmp: trans-GetWordOrPath either set-path? word [
							head remove back tail form word
						][	word ]
						either all [
							'aGetRegister = first tmp
							3 > length? tmp
						][
							insert tail mv2 reduce ['aSetRegister tmp/2]
							insert pre remove/part tmp 2
						][
							lastAction: last tmp
							insert pre head remove back tail tmp
							
							switch/default lastAction [
								aGetVariable [
									either any [asLocal isLocal? mv1] [
										;print defineLocal
										either first? [
											insert tail mv2 'aStoreSetLocalGetVariable
											first?: false
										][
											insert tail mv2 'aSetLocalGetVariable
										]
									][
										either first? [
											insert tail mv2 'aStoreSetGetVariable
											first?: false
										][
											insert tail mv2 'aSetGetVariable
										]
									]
								]
								aGetProperty [
									either first? [
										insert tail mv2 'aStoreSetGetProperty
										first?: false
									][
										insert tail mv2 'aSetGetProperty
									]
								]
							][
								either first? [
									insert tail mv2 'aStoreSetGetMember
									first?: false
								][
									insert tail mv2 'aSetGetMember
								]
							]
							
						]
					)
				]
			]
	
			insert mv2 pre
			push mv2
		]
		trans-SetEvalWord: func [/local pre word first?][
			mv2: pop
			mv1: reverse pop
			pre: copy []
			first?: true
			;print ["trans-SetEvalWord:" mold mv1 mold mv2]
			parse mv1 [some [
				set word block! (
					;probe word
					insert pre word
					either first? [
						insert tail mv2 'aStoreSetGetVariable
						first?: false
					][
						insert tail mv2 'aSetGetVariable
					]
				)
			]]
			insert mv2 pre
			push mv2
			
		]
		
		trans-GetWordOrPath: func[wordOrPath /local pre result here there var c first? *crement ][
			;print ["processGetWordOrMember:" mold wordOrPath]
			first?: true
			either any [
				error? try [wordOrPath: to-word wordOrPath]
				none? prop: select properties wordOrPath
			] [
				result: copy []
				
				parse/all form wordOrPath [some [
					 ch_separator
					 | here: some [ch_label]    there: (
					 	var: copy/part here there
					 	;print ["pathPart:" mold var]

					 	if *crement [
					 		make-error! "Using (in|de)crement inside path" pos
				 		]
					 	if not parse/all var [
					 		":" copy var to end (
					 			unless var [ make-error! "Imvalid 'get-word!" pos ]
					 			count-str var
					 			insert tail result var
					 			insert tail result reduce either first? [
							 		first?: false
							 		['aGetVariable 'aGetVariable]
						 		][
						 			['aGetVariable 'aGetMember]
						 		]
					 		)
					 		|
					 		["++" (*crement: 'aIncrement) | "--" (*crement: 'aDecrement)] copy var to end 
					 		 (
					 		 	unless var [ make-error! "Nothing to (in|de)crement" pos ]
					 		 	either all [
					 		 		first?
					 		 		any [
					 					preloadVar? var
					 					isLocal? var
				 					]
				 				][
				 					first?: false
				 					insert tail result reduce [
				 						'aGetRegister var *crement 'aSetRegister var
							 		]
			 					][
						 		 	count-str var
						 		 	insert tail result var
					 				insert tail result result
					 				insert tail result reduce either first? [
								 		first?: false
								 		['aGetVariable *crement 'aStoreSetGetVariable]
							 		][
							 			['aGetMember *crement 'aStoreSetGetMember]
							 		]
						 		]
					 		 	
					 		 )
					 		|
					 		copy var [to "++" (*crement: 'aIncrement) | to "--" (*crement: 'aDecrement)] 2 skip end
					 		 (
					 		 	unless var [ make-error! "Nothing to (in|de)crement" pos ]
				 		 		
				 		 		either all [
					 		 		first?
					 		 		any [
					 					preloadVar? var
					 					isLocal? var
				 					]
				 				][
				 					first?: false
				 					insert tail result reduce [
								 		'aGetRegister var *crement 'aSetRegister var
							 		]
			 					][
						 		 	count-str var
						 		 	insert tail result var
						 		 	tmp: copy result
						 		 	unless empty? stack [
						 		 		insert tail result 'aGetVariable
					 					insert tail result tmp
				 					]
					 				insert tail result tmp
					 				insert tail result reduce either first? [
								 		first?: false
								 		['aGetVariable *crement 'aSetVariable]
							 		][
							 			['aGetMember *crement 'aSetMember]
							 		]
						 		]
					 		 )
					 	][
					 		;no (in|de)crement
					 		;test on integer path
					 		if error? try [var: -1 + to integer! var][
			 					count-str var
		 					]
		 					;probe var
						 	insert tail result reduce either first? [
						 		first?: false
						 		either all [
						 			useRegisters?
						 			any [
						 				preloadVar? var
						 				isLocal? var
					 				]
					 			][
						 			['aGetRegister var]
					 			][	[var 'aGetVariable] ]
					 		][
					 			[var 'aGetMember]
					 		]
						]
				 		
					 )
					 | here: rl_path-expression there: (
					 	insert tail result trans-paren/store copy/part here there
				 		insert tail result 'aGetMember
					 )
				]]
			][
				;is just property
				result: reduce either with-depth > 0[
					;we are inside 'with' block
					[form wordOrPath 'aGetVariable]
				][	['none prop 'aGetProperty]	]
			]
			result
		]
	
		trans-callFunction: func[wordOrPath args /local result numArgs arg][
			result: copy []
			;print ["trans-callFunction:" mold wordOrPath mold args]
			args: reverse to block! args
			parse/all args [
				any [
					set arg lit-word! (insert tail result select local-constants arg)
					| ['false | 'off] (insert tail result reduce ['false] )
					| ['true  | 'on ] (insert tail result reduce ['true] )
					| 'null  (insert tail result reduce ['null] )
					| set arg [word! | path!] (insert tail result trans-GetWordOrPath arg)
					| set arg paren! ( insert tail result trans-paren arg)
					| set arg any-type! (insert tail result reduce [arg])
				]
			]
			insert tail result reduce [length? args]
			insert tail result trans-GetWordOrPath wordOrPath
			;probe result
			switch/default last result [
				aGetVariable [	change back tail result 'aCallFunction]
				aGetMember   [ change back tail result 'aCallMethod ]
			][	insert tail result 'aCallMethod ]
			;print ["CALLFCE" mold result]
			result
		]
		
		trans-paren: func[val /store /local mv1 lastAction][
			;debug ["paren!!!!!!!" mold val]
	        mv1: copy []
	        
	        foreach sub-result translate to-block val [
	        	insert tail mv1 sub-result 
	    	]
	    	;print ["vysledek zavorky:" mold mv1]
	    	;print ["stack:" mold stack]
	    	either 'aPop = lastAction: last mv1 [remove back tail mv1][
	    		if any [store not empty? stack] [
	    			switch lastAction [
	    				aSetVariable [change back tail mv1 'aStoreSetGetVariable]
						aSetMember   [change back tail mv1 'aStoreSetGetMember  ]
						aSetProperty [change back tail mv1 'aStoreSetGetProperty]
					]
				]
			]
	    	mv1
		]
		
		trans-if: func[condition block /local result label][
			;print ["###### IF" mold condition mold block]
			;print ["ZAS:" mold stack]
			result: translate/flat/store condition
			if 'aPop = last result [remove back tail result]
			;print ["$$$$$$$$$$" mold result]
			label: new-label
			insert tail result reduce ['aNot 'aIf label]
			insert tail result translate/flat block
			insert tail result reduce ['end label]
			;insert/only tail result translate/flat block
			result
		]
		
		trans-either: func[condition true-block false-block /local result label1 label2][
			;print ["###### either" mold condition mold true-block mold false-block]
			;print ["ZAS:" mold stack]
			label1: new-label
			label2: new-label
			result: translate/flat/store condition
			if 'aPop = last result [remove back tail result]
			insert tail result reduce ['aNot 'aIf label1]
			insert tail result translate/flat true-block
			insert tail result reduce ['aJump label2 'end label1]
			insert tail result translate/flat false-block
			insert tail result reduce ['end label2]
			result
		]
		
		trans-switch: func[
			value cases
			/default case
			/local result value-translated case-translated case-value case-action switchend label
		][
			value-translated: translate/flat/store value
			either 'aPop = last value-translated [
				remove back tail value-translated
			][
				make-error! "SWITCH is missing its value argument" pos
			]
			result: copy []
			switchend: new-label
			parse cases [
				some [
					copy case-value to block! set case-action block! (
						;print ["SWCASE:" mold case-value mold case-action]
						case-translated: translate/flat/store case-value
						either 'aPop = last case-translated [
							label: new-label
							insert tail result value-translated
							insert tail result head remove back tail case-translated
							insert tail result reduce ['aEquals 'aNot 'aIf label]
							insert tail result translate/flat case-action
							insert tail result reduce ['aJump switchend 'end label]
						][
							make-error! reform ["SWITCH case" mold case-value "does not return any value"] pos
						]
					)
					| any-type! (
						make-error! "SWITCH has invalid cases" pos
					)
				]
			]
			either default [
				insert tail result translate/flat case
			][
				remove/part skip tail result -4 2
			]
			insert tail result reduce ['end switchend]
	
			result
		]
		
		trans-break: func[][
			copy either error? try [label: last break-labels][
				make-warning! "Nothing to break" pos
				[]
			][	reduce ['aJump label ] ]
		]
		trans-while: func[cond-block body-block /local result cond-translated startlabel endlabel][
			result: copy []
			if empty? cond-block [
				make-error! "Missing WHILE condition" pos
				return copy []
			]
			cond-translated: translate-value cond-block "WHILE condition"
			insert tail result reduce ['label startlabel: new-label]
			insert tail break-labels endlabel: new-label
			insert tail result cond-translated
			insert tail result reduce ['aNot 'aIf endlabel]
			insert tail result translate/flat body-block
			insert tail result reduce ['aJump startlabel 'end endlabel]
			remove back tail break-labels
			result
		]
		trans-do-while: func[body-block cond-block /local result cond-translated startlabel endlabel][
			result: copy []
			if empty? cond-block [
				make-error! "Missing DO-WHILE condition" pos
				return result
			]
			cond-translated: translate-value cond-block "DO-WHILE condition"
			insert tail break-labels endlabel: new-label
			insert tail result reduce ['label startlabel: new-label]
			insert tail result translate/flat body-block		
			insert tail result cond-translated
			insert tail result reduce ['aIf startlabel]
			insert tail result reduce ['end endlabel]
			remove back tail break-labels
			result
		]
		
		trans-for: func[word start end bump body /local result startlabel endlabel word-translated word-type start-translated set-word][
			result: copy []
			if bump = 0 [
				make-warning! "FOR 'bump' value must not be zero" pos
				return result
			]
			word-translated: trans-GetWordOrPath word
			start-translated: translate-value start "FOR 'start'"
			end-translated:   translate-value end   "FOR 'end'"
				
			set-word: either 'aGetMember = last word-translated ['aSetMember][
				either 'aGetRegister = first word-translated [
					reduce ['aSetRegister word-translated/2]
				][	'aSetVariable ]
			]
			
			either block? set-word [
				insert tail result start-translated
				insert tail result set-word
				insert tail result 'aPop
				insert tail break-labels endlabel: new-label
				insert tail result reduce ['label startlabel: new-label]
				insert tail result word-translated
				insert tail result end-translated
				insert tail result reduce [either bump > 0 ['aGreater ]['aLess] 'aNot 'aNot 'aIf endlabel]
				insert tail result translate/flat body
				insert tail result word-translated
				insert tail result reduce [bump 'aAdd2]
				insert tail result set-word
				insert tail result 'aPop
				insert tail result reduce ['aJump startlabel 'end endlabel]
				remove back tail break-labels
			][
				insert tail result word-translated
				remove back tail result
				insert tail result start-translated
				insert tail result set-word
				insert tail break-labels endlabel: new-label
				insert tail result reduce ['label startlabel: new-label]
				insert tail result word-translated
				insert tail result end-translated
				insert tail result reduce [either bump > 0 ['aGreater ]['aLess] 'aNot 'aNot 'aIf endlabel]
				insert tail result translate/flat body
				insert tail result word-translated
				remove back tail result
				insert tail result word-translated
				insert tail result reduce [bump 'aAdd2 set-word]
				insert tail result reduce ['aJump startlabel 'end endlabel]
				remove back tail break-labels
			]
			result
		]
		trans-for-in: func[word object body local? /local result startlabel endlabel word-translated set-word][
			;print ["trans-for-in:" local? mold word mold object mold body ]
			result: copy []
			insert tail result translate-value object "FOR..IN object"
			insert tail result 'aEnumerate2
			
			insert tail result reduce ['label startlabel: new-label]
			insert tail result [aSetRegister "enumValue" null aEquals2 aIf]
			insert tail break-labels endlabel: new-label
			insert tail result endlabel
			
			word-translated: trans-GetWordOrPath word
			set-word: either 'aGetMember = last word-translated ['aSetMember][
				either 'aGetRegister = first word-translated [
					reduce ['aSetRegister word-translated/2]
				][	either local? ['aDefineLocal]['aSetVariable] ]
			]
			
			insert tail result head remove back tail word-translated			
			insert tail result [aGetRegister "enumValue"]
			insert tail result set-word
			
			insert tail result translate/flat body	
			insert tail result reduce ['aJump startlabel 'end endlabel]
			remove back tail break-labels
			result
		]
		
		trans-foreach: func[words data body /local result startlabel endlabel data-translated][
			comment {Should be optimized using register for data value}
			
			result: copy []
			unless block? words [words: to block! words]
			;print [newline words data]
			;print [mold words mold data mold body]
			
			data-translated: translate-value data "FOREACH 'data'"
			repend result [0 'label startlabel: new-label 'aPushDuplicate]
			insert tail result data-translated
			insert tail result ["length" aGetMember aGreaterEquals  aIf]
			insert tail result endlabel: new-label
			
			while [not tail? words][
				either word? first words [
					;[counter]
					append result 'aPushDuplicate
					;[counter counter]
					append result form first words
					;[counter counter word]
					append result 'aStackSwap
					;[counter word counter]
					insert tail result data-translated
					;[counter word counter data]
					append result 'aStackSwap
					;[counter word data counter]
					append result [aGetMember aSetVariable aIncrement]
					
					words: next words
				][
					make-warning! reform ["Invalid datatype in FOREACH words (" mold first words ")"] pos
					remove words
				]
				
			]
			insert tail result translate/flat body
			insert tail result reduce ['aJump startlabel 'end endlabel 'aPop]
			result
		]
		
		trans-with: func[object body /local result label object-translated][
			result: copy []
			with-depth: with-depth + 1
			object-translated: translate-value object "WITH object"
			
			defineLocals copy []
			insert tail result object-translated
			insert tail result reduce ['aWith label: new-label]
			insert tail result translate/flat body
			insert tail result reduce ['end label]
			if 1 < l: length? localVars [
				;if there were defined any local vars and I'm inside func2 block store these new vars
				localVars/(l - 1): union localVars/(l - 1) copy last localVars
			]
			with-depth: with-depth - 1
			clearLocals
			result
		]
		trans-tellTarget: func[object body /local result label object-translated l][
			result: copy []
			tellTarget-depth: tellTarget-depth + 1
			either swf-version < 4 [
				insert tail result reduce ['aSetTarget to-string first object]
				defineLocals copy []
				insert tail result translate/flat body
				insert tail result reduce ['aSetTarget ""]
			][
				object-translated: translate-value object "TellTarget object"
				insert tail result object-translated
				insert tail result 'aSetTarget2
				defineLocals copy []
				insert tail result translate/flat body
				insert tail result reduce ['aSetTarget ""]
			]
			if 1 < l: length? localVars [
				;if there were defined any local vars and I'm inside func2 block store these new vars
				localVars/(l - 1): union localVars/(l - 1) last localVars
			]
			tellTarget-depth: tellTarget-depth - 1
			clearLocals
			result
		]
		
		trans-rejoin: func[block /with divider [string!] /local result n p parts][
			result: copy []
			n: 0 p: 0
			foreach part parts: translate block [
				switch last part [
					aPop [ remove back tail part]
					aSetVariable [change back tail part 'aStoreSetGetVariable]
					aSetMember   [change back tail part 'aStoreSetGetMember]
				]
				insert tail result part
				n: n + 1
				p: p + 1
				if all [with p < length? parts] [
					insert tail result divider
					n: n + 1
				]
			]
			;print ["REJOIN" mold parts]
			insert/dup tail result 'aStringAdd (n - 1)
			result
		]
		
		trans-func: func[spec body /local result params locals label paramsstr][
			result: copy []
			params: copy []
			paramsstr: copy ""
			parse spec [
				any [
					set p word! (
						append params p
						append paramsstr join to-string p "^@"
					)
					| /local copy locals to end
					| any-type!
				]
			]
			;defineLocals
			 either none? locals [locals: copy []][locals]
			insert tail result reduce ['aFunc "" length? params paramsstr label: new-label ]
			unless empty? locals [
				foreach var locals [insert tail result to-string var]
				insert/dup tail result 'aDefineLocal2 length? locals
			]
	
			insert tail result translate/flat body
			insert tail result reduce ['end label]
			;clearLocals
			result
		]
		
		trans-func2: func[spec body /local result params locals label translated ][
			result: copy []
			params: copy []
			locals: copy []
			parse spec [
				any [
					set p word! (append params to-string p)
					| /local any [
						set p word! (append locals to-string p)
						| any-type!
					]
					| any-type!
				]
			]
			insert locals params
			defineLocals locals
			
			translated: translate/flat body

			;probe localVars
			insert tail result reduce ['aFunc2 "" params copy last localVars]
			;insert tail result locals
			insert tail result label: new-label
			insert tail result translated
			insert tail result reduce ['endFunc2 label]
			clearLocals
			result
		]
		
		trans-block: func[values /local result translated num][
			result: copy []
			translated: reverse translate/do-not-pop values
			num: length? translated
			insert tail result flat-block translated
			insert tail result reduce [num 'aInitArray]
			result
		]
		
		trans-fscommand: func[args /local result mv1 mv2][
			result: copy []
			parse args [
				some [
					[ set mv1 [string! | 'exec | 'showmenu | 'fullscreen | 'allowscale | 'quit | 'trapallkeys | set-word!]
						(mv1: join "FSCommand:" to-string mv1)
					| set mv1 word! (mv1: reduce ["FSCommand:" form mv1 'aGetVariable 'aStringAdd])
					]
					[ set mv2 [string! | 'true | 'false] (mv2: to-string mv2)
					| 'on (mv2: "true") | 'off (mv2: "false")
					| set mv2 word! (mv2: reduce [form mv2 'aGetVariable])
					]
					(
						either all [string? mv1 string? mv2] [
							insert tail result reduce ['aGetURL mv1 mv2]
						][
							insert tail result mv1
							insert tail result mv2
							insert tail result 'aGetURL2
						]
					)
				]
			]
			result
		]
		
		
		trans-make-object: func[name args /local pos result argsTranslated transVal num vars val][
			;print ["MAKE Object:" mold name mold args]
			result: copy []
			unless args [args: copy []]
			either name = 'object! [
				num: 0
				parse args [
					any [
						pos: 
						copy vars some set-word!  copy val [ to set-word! | to end] (
							;probe val probe 
							transVal: translate/flat val "Make Object!"
							if 'aPop = last transVal [remove back tail transVal]
							forall vars [
								num: num + 1
								insert tail result to-string vars/1
								insert tail result transVal
							]
						)
					]
				]
				insert tail result reduce [num 'aDefineObject]
				
			][
				either date? args [
					argsTranslated: reduce [
						args/day
						args/month - 1
						args/year
					]
					if val: args/time [
						insert argsTranslated reduce [
							val/second - 1
							val/minute - 1
							val/hour - 1
						]
					]
				][
					argsTranslated: reverse translate/do-not-pop args
				]
				num: length? argsTranslated
				insert tail result flat-block argsTranslated
				insert tail result num
				if #"!" = last form name [
					name: either none? val: select path-shortcuts name [
						val: head remove back tail to-string name
						make-warning! reform ["Unknown path-shortcut" mold name "using:" mold val] pos
						val
					][ val ]
				]
				insert tail result trans-GetWordOrPath name
				change back tail result either 'aGetVariable = last result ['aNewObject]['aNewMethod]
			]
	
			result
		]
		
		trans-make-object2: func[name args /local pos result argsTranslated transVal num vars val][
			;print ["MAKE Object:" mold name mold args]
			result: copy []
			unless args [args: copy []]
			
			either date? args [
				argsTranslated: reduce [
					args/day
					args/month - 1
					args/year
				]
				num: either none? val: args/time [3][
					insert argsTranslated reduce [
						val/second - 1
						val/minute - 1
						val/hour - 1
					]
					6
				]
			][
				num: 0
				argsTranslated: copy []
				parse args [
					any [
						pos: 
						copy vars some set-word!  copy val [ to set-word! | to end] (
							probe val
							probe
							 transVal: translate/flat val "Make Object!"
							if 'aPop = last transVal [remove back tail transVal]
							forall vars [
								num: num + 1
								insert argsTranslated transVal
								insert argsTranslated to-string vars/1
								
							]
						)
					]
				]
			]
			probe argsTranslated
			insert tail result argsTranslated
			either name = 'object! [
				insert tail result reduce [num 'aDefineObject]
			][
				insert tail result num
				if #"!" = last form name [
					name: either none? val: select path-shortcuts name [
						val: head remove back tail to-string name
						make-warning! reform ["Unknown path-shortcut" mold name "using:" mold val] pos
						val
					][ val ]
				]
				insert tail result trans-GetWordOrPath name
				change back tail result either 'aGetVariable = last result ['aNewObject]['aNewMethod]
			]
			result
		]
		
		trans-poke: func[value index data /local result][
			;print ["POKE" mold value mold index mold data]
			result: trans-GetWordOrPath value
			insert tail result translate-value index "POKE Index"
			insert tail result translate-value data  "POKE Data"
			insert tail result 'aSetMember
			result
		]
		trans-pick: func[series index /local result][
			;print ["PICK" mold series mold index]
			result: trans-GetWordOrPath series
			insert tail result translate-value index "PICK Index"
			insert tail result 'aGetMember
			result
		]
		
		trans-loadmovie: func[mv1 mv2 mv3 /local result][
			result: copy []
			insert tail result translate-value index "POKE Index"
			either word? mv1 [do process-get-path mv1][	form-push mv1 ]
					either word? mv2 [do process-get-path mv2][	form-push mv2 ]
				    form-act-tag #{9A} select [none #{40} post #{82} get #{81}] mv3
		]
		
		trans-class: func[classBlock extends /local className pre result name p val constructor trans label][
			pre: pop
			if 1 < length? pre [
				make-error! "CLASS can have only one name!" pos
			]
			if empty? pre [
				make-error! "CLASS requires a name!" pos
			]
			if not set-word?  className: last pre [
				make-error! "CLASS requires name (as a set-word!)" pos
			]
			className: form className
			;print ["====CLASS====" className "extends:" extends]
			;probe classBlock
			remove back tail pre
			
			constructor: none
			result: copy []
			
			parse classBlock [any [
				set name set-word! [copy val to set-word! | copy val to end] (
					name: form name
					trans: translate val
					if 'aPop = last last trans [remove back tail last trans]
					either name = "init" [
						constructor: last trans
					][	
						repend result ['aGetRegister "CLASSPROTO" name]
						append result last trans
						repend result 'aSetMember
					]
				)
				| p: any-type! (
					make-error! "Invalid CLASS statement" p
				)
			]]
			either none? extends [
				insert result reduce [
         			'aGetRegister "CLASS1" "prototype" 'aGetMember
         			'aSetRegister "CLASSPROTO" 'aPop
 				]
				
			][
				insert result reduce either swf-version < 7 [
					[
						"_global" 'aGetVariable className 'aGetMember
         				"prototype" 0 form extends 'aNewObject
         				'aSetRegister "CLASSPROTO" 'aSetMember
     				]
     			][
     				[
     					"_global" 'aGetVariable className 'aGetMember
     					form extends 'aGetVariable 'aExtends
         				'aGetRegister "CLASS1" "prototype" 'aGetMember
         				'aSetRegister "CLASSPROTO" 'aPop
 					]
				]
			]
			
			insert result compose [
				"_global" aGetVariable (className)
				(
					either none? constructor [
						compose [
							aFunc "" 0 "" (label: new-label) 0 "super" aCallFunction aPop end (label)
							;aSetRegister "CLASS1" aSetMember
							
						]
					][	constructor ]
				)
				aSetRegister "CLASS1" aSetMember
			]
			
			append result compose [
				1 null "_global" aGetVariable (className) aGetMember "prototype" aGetMember
         		3 "ASSetPropFlags" aCallFunction
			]
			insert result compose [
				"_global" aGetVariable (className) aGetMember aNot aNot aIf (label: new-label)
			]
			append result reduce ['end label]
;probe result
			push pre
			result
		]
		
		RESERVED-WORDS: [
			  'or | 'and | '= | '== | '!= | '!== | '** | '* | 'band | 'xor | '&& | '& | '|| | '.
			| slash | dslash | rShift | UrShift | _greater | _less | _noteql | _lesseql | _greatereql | lShift
			| 'func | 'while | 'do | 'if | 'else | 'foreach | 'for | 'switch | 'switch-default | 'make | 'new | 'fscommand
			| 'rejoin | 'reform | 'Modulo | 'InstanceOf | 'pick | 'poke | 'set | 'catch | 'throw | 'StopDrag
			| 'goto | 'gotoLabel | 'gotoFrame | 'stop | 'date? | 'string? | 'MovieClip? | 'block? | 'color? | 'sound? | object?
			| 'on | 'off | 'true | 'false | 'integer? | 'number? | 'logic? | 'function?
		]
		
	    ELEMENT: [
	    	pos: (debug ["....element?" mold pos])
	        set mv1 [integer! | string! | issue! | binary! | decimal! | tuple! | file!] (push reduce [mv1] if string? mv1 [count-str mv1])
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
	 	   		if trace? [push trans-callFunction 'cmsg to-paren reduce [to-paren compose/only [reform (to-block mv1)]]]
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
			| 'break ( push trans-break )
			| IFRULE
			| EITHERRULE
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
				make-warning! "FOREACH not supported now!" pos
			;	push trans-foreach v v2 v3
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
	
		parse code EXPRESSION
	
		;probe stack
		;either flat [
		;	print ["VYSLEDEK" mold results]
		;][
		;    forall results [
		;    	print ["VYSLEDEK" index? results mold results/1]
		;	]
		;]
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
			if all [swf-version > 5 utf8-encode?][v: utf8/encode v]
			rejoin [#{00} v #{00}]
		][
			rejoin either (v: (-1 + index? p)) > 255 [
				[#{09} int-to-ui8 v]
			][	[#{08} int-to-ui8 v] ]
		]
	]
	
	form-push-values: func[values /local v result][
		;print ["form-push-values:" mold values ]
		result: copy #{}
		parse values [some [
			  set v integer! (insert tail result either v = 0 [#{060000000000000000}][join #{07} int-to-ui32 v])
			| set v decimal! (insert tail result join #{06} to-ieee64/flash v)
			| set v string!  (insert tail result push-str-value v)
			| set v string!  (insert tail result push-str-value as-string v)
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
					print ["!!! aGetRegister not found !!!" mold v mold registers]
					halt
				]
			)
			| set v any-type! (insert tail result push-str-value to string! v)
		]]
		result
	]
	
	registers: copy []	
	;ttxt: 0
	
	set 'compile-actions func[
		[catch]
		code
		/local mv1 tmp bytecode translated label pos err ;xt xt1
	][
		;xt: now/time/precise
	
		if empty? code [ return copy #{} ]
		labels: with-depth: 0
		break-labels: copy []
		clear registers
		bytecode: copy #{}
		used-strings: make hash! 400
		
		append-action-tag: func[id [binary!] data [binary! string!]][
			insert tail bytecode rejoin [id int-to-ui16 length? data data]
		]
		translated: translate/flat code
		;xt1: now/time/precise - xt
		debug ["TRANSLATED:" mold translated]
		used-strings: sort/skip/compare/reverse to-block used-strings 2 2
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
					;unless find ["this" "_global" "_super"] string [
						insert tail constantPool string
						insert tail cp join either all [swf-version > 5 utf8-encode?][utf8/encode string][string] #"^@"
					;]
				]
				append-action-tag #{88} rejoin [int-to-ui16 (length? used-strings) / 2 cp]
			]
		]
		
		debug ["constantPool:" mold constantPool]
	
		;probe translated
		
		parse translated [
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
							int-to-ui8 either none? tmp: find last registers mv1 [
								insert tail last registers mv1
								length? last registers
							][	index? tmp ]
						]
					][
						print ["!!!!!:" mold mv1 mold registers]
						probe disarm err
					]
					)
				| 'aGreaterEquals (insert tail bytecode either swf-version > 4 [#{4812}][#{0F12}])
				| 'aStoreSetGetVariable (insert tail bytecode #{87010000 1D 9602000400})
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


