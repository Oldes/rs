;; ====================================================
;; Script: xml-dom.r
;; downloaded from: www.REBOL.org
;; on: 2-Nov-2010
;; at: 9:43:42.14025 UTC
;; owner: chrisrg [script library member who can update
;; this script]
;; ====================================================
REBOL [
	Title: "XML/DOM"
	Date: 15-Dec-2008
	Author: "Christopher Ross-Gill"
	Type: 'module
	Exports: [load-xml]
	Version: 0.1.2
	File: %xml-dom.r
	Purpose: {A rudimentary in-memory XML interpreter and interface.}
	Notes: {
		Features: utilizes REBOL datatypes to represent XML structure;
		DOM methods for extraction; self-contained and works with /Base;
		prettified block structure.

		Caveat: destructive - discards whitespace and comments; does not
		preserve empty tags vs. matching tags with no content; NOT an
		implementation of W3 DOM, only a loosely inspired subset.

		ToDo: saving.
	}
	Library: [
		Level: 'intermediate
		Platform: 'all
		Type: [module dialect function]
		Domain: [html markup parse text web xml]
		License: 'cc-by-sa
	]
	Usage: [
		test: {<a><b><c id="d">Text</c> <c id="e" /></b></a>}
		load-xml test
		doc: load-xml/dom test
		doc/get-by-tag <c>
		c: doc/get-by-id "d"
		c/text
		doc/tree/<a>/<b>
	]
]

