rebol [
	title: "SWF actions related parse functions"
	purpose: "Functions for parsing actions related tags in SWF files"
]

	parse-DoAction:
	readACTIONRECORDs: has[records Length ActionCode i] [
		records: copy []
		until [
			i: index? inBuffer
			insert tail records reduce [
				(i - 1)
				ActionCode: readByte
				readBytes either (to integer! actionCode) > 127 [readUI16][0]
			]
			ActionCode = #{00} ;end?
		]
		new-line/skip records true 3
		records
	]
	
	parse-DoInitAction: does [reduce[
		readUsedID	;Sprite ID
		readACTIONRECORDs
	]]
comment {	
	parse-DoABC: has[abc][
		write/binary join rswf-root-dir %tmp.abc abc: readRest
		if error? try [
			call/wait rejoin [ to-local-file rswf-root-dir/bin/abcdump.exe " " to-local-file rswf-root-dir/tmp.abc]
			return read rswf-root-dir/tmp.abc.il
		][ abc ]
	]
	
	parse-DoABC2: does [reduce [
		readSI32   ;skip
		as-string readString ;frame
		parse-DoABC
	]]
	
	parse-SymbolClass: has[classes][
		classes: copy []
		loop readUI16 [
			insert tail classes reduce [
				readUsedID ;id
				as-string readString ;frame
			]
		]
		classes
	]
}
	readNamespace: does [
		reduce [
			select [
				#{08} Namespace
				#{16} PackageNamespace
				#{17} PackageInternalNs
				#{18} ProtectedNamespace
				#{19} ExplicitNamespace
				#{1A} StaticProtectedNs
				#{05} PrivateNs
			] readByte
			ABC/Cpool/string/(readUI30)
		]
	]
	readNSset: funct[][
		count: readUI30
		result: make block! count
		loop count [
			append result ABC/Cpool/namespace/(readUI30)
		]
		new-line/skip result true 2
		result
	]
	readMultiname: funct[][
		reduce switch/default kind: readByte [
			#{07} [['QName   ABC/Cpool/namespace/(readUI30) ABC/Cpool/string/(readUI30)]]
			#{0D} [['QNameA  ABC/Cpool/namespace/(readUI30) ABC/Cpool/string/(readUI30)]]
			#{0F} [['RTQName  ABC/Cpool/string/(readUI30)]]
			#{10} [['RTQNameA ABC/Cpool/string/(readUI30)]]
			#{11} [['RTQNameL]]
			#{12} [['RTQNameLA]]
			#{09} [['Multiname  ABC/Cpool/string/(readUI30) ABC/Cpool/nsset/(readUI30)]]
			#{0E} [['MultinameA ABC/Cpool/string/(readUI30) ABC/Cpool/nsset/(readUI30)]]
			#{1B} [['MultinameL  ABC/Cpool/nsset/(readUI30)]]
			#{1C} [['MultinameLA ABC/Cpool/nsset/(readUI30)]]
			#{1D} [['GenericName ABC/Cpool/multiname/(readUI30) readGenericName ]]
		][	ask ["UNKNOWN multiname kind:" mold kind] ]
	]
	readGenericName: funct[][
		count: readUI30
		result: make block! count
		loop count [
			append result ABC/Cpool/multiname/(readUI30)
		]
		result
	]
	
	readParamTypes: funct[count][
		result: make block! count
		loop count [
			append result readUI30	
		]
		result
	]
	readParamNames: funct[count][
		result: make block! count
		loop count [
			append result readUI30	
		]
		result
	]
	readOptions: funct[][
		count: readUI30
		result: make block! count
		loop count [
			append/only result reduce [
				readUI30
				select [
					#{03} Int
					#{04} UInt
					#{06} Double
					#{01} Utf8
					#{0B} True
					#{0A} False
					#{0C} Null
					#{00} Undefined
					#{08} Namespace
					#{16} PackageNamespace
					#{17} PackageInternalNs
					#{18} ProtectedNamespace
					#{19} ExplicitNamespace
					#{1A} StaticProtectedNs
					#{05} PrivateNs
				] readByte
			]
		]
		result
	]
	
	readMethod: func[num /local param_count] [
		param_count: readUI30
		context [
			method: num
		 	return_type: readUI30
		 	param_type:  readParamTypes param_count
			name: ABC/Cpool/string/(readUI30)
			flags:       readByte
			options:     either (flags and #{08}) = #{08} [readOptions][none]
 			param_names: either (flags and #{80}) = #{80} [readParamNames param_count][none] 
		]
	]
	readItemsArray: funct[][
		count: readUI30
		result: make block! count
		loop count [
			append/only result reduce [
				ABC/Cpool/string/(readUI30)
				ABC/Cpool/string/(readUI30)
			]
		]
		new-line/all result true
	]
	readMetadata: funct[][
		new-line/skip reduce [
		 	ABC/Cpool/string/(readUI30)       ;name
		 	readItemsArray ;items
		] true 2
	]

	
	
	readNamespaceArray: func[/local count result][
		count: readUI30 - 1
		either count >= 0 [
			result: make block! count
			loop count [ append/only result readNamespace]
			result
		][	copy [] ]
	]
	readNSsetArray: func[/local count result][
		count: readUI30 - 1
		either count >= 0 [
			result: make block! count
			loop count [ append/only result readNSset]
			result
		][	copy [] ]
	]
	readStringInfoArray: func[/local count result][
		count: readUI30 - 1
		either count >= 0 [
			result: make block! count
			loop count [ append/only result readStringInfo ]
			result
		][	copy [] ]
	]
	readMultinameArray: funct[][
		count: readUI30 - 1
		either count >= 0 [
			ABC/Cpool/multiname: make block! count
			loop count [ append/only ABC/Cpool/multiname readMultiname ]
			ABC/Cpool/multiname
		][  ABC/Cpool/multiname: copy [] ]
	]
	readMethodArray: funct[][
		count: readUI30
		either count >= 0 [
			result: make block! count
			repeat i count [ append/only result readMethod i]
			result
		][ copy [] ]
	]
	readMetadataArray: funct[][
		count: readUI30
		either count >= 0 [
			result: make block! count
			loop count [ append/only result readMetadata ]
			result
		][ copy [] ]
	]
	readInstanceArray: funct[count][
		result: make block! count
		loop count [ append result readInstance ]
		result
	]
	readClassArray: funct[count][
		result: make block! count
		loop count [ append/only result readClass ]
		result
	]
	readScriptArray: funct[][
		count: readUI30
		result: make block! count
		loop count [ append/only result readScript ]
		result
	]
	readMethodBodyArray: funct[][
		count: readUI30
		result: make block! count
		loop count [ append/only result readMethodBody ]
		result
	]
	readTrait: has[vindex][
		context [
			name: ABC/Cpool/multiname/(readUI30)
			kind: (readUI8 and 15)
			data: (
				;print ["kind:" kind]
				reduce switch/default kind [
					0 6 [;Slot or Const
						[
							select [0 Slot 6 Const] kind
							readUI30 ;slot_id 
							ABC/Cpool/multiname/(readUI30) ;type_name 
							vindex: readUI30 ;vindex
							either vindex > 0 [
								readUI8 ;vkind
							][	none]
							
						]
					]
					4 [;Class
						[
							'Class
							readUI30 ;slot_id 
							readUI30 ;ABC/ClassInfo/(1 + readUI30) ;classi 
						]
					]
					5 [;Function
						[
							'Function
							readUI30 ;slot_id 
							readUI30 ;function
						]
					]
					1 2 3 [;Method, Getter or Setter
						[
							select [1 Method 2 Getter 3 Setter] kind
							readUI30 ;disp_id 
							readUI30 ;method
						]
					]
				][
					; ask "UNKNOWN KIND"
				]
			)
			metadata: (
				either (kind and 240) = 64 [readMetadataArray][none]
			)
		]
	]

	readInstance: has[blk count][
		context [
			name:        ABC/Cpool/multiname/(readUI30)
			super_name:  ABC/Cpool/multiname/(readUI30)
			flags:       readByte
			protectedNs: either #{08} = (flags and #{08}) [ABC/Cpool/namespace/(readUI30)][none]
			interface:   (
				blk: make block! count: readUI30
				loop count [append blk readUI30]
				blk
			)
			iinit: ABC/MethodInfo/(1 + readUI30)
			trait:   (
				blk: make block! count: readUI30
				;print "INSTANCE TRAITS.."
				loop count [append blk readTrait]
				blk
			)
		]
	] 
	readClass: has[blk count][
		context [
			cinit:   readUI30
			trait:   (
				;either cinit > 0 [
					blk: make block! count: readUI30
					;print ["CLASS TRAITS.." count]
					loop count [append blk readTrait]
					blk
				;][	none]
			)
		]
	]
	readScript: has[blk count][
		context [
			init:    ABC/MethodInfo/(1 + readUI30)
			trait:   (
				blk: make block! count: readUI30
				;print ["SCRIPT TRAITS.." count]
				loop count [append blk readTrait]
				blk
			)
		]
	]
	readException: does [
		reduce [
			readUI30 ;from
			readUI30 ;to
			readUI30 ;target
			readUI30 ;exc_type
			ABC/Cpool/multiname/(readUI30) ;var_name
		]
	]
	readMethodBody: has[blk count][
		context [
			method:           ABC/MethodInfo/(1 + readUI30) 
			max_stack:        readUI30
			local_count:      readUI30
			init_scope_depth: readUI30
			max_scope_depth:  readUI30
			code: readBytes readUI30
			exception:   (
				blk: make block! count: readUI30
				loop count [append blk readException]
				blk
			)
			trait:   (
				blk: make block! count: readUI30
				loop count [append blk readTrait]
				blk
			)
		]
	]

	ABC: context [
		Version: none
		Cpool: context [
			integer: 
		 	uinteger:
			double:
			string: 
			namespace: 
			nsset: 
			multiname: none
		]
		MethodInfo:
		Metadata:
		InstanceInfo:
		ClassInfo:
		ScriptInfo:
		MethodBodies: none
	]
	parse-DoABC: has[class_count tmp][
		write %tmp.abc inBuffer
		ABC/Version: readBytesRev 4
		ABC/Cpool/integer:   (readSI32array)
		ABC/Cpool/uinteger:  (readUI32array)
		ABC/Cpool/double:    (readD64array ) 
		ABC/Cpool/string:    (readStringInfoArray)
		ABC/Cpool/namespace: (readNamespaceArray)
		ABC/Cpool/nsset:     (readNSsetArray)
		(readMultinameArray)
		
		ABC/MethodInfo:  readMethodArray
		ABC/Metadata:    readMetadataArray
		
		foreach tmp [
			integer
			uinteger
			double
			string
			namespace
			nsset
			multiname
		][	error? try [new-line/all ABC/Cpool/(tmp) true] ]
		foreach tmp [
			MethodInfo
			Metadata
		][	error? try [new-line/all ABC/(tmp) true] ]
		
		ABC/InstanceInfo: (
			class_count: readUI30
			readInstanceArray class_count
		)

		;print ["class_count: " class_count]
		;ask ""
		ABC/ClassInfo:    readClassArray class_count

		ABC/ScriptInfo:   readScriptArray
		ABC/MethodBodies: readMethodBodyArray
		
		foreach tmp [string namespace nsset multiname][
			new-line/all ABC/Cpool/(tmp) true	
		]
		foreach tmp [
			MethodInfo
			InstanceInfo
			ClassInfo
			ScriptInfo
			MethodBodies
		][	new-line/all ABC/(tmp) true ]

		ABC
	]

	parse-DoABC2: does [reduce [
		readSI32   ;skip
		to-string readString ;frame
		parse-DoABC
	]]
	
	parse-SymbolClass: has[symbols][
		symbols: copy []
		loop readUI16 [
			append symbols reduce [
				readUsedID ;id
				as-string readString ;frame
			]
		]
		symbols
	]

	

	
	
	