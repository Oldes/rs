rebol []
;rs/run/version/file %acompiler 'new %test.r


ctx1: context [
	translate: func [
	    code [block!] /local stack x pos push
	] [
		stack: copy []
	    push:  func [mv][insert/only tail stack mv]
	    parse code [some [
	    	pos:
	    	  set x block!   (push translate x )
	    	| set x integer! (push x + 1)
    	]]
    	stack
	]
]
print ["translated1:" mold ctx1/translate [1 [2 3] 4]]
tm 10000 [ctx1/translate [1 [2 3] 4]]

ctx2: context [
	push:  func [mv][insert/only tail stack mv]
	translate: func [
	    code [block!] /local stack x pos
	] [
		stack: copy []
		bind second :push 'stack
	    parse code [some [
	    	pos:
	    	  set x block!   (push translate x )
	    	| set x integer! (push x + 1)
    	]]
    	stack
	]
]

print ["translated2:" mold ctx2/translate [1 [2 3] 4]]
tm 10000 [ctx2/translate [1 [2 3] 4]]
halt

ctx: context [
	;stack: none
	translate: func [
	    code [block!] stack /local x pos push
	] [
		'stack
		print ["trans:" mold code mold stack]
	    
	    parse code [some [
	    	pos:
	    	  set x block!    (push translat x stack )
	    	| set x any-type! (push x + 1)
    	]]
    	probe head stack
	]
	push:  func [mv] [print ["push:" mold mv mold stack] insert/only tail stack mv] 
	;push:  func [mv] bind [print ["push:" mold mv mold stack] insert/only tail stack mv] first second :translate
]
translat: func[code][ctx/translate code copy [] ]
print ["translated:" mold translat [1 [2 3] 4]]


halt
ctx: context [
	;stack: copy []
	stack: none
	push:  func [mv][print ["push:" mold mv mold stack] insert/only tail stack mv]
	trans: func [
	    code [block!] stack /local x pos stackpos
	] [
		stack: :stck
		print ["transl:" mold code]
		;stackpos: index? stack
	    parse code [some [
	    	pos:
	    	  set x block! (
	    	  	print [">" mold stack]
	    	  	push copy/deep trans x stck
	    	  	print ["<" mold head stack]
	    	  )
	    	| set x integer! (push x + 1)
    	]]
    	;probe at stack stackpos
    	probe stack
	]
]

translate: func[code][ctx/trans code copy []]

	
print ["translated:" mold head translate [1 [2 3] 4 5] copy []]
halt

ctx1: context [
 	init-functions: func[/local stack push][
 		use [stack] copy/deep [
 			stack: copy []
 			push:  func [mv][probe stack insert/only tail stack mv]
 			return reduce [
				:push
			]
		]
	]
	probe functions: init-functions
	translate: func [
	    code [block!] /local stack x pos push
	] [
		;stack: copy []
		print ["trans:" mold code]
		set [push] bind functions 'stack
	    parse code [some [
	    	pos:
	    	  set x block!    (push translate x )
	    	| set x any-type! (push x)
    	]]
    	;probe head stack
    	stack
	]

]
print ["translated:" mold ctx1/translate [1 [2 3] 4]]

halt
ctx1: context [
	translate: func [
	    code [block!] /local stack x pos push
	] [
		print ["trans:" mold code]
	    push:  func [mv][insert/only tail stack mv]
		stack: copy []
	    parse code [some [
	    	pos:
	    	  set x block!    (push translate x )
	    	| set x any-type! (push x)
    	]]
    	probe head stack
	]
]
print ["translated:" mold ctx1/translate [1 [2 3] 4]]



halt 
ctx: context [
    push: func ["pøidej na zásobník" mv] [
    	;print ["PUSH" mv]
    	insert/only tail stack mv
    ]
    words: [push ]
	translate: func [
		[catch]
	    code [block!]
	    /local
		 stack
	     x pos
	] [

		print ["trans:" mold code]
		
		stack:   copy []
		bind 'stack ctx
	    parse code [some [
	    	pos:
	    	  set x  block! ( push copy translate x )
	    	| copy x any-type! (push x)
    	]]
    	probe head stack
	]
]

	
translate [1 [2 3] 4]