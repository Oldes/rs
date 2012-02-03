Rebol [
	title: "SWF creator"
	Author: "oldes"
    File:    %make-swf.r
    Email:   oliva.david@seznam.cz
    preprocess: true
]



ins:     func[b [binary!]][insert tail body b]
ins-act: func[b [binary!] /local tmp len][
	;print ["INS-ACT b:" mold b "action-push-buff:" mold action-push-buff]
	;print ["         action-bin-buff:" mold action-bin-buff]   
	if not empty? action-push-buff [
		either 150 = first b [
			;the binary I insert starts with actionPush
			;so I have to first remove this tag and place it onto the end of push-buffer
			len: to integer! reverse copy/part next b 2
			if (3 + len) < length? b [
				insert tail action-push-buff copy/part skip b 3 len
				b: remove/part b (3 + len)
				form-push/compact/nobuff action-push-buff
				clear action-push-buff
			]
		][
		
			;here should be optimalisation if first tag is push (b/1 = 150),
			;I should join it with the push in the push-buffer
			;probe action-bin
			
			;tmp: copy action-push-buff
			;clear action-push-buff
			;form-push/compact/nobuff tmp
			form-push/compact/nobuff action-push-buff
			clear action-push-buff
		]
	]
	insert tail action-bin b
]
ins-def: func[b [binary!]][
	;According spec, the definition tags are allowed only in the main body so this function
	;inserts directly into swf body or into definition dictionary buffer if we are insight a sprite definition
	insert tail any[dictionary-bin body] b
]

pause-on-warning?: on
quiet?: off
swf-version: 8
useConstantPool?: true
useFunc2?: true
use-web-includes?: true
cache-images?: true

utf8-encode?: true ;if I have strings already encoded, I need to turn off this switch!!!
	frames: 0

set-word: func[][
	;print ["Set-word:" mold set-word-buff]
	return current-set-word: either empty? set-word-buff [none][first set-word-buff]
]
	
init: does [
	FileAttributes: copy #{}
	ScriptLimits: copy #{}
	search-paths: reduce [
		what-dir
		rswf-project-dir
		rswf-root-dir
		join rswf-root-dir %includes/
		join rswf-root-dir %fonts/
		join rswf-root-dir %bitmaps/
	]
	system/options/binary-base: 32
	exported-assets: make block! 20 ;names of exported assets - it may be useful to know if you are not trying to set same names for different objects
	twips?: false
	swf-framerate: 12 ;default frame rate
	including: false ;to disable 'end and 'background tags in the included scripts
	included-files: make block! 5 ;this is used by 'require dialect word to store informations about files which are already included, so this file is not included only once
	body: make binary! 1000000

	animations: make block! 10 ;array which hold information of animations - processed before showframe action
	
	dictionary-bin:  none
	action-bin:      make binary! 10000
	action-bin-buff: make block!  1000

	sprite-recursion-buff: make block! 10
	max-bits: 0 ;I use this variable while converting integers to signed bytes
	set-word-buff: make block! 30 ;This variable will be set by any set-word! in the dialect
	current-set-word: none
	last-id: none	;This should hold the last used ID
	last-depth: 0
	used-ids: make block! 50 ;To be able find new ID that is not used yet, I need this var.
	stream: none ;used for sound streaming (object! if used)
		
	names-ids-table: make block! 100
;This block will hold informations, which which unique name is equal to which character ID.
;	For example:	[my_ball 10 shp_tree 12]
;	will be set by:	my_ball: Shape [id 10 ...] and so on
;	so I will be able to use:	PlaceObject my_ball [at 10x10]
;	instead of: PlaceObject 10 [at 0x0]

	placed-images:  make block! 100 ;to have informations about image sizes
	placed-objects: make block! 100	;to be able create simple animations from the dialect
;I must know some informations about already placed objects in the scene that has own names
;This table will looks like:
;[depth [offset]] - depth is the key ID for placed object, because it's not posible to animate more objects with the same depth

	;defined-objects: make block! 100 ;same as 'declared-funcs but for objects and their methods
	;defined-methods: make block! 100
	
	GUIcounters: make hash! 20
	acompiler/setLocalConstant 'lastBitmapWidth  none
	acompiler/setLocalConstant 'lastBitmapHeight none
	
	clear acompiler/strConstantPool
	
	clear swf-parser/swf-tag-parser/tag-checksums
 	recycle
 	true
]

