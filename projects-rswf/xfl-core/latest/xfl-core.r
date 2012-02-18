REBOL [
	Title:   "XFL-core"
	Date:    14-Feb-2012/20:07:22+1:00
	Author:  "Oldes"
	Purpose: {This is core script for manipulations with XFL files}
	Version: 0.1.0
	History: [
		0.1.0 14-Feb-2012 {Initial review of the original quick-coded %xfl.r script}
	]
	require: [
		rs-project 'utf8-cp1250
		rs-project 'form-xml
		rs-project 'xml-parse
		;used for binary image manipulations:
		rs-project 'imagick 'minimal
		rs-project 'premultiply
		rs-project 'binary-conversions
		;rs-project 'imageCore
		rs-project 'stream-io
		rs-project 'zlib
	]
	preprocess: true
	usage: [
		with ctx-XFL [
			parse-xfl init/into-dir %tests/combine-bmps/ %tests/combine-bmps-result/
		]
	]
]

ctx-XFL: context [
	xfl-source-dir:   none
	xfl-target-dir:   none
	xfl-name:         none
	DOMDocument:      none
	xmldom:           none
	Media:            copy []
	Media-content:    copy []
	Symbols:          copy []
	tabs:             copy ""
	Shape:            copy []
	Shape-bounds:     copy []
	BmpFills:         copy []
	Media-to-remove:  copy []
	Shape-counter:    copy []
	Media-counter:    copy []
	Symbol-counter:   copy []
	files-to-parse:   copy []
	
	scale-x: 
	scale-y: 1
	
	verbose: 1
	
	num-imported: 0 ;imported media files counter
	
	actions-stack:           copy [none]
	xfl-current-action:      none
	xfl-current-action-name: none
	nodes-stack:             tail copy/deep [[none none none]]
	current-node:            none   
	dom-symbols:             none
	act-state:               none
	current-symbol:          none
	
	tmp_shapeMinPos:         99999999x99999999
	tmp_isSymbolGraphic?:    none
	
	_s: _n: none
	
	ch_space:   charset " ^-^M^/"
	ch_digits:  charset "0123456789"
	ch_notname: charset {="}
	ch_name:    complement union ch_space ch_notname
	ch_value:   complement charset {"}
	ch_hex:     charset "0123456789ABCDEF"

	SP:           [any ch_space]
	rl_edgNumber: [SP opt [#"+" | #"-"] some ch_digits opt [#"." some ch_digits]]
	rl_hexNum: [#"#" copy _n [some ch_hex #"." some ch_hex] (
			trim _n
			_s: find n #"." remove _s if 1 = length? _s [append _s "0"] ;removes dot and aligns the number after it
			_n: (to integer! debase/base head insert/dup _n #"0" (length? _n) // 2 16) / 256
		)
	]
	
	to-DOM: func[str [string! block!]][
		third parse-xml+/trim either block? str [rejoin str][str]
	]

	#include %dat-functions.r
	
	XFL-action-rules: [
		;this default rule just traverse thru all nodes and does nothing else:
		DOMDocument_TraverseOnly [
			to end ( ;passes all node names
				if content [parse-xfl content]
			)
		]
	]
	
	clear-values: does [
		DOMDocument: xmldom:   none
		clear head Media
		clear head Media-content
		clear head Symbols
		clear head tabs
		clear head Shape
		clear head Shape-bounds
		clear head BmpFills
		clear head Media-to-remove
		clear head Shape-counter
		clear head Media-counter
		clear head Symbol-counter
		clear head files-to-parse
		
		scale-x: 
		scale-y: 1
		num-imported: 0
		
		actions-stack:           copy [none ]
		xfl-current-action:      none
		xfl-current-action-name: none
		nodes-stack: tail copy/deep [[none none none]]
		current-node: none  
		dom-symbols:  none
		
		act-state:
		current-symbol: none
		
		tmp_shapeMinPos: 99999999x99999999
		tmp_isSymbolGraphic?: none
	]
	
	init: func[
		"Init XFL environment"
		source-dir        [file!] "XFL source directory"
		/into-dir target-dir  [file!] "Optional XFL target directory"
	][
		xfl-source-dir:  source-dir
		;uses full dir path:
		if #"/" <> first xfl-source-dir [insert xfl-source-dir what-dir]
		
		print ["XFL INIT: [" xfl-source-dir "]"]
	
		xfl-target-dir:  either into-dir [
			target-dir
		][
			print "=============================================================="
			print "=== XFL target dir not specified, the source will be used! ==="
			print "=============================================================="
			ask   "[Press ENTER to continue]"
			xfl-target-dir: xfl-source-dir
		]
		
		if xfl-target-dir [
			if #"/" <> first xfl-target-dir [insert xfl-target-dir what-dir]
		]
		
		clear-values

		if xfl-target-dir <> xfl-source-dir [
			either exists? xfl-target-dir [
				call/wait probe rejoin ["del /Q /S /A:-S /A:-H /A:-R " to-local-file xfl-target-dir "\*"]
			][  make-dir/deep xfl-target-dir ]
			copy-dir xfl-source-dir xfl-target-dir
		]
		
		;remove the XFL's cache file which is not documented and so not supported
		;it will force Flash IDE to recreate it properly
		error? try [delete xfl-target-dir/bin/SymDepend.cache]

		append actions-stack xfl-current-action-name: 'DOMDocument_TraverseOnly
		xfl-current-action: select XFL-action-rules xfl-current-action-name
		
		DOMDocument: as-string read/binary xfl-source-dir/DOMDocument.xml
		xmldom:      to-DOM DOMDocument

		error? try [
			insert Media-content (get-node-content xmldom %DOMDocument/media)
		]
		xmldom
	]
	
	parse-xfl: func[dom /act action-id /local node fills][
		if dom [
			if act [
				append actions-stack xfl-current-action-name: action-id
				xfl-current-action: select XFL-action-rules action-id
				if verbose > 1 [print ["^/### CHANGING ACTION RULES ###:-->" action-id]]
			]
			append tabs #"^-"
			parse dom [any [
				string!
				|
				set node block! (
					foreach [ name atts content ] node [
						current-node: node
						nodes-stack: insert/only nodes-stack node
						;print xfl-current-action-name
						if verbose > 2 [print join tabs name]
						unless parse/case name bind xfl-current-action 'name [
							print ["*** UNKNOWN node:" mold name]
							print ["*** IN:" xfl-current-action-name mold actions-stack]
							ask    "*** continue?"
						]
						nodes-stack: remove back nodes-stack
					]
				)
			]]

			remove back tail tabs
			
			if act [
				remove back tail actions-stack
				xfl-current-action-name: last actions-stack
				
				xfl-current-action: select XFL-action-rules xfl-current-action-name
				if verbose > 1 [print ["^/### CHANGING ACTION RULES ###:<--" xfl-current-action-name]]
			]
		]
	]
	
	get-node: func[
		"Returns DOM's node according specified path"
		dom  [block!]      "XFL dom structure"
		path [any-string!] "Node selector"
		/local tag tags cont?
	][
		tags: parse path "/"
		forall tags [
			tag: tags/1
			cont?: false
			if block? dom [
				foreach node dom [
					if all [
						block? node
						node/1 = tag
					][
						either 1 = length? tags [
							return node
						][
							dom: node/3
							cont?: true
						]
						break
					]
				]
			]
			unless cont? [return none]
		]
		none
	]
	
	get-node-content: func[
		dom  [block!]      "XFL dom structure"
		path [any-string!] "Node selector"
		/local node
	][
		either node: get-node dom path [
			third node
		][ none ] 
	]
	
	get-nodes: func[
		"Returns multiple nodes which have specified path"
		dom  [block!]      "XFL dom structure"
		path [path! any-string!] "Node selector"
		/flat
		/local tags node-name cont? result
	][
		;probe path
		tags: parse form path "/"
		node-name: last tags
		remove back tail tags
		foreach tag tags [
			cont?: false
			if block? dom [
				foreach node dom [
					;probe node
					if all [
						block? node
						node/1 = tag
					][
						dom: node/3
						cont?: true
						;dom: third cont
						break
					]
				]
			]
			unless cont? [return none]
		]
		result: copy []
		if block? dom [
			foreach node dom [
				if all [block? node node/1 = node-name][
					either flat [
						repend result node
					][  append/only result node ]
				]
			]
		]
		result
	]
	
	add-file-to-parse: func[node /local href atts][
		if atts: node/2 [
			either href: select atts "libraryItemName" [
				href: join href ".xml"
			][	href: select atts "href" ]
			if none? find head files-to-parse href [
				if verbose > 0 [print ["ADDING FILE to parse:" mold to-file href]]
				append files-to-parse href
			]
		]
	]
	
	shape-to-symbol: func[
		"Converts existing shape into new symbol"
		shp [block!]  "Shape's DOM"
		id  [any-string! integer!] "New symbol's name id"
		/local name symbol shpNode file
	][
		name: join "__symbol_" id ;checksum mold shp/3
		symbol: to-DOM [
{<DOMSymbolItem xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://ns.adobe.com/xfl/2008/" name="} name {" itemID="} make-id {" sourceLibraryItemHRef="} name {" symbolType="graphic" lastModified="} to-timestamp now {">
  <timeline>
	<DOMTimeline name="} name {">
	  <layers>
		<DOMLayer name="Layer 1" color="#4FFF4F" current="true" isSelected="true" >
		  <frames>
			<DOMFrame index="0" keyMode="9728">
			  <elements>
				<DOMShape/>
			  </elements>
			</DOMFrame>
		  </frames>
		</DOMLayer>
	  </layers>
	</DOMTimeline>
  </timeline>
</DOMSymbolItem>}]
		
		shpNode: get-node symbol %DOMSymbolItem/timeline/DOMTimeline/layers/DOMLayer/frames/DOMFrame/elements/DOMShape
		if shpNode [
			shpNode/3: shp/3
		]
		;probe shpNode
		repend/only dom-symbols compose/deep ["Include" ["href" ( join name %.xml ) "itemIcon" "1" "loadImmediate" "false"] none]
		;ask ""
		write/binary file: xfl-target-dir/LIBRARY/(join encode-filename name %.xml) form-xml symbol
		
		append files-to-parse file                    
		name
	]
	make-symbol-dom: func[name][
		first to-DOM [
			{<DOMSymbolInstance libraryItemName="} name {" name="" symbolType="graphic">
				 <matrix>
					  <Matrix/>
				 </matrix>
				 <transformationPoint>
					  <Point/>
				 </transformationPoint>
			</DOMSymbolInstance>}
		]
	]

	count-medium: func[name /local tmp][
		if name [Media-counter/(name): Media-counter/(name) + 1]
	]
	count-symbol: func[name /local tmp n][
		if name [
			print ["SYMBOLNAME:" name]
			if all [
				0 = n: Symbol-counter/(name)
				exists? tmp: xfl-source-dir/LIBRARY/(encode-filename name)
			][
				append files-to-parse name 
			]
			
			Symbol-counter/(name): n + 1

		]
	]
	
	remove-atts: func[atts att-rule-to-remove /local _s][
		if atts [
			if verbose > 1 [print ["remove-atts:" mold atts mold att-rule-to-remove]]
			parse atts [
				any [
					_s:
					att-rule-to-remove (_s: remove/part _s 2) :_s
					|
					2 skip
				]
			]
		]
	]

	get-edges-BB: func[data /local minX minY maxX maxY x y x0 y0 x1 y1 t t1][
		;print ["get-edges-BB:" mold data]
		minX: 
		minY:  999999999
		maxX: 
		maxY: -999999999
		rlPos: [
			;_s: (probe copy/part _s 20)
			[copy x rl_edgNumber (x: load x) | rl_hexNum (x: n)]   SP
			[copy y rl_edgNumber (y: load y) | rl_hexNum (y: n)] 
			(
			;   print ["pos:" x y]
			)
		]
		parse/all data [
			any [
				SP [
					#"!" rlPos 
					;remove optional "select" information
					opt [_s: #"S" ch_digits _e: (_e: remove/part _s _e) :_e]
					|
					[#"|" | #"/"] rlPos
				] (
					minX: min minX x
					minY: min minY y
					maxX: max maxX x
					maxY: max maxY y
				)
				|
				SP [#"[" | #"]"] (x0: x y0: y) rlPos (x1: x y1: y) SP rlPos SP (
					comment {
					minX: min minX x
					minY: min minY y
					maxX: max maxX x
					maxY: max maxY y
					}
					;comment {
					;counting BB of the quadratic curve
					;print [x0 y0 x1 y1 x y]

					minY: min minY yMin: either y0 >= y [
						either y1 >= y [y][
							t: -( y1 - y0 ) / ( y - (2 * y1) + y0 )
							(t1: 1 - t) * t1 * y0 + (2 * t * t1 * y1) + (t * t * y)
						]
					][
						either y1 > y0 [y0][
							t: -( y1 - y0 ) / ( y - (2 * y1) + y0 )
							(t1: 1 - t) * t1 * y0 + (2 * t * t1 * y1) + (t * t * y)
						]
					]
					maxY: max maxY yMax: either y0 >= y [
						either y1 <= y0 [y0][
							t: -( y1 - y0 ) / ( y - (2 * y1) + y0 )
							(t1: 1 - t) * t1 * y0 + (2 * t * t1 * y1) + (t * t * y)
						]
					][
						either y > y1 [y][
							t: -( y1 - y0 ) / ( y - (2 * y1) + y0 )
							(t1: 1 - t) * t1 * y0 + (2 * t * t1 * y1) + (t * t * y)
						]
					]
					minX: min minX xMin: either x0 >= x [
						either x1 >= x [x][
							t: -( x1 - x0 ) / ( x - (2 * x1) + x0 )
							(t1: 1 - t) * t1 * x0 + (2 * t * t1 * x1) + (t * t * x)
						]
					][
						either x1 > x0 [x0][
							t: -( x1 - x0 ) / ( x - (2 * x1) + x0 )
							(t1: 1 - t) * t1 * x0 + (2 * t * t1 * x1) + (t * t * x)
						]
					]
					maxX: max maxX xMax: either x0 >= x [
						either x1 <= x0 [x0][
							t: -( x1 - x0 ) / ( x - (2 * x1) + x0 )
							(t1: 1 - t) * t1 * x0 + (2 * t * t1 * x1) + (t * t * x)
						]
					][
						either x1 < x [x][
							t: -( x1 - x0 ) / ( x - (2 * x1) + x0 )
							(t1: 1 - t) * t1 * x0 + (2 * t * t1 * x1) + (t * t * x)
						]
					]
					;}
				)
				|
				pos: skip 1  (probe copy/part pos 100 ask "~~~ unknown edge value!") rlPos
			]
		]
		;probe
		reduce [minX minY maxX maxY]
	]

	form-matrix: func[m][
		reduce [
			to decimal! any [select m "a" 0] ;sx
			to decimal! any [select m "d" 0] ;sy
			to decimal! any [select m "b" 0] ;rx
			to decimal! any [select m "c" 0] ;ry
			to decimal! any [select m "tx" 0] ;tx
			to decimal! any [select m "ty" 0] ;tx
		]
	]
	form-float: func[v /local i fv][
		;v: round v 
		case [
			integer? v [v]
			same? (i: to integer! v) v [i]
			zero? v // .5 [v]
			'else [
				ui32-struct/value: to integer! v * 256
				v: enbase/base head reverse third ui32-struct 16
				either "00000000" = v: enbase/base head reverse third ui32-struct 16 [
					0
				][
					;parse v [some #"0" _e: (remove/part v _e)]
					join "#" head either "00" = p: skip tail v -2 [clear p][insert p #"."]
				]
			]
		]
	]
	opt-updateBmpMATRIX: func[mat bmpdata /local v a b c d tx ty][
		if verbose > 2 [print ["UPDMAT:" mold mat lf mold bmpdata]]
		a:  either a:  select mat "a"  [(to decimal! a) / 20][0]
		b:  either b:  select mat "b"  [(to decimal! b) / 20][0]
		c:  either c:  select mat "c"  [(to decimal! c) / 20][0]
		d:  either d:  select mat "d"  [(to decimal! d) / 20][0]
		tx: either tx: select mat "tx" [(to decimal! tx) ][repend mat ["tx" 0] 0]
		ty: either ty: select mat "ty" [(to decimal! ty) ][repend mat ["ty" 0] 0]
		
		mat/("tx"): (tx + ((bmpdata/5 * a) + (bmpdata/6 * c)))
		mat/("ty"): (ty + ((bmpdata/6 * d) + (bmpdata/5 * b)))
		
		mat
	]
	
	act_unknown: [
		copy unknow-node to end (
			print ["UNKNOWN node:" mold unknow-node]
			;halt
		)
	]
	
	in-guide?: has[is?][
		is?: false
		while [not head? nodes-stack: back nodes-stack][
			;probe nodes-stack/1/1
			if nodes-stack/1/1 = "DOMLayer" [
				is?: all [block? nodes-stack/1/2 "guide" = select nodes-stack/1/2 "layerType"]
				break
			]
		]
		nodes-stack: tail nodes-stack
		;print ["in-guide?:" is?]
		is?
	]
	in-tween?: has[is?][
		is?: false
		while [not head? nodes-stack: back nodes-stack][
			if nodes-stack/1/1 = "DOMFrame" [
				is?: all [block? nodes-stack/1/2 "shape" = select nodes-stack/1/2 "tweenType"]
				break
			]
		]
		nodes-stack: tail nodes-stack
		is?
	]

	copy-dir: func[src target][
		src: to-local-file dirize src
		target: to-local-file dirize target
		;probe call/wait probe rejoin [{RD /S /Q "} target {"}]
		call/wait probe rejoin [{XCOPY "} src {\*.*" "}  target {\*.*" /S /E /C /Y}]
	]

	ch_forbidden-file-chars: charset "*:<>?|^""
	ch_safe-file-chars: complement ch_forbidden-file-chars
	ch_safe-name-chars: complement charset {&<>'"}
	ch_not-amp: complement charset "&"
	
	encode-entities: func[str [any-string!] /local][
		result: copy ""
		parse/all str [
			any [
				pos: ;(probe pos)
				[ 
					#"&" (append result "&amp;") |
					#"<" (append result "&lt;") |
					#">" (append result "&gt;") |
					#"'" (append result "&apos;") |
					#"^"" (append result "&quot;")
					;1 skip (ask reform ["invalid entity:" mold copy/part s 10])
				]
				|
				copy tmp some ch_safe-name-chars (append result tmp)
			]
		]
		result
	]
	decode-entities: func[str [any-string!] /local result pos tmp][
		;print ["decode-entities <--" mold str]
		result: copy ""
		parse/all str [
			any [
				pos: ;(probe pos)
				[ 
					"&amp;#" copy tmp 3 ch_digits (append result  to-char to-integer tmp) |
					"&#" copy tmp 3 ch_digits (append result  to-char to-integer tmp) |
					"&lt;"   (append result "<") |
					"&gt;"   (append result ">") |
					"&quot;" (append result {"}) |
					"&apos;" (append result "'") |
					"&amp;"  (append result "&")
					;1 skip (ask reform ["invalid entity:" mold copy/part s 10])
				]
				|
				copy tmp some ch_not-amp (append result tmp)
			]
		]
		;print ["decode-entities -->" mold result]
		result
	]
	decode-filename: func[name [any-string!]][
		decode-entities name
	]
	encode-filename: func[name [any-string!] /as-utf8 /local _s _e char][
		;print ["encode-filename <--" mold name]
		name: decode-entities name
		unless as-utf8 [name: as-string utf8/decode name]
		
		parse/all name [
			any [
				some ch_safe-file-chars |
				_s: copy char 1 skip _e: (
					_e: change/part _s (
						char: to-integer to-char char
						if char < 100 [char: join "0" char]
						join "&#" char
					) _e
				) :_e
			]
		]
		;print ["encode-filename -->" mold name]
		name
	]
	
]
