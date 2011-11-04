rebol []

init-translate-functions: func[
	/local
	stack
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
	
][
	use [stack] copy/deep [
		stack:   copy []

		
		
	    push: func ["pøidej na zásobník" mv] [
	    	;print ["PUSH" mv]
	    	insert/only tail stack mv]
	    pop: func ["vyber ze zásobníku" /local vysl] [
	    	;probe stack
	    	if error? try [
	        	vysl: last stack
	        	
        	][
        		probe pos
        		halt
    		]
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
										][
											insert tail mv2 'aSetLocalGetVariable
										]
									][
										either first? [
											insert tail mv2 'aStoreSetGetVariable
										][
											insert tail mv2 'aSetGetVariable
										]
									]
								]
								aGetProperty [
									either first? [
										insert tail mv2 'aStoreSetGetProperty
									][
										insert tail mv2 'aSetGetProperty
									]
								]
							][
								either first? [
									insert tail mv2 'aStoreSetGetMember
								][
									insert tail mv2 'aSetGetMember
								]
							]
							first?: false
						]
					)
				]
			]
	
			insert mv2 pre
			push mv2
		]
		
		trans-GetWordOrPath: func[wordOrPath /local tmp pre result here there var c first? *crement ][
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
	
					 	if not none? *crement [
					 		make-error! "Using (in|de)crement inside path" pos
				 		]
					 	if not parse/all var [
					 		["++" (*crement: 'aIncrement) | "--" (*crement: 'aDecrement)] copy var to end 
					 		 (
					 		 	if none? var [ make-error! "Nothing to (in|de)crement" pos ]
					 		 	count-str var
					 		 	insert tail result var
				 				insert tail result result
				 				insert tail result reduce either first? [
							 		first?: false
							 		['aGetVariable *crement 'aStoreSetGetVariable]
						 		][
						 			['aGetMember *crement 'aStoreSetGetMember]
						 		]
					 		 	
					 		 )
					 		|
					 		copy var [to "++" (*crement: 'aIncrement) | to "--" (*crement: 'aDecrement)] 2 skip end
					 		 (
					 		 	print ["???" recursion-depth mold stack]
					 		 	if none? var [
					 		 		make-error! "Nothing to (in|de)crement" pos
				 		 		]
					 		 	count-str var
					 		 	insert tail result var
					 		 	probe tmp: copy result
					 		 	if not empty? stack [
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
						 		print [newline mold result newline]
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
				result: reduce ['none prop 'aGetProperty]
			]
			result
		]
	
		trans-callFunction: func[wordOrPath args /local result numArgs arg][
			result: copy []
			args: reverse to block! args
			parse/all args [
				any [
					set arg lit-word! (insert tail result get-local-const arg)
					| 'false (insert tail result reduce ['false] )
					| 'true  (insert tail result reduce ['true] )
					| 'null  (insert tail result reduce ['null] )
					| set arg [word! | path!] (insert tail result trans-GetWordOrPath arg)
					| set arg paren! ( insert tail result trans-paren arg)
					| set arg any-type! (insert tail result reduce [arg])
				]
			]
			insert tail result reduce [length? args]
			insert tail result trans-GetWordOrPath wordOrPath
			either 'aGetVariable = last result [
				change back tail result 'aCallFunction
			][	change back tail result 'aCallMethod ]
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
		
		trans-switch: func[value cases /local result value-translated case-translated case-value case-action switchend label][
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
			remove/part skip tail result -4 2
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
			probe word-translated: trans-GetWordOrPath word
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
		
		trans-with: func[object body /local result label object-translated][
			result: copy []
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
			clearLocals
			result
		]
		trans-tellTarget: func[object body /local result label object-translated][
			result: copy []
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
			if 1 < length? localVars [
				;if there were defined any local vars and I'm inside func2 block store these new vars
				localVars/(l - 1): union localVars/(l - 1) last localVars
			]
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
			if not empty? locals [
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

			insert tail result reduce ['aFunc2 "" (length? params) copy last localVars]
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
		
		trans-make-object: func[name args /local result argsTranslated transVal num vars val][
			;print ["MAKE Object:" mold name mold args]
			result: copy []
			if none? args [args: copy []]
			either name = 'object! [
				num: 0
				parse args [
					any [
						copy vars some set-word!  copy val [ to set-word! | to end] (
							transVal: translate-value val "Make Object!"
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
					if not none? val: args/time [
						insert argsTranslated reduce [
							val/second - 1
							val/minute - 1
							val/hour - 1
						]
					]
				][
					argsTranslated: reverse translate/do-not-pop/store args
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
		
		trans-poke: func[value index data /local result][
			;print ["POKE" mold value mold index mold data]
			result: trans-GetWordOrPath value
			insert tail result translate-value index "POKE Index"
			insert tail result translate-value data  "POKE Data"
			insert tail result 'aSetMember
			result
		]
		trans-pick: func[series index /local result][
			;print ["PICK" mold value mold index mold data]
			result: trans-GetWordOrPath value
			insert tail result translate-value index "POKE Index"
			insert tail result translate-value data  "POKE Data"
			insert tail result 'aSetMember
			result
		]
		
		return reduce [
			:pop
			:push
			:addPostAct
			:addUnaryAct
			:new-label
			:count-str
			:trans-SetWordOrMember
			:trans-GetWordOrPath
			:trans-paren
			:trans-callFunction
			:trans-if
			:trans-either
			:trans-switch
			:trans-break
			:trans-while
			:trans-do-while
			:trans-for
			:trans-with
			:trans-tellTarget
			:trans-rejoin
			:trans-func
			:trans-func2
			:trans-block
			:trans-fscommand
			:trans-make-object
			:trans-poke
			:trans-pick
		]
	]
]
translate-functions: init-translate-functions