string-replace-pairs: none

	
init

rename-font: func[font-tag [binary!] newName [string!] /local tmp][
	if 255 < length? newName [clear skip newName 255]
	font-tag: skip font-tag 2
	tmp: first font-tag ;length of the original name
	change font-tag int-to-ui8 length? newName
	change/part  next font-tag  newName tmp
	head font-tag
]


to-twips: func[v [number! pair!]][
	unless twips? [v: v * 20]
	either pair? v [v][to integer! v] 
]




load-img: func[file id /alpha /size sz /key kcolor /local tmp bin x y type ext jpg bll-file ico][
	;print [file id]
	bin:  copy #{}
	file: copy file
	ext:  last parse file "."
	file: get-filepath file
	either find ["jpg" "jpeg"] ext [
		;Jpegs
		either exists? file [
			if jpg: read-stripped-jpg file [
				if jpg/progressive? [
					print ["Warning: JPGs must be in saved as Baseline (standart) - this file is progressive JPG" file]
				]
				either all [size pair? sz][size: sz][ size: jpg/size ]
				ins-def form-tag 21 join set-id id jpg/binary
				insert placed-images reduce [last-id size]
			]
		][
			print ["Cannot find the image file" file "!!"]
		]
	][
		;bitsLossless
		either all [
			find ["ico" "bmp" "png"] ext
			none? key
		][
			;Using ImageCore for loading image..
			bll-file: rejoin [file %.bll]
			type: 36
			either all [
				cache-images?
				any [
					exists? tmp: bll-file
					exists? tmp: rswf-root-dir/:bll-file
					exists? tmp: rswf-project-dir/:bll-file
				]
				exists? file
				(modified? file) < (modified? tmp)
			][
				;temp file exists and is uptodate
				bin: read/binary bll-file
				parse/all bin [1 skip copy x 2 skip copy y 2 skip to end]
				size: to pair! reduce [bin-to-int as-binary x bin-to-int as-binary y]
			][
				;there is no temp file yet or it's older than source file
				if none? bin: ImageCore/load file [
					print ["Cannot load image:" mold file]
					return none
				]
				size: bin/size
				bin: ImageCore/ARGB2BLL bin
					
				if cache-images? [error? try [write/binary bll-file bin]]
				
			]
		][
			type: either any [alpha key] [36][20]
			bll-file: rejoin [file "." type]
			either all [
				cache-images?
				any [
					exists? tmp: bll-file
					exists? tmp: rswf-root-dir/:bll-file
					exists? tmp: rswf-project-dir/:bll-file
				]
				exists? file
				(modified? file) < (modified? tmp)
			][
				bin: read/binary bll-file
			][
				switch type [
					36 [
						write/binary bll-file bin: either alpha [
							;print "alpha img-to-bll"
							img-to-bll-alpha file
						][	img-to-bll/key file either key [kcolor][123.109.57] ]
					]
					20 [write/binary bll-file bin: img-to-bll file]
				]
			]
			parse/all bin [1 skip copy x 2 skip copy y 2 skip to end]
			size: to pair! reduce [bin-to-int as-binary x bin-to-int as-binary y]
		]
		ins-def form-tag type join set-id id bin
		insert placed-images reduce [last-id size]
	]
	if pair? size [
		acompiler/setLocalConstant 'lastBitmapWidth  size/x
		acompiler/setLocalConstant 'lastBitmapHeight size/y
	]
]

create-img: func[img [image!] id /param par /local type kcolor][
	type: 20
	if all [param block? par] [
		parse par [some ['key set kcolor tuple! (type: 36) | any-type!]]
	]
	ins-def form-tag type join either none? id [set-id id][set-id/as id] either type = 20 [img-to-bll img][img-to-bll/key img kcolor]
	insert placed-images reduce [last-id img/size]
]

get-id: func[
	"Will try to find the ID and sets the last-id"
	char	[word! integer!]	"The characters name"
	/local id
][
	id: either integer? char [char][select names-ids-table char]
	if none? id [
		make-warning!/msg none ["Invalid get-id: " mold char]
		id: last-id + 1
	]
	last-id: id
]

get-new-id: func[][
	either empty? used-ids [1][
		1 + last sort used-ids
	]
]
pop-set-word: func[/local sw][
	either empty? set-word-buff [none][
		sw: first set-word-buff 
		remove set-word-buff
		sw
	]
]
do-set-word: func[i /as word /local f w][
	w: either as [word][set-word]
	unless none? w [
		either found? f: find/tail/last names-ids-table w [
			change f i
		][
			insert tail names-ids-table reduce [w i]
		]
		unless as [remove set-word-buff]
	]
]
set-id: func[id /as][
	unless integer? id [
		if as [id-word: id]
		id: get-new-id
	]
	unless find used-ids id [insert tail used-ids id]
	either as [
		do-set-word/as id id-word
	][	do-set-word id]
	last-id: id
	int-to-ui16 id
]

make-warning!: func[val /msg m][
	prin "WARNING: "
	print either msg [m][
		ajoin [
			"misplaced item: " mold first val newline
			"   NEAR: " copy/part val 4 " ..."
		]
	]
	if pause-on-warning? [ask "Press ENTER to continue!"]
]

get-filepath: func[
	"Returns filename with path."
	file
	/local f local-file local-dir host
][
	foreach dir search-paths [
		if exists? f: dir/:file [return f]
	] 
	return case [
		;any [
		;	exists? f: file (f false)
		;	exists? f: rswf-project-dir/:file (f false)
		;	exists? f: rswf-root-dir/:file (f false)
		;	exists? f: rswf-root-dir/includes/:file (f false)
		;	exists? f: rswf-root-dir/fonts/:file (f false)
		;	exists? f: rswf-root-dir/bitmaps/:file (f false)
		;][	f ]
				
		all [
			use-web-includes?
			(print ["Looking for: " rswf-web-url/:file] true)
			exists? f: rswf-web-url/:file url? f
		][
			print ["Downloading from web:" f]
			local-dir:  join rswf-root-dir %downloaded/
			unless exists? local-dir [
				make-dir/deep local-dir
			]
			parse form f [thru "//" copy host thru "/" copy local-file to end]
			replace host ":" "_atport_"
			local-file: to-file rejoin [local-dir host local-file]
			read-thru/to f local-file
			local-file
		]
		true [file]
	]
]


;-----------------------------------------
bin-to-int: func[bin][to integer! reverse bin]
extend-int: func[num /local i][
	i: num // 8
	if i > 0 [num: num + 8 - i]
	num
]


byte-align: func[bits [string!] /local p][
	p: (length? bits) // 8
	if p > 0 [insert/dup tail bits #"0" 8 - p]
	bits
]

bits-to-bin: func[bits [string!]][debase/base byte-align bits 2]


comment {
;is this function used?
int-to-si16: func[i [number!] /local n][
	n: i < 0
	if i > 32767 [i: i - (32767 // i)]
	i: reverse int-to-ui16 abs i
	if n [i: i or #{8000}]
	reverse i
]
}
;int-to-sb16: func[int [integer!]][reverse copy skip load rejoin ["#{" to-hex int "}"] 2]
int-to-sb16: :int-to-ui16

bits-needed: func[
	"Counts the less number of bits needed to hold the integer"
	i [integer!]
][
	either i = 0 [0][1 + to integer! log-2 abs i]
]

ints-to-sbs: func[
	ints [block!]	 "Block of integers, that I want to convert to SBs"
	/complete l-bits "Completes the bit-stream => l-bits stores the nBits info of the values"
	;/maxb mb
	/local b b2 l bits sb
][
	ints: reduce ints
	max-bits: 0
	bits: make block! length? ints
	foreach i ints [
		;b: enbase/base load rejoin ["#{" to-hex i "}"] 2
		b: enbase/base reverse int-to-ui32 i 2
		b: find b either i < 0 [#"0"][#"1"]
		b: copy either none? b [either i >= 0 ["00"]["11"]][back b]
		;insert b either i >= 0 [#"0"][#"1"]
		if max-bits < l: length? b [max-bits: l]
		append bits b
	]
	foreach b bits [
		if max-bits > l: length? b [
			insert/dup b b/1 max-bits - l
		]
	]
	either complete [
		sb: int-to-bits max-bits l-bits
		foreach b bits [insert tail sb b]
		sb
	][	
		bits
	]
]

int-to-FB: func[i /local x y fb][
	x: to integer! i
	y: to integer! (either x = 0 [i][i // x]) * 65535
	fb: rejoin [either x = 0 ["0"][first ints-to-sbs to block! x] int-to-bits y 16]
	if all [x = 0 i < 0][fb/1: #"1"]
	fb
]


form-tag: func[
	"Creates the SWF-TAG"
		id [integer!]	"Tag ID"
		data [binary!]	"Tag data block"
		/local len
][
	;print ["FORMTAG" id]
		either any [
			62 < len: length? data
			not none? find [2 20 34 36 37 48] id
		] [
			;print ["Long tag:" len id]
			abin [
				int-to-ui16 (63 or (id * 64))
				int-to-ui32 len
				data
			]
		][
			;print ["Short tag:" len id]
			abin [
				int-to-ui16 (len or (id * 64))
				data
			]
		]
]

form-metadata: func[data [string! block!] /local metadata][
	metadata: either block? data [
		metadata: make string! 500
		foreach [tag val] data [
			tag: lowercase to-string tag
			append metadata rejoin [{<dc:} tag {>} val {</dc:} tag {>}]
		]
		ajoin [
			{<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">}
			{<rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/1.1/">}
			metadata
			{</rdf:Description></rdf:RDF>}
		]
	][data]
	;form-tag 77 join utf8/encode metadata #{00}
	copy #{}
]


showFrame: func[/local constantPool tmp][
	foreach animation animations [
				use [bin flags m a][
					bin: make binary! 40
					flags: make string! "00000001"
					;m: select val2 'multiply
					;a: select val2 'add
					;if any [not none? a	not none? m	][
					;	insert bin bits-to-bin create-cxform/withalpha m a
					;	flags/5: #"1"
					;]
					if all [block? animation/2 not tail? animation/2][
						insert bin bits-to-bin create-matrix first animation/2 copy [rotate 0]
						flags/6: #"1"
						animation/2: next animation/2
					]
					insert bin int-to-ui16 animation/1
					insert bin load rejoin ["2#{" flags "}"]
		 			ins form-tag 26 bin
				]
		;	]
		;]
	]
	;streaming:
	unless none? stream [
		if none? mp3/frame [
			mp3/getMp3Frame stream/port
		]
		if stream/MakeHead? [
			ins create-soundStreamHead
			stream/MakeHead?: false
		]
		either none? mp3/frame [
			;print ["end of stream at frame:" frames]
			close stream/port
			stream: none
		][
			create-soundStreamBlock
		]
	]
	;---
	unless empty? action-bin [
		either empty? acompiler/strConstantPool [
			ins form-tag 12 abin [action-bin #{00}]
		][
			constantPool: make binary! 10000
			foreach string acompiler/strConstantPool [
				insert tail constantPool abin [string #"^@"]
			]
			ins form-tag 12 abin [
				#{88}
				int-to-ui16 length? tmp: abin [int-to-ui16 length? acompiler/strConstantPool constantPool]
				tmp
				action-bin #{00}
			]
			clear acompiler/strConstantPool
		]
		;print ["INSERT ActionTag CP:" length? ConstantPool mold ConstantPool]
		clear action-bin
	]
	;init classes for swf7:
	;compile-classes
	;---
	;print ["SHOWFRAME-sprite-depth:" length? sprite-recursion-buff]
	ins form-tag 1 #{}
	frames: frames + 1
	do-set-word frames + 1
]


create-cxform: func[
	"Creates Color Transform Record (in bits)"
	mult [none! integer! tuple! block!] "Multiplication Transforms"
	addi [none! integer! tuple! block!] "Addition Transforms"
	/withalpha	"Colors are with alpha channel"
	/local bl bits prep
][
	if all [none? mult none? addi][return "00000100"]
	bits: make string! 64
	bl: make block! 8
	prep: func[v /local b l][
		b: make block! 4
		either integer? v [
			insert/dup b v 3
		][
			repeat i l: length? v [append b max min pick v i 256 -256]
		]
		if all [withalpha l <> 4][append b 256]
		b
	]
	insert bits either none? mult [#"0"][append bl prep mult #"1"]
	insert bits either none? addi [#"0"][append bl prep addi #"1"]
	head insert tail bits ints-to-sbs/complete bl 4 
]

create-matrix: func[
	transp [pair! block!]	"Transposition offset"
	other [block!]	"Scale and rotation info"
	/local bits v lx ly l scy scx sk0 sk1 ro sc
][
	bits: make string! 64
	scy: scx: 1
	sk0: sk1: 0
	;print ["create-matrix:" mold other]
	if not none? ro: select other 'rotate [
		if number? ro [ro: reduce [ro ro]]
		scx: cosine ro/1
		scy: cosine ro/2
		sk0: sine ro/1
		sk1: negate sine ro/2
	]
	if not none? sc: select other 'scale [
		if number? sc [sc: reduce [sc sc]]
		scx: scx * sc/1
		scy: scy * sc/2
		sk0: sk0 * sc/1
		sk1: sk1 * sc/2
	]
	if not none? v: select other 'skew [
		v: reduce either number? v [[v v]][[v/1 v/2]]
		v: reduce [v/1 / 360 v/2 / 360]
		sk0: sk0 + v/2
		sk1: sk1 + v/1
	]
	if not none? v: select other 'reflect [
		v: reduce either number? v [[v v]][[v/1 v/2]]
		scx: scx * v/1
		scy: scy * v/2
	]
	;print ["==" scx scy sk0 sk1]
	append bits either any [scx <> 1 scy <> 1][
		scx: int-to-FB scx
		scy: int-to-FB scy
		lx: length? scx
		ly: length? scy
		
		either lx > ly [
			insert/dup scy scy/1 lx - ly
			l: lx
		][	insert/dup scx scx/1 ly - lx
			l: ly
		]
		rejoin [#"1" int-to-bits l 5 scx scy]
	][ #"0" ]
	append bits either any [sk0 <> 0 sk1 <> 0][
		sk0: int-to-FB sk0
		sk1: int-to-FB sk1
		lx: length? sk0
		ly: length? sk1
		either lx > ly [
			insert/dup sk1 sk1/1 lx - ly
			l: lx
		][	insert/dup sk0 sk0/1 ly - lx
			l: ly
		]
		rejoin [#"1" int-to-bits l 5 sk0 sk1]
	][ #"0" ]
	append bits either all [transp/1 = 0 transp/2 = 0]["00000"][
		ints-to-sbs/complete [transp/1 transp/2] 5
	]
	;probe bits
]

create-rect: func [min-pos max-pos /bin /local rect][
	rect: ints-to-sbs/complete [min-pos/x max-pos/x min-pos/y max-pos/y] 5
	either bin [bits-to-bin rect][ rect ]
]

start-sprite-creation: does [
	if none? dictionary-bin [dictionary-bin: make binary! 500000]
	insert/only sprite-recursion-buff reduce [frames copy body]
	insert/only sprite-recursion-buff reduce [
		copy action-bin
		copy set-word-buff
		last-depth
	]
	clear action-bin
	clear set-word-buff
	last-depth: frames: 0
	body: make binary!  10000
]

finish-sprite-creation: func[id /local spr][
	set [
		action-bin set-word-buff last-depth
	] first sprite-recursion-buff
	remove sprite-recursion-buff
	spr: rejoin [
		id: set-id val
		int-to-ui16 frames
		body
	]
	set [frames body] first sprite-recursion-buff
	remove sprite-recursion-buff
	if empty? sprite-recursion-buff [
		ins dictionary-bin
		dictionary-bin: none
	]
	spr
]

compile-sprite: func[val val2 val3 /local spr id][
	either binary? val2 [
		ins-def form-tag 39 abin [id: set-id val val2]
	][
		if word? val2 [	val2: compose [place (val2) showFrame end]]
		start-sprite-creation
		compile val2
		if #{40000000} <> copy/part skip tail body -4 4 [
			;missing showFrame and end tag at the end
			;else Scaleform player crashes
			showFrame
			append body #{0000}
		]
		ins-def form-tag 39 finish-sprite-creation val
		id: last-id
	]
	if not none? val3 [ doInitAction id val3 ]
	id
]

doInitAction: func[id val][
	unless empty? action-bin [
		ins form-tag 12 abin [aCompiler/get-CP-tag action-bin #{00}]
		clear action-bin
	]
	insert action-bin either binary? val [	val	][ compile-actions val ]
	ins-def form-tag 59 abin [
		either binary? id [id][int-to-ui16 get-id id] ;sprite id
		aCompiler/get-CP-tag
		action-bin #{00}
	]
	clear action-bin
]

ExportAssets: func[assets [block!] /local bin][
	bin: make binary! 10
	insert bin int-to-ui16 (length? assets) / 2
	foreach [id name] assets [
		name: either utf8-encode? [utf8/encode name][name]
		either find exported-assets name [
			make-warning!/msg none reform ["Reusing assets: " name]
		][	insert tail exported-assets name ]
		append bin abin [int-to-ui16 get-id id name #{00}]
	]
	ins-def form-tag 56 bin
]

create-class: func[definition [block!] extends [word! none!] with [block! none!]  /local name id][
	probe name: first set-word-buff
	id: form name
	either none? select names-ids-table name [
		ins-def form-tag 39 abin [set-id none #{010040000000}] ;creates EmptySprite
	][
		print ["Creating class for existing character:" id]
	]
	ExportAssets reduce [name id]
		
	code: compose/only [
		(to-set-word name)
		(either none? extends ['Class]['Extends])
		(any [extends ()])
		(definition)
		Object.registerClass( to-paren reduce [id  name] )
	]
	if block? with [append code with]
	;probe code
	doInitAction name code
]

include-files: func[files [block! file! url!] /unique /local not-included? data f][
	unless block? files [files: reduce [files]]
	foreach file files [
		if any [
			not-included?: none? find included-files file
			none? unique
		][
			including: true
			either any [
				not none? f: get-filepath file
			][
				print ["Including:" f]
				if not-included? [ insert included-files file ]
				if block? data: load/header f [
					if all [
						not error? try [data/1/preprocess]
						data/1/preprocess
					][
						process-source data 0
					]
					compile next data
				]
			][
				make-warning!/msg none ["Cannot include file:" file]
			]
			including: false
		]
	]
]

compile: func[data [block! string!] /rules rul][
	if string? data [data: load data]
	parse data either rules [rul][tag-rules]
]

create-header: func[version size rate frames][
	abin [
		#{465753}
		int-to-ui8 version
		#{00000000}						;length of file
		create-rect/bin 0x0 size * 20	;size
		#{00} int-to-ui8 rate			;rate
		int-to-ui16 frames				;frames
	]
]

set 'create-swf func[
	size [pair!] "Size of the flash file in pixels!"
	content [block! binary!]
	/rate r
	/version v
	/compressed compressed?
	/metadata mtd [block!]
	/local header swf tmp constantPool
][
	init
	swf: make binary! 10000
	swf-version: acompiler/swf-version: either version [v][8]
	swf-framerate: either rate [r][12]
	
	
	
	
	if not metadata [
		mtd: [
			title: "Rebol/Flash dialect made file"
			publisher: "David 'Oldes' Oliva"
		]
	]
	ins-def form-metadata mtd ;insert metadata as a first tag
	
	either binary? content [
		append body content
	][
		compile content
	]
	
	;probe acompiler/strConstantPool


	;print [">>>>> FileAttributes:" mold FileAttributes]
	
	either compressed? [
		tmp: abin [
			create-rect/bin 0x0 size * 20	;size
			#{00} int-to-ui8 swf-framerate	;rate
			int-to-ui16 frames				;frames
			FileAttributes
			ScriptLimits
			;;;;;constantPool                    ;global constantPool
			body
		]
		swf: abin [
			#{435753}
			int-to-ui8  swf-version
			int-to-ui32 8 + length? tmp
			compress tmp

			;head remove/part tail compress tmp -4
		]
	][
		header: create-header swf-version size swf-framerate frames
		swf: abin [header FileAttributes ScriptLimits body]
		;now set the FileLength!
		change/part skip swf 4 int-to-ui32 length? swf 4
	]
	frames: 0
	swf
]

make-html: func[src size color][
	if not issue? color [
		parse mold to-binary color [thru "#{" copy color to "}"]
	]
	id: copy last split-path to-file src
	replace/all id "." "_"
	rejoin [{
<HTML>
<HEAD>
<TITLE>Rebol/Flash - } src {</TITLE>
</HEAD>
<BODY bgcolor="#} color {">
<table width="100%" height="100%"  style="font-family: sans-serif; font-size: 9pt;">
<tr><td width="100%" height="100%" align="CENTER" valign="MIDDLE">
<OBJECT classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
 codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=} swf-version {,0,0,0"
 WIDTH="} size/x {" HEIGHT="} size/y {" id="} id {" ALIGN="center">
 <PARAM NAME=movie VALUE="} src {">
 <PARAM NAME=quality VALUE=high>
 <PARAM NAME=bgcolor VALUE=#} color {>
 <EMBED src="} src {"
  quality="high"
  bgcolor="#} color {"
  WIDTH="} size/x {"
  HEIGHT="} size/y {"
  NAME="} id {"
  ALIGN="center"
  TYPE="application/x-shockwave-flash"
  PLUGINSPAGE="http://www.macromedia.com/go/getflashplayer"
 ></EMBED>
</OBJECT>
<script tyle="text/javascript">
//<![CDATA[
document.getElementById('} id {').focus();
//]]>
</script>
</td></tr>
</table>
</BODY>
</HTML>
}]
]
set 'make-swf func[
	"Creates SWF file (MACROMEDIA FLASH) from Rebol/Flash dialect file" [catch]
	file [file! url!] "Dialect file co compile"
	/html	"Will create a HTML file as well (only with the save switch!)"
	/save	"Save result into file set in the rswf-header"
	/to	out-file "if saving than into this file instead of the file set in the header"
	/compressed	"Compressed swf file"
	/local bin data was-dir swf-file html-file f err
][
	init
	if url? file [
		read-thru/to/update file file: join what-dir last split-path file
	]
	if not exists? file [
		either any [
			exists? f: join file ".rswf"
			exists? f: join rswf-root-dir file
			exists? f: join rswf-root-dir [file ".rswf"]
		][file: f][print ["Cannot found the file" file "!"] halt]
	]
	if error? set/any 'err try [
		data: load/header file
	][
		print "!!! ERRROR: Cannot load script file!"
		probe disarm err
		return none
	]
	recycle	;print ["1)====" stats]
	if all [
		not error? try [data/1/preprocess]
		data/1/preprocess
	][
		process-source data 0
	]
	recycle	;print ["2)====" stats]	
	if not integer? swf-version: data/1/type [
		if none? swf-version: select [
			swf  4
			swf5 5
			swf6 6
			mx   6
			mx2004 7
			swf7 7
			swf8 8
		] swf-version [ swf-version: 6 ]
	]
	acompiler/swf-version: swf-version
	
	
	was-dir: what-dir
	if error? try [change-dir data/1/base-dir][
		change-dir first split-path file
	]
	error? try [compressed: data/1/compressed]
	frames: 0
	recycle ;print ["3)====" stats]	
	bin: create-swf/rate/version/compressed data/1/size next data data/1/rate swf-version compressed
	recycle	;print ["3b)====" stats]	
	if all [data/1/file save][
		write/binary swf-file: either to [out-file][data/1/file] bin
		if html [
			html-file: append (copy/part swf-file ((length? swf-file) - 3)) "html"
			write/binary html-file make-html (last parse swf-file "/") data/1/size data/1/background
		]
		recycle	;print ["4)====" stats]	
		clear bin
		bin: none
	]
	change-dir was-dir
	recycle	;print ["5)====" stats]	
	bin
	
]
