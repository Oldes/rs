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
			code: parse-ABC-code readBytes readUI30
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
	readLookupOffsets: has[count result][
		result: copy []
		loop readUI30 [append result readS24]
		result
	]
	opcode-reader: make stream-io []
	parse-ABC-code: funct[opcodes [binary!]][
		;probe opcodes
		result: copy []
		with opcode-reader [
			setStreamBuffer opcodes
			while [not empty? inBuffer][
				op: readByte
				result: insert result new-line reduce [
					switch/default op [
						#{a0} ['add]
						#{c5} ['add_i]
						#{86} ['astype]
						#{87} ['astypelate]
						#{a8} ['bitand]
						#{97} ['bitnot]
						#{a9} ['bitor]
						#{aa} ['bitxor]
						#{41} ['call]
						#{43} ['callmethod]
						#{46} ['callproperty]
						#{4c} ['callproplex]
						#{4f} ['callpropvoid]
						#{44} ['callstatic]
						#{45} ['callsuper]
						#{4e} ['callsupervoid]
						#{78} ['checkfilter]
						#{80} ['coerce]
						#{82} ['coerce_a]
						#{85} ['coerce_s]
						#{42} ['construct]
						#{4a} ['constructprop]
						#{49} ['constructsuper]
						#{76} ['convert_b]
						#{75} ['convert_d]
						#{73} ['convert_i]
						#{77} ['convert_o]
						#{70} ['convert_s]
						#{74} ['convert_u]
						#{ef} ['debug]
						#{f1} ['debugfile]
						#{f0} ['debugline]
						#{94} ['declocal]
						#{c3} ['declocal_i]
						#{93} ['decrement]
						#{c1} ['decrement_i]
						#{6a} ['deleteproperty]
						#{a3} ['divide]
						#{2a} ['dup]
						#{06} ['dxns]
						#{07} ['dxnslate]
						#{ab} ['equals]
						#{72} ['esc_xattr]
						#{71} ['esc_xelem]
						#{5e} ['findproperty]
						#{5d} ['findpropstrict]
						#{59} ['getdescendants]
						#{64} ['getglobalscope]
						#{6e} ['getglobalslot]
						#{60} ['getlex]
						#{62} ['getlocal]
						#{d0} ['getlocal_0]
						#{d1} ['getlocal_1]
						#{d2} ['getlocal_2]
						#{d3} ['getlocal_3]
						#{66} ['getproperty]
						#{65} ['getscopeobject]
						#{6c} ['getslot]
						#{04} ['getsuper]
						#{b0} ['greaterthan]
						#{af} ['greaterthan]
						#{1f} ['hasnext]
						#{32} ['hasnext2]
						#{13} ['ifeq]
						#{12} ['iffalse]
						#{18} ['ifge]
						#{17} ['ifgt]
						#{16} ['ifle]
						#{15} ['iflt]
						#{14} ['ifne]
						#{0f} ['ifnge]
						#{0e} ['ifngt]
						#{0d} ['ifnle]
						#{0c} ['ifnlt]
						#{19} ['ifstricteq]
						#{1a} ['ifstrictne]
						#{11} ['iftrue]
						#{b4} ['in]
						#{92} ['inclocal]
						#{c2} ['inclocal_i]
						#{91} ['increment]
						#{c0} ['increment_i]
						#{68} ['initproperty]
						#{b1} ['instanceof]
						#{b2} ['istype]
						#{b3} ['istypelate]
						#{10} ['jump]
						#{08} ['kill]
						#{09} ['label]
						#{ae} ['lessequals]
						#{ad} ['lessthan]
						#{38} ['lf32]
						#{35} ['lf64]
						#{36} ['li16]
						#{37} ['li32]
						#{35} ['li8]
						#{1b} ['lookupswitch]
						#{a5} ['lshift]
						#{a4} ['modulo]
						#{a2} ['multiply]
						#{c7} ['multiply_i]
						#{90} ['negate]
						#{c4} ['negate_i]
						#{57} ['newactivation]
						#{56} ['newarray]
						#{5a} ['newcatch]
						#{58} ['newclass]
						#{40} ['newfunction]
						#{55} ['newobject]
						#{1e} ['nextname]
						#{23} ['nextvalue]
						#{02} ['nop]
						#{96} ['not]
						#{29} ['pop]
						#{1d} ['popscope]
						#{24} ['pushbyte]
						#{2f} ['pushdouble]
						#{27} ['pushfalse]
						#{2d} ['pushint]
						#{31} ['pushnamespace]
						#{28} ['pushnan]
						#{20} ['pushnull]
						#{30} ['pushscope]
						#{25} ['pushshort]
						#{2c} ['pushstring]
						#{26} ['pushtrue]
						#{2e} ['pushuint]
						#{21} ['pushundefined]
						#{1c} ['pushwith]
						#{48} ['returnvalue]
						#{47} ['returnvoid]
						#{a6} ['rshift]
						#{6f} ['setglobalslot]
						#{63} ['setlocal]
						#{d4} ['setlocal_0]
						#{d5} ['setlocal_1]
						#{d6} ['setlocal_2]
						#{d7} ['setlocal_3]
						#{61} ['setproperty]
						#{6d} ['setslot]
						#{05} ['setsuper]
						#{3d} ['sf32]
						#{3d} ['sf32]
						#{3b} ['si16]
						#{3c} ['si32]
						#{3a} ['si8]
						#{ac} ['strictequals]
						#{c6} ['subtract_i]
						#{2b} ['swap]
						#{50} ['sxi_1]
						#{52} ['sxi_16]
						#{51} ['sxi_8]
						#{03} ['throw]
						#{95} ['typeof]
						#{a7} ['urshift]
					]["unknown!!!!!"]
				] true
				if args: switch op [
					#{86} [ABC/Cpool/multiname/(readUI30)] ;astype
					#{41} [readUI30] ;call - arg_count
					#{43} [reduce [readUI30 readUI30]] ;callmethod - index, arg_count
					#{46} [reduce [readUI30 readUI30]] ;callproperty - index, arg_count
					#{4c} [reduce [readUI30 readUI30]] ;callproplex - index, arg_count
					#{4f} [reduce [readUI30 readUI30]] ;callpropvoid - index, arg_count
					#{44} [reduce [readUI30 readUI30]] ;callstatic - index, arg_count
					#{45} [reduce [readUI30 readUI30]] ;callsuper - index, arg_count
					#{4e} [reduce [readUI30 readUI30]] ;callsupervoid - index, arg_count
					#{80} [ABC/Cpool/multiname/(readUI30)] ;coerce
					#{42} [readUI30] ;construct - arg_count
					#{4a} [[readUI30 readUI30]] ;constructprop - index, arg_count
					#{49} [readUI30] ;constructsuper - arg_count
					#{ef} [context [type: readUI8 name: ABC/Cpool/string/(readUI30) register: readUI8 extra: readUI30]] ;debug
					#{f1} [ABC/Cpool/string/(readUI30)] ;debugfile
					#{f0} [readUI30] ;debugline
					#{94} [readUI30] ;declocal - index
					#{c3} [readUI30] ;declocal_i - index
					#{6a} [ABC/Cpool/multiname/(readUI30)] ;deleteproperty
					#{06} [ABC/Cpool/string/(readUI30)] ;dxns
					#{5e} [ABC/Cpool/multiname/(readUI30)] ;findproperty
					#{5d} [ABC/Cpool/multiname/(readUI30)] ;findpropstrict
					#{59} [ABC/Cpool/multiname/(readUI30)] ;getdescendants
					#{6e} [readUI30] ;getglobalslot - slotindex
					#{60} [ABC/Cpool/multiname/(readUI30)] ;getlex
					#{62} [readUI30] ;getlocal - local register
					#{66} [ABC/Cpool/multiname/(readUI30)] ;getproperty
					#{65} [readUI30] ;getscopeobject - index
					#{6c} [readUI30] ;getslot - slotindex
					#{04} [ABC/Cpool/multiname/(readUI30)] ;getsuper
					#{32} [[readUI30 readUI30]] ;hasnext2
					#{13} [readS24] ;ifeq - offset
					#{12} [readS24] ;iffalse - offset
					#{18} [readS24] ;ifge - offset
					#{17} [readS24] ;ifgt
					#{16} [readS24] ;ifle
					#{15} [readS24] ;iflt
					#{14} [readS24] ;ifne
					#{0f} [readS24] ;ifnge
					#{0e} [readS24] ;ifngt
					#{0d} [readS24] ;ifnle
					#{0c} [readS24] ;ifnlt
					#{19} [readS24] ;ifstricteq
					#{1a} [readS24] ;ifstrictne
					#{11} [readS24] ;iftrue - offset
					#{92} [readUI30] ;inclocal
					#{c2} [readUI30] ;inclocal_i
					#{68} [ABC/Cpool/multiname/(readUI30)] ;initproperty
					#{b2} [ABC/Cpool/multiname/(readUI30)] ;istype
					#{10} [readS24] ;jump
					#{08} [readUI30] ;kill
					#{1b} [context [default_offset: readS24 offsets: readLookupOffsets]] ;lookupswitch
					#{56} [readUI30] ;newarray - arg_count
					#{5a} [readUI30] ;newcatch - index is a u30 that must be an index of an exception_info
					#{58} [ABC/ClassInfo/(readUI30)] ;newclass
					#{40} [ABC/MethodInfo/(readUI30)] ;newfunction
					#{55} [readUI30] ;newobject - arg_count
					#{24} [readUI8] ;pushbyte - byte_value
					#{2f} [ABC/Cpool/double/(readUI30)] ;pushdouble
					#{2d} [ABC/Cpool/integer/(readUI30)] ;pushint
					#{31} [ABC/Cpool/namespace/(readUI30)] ;pushnamespace
					#{25} [readUI30] ;pushshort
					#{2c} [ABC/Cpool/string/(readUI30)] ;pushstring
					#{2e} [ABC/Cpool/integer/(readUI30)] ;pushuint
					#{6f} [readUI30] ;setglobalslot - slotindex
					#{63} [readUI30] ;setlocal
					#{61} [ABC/Cpool/multiname/(readUI30)] ;setproperty
					#{6d} [readUI30] ;setslot
					#{05} [ABC/Cpool/multiname/(readUI30)] ;setsuper
				][
					result: insert/only result args
				]
				
			]
			clear head inBuffer
		]
		head result
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
		ABC/Version: reduce [readUI16 readUI16] 
		ABC/Cpool/integer:   (readS32array)
		ABC/Cpool/uinteger:  (readU32array)
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

	parse-DoABC2: does [probe as-string inBuffer reduce [
		readSI32   ;Flags
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

	

	
	
	