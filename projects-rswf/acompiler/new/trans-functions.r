rebol [
	title: "RSWF Actions compiler's TRANS functions"
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
					 	unless parse/all var [
					 		":" copy var to end (
					 			unless var [ make-error! "Imvalid 'get-word!" pos ]
					 			;count-str var
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
						 		 	;count-str var
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
						 		 	;count-str var
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
			 					;count-str var
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
			switch/default wordOrPath [
				fscommand2 [
					insert tail result 'aFscommand2
				]
			][
				insert tail result trans-GetWordOrPath wordOrPath
				switch/default last result [
					aGetVariable [	change back tail result 'aCallFunction]
					aGetMember   [ change back tail result 'aCallMethod ]
				][	
					insert tail result either 'aGetRegister = pick tail result -2 [
						either "super" = last result [
							[undefined aCallMethod]
						][	'aCallFunction ]
					]['aCallMethod ]
				]
			]
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
		trans-case: func[case-block [block!] /all /local result label-end label-cond-end cond eval-block ][
			insert tail break-labels label-end: new-label
			result: copy []
			parse case-block [
				any [
					copy cond to block! set eval-block block! (
						result: insert result translate/flat/store cond
						either 'aPop = result/-1 [
							label-cond-end: new-label
							either all [
								result: change back result reduce ['aNot 'aIf label-cond-end]
								result: insert result translate/flat eval-block
							][
								result: change back result reduce ['aNot 'aIf label-cond-end]
								result: insert result translate/flat eval-block
								result: insert result reduce ['aJump label-end]
							]
							result: insert result reduce ['end label-cond-end]
							
						][
							make-error! reform ["CASE condition" mold cond "returns no value"] pos
						]
					)
					| any-type! (
						make-error! "CASE has invalid cases" pos
					)
					
				]
			]
			head insert result reduce ['end label-end]
		]
		
		trans-switch: func[
			value cases
			/default case
			/local result value-translated cases-translated case-value case-action case-action-translated switchend label-true label-false tmp c eq
		][
			result: translate/flat/store value
			either 'aPop = last result [
				remove back tail result
			][
				make-error! "SWITCH is missing its value argument" pos
			]

			switchend: new-label
			result: tail result
			
			eq: either swf-version < 6 ['aEquals]['aStrictEqual]
			parse cases [
				some [
					copy case-value to block! set case-action block! (
						;print ["SWCASE:" mold case-value mold case-action]
						cases-translated: translate/store case-value
						label-true: new-label
						label-false: new-label
						tmp: index? result
						c: 0
						foreach case cases-translated [
							either 'aPop = last case [
								c: c + 1
								;result: insert result value-translated
								result: insert result 'aPushDuplicate
								result: insert result head remove back tail case
								result: insert result reduce [eq 'aIf label-true]
							][
								make-error! reform ["SWITCH case" mold case-value "does not return any value"] pos
							]
						]
						result: insert tail result reduce ['aJump label-false 'end label-true 'aPop] ;the last Pop removes the case value from stack
						unless unpop case-action-translated: translate/flat case-action [
							insert tail case-action-translated 'undefined
						]
						result: insert result case-action-translated
						result: insert result reduce ['aJump switchend 'end label-false]
;;old version:
;						case-translated: translate/flat/store case-value
;						either 'aPop = last case-translated [
;							label: new-label
;							insert tail result value-translated
;							insert tail result head remove back tail case-translated
;							insert tail result reduce ['aEquals 'aNot 'aIf label]
;							insert tail result translate/flat case-action
;							insert tail result reduce ['aJump switchend 'end label]
;						][
;							make-error! reform ["SWITCH case" mold case-value "does not return any value"] pos
;						]
					)
					| 'comment 1 skip
					| any-type! (
						make-error! "SWITCH has invalid cases" pos
					)
				]
			]
			;probe head result
			result: insert result 'aPop
			either default [
				unless unpop case-action-translated: translate/flat case [
					insert tail case-action-translated 'undefined
				]
				result: insert result case-action-translated
			][
				;remove/part skip tail result -4 2
				result: insert result 'undefined
			]
			result: insert result reduce ['label switchend]
	
			head result
		]
		
		trans-break: func[][
			either error? try [label: last break-labels][
				make-warning! "Nothing to break" pos
				copy []
			][	reduce ['aJump label ] ]
		]
		trans-continue: func[][
			make-warning! "Not ready yet!" pos return copy []
			copy either error? try [label: last break-labels][
				make-warning! "Nothing to break" pos
				[]
			][	reduce ['aJump label ] ]
		]
		trans-while: func[cond-block body-block /local result cond-translated startlabel endlabel][
			if empty? cond-block [
				make-error! "Missing WHILE condition" pos
				return copy []
			]
			result: copy []
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
			if empty? cond-block [
				make-error! "Missing DO-WHILE condition" pos
				return result
			]
			result: copy []
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
		
		trans-foreach: func[words data body /local result result-init-words result-restore-words word startlabel endlabel data-translated][
			result: copy []
			result-init-words: copy []
			result-restore-words: copy []
			unless block? words [words: to block! words]
			;print [newline words data]
			;print [mold words mold data mold body]
			if empty? words [
				make-error! "Empty block of words specified in FOREACH" pos
			]
			data-translated: translate-value data "FOREACH 'data'"
			insert tail break-labels endlabel: new-label
			
			forall words [
				either word? words/1 [
					change words word: to-string words/1
					repend result [word word 'aGetVariable] ;stores previous word content into stacks
					append result-init-words compose [
						aPushDuplicate
						(word)
						aStackSwap
						(data-translated)
						aStackSwap aGetMember
						aDefineLocal
						aIncrement ;<- increments counter
					]
					append result-restore-words [aDefineLocal] ;restores previous word content
					
				][
					make-error! reform ["Invalid FOREACH argument:" word] pos
				]
			]
			
			append result compose [
				0 ;<- counter
				label (startlabel: new-label)
				aPushDuplicate ;<- dup. counter
				(data-translated) "length" aGetMember
				aLess aNot aIf (endlabel)
				(result-init-words)
				(translate/flat body)
				aJump (startlabel)
				end (endlabel)
				aPop ;<- remove counter
				(result-restore-words)
			]
			remove back tail break-labels
			result
		]
		
		trans-repeat: func[word count body /local startlabel endlabel][
			compose [
				(word: to-string word) (word) aGetVariable ;stores previous word content into stacks
				0 ;<- counter
				label (startlabel: new-label)
				aPushDuplicate ;<- dup. counter
				(translate-value count "REPEAT 'count'")
				aLess aNot aIf (insert tail break-labels endlabel: new-label endlabel)
				aPushDuplicate (word) aStackSwap aDefineLocal
				(translate/flat body)
				aIncrement ;<- increments counter
				aJump (startlabel)
				end (remove back tail break-labels  endlabel)
				aPop ;<- remove counter
				aDefineLocal ;restores previous word content
			]
		]
		
		trans-loop: func[count body /local startlabel endlabel][
			compose [
				(translate-value count "LOOP 'count'")
				label (startlabel: new-label)
				aPushDuplicate
				0
				aGreater aNot aIf (insert tail break-labels endlabel: new-label  endlabel)
				(translate/flat body)
				aDecrement
				aJump (startlabel)
				end (remove back tail break-labels endlabel)
				aPop
			]
			
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
				insert tail result reduce ['aSetTarget to string! first object]
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
						append paramsstr join to string! p "^@"
					)
					| /local copy locals to end
					| any-type!
				]
			]
			;defineLocals
			 ;either locals [locals][locals: copy []]
			 unless locals [locals: copy []]
			insert tail result reduce ['aFunc "" length? params paramsstr label: new-label ]
			unless empty? locals [
				foreach var locals [insert tail result to string! var]
				insert/dup tail result 'aDefineLocal2 length? locals
			]
	
			insert tail result translate/flat body
			insert tail result reduce ['end label]
			;clearLocals
			result
		]
		
		trans-func2: func[spec body /local result params locals label translated ][
			;print "FUNC2"
			result: copy []
			params: copy []
			locals: copy []
			parse spec [
				any [
					set p word! (append params to string! p)
					| /local any [
						set p word! (append locals to string! p)
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
						(mv1: join "FSCommand:" to string! mv1)
					| set mv1 word! (mv1: reduce ["FSCommand:" form mv1 'aGetVariable 'aStringAdd])
					]
					[ set mv2 [string! | 'true | 'false] (mv2: to string! mv2)
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
								insert tail result to string! vars/1 ;insert tail result count-str to string! vars/1
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
					name: either val: select path-shortcuts name [val][
						val: head remove back tail to string! name
						make-warning! reform ["Unknown path-shortcut" mold name "using:" mold val] pos
						val
					]
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
			unless set-word? className: last pre [
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
			either extends [
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
			][
				insert result reduce [
         			'aGetRegister "CLASS1" "prototype" 'aGetMember
         			'aSetRegister "CLASSPROTO" 'aPop
 				]
			]
			
			insert result compose [
				"_global" aGetVariable (className)
				(
					any [
						constructor
						compose [
							aFunc "" 0 "" (label: new-label) 0 "super" aCallFunction aPop end (label)
							;aSetRegister "CLASS1" aSetMember
							
						]
					]
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
		
		
	trans-any: func[block /local result label-end label-cond][
		;>> any [a b]
		comment{
		 "a" aGetVariable ;first expr.
		 aPushDuplicate   ;dupl result of the expr.
		 aIf label-end
		 aPop
		 
		 "b" aGetVariable ;next expr.
		 aPushDuplicate
		 aIf label-end
		 aPop
		 
		 false ;puts final false result
		 label label-end
		}
		;print ["ANY" mold block]
		result: copy []
		label-end: new-label
		foreach expr translate block [
			;probe expr
			if unpop/err expr "ANY block" [
				append result head expr
				repend result [
					'aPushDuplicate
					'aIf label-end
					'aPop
				]
			]
		]
		repend result ['false 'label label-end]
		;probe result
		;result
	]
	
	trans-all: func[block /local result label-end tmp][
		;>> all [a b]
		comment{
		 "a" aGetVariable ;first expr.
		 aPushDuplicate   ;dupl result of the expr.
		 aNot aIf label-end
		 aPop
		 
		 "b" aGetVariable ;next expr.
		 aPushDuplicate
		 aIf aNot label-end
		 
		 label label-end
		}
		;print ["ALL" mold block]
		result: copy []
		label-end: new-label
		foreach expr translate block [
			;probe expr
			if unpop/err expr "ALL block" [
				append result head expr
				repend result [
					'aPushDuplicate
					'aNot 'aIf label-end
					'aPop
				]
			]
		]
		if 'aPop = last result [
			change/part skip tail result -5 reduce ['label label-end] 5
		]
		result
	]
	
	unpop: func[expr [block!] /err errIn [string!]][
		either all [
			not empty? expr
			find [aSetVariable aSetMember aPop aDefineLocal] tmp: last expr
		][
			switch tmp [
		 		aSetVariable [change back tail expr 'aStoreSetGetVariable]
		 		aDefineLocal [change back tail expr 'aStoreSetLocalGetVariable]
				aSetMember   [change back tail expr 'aStoreSetGetMember]
				aPop         [remove back tail expr]
			]
			head expr
		][
			either err [
				make-warning! reform ["Unsupported expression in" errIn] pos
				probe expr
				none
			][	expr ]
		]
	]
	