load-xml: use [
	xml! doc make-node
	space word decode entity text name attribute element header content
][
	xml!: context [
		name: value: tree: branch: position: none

		flatten: does [""]

		get-by-tag: func [tag /local result rule mk][
			result: copy []
			parse tree rule: [
				some [
					opt [mk: tag skip (append result make-node mk) :mk]
					skip [into rule | skip]
				]
			] result
		]

		get-by-id: func [id /local result rule mk][
			parse tree rule: [
				some [
					  mk: tag! into [thru /id id to end] (result: make-node mk) end skip
					| skip [into rule | skip]
				]
			] result
		]

		text: has [result][
			case/all [
				string? value [result: value]
				block? value [
					result: all [
						parse value [any [refinement! skip] # set result string!]
						result
					]
				]
				string? result [trim/auto copy result]
			]
		]

		get: func [name [refinement! tag!] /local result mk][
			if parse tree [
				tag! into [
					any [
						  mk: name [block! (result: make-node mk) | set result skip] to end
						| [refinement! | tag! | issue!] skip
					]
				]
			][result]
		]

		sibling: func [/before /after][
			case [
				all [after find [tag! issue!] type?/word position/3] [
					make-node skip position 2
				]
 				all [before find [tag! issue!] type?/word position/-2] [
					make-node skip position -2
				]
			]
		]

		parent: "Need position stack"

		children: has [result mk][
			result: copy []
			parse case [
				block? value [value] string? value [reduce [# value]] none? value [[]]
			][
				any [refinement! skip]
				any [mk: [tag! | issue!] skip (append result make-node mk)]
			]
			result
		]

		clone: does [make-node tree]

		append-child: func [name data /local at][
			case [
				none? position/2 [value: tree/2: position/2: copy []]
				string? position/2 [
					new-line value: tree/2: position/2: compose [# (position/2)] true
				]
			]

			either refinement? name [
				parse position/2 [any [refinement! skip] at:]
			][at: tail position/2]

			insert at reduce [name data]
			new-line at true
		]

		append-text: func [text][
			case [
				none? position/2 [value: tree/2: position/2: text]
				string? position/2 [append position/2 text]
				# = pick tail position/2 -2 [append last position/2 text]
				block? position/2 [append-child # text]
			]
		]

		append-attr: func [name value][
			append-child to-refinement name value
		]
	]

	doc: make xml! [
		branch: make block! 10
		document: true
		new: does [clear branch tree: position: reduce ['document none]]

		open-tag: func [tag][
			insert/only branch position
			tree: position: append-child to-tag tag none
		]

		close-tag: func [tag][
			tag: to-tag tag
			while [tag <> position/1][
				probe reform ["No End Tag:" position/1]
				if empty? branch [make error! "End tag error!"]
				take branch
			]
			tree: position: take branch
		]
	]

	make-node: func [here /base][
		make either base [doc][xml!][
			position: here
			name: here/1
			value: here/2
			tree: reduce [name value]
		]
	]

	space: use [space][
		space: charset "^-^/^M "
		[some space]
	]

	word: use [w1 w+][
		w1: #[bitset! 64#{AAAAAAAAAAD+//+H/v//B/////////////////////8=}]
		w+: #[bitset! 64#{AAAAAABg/wP+//+H/v//B/////////////////////8=}]
		[w1 any w+]
	]

	decode: use [nm hx rf mk ex ns entity to-utf-char][
		nm: #[bitset! 64#{AAAAAAAA/wMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=}]
		hx: #[bitset! 64#{AAAAAAAA/wN+AAAAfgAAAAAAAAAAAAAAAAAAAAAAAAA=}]
		ns: ["lt" 60 "gt" 62 "amp" 38 "quot" 34 "apos" 39]

		to-utf-char: use [os fc en][
			os: [0 192 224 240 248 252]
			fc: [1 64 4096 262144 16777216 1073741824]
			en: [127 2047 65535 2097151 67108863 2147483647]

			func [int [integer!] /local char][
				repeat ln 6 [
					if int <= en/:ln [
						char: reduce [os/:ln + to integer! (int / fc/:ln)]
						repeat ps ln - 1 [
							insert next char (to integer! int / fc/:ps) // 64 + 128
						]
						break
					]
				]

				to-string to-binary char
			]
		]

		entity: [
			mk: #"&" [
				  copy rf word ";" (rf: any [select ns rf 63])
				| #"#" [
					  #"x" copy rf 2 4 hx ";" (rf: to-integer to-issue rf)
					| copy rf 2 5 nm ";" (rf: to-integer rf)
				]
			] ex: (mk: change/part mk to-utf-char rf ex) :mk
		]

		func [text [string!]][
			if parse/all text [any [to "&" [entity | skip]] to end][text]
		]
	]

	entity: use [nm hx][
		nm: charset "0123456789"
		hx: charset "0123456789abcdefABCDEF"
		[#"&" [word | #"#" [1 5 nm | #"x" 1 4 hx]] ";" | #"&"]
	]

	text: use [char value][
		char: complement charset "^-^/^M &<"
		[
			copy value [
				opt space [char | entity]
				any [char | entity | space]
			] (doc/append-text decode value)
		]
	]

	name: [word opt [":" word]]

	attribute: use [q1 q2 attr value][
		q1: complement charset {"&<}
		q2: complement charset {&'<}
		[	space copy attr name opt space "=" opt space [
				; lone ampersand is 'loose' not 'strict'
				  {"} copy value any [q1 | entity | "&"] {"}
				| {'} copy value any [q2 | entity | "&"] {'}
			] (doc/append-attr attr decode any [value ""])
		]
	]

	element: use [tag value][
		[	#"<" [
				copy tag name (doc/open-tag tag) any attribute opt space [
					  "/>" (doc/close-tag tag)
					| #">" content "</" copy tag name (doc/close-tag tag) opt space #">"
				]
				| #"!" [
					  "--" copy value to "-->" 3 skip ; (doc/append-child #comment value)
					| "[CDATA[" copy value to "]]>" 3 skip (doc/append-text value)
				]
			]
		]
	]

	header: [
		any [
			  space 
			| "<" ["?xml" thru "?>" | "!" ["--" thru "-->" | thru ">"] | "?" thru "?>"]
		]
	]

	content: [any [text | element | space]]

	load-xml: func [document /dom /local root][
		if any [file? document url? document][document: read document]
		root: doc/new
		parse/all/case document [header element to end]
		doc/tree: any [root/document []]
		doc/value: doc/tree/2
		either dom [make-node/base doc/tree][doc/tree]
	]
]