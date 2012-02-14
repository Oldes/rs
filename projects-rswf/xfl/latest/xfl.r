REBOL [
    Title: "Xfl"
    Date: 1-Nov-2010/11:54:06+1:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "Oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: none
    Purpose: none
    Comment: none
    History: none
    Language: none
    Type: none
    Content: none
    Email: none
    require: [
    	rs-require 'ajoin
    	rs-project 'stream-io
    	rs-project 'imagick 'minimal
    	rs-project 'xml-dom
    	rs-project 'utf8-cp1250
    	rs-project 'zlib
    	rs-project 'imageCore
    	rs-project 'xml-parse
	]
	preprocess: true
]

zlib-decompress: func [
    zlibData [binary!]
    length [integer!] "known uncompressed zlib data length"
][
    decompress head insert tail zlibData third make struct! [value [integer!]] reduce [length]
]

context [
	out: copy ""
	tabs: copy "^/"
	emitxml: func[dom][
		
		foreach node dom [
			either string? node [
				clear skip out negate length? tabs
				out: insert tail out join node #" "
			][	
				foreach [ name atts content ] node [
					out: insert out ajoin [{<} name #" "]
					if atts [
						foreach [att val] atts [ 
							val: to string! any [val ""]
							out: insert out ajoin either find val #"^"" [
								[att {='} val {' }]
							][	[att {="} val {" }]]
						]
					]
					out: remove back out
					
					either all [content not empty? content] [
						append tabs #"^-"
						out: insert out join ">" tabs
						;print [ name mold content]
						
						either all [
							name = "script"
							1 = length? content
							string? content/1
						][	
							out: insert tail out rejoin [{<![CDATA[} content {]]>}]
						][
							emitxml content
							remove back tail out
							
						]
						remove back tail tabs
						
						out: insert out ajoin ["</" name #">" tabs]
					][
						out: insert out join "/>" tabs
					]
				]
			]
		]
	]
	set 'xmltree-to-str func[dom][
		clear head out
		insert clear head tabs #"^/"
		emitxml dom
		head out
	]
]
;print xmltree-to-str probe third parse-xml+ probe "<a>a2s<b><c/><d></d></b><b><script><![CDATA[sdsd]]></script></b></a>"
;halt 

ctx-XFL: context [
	DOMDocument:  none
	Media:        copy []
	Symbols:      copy []
	tabs:         ""
	Shape:        copy []
	Shape-bounds: copy []
	bmpFills:     copy []
	noCrops:      copy []
	Media-to-remove: copy []
	shape-counter: copy []
	Media-counter:  copy []
	Symbol-counter: copy []
	files-to-parse: copy []
	scale-x: 
	scale-y: 1
	
	actions-stack: copy [none ]
	xfl-current-action: none
	xfl-current-action-name: none
	nodes-stack: tail copy/deep [[none none none]]
	current-node: none	
	dom-symbols: none
	
	act-state:
	current-symbol:
	
	tmp_shapeMinPos: 99999999x99999999
	tmp_isSymbolGraphic?: none

	ch_space:   charset " ^-^M^/"
	ch_digits:  charset "0123456789"
	ch_notname: charset {="}
	ch_name:    complement union ch_space ch_notname
	ch_value:   complement charset {"}
	ch_hex: charset "0123456789ABCDEF"

	SP: [any ch_space]
	rl_edgNumber: [SP opt [#"+" | #"-"] some ch_digits opt [#"." some ch_digits]]
	rl_hexNum: [#"#" copy n [some ch_hex #"." some ch_hex] (
			trim n
			_s: find n #"." remove _s if 1 = length? _s [append _s "0"] ;removes dot and aligns the number after it
			n: (to integer! debase/base head insert/dup n #"0" (length? n) // 2 16) / 256
		)
	]

	
	#include %dat-functions.r
	#include %do-crops.r
	
	#include %rules_analyse.r
	#include %rules_update.r
	#include %rules_resize.r
	
	
	shape-to-symbol: func[shp ch /local name symbol shpNode file][
		;probe shp
		;ask ""
		name: join "__symbol_" ch ;checksum mold shp/3
		symbol: third parse-xml+/trim rejoin [
{<DOMSymbolItem xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://ns.adobe.com/xfl/2008/" name="} name {" itemID="} make-id {" sourceLibraryItemHRef="} name {" symbolType="graphic" lastModified="} to-timestamp now {">
  <timeline>
    <DOMTimeline name="} name {">
      <layers>
        <DOMLayer name="Vrstva 1" color="#4FFF4F" current="true" isSelected="true" >
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
		
		shpNode: first get-nodes symbol %DOMSymbolItem/timeline/DOMTimeline/layers/DOMLayer/frames/DOMFrame/elements/DOMShape
		if shpNode [
			shpNode/3: shp/3
		]
		;probe shpNode
		repend/only dom-symbols compose/deep ["Include" ["href" ( join name %.xml ) "itemIcon" "1" "loadImmediate" "false"] none]
		;ask ""
		write/binary file: xfl-folder-new/LIBRARY/(join as-string utf8/decode name %.xml) xmltree-to-str symbol
		
		append files-to-parse file                    
		name
	]
	get-symbol-dom: func[name][
		first third parse-xml+/trim rejoin [
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
			;probe name
			if all [
				0 = n: Symbol-counter/(name)
				exists? tmp: xfl-folder/LIBRARY/(as-string utf8/decode name)
			][
				append files-to-parse name 
			]
			
			Symbol-counter/(name): n + 1

		]
	]
	
	remove-atts: func[atts att-rule-to-remove /local _s][
		if atts [
			print ["remove-atts:" mold atts mold att-rule-to-remove]
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
			;	print ["pos:" x y]
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
			to-decimal any [select m "a" 0] ;sx
			to-decimal any [select m "d" 0] ;sy
			to-decimal any [select m "b" 0] ;rx
			to-decimal any [select m "c" 0] ;ry
			to-decimal any [select m "tx" 0] ;tx
			to-decimal any [select m "ty" 0] ;tx
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
		print ["UPDMAT:" mold mat lf mold bmpdata]
		a: either a: select mat "a" [(to-decimal a) / 20][0]
		b: either b: select mat "b" [(to-decimal b) / 20][0]
		c: either c: select mat "c" [(to-decimal c) / 20][0]
		d: either d: select mat "d" [(to-decimal d) / 20][0]
		tx: either tx: select mat "tx" [(to-decimal tx) ][repend mat ["tx" 0] 0]
		ty: either ty: select mat "ty" [(to-decimal ty) ][repend mat ["ty" 0] 0]
		
		mat/("tx"): (tx + ((bmpdata/5 * a) + (bmpdata/6 * c)))
		mat/("ty"): (ty + ((bmpdata/6 * d) + (bmpdata/5 * b)))
		probe mat
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

	parse-xfl: func[dom /act action-id /local node fills][
		if dom [
			if act [
				append actions-stack xfl-current-action-name: action-id
				xfl-current-action: select XFL-action-rules action-id
				;print [tabs "-->" action-id]
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
						;print join tabs name
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
				;print [tabs "<--" action-id]
			]
		]
	]
	
	doc-path:  copy ""
	doc-blk:   copy []
	doc-nodes: copy []
	doc-xfl: func[dom /local node fills][
		if dom [
			append tabs #"^-"
			parse dom [any [
				string! (
					unless find doc-blk tmp: join doc-path "/[string!]" [
						append doc-blk tmp
					]
				)
				|
				set node block! (
					foreach [ name atts content ] node [
						append doc-path join "/" name
						;print doc-path 
						;print join tabs name
						;print join tabs [" :" mold atts]
						
						unless find doc-blk doc-path [
							append doc-blk copy doc-path
						]
						unless doc-vals: select doc-nodes name [
							doc-vals: copy []
							repend doc-nodes [copy name doc-vals]
						]
						if atts [
							foreach [att val] atts [
								either string? val [
									trim val
									if 70 < length? val [val: join copy/part val 70 " ..."]
								][	val: copy ""]
								either att-val: select doc-vals att [
									if all [
										11 > length? att-val
										not find att-val val
									][
										append att-val val
										new-line/all att-val true
									]
								][
									repend doc-vals reduce [att reduce [val]] 
								]
							]
						]
						new-line/skip doc-vals true 2
						
						;print length? doc-blk
						;probe doc-blk
						;ask ""
						if block? content [
							doc-xfl content
						]
						clear find/last doc-path "/"
					]
				)
			]]
			remove back tail tabs
		]
	]
	
	get-node: func[dom path /flat /local tags node-name cont? result ][
		;probe path
		tags: parse path "/"
		node-name: last tags
		remove back tail tags
		foreach tag tags [
			cont?: false
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
		result: copy []

		foreach node dom [
			if all [block? node node/1 = node-name][
				either flat [
					repend result node
				][	append/only result node ]
			]
		]
		result
	]
	get-node-content: func[dom path][
		third get-node/flat dom path
	]
	get-nodes: func[dom path /flat /local tags node-name cont? result ][
		;probe path
		tags: parse path "/"
		node-name: last tags
		remove back tail tags
		foreach tag tags [
			cont?: false
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
			unless cont? [return none]
		]
		result: copy []
		foreach node dom [
			if all [block? node node/1 = node-name][
				either flat [
					repend result node
				][	append/only result node ]
			]
		]
		result
	]
	clear-values: [
		DOMDocument:  none
		clear Media
		clear Symbols
		clear tabs
		clear Shapes
		clear Shape-bounds
		clear bmpFills
		clear noCrops
		clear Media-to-remove
		clear shape-counter
		clear Media-counter
		clear Symbol-counter
	
		current-symbol: none
	]
	init: func[xfl /into-dir dir][
		DOMDocument:  none
		Media:        copy []
		Symbols:      copy []
		tabs:         ""
		Shape:        copy []
		Shape-bounds: copy []
		bmpFills:     copy []
		noCrops:      copy []
		Media-to-remove: copy []
		shape-counter: copy []
		Media-counter:  copy []
		Symbol-counter: copy []
		files-to-parse: copy []
		scale-x: 
		scale-y: 1
		
		actions-stack: copy [none ]
		xfl-current-action: none
		xfl-current-action-name: none
		nodes-stack: tail copy/deep [[none none none]]
		current-node: none	
		dom-symbols: none
		
		act-state:
		current-symbol:
		
		tmp_shapeMinPos: 99999999x99999999
		tmp_isSymbolGraphic?: none
		
		
		
		probe xfl-folder: xfl 
		xfl-name: trim/with second split-path xfl-folder #"/"
		
		if #"/" <> probe first xfl [insert xfl-folder what-dir]
		
		xfl-folder-new: either into-dir [
			 dir
		][ dirize join %tests/new/ xfl-name]
		
		if #"/" <> probe first xfl-folder-new [insert xfl-folder-new what-dir]
		either exists? xfl-folder-new [
			call/wait probe rejoin ["del /Q /S /A:-S /A:-H /A:-R " to-local-file xfl-folder-new "\*"]
		][	make-dir/deep xfl-folder-new ]
		copy-dir xfl-folder xfl-folder-new
		
		error? try [delete xfl-folder-new/bin/SymDepend.cache]

		clear-values
		
		num-imported: 0

		

		DOMDocument: as-string read/binary xfl-folder/DOMDocument.xml
		xmldom: third parse-xml+/trim DOMDocument

		;foreach item get-nodes xmldom %DOMDocument/media/DOMBitmapItem [
		;	append/only append Media select item/2 "name" item/2
		;]
		if error? try [Media-content: third first get-nodes xmldom %DOMDocument/media][Media-content: copy []]

	]
	resize-xfl: func[scx scy src trg /local PublishSettings.xml new-file dom s e val][
		init/into-dir src trg
		act-state: 'resize
		scale-x: scx
		scale-y: scy
		scale-xy: max scx scy ;(scx + scy) / 2
		PublishSettings.xml: read/binary xfl-folder/PublishSettings.xml
		parse/all PublishSettings.xml [
			any [
				thru {<} [
					{Width>}  s: copy val to {<} e: (s: change/part s (round (scale-x * to-integer val)) e) :s
					|
					{Height>} s: copy val to {<} e: (s: change/part s (round (scale-y * to-integer val)) e) :s
					| 1 skip
				]
			]
		]
		write/binary xfl-folder-new/PublishSettings.xml PublishSettings.xml
		
		parse-xfl/act xmldom 'DOMDocument-rsz
		write/binary xfl-folder-new/DOMDocument.xml xmltree-to-str xmldom
		recycle
		print "---"
		probe files-to-parse: head files-to-parse
		foreach file files-to-parse [
			recycle
			print ["RESIZING:" file stats]
			if file? file [ file: last split-path file ]
			new-file: join xfl-folder-new ["LIBRARY/" as-string utf8/decode file]
			dom: third parse-xml+/trim as-string read/binary xfl-folder/LIBRARY/(as-string utf8/decode file)
			parse-xfl/act dom 'DOMSymbolItem-rsz
			write/binary new-file xmltree-to-str dom
			
		]
		print ["stats:" stats]
	]

	opt-symbols: has[fills strokes edges fill x1 x2 y1 y2 dom][
		act-state: 'analyze
		parse-xfl/act xmldom 'DOMDocument
		recycle
		print "---"
		probe files-to-parse: head files-to-parse
		;ask ["stats:" stats]
		log_removed: copy ""
		#include %noBBs-per-XFL.r
		probe noBBs: any [select noBBs-per-XFL xfl-name  copy []]
		
		while [not tail? files-to-parse] [
			recycle
			print ["PARSING:" files-to-parse/1 stats]
			dom: third parse-xml+/trim as-string read/binary either file? files-to-parse/1 [
				files-to-parse/1
			][	xfl-folder/LIBRARY/(as-string utf8/decode files-to-parse/1) ]
			;new-file: head insert find/last copy file "/Library/" "-new"
			;ask ""
			parse-xfl/act dom 'DOMSymbolItem
			files-to-parse: next files-to-parse
			;write/binary new-file xmltree-to-str xmldom
		]
		files-to-parse: head files-to-parse
		
		probe new-line/skip Media-counter true 2
		probe new-line/skip Symbol-counter true 2
		;ask "xx"
		do-crops
		
		print ["Free shapes count:" (length? shape-counter) / 2]
				i: 0
		foreach [ch shp] shape-counter [
			;print [ch shp/1]
			if shp/1 > 1 [i: i + 1 print [ch shp/1]]
		]
		print ["Free shapes dup:" i]
		;ask ""
		print "UPDATE SHAPES AFTER CROPPING:"


		noBB-fills: any [select noBBs "*" copy []]
		
		act-state: 'update

		parse-xfl/act xmldom 'DOMDocument-upd
		
					
		
		
		
		
		foreach file files-to-parse [
			recycle
			current-symbol: either file? file [
				current-symbol: form last split-path file 
				copy/part current-symbol find/last current-symbol "."
			][	copy/part file find/last file "." ]
			print ["UPDATING:" file mold current-symbol stats]
			;ask mold noBBs
			noBB-fills: any [select noBBs "*" copy []]
			if tmp: select noBBs current-symbol [ append noBB-fills tmp ]
			;ask mold noBB-fills
			;if not empty? noBB-fills [ask ""]
			either file? file [
				dom: third parse-xml+/trim as-string read/binary file
				new-file: file
			][
				dom: third parse-xml+/trim as-string read/binary xfl-folder/LIBRARY/(as-string utf8/decode file)
				new-file: join xfl-folder-new ["LIBRARY/" as-string utf8/decode file]
			]
			parse-xfl/act dom 'DOMSymbolItem-upd
			write new-file xmltree-to-str dom
		]

		write/binary xfl-folder-new/DOMDocument.xml xmltree-to-str xmldom

		clear-values
		recycle
		print ["stats:" stats]
		print log_removed
		;ask ""
	]

	
	copy-dir: func[src target][
		src: to-local-file dirize src
		target: to-local-file dirize target
		;probe call/wait probe rejoin [{RD /S /Q "} target {"}]
		probe call/wait probe rejoin [{XCOPY "} src {\*.*" "}  target {\*.*" /S /E /C /Y}]
	]
	
	
	;parse-xfl xmldom
	;write/binary %tests/empty/DOMDocument.xml xmltree-to-str xmldom
	;probe Shape-bounds
]
;with ctx-xfl [
	;init %tests/sound/
	;init %tests/hlava/ ;00_intro/
	;init/into-dir %tests/test/ %tests/test-new/
	;init/into-dir %tests/mafian/ %tests/mafian-new/
	;init/into-dir %/K/robotek\SVN\flash\05_mafodoupe/ %/F/SVN/machinarium/XFL/05_mafodoupe/
	;init/into-dir %/K/robotek\SVN\flash\06_vezeni/ %/K/robotek/SVN_machinarium/XFL/06_vezeni/
	;init/into-dir %/f/rs/projects-mm/robotek/wii/swf/07_bachar/ %/f/SVN/machinarium/XFL/07_bachar/
	;import-media-img %tests/empty-new/Library/01skladka_krysa.png
	;export-media-item ["bitmapDataHRef" "My 9948373.dat" "sourceExternalFilepath" "test-origmoje.png" ]
	;export-media-item ["bitmapDataHRef" "Media 15.dat" "sourceExternalFilepath" "test-origide.png" ]
	;import-media-img %tests/empty-new/Library/01skladka_krysa_crop_12x1_84x39.png
	;export-media-item ["bitmapDataHRef" "Kopie - My 113936.dat" "sourceExternalFilepath" "test-moje.png" ]
	;export-media-item ["bitmapDataHRef" "My 113936.dat" "sourceExternalFilepath" "test-ide.png" ]
	;halt
	;opt-symbols
;]

files-to-build: [
	;%/K/robotek\SVN\flash\05_mafodoupe/ %/F/SVN/machinarium/XFL/05_mafodoupe/
	;%/f/rs/projects-mm/robotek/wii/swf/klip/ %/f/SVN/machinarium/XFL/klip/
	;%/f/rs/projects-mm/robotek/wii/swf/00_intro/ %/f/SVN/machinarium/XFL/00_intro/
	;%/f/rs/projects-mm/robotek/wii/swf/01_skladka/ %/f/SVN/machinarium/XFL/01_skladka/
	;%/f/rs/projects-mm/robotek/wii/swf/02_brana/ %/f/SVN/machinarium/XFL/02_brana/
	;%/f/rs/projects-mm/robotek/wii/swf/03_dno/ %/f/SVN/machinarium/XFL/03_dno/
	;%/f/rs/projects-mm/robotek/wii/swf/03_dno_ovladac/ %/f/SVN/machinarium/XFL/03_dno_ovladac/
	;%/f/rs/projects-mm/robotek/wii/swf/04_pec/ %/f/SVN/machinarium/XFL/04_pec/
	;%/f/rs/projects-mm/robotek/wii/swf/08_venek1/ %/f/SVN/machinarium/XFL/08_venek1/
	;%/f/rs/projects-mm/robotek/wii/swf/09_venek2/ %/f/SVN/machinarium/XFL/09_venek2/
	;%/f/rs/projects-mm/robotek/wii/swf/09_venek2_ovladac/ %/f/SVN/machinarium/XFL/09_venek2_ovladac/
	;%/f/rs/projects-mm/robotek/wii/swf/10_ulicka/ %/f/SVN/machinarium/XFL/10_ulicka/
	;%/f/rs/projects-mm/robotek/wii/swf/11_namesti/ %/f/SVN/machinarium/XFL/11_namesti/
	;%/f/rs/projects-mm/robotek/wii/swf/12_predhernou/ %/f/SVN/machinarium/XFL/12_predhernou/
	;%/f/rs/projects-mm/robotek/wii/swf/12_predhernou_puzzle/ %/f/SVN/machinarium/XFL/12_predhernou_puzzle/
	;%/f/rs/projects-mm/robotek/wii/swf/13_herna/ %/f/SVN/machinarium/XFL/13_herna/
	;%/f/rs/projects-mm/robotek/wii/swf/14_vodarna/ %/f/SVN/machinarium/XFL/14_vodarna/
	;%/f/rs/projects-mm/robotek/wii/swf/14_voda-mafosi/ %/f/SVN/machinarium/XFL/14_voda-mafosi/
	;%/f/rs/projects-mm/robotek/wii/swf/14_vodarna_trubky/ %/f/SVN/machinarium/XFL/14_vodarna_trubky/
	;%/f/rs/projects-mm/robotek/wii/swf/15_bar/ %/f/SVN/machinarium/XFL/15_bar/
	;%/f/rs/projects-mm/robotek/wii/swf/16_zed1/ %/f/SVN/machinarium/XFL/16_zed1/
	;%/f/rs/projects-mm/robotek/wii/swf/17_zed2/ %/f/SVN/machinarium/XFL/17_zed2/
	;%/f/rs/projects-mm/robotek/wii/swf/18_zed3/ %/f/SVN/machinarium/XFL/18_zed3/
	;%/f/rs/projects-mm/robotek/wii/swf/19_sklenik/ %/f/SVN/machinarium/XFL/19_sklenik/
	;%/f/rs/projects-mm/robotek/wii/swf/20_pata_veze/ %/f/SVN/machinarium/XFL/20_pata_veze/
	;%/f/rs/projects-mm/robotek/wii/swf/21_mezilevel/ %/f/SVN/machinarium/XFL/21_mezilevel/
	;%/f/rs/projects-mm/robotek/wii/swf/22_vytah/ %/f/SVN/machinarium/XFL/22_vytah/
	;%/f/rs/projects-mm/robotek/wii/swf/23_foyer/ %/f/SVN/machinarium/XFL/23_foyer/
	;%/f/rs/projects-mm/robotek/wii/swf/23_pohled_bomba/ %/f/SVN/machinarium/XFL/23_pohled_bomba/
	;%/f/rs/projects-mm/robotek/wii/swf/24_bomba/ %/f/SVN/machinarium/XFL/24_bomba/
	;%/f/rs/projects-mm/robotek/wii/swf/24_bomba_detail/ %/f/SVN/machinarium/XFL/24_bomba_detail/
	;%/f/rs/projects-mm/robotek/wii/swf/25_mozkovna/ %/f/SVN/machinarium/XFL/25_mozkovna/
	;%/f/rs/projects-mm/robotek/wii/swf/25_mozkovna_trezor/ %/f/SVN/machinarium/XFL/25_mozkovna_trezor/
	;%/f/rs/projects-mm/robotek/wii/swf/26_strecha/ %/f/SVN/machinarium/XFL/26_strecha/
	;%/f/rs/projects-mm/robotek/wii/swf/27_outro/ %/f/SVN/machinarium/XFL/27_outro/
	;%/f/rs/projects-mm/robotek/wii/swf/rob-include/ %/f/SVN/machinarium/XFL/rob-include/
	;%tests/mafian/ %tests/mafian-new/
	;%tests/mafian/ %tests/mafian-new/
	;rob-include
	
]
all-files: [
	%00_intro
	%01_skladka
	%02_brana
	%03_dno
	;%03_dno_ovladac
	%04_pec
	%05_mafodoupe
	%06_vezeni
	%07_bachar
	%08_venek1
	%09_venek2
	;%09_venek2_ovladac
	%10_ulicka
	%11_namesti
	%12_predhernou
	;%12_predhernou_puzzle
	%13_herna

	%14_vodarna
	;%14_voda-mafosi
	;%14_vodarna_trubky
	;%15_bar
	%16_zed1
	%17_zed2
	%18_zed3
	]all-files: [
	%19_sklenik
	%20_pata_veze
	%21_mezilevel
	%22_vytah
	%23_foyer
	%23_foyer_wc
	;%23_pohled_bomba
	%24_bomba
	;%24_bomba_detail
	%25_mozkovna
	;%25_mozkovna_trezor
	%26_strecha
	%27_outro
	;%rob-include
	;%kursor
	;%inventorar_wii
	;%navod-wii
	;%menu_EN_wii
	;%zvuky2
]


rszxfl-bb2: func[file][
	rob-scale-x: rob-scale-y: 0.7592 ;1 ;
	ctx-xfl/resize-xfl
			rob-scale-x rob-scale-y
			dirize join %/d/SVN/machinarium/XFL_opt/ file
			dirize join %/d/SVN/machinarium-bb/XFL/ file
]



rszxfl-bb: func[file][
	rob-scale-x: rob-scale-y: 0.7592 ;1 ;
	ctx-xfl/resize-xfl
			rob-scale-x rob-scale-y
			dirize join %/d/RS/projects-mm/robotek/AS3/ file
			dirize join %/d/BlackBerry/Machinarium/ file
]
rszxfl-ipad: func[file][
	rob-scale-x: rob-scale-y: 0.8192 ;1 ;
	ctx-xfl/resize-xfl
			rob-scale-x rob-scale-y
			dirize join %/d/RS/projects-mm/robotek/MachinariumTablet/assets/levels/ file
			dirize join %/d/iPad/Machinarium/assets/levels/ file
]
rszxfl-ipad-to-bb: func[file][
	rob-scale-x: rob-scale-y: 600 / 647
	ctx-xfl/resize-xfl
			rob-scale-x rob-scale-y
			dirize join %/d/iPad/Machinarium/assets/levels/ file
			dirize join %/d/BlackBerry/Machinarium/assets/levels/ file
			
]

rszxfl-android-to-bb: func[file][
	rob-scale-x: rob-scale-y: 600 / 750
	ctx-xfl/resize-xfl
			rob-scale-x rob-scale-y
			dirize join %/d/Android/Machinarium/assets/levels/ file
			dirize join %/d/BlackBerry/Machinarium2/assets/levels/ file
			
]


rszxfl-ipad-to-android: func[file][
	
	rob-scale-x: rob-scale-y: 750 / 647
	ctx-xfl/resize-xfl
			rob-scale-x rob-scale-y
			dirize join %/d/iPad/Machinarium/assets/levels/ file
			dirize join %/d/Android/Machinarium/assets/levels/ file
			
]

rszxfl-wii: func[file][
	rob-scale-x: round/to 724 / 1250 .001
	rob-scale-y: round/to 448 / 790  .001
	ctx-xfl/resize-xfl
			rob-scale-x rob-scale-y
			dirize join %/d/SVN/machinarium/XFL/ file
			dirize join %/d/SVN/machinarium-wii/XFL/ file
			;dirize join %/d/rs/projects-mm/robotek/wii-final/XFL/ file
]

rszxfl-android: func[file][
	rob-scale-x: rob-scale-y: 750 / 790
	ctx-xfl/resize-xfl
			rob-scale-x rob-scale-y
			dirize join %/d/SVN/machinarium/XFL_ORIG/ file
			dirize join %/d/SVN/machinarium-android/XFL/ file
			;dirize join %/d/rs/projects-mm/robotek/wii-final/XFL/ file
]


optxfl: func[file][
	ctx-xfl/init/into-dir
			dirize join %/D/SVN/machinarium/XFL_ORIG/ file
			dirize join %/D/SVN/machinarium/XFL_xxx/ file
	ctx-xfl/opt-symbols
]


print {
	optxfl %02_brana ;%/D/SVN/machinarium/XFL_ORIG/ ===> %/D/SVN/machinarium/XFL_xxx/
	rszxfl-bb %00_intro
	rszxfl-wii %00_intro
	rszxfl-ipad %00_intro ;%/d/RS/projects-mm/robotek/MachinariumTablet/assets/levels/ ==> %/d/iPad/Machinarium/assets/levels/
	rszxfl-ipad-to-bb %00_intro ;%/d/iPad/Machinarium/assets/levels/ ==> %/d/BlackBerry/Machinarium/assets/levels/
	rszxfl-android-to-bb %00_intro ;%/d/Android/Machinarium/assets/levels/ ==> %/d/BlackBerry/Machinarium2/assets/levels/
	
	images: load %/d/Android\Machinarium\images.rb
	resize-image: :resize-image-android
	rszxfl-ipad-to-android %00_intro ;%/d/iPad/Machinarium/assets/levels/ ==> %/d/Android/Machinarium/assets/levels/
	
}


halt



;recycle/off
t: now/time/precise 
rszxfl-bb  %rob-include %01_skladka/ %00_intro  %rob-include  ; %test/ ;
print now/time/precise - t

halt


halt
rob-scale-x: rob-scale-y: 0.7592
rszxfl: func[file /air][
	ctx-xfl/resize-xfl
			rob-scale-x rob-scale-y
			dirize join %/f/SVN/machinarium/XFL/ file
			dirize join either air [
				%/f/SVN/machinarium-air/XFL/
			][	%/f/rs/projects-mm/robotek/wii-final/XFL/ ] file
]

;foreach file all-files [rszxfl/air file]
halt

rob-scale-x: round/to 724 / 1250 .001
rob-scale-y: round/to 448 / 790  .001
optxfl: func[file][
	ctx-xfl/init/into-dir
			dirize join %/f/rs/projects-mm/robotek/wii/swf/ file
			dirize join %/f/SVN/machinarium/XFL/ file
	ctx-xfl/opt-symbols
]


;ctx-xfl/test-dat read/binary to-rebol-file "f:\rs\projects-mm\robotek\wii-final\XFL\25_mozkovna\bin\M 17 1246394152.dat"
;			halt
;ctx-xfl/resize-xfl .5 .5 %tests/sc/ %tests/sc-rsz/
;ctx-xfl/init/into-dir %/f/rs/projects-mm/robotek/wii/swf/dalekohled_pohled/ %/f/rs/projects-mm/robotek/wii-final/xfl/dalekohled_pohled/ ctx-xfl/opt-symbols
;optxfl %dalekohled_pohled
;rszxfl %dalekohled_pohled
;optxfl %27_outro

;optxfl %06_vezeni
;rszxfl %06_vezeni

;ctx-xfl/init/into-dir %/f/rs/projects-mm/robotek/wii/swf/06_vezeni/  %/f/SVN/machinarium/XFL/06_vezeni-opt/ ctx-xfl/opt-symbols

;ctx-xfl/resize-xfl rob-scale-x rob-scale-y %/d\RS\projects-mm\robotek\latest\swf\12_predhernou\  %/d\RS\projects-mm\robotek\latest\swf\12_predhernou-opt/

;ctx-xfl/resize-xfl rob-scale-x rob-scale-y %/f/SVN/machinarium/XFL/06_vezeni-opt/ %/f/rs/projects-mm/robotek/wii-final/XFL/06_vezeni/
;ctx-xfl/resize-xfl rob-scale-x rob-scale-y %tests/lano/ %tests/lano-rsz/
;ctx-xfl/resize-xfl rob-scale-x rob-scale-y %tests/ruka/ %tests/ruka-rsz/
;ctx-xfl/init/into-dir %tests/shp/ %tests/shp-opt/ ctx-xfl/opt-symbols
;ctx-xfl/init/into-dir %tests/rob/ %tests/rob-opt/ ctx-xfl/opt-symbols
;ctx-xfl/init/into-dir %tests/kour/ %tests/kour-opt/ ctx-xfl/opt-symbols
;ctx-xfl/init/into-dir %tests/ruka/ %tests/ruka-opt/ ctx-xfl/opt-symbols
;ctx-xfl/init/into-dir %tests/rob-kadi/ %tests/rob-kadi-opt/ ctx-xfl/opt-symbols
;ctx-xfl/resize-xfl rob-scale-x rob-scale-y %tests/ruka/ %tests/ruka-rsz/
;ctx-xfl/init/into-dir %/f/rs/projects-mm/robotek/wii/swf/00_intro/ %/f/SVN/machinarium/XFL/00_intro/ ctx-xfl/opt-symbols
;optxfl %04_pec_draty rob-scale-x: rob-scale-y: .7 rszxfl %04_pec_draty
;foreach file [%05_mafodoupe] [optxfl file	rszxfl file]
optxfl %07_bachar
rszxfl %07_bachar
;rszxfl %00_intro
;rszxfl %09_venek2_ovladac
;ctx-xfl/init/into-dir %/f/rs/projects-mm/robotek/wii/swf/25_mozkovna/ %/f/SVN/machinarium/XFL/25_mozkovna/ ctx-xfl/opt-symbols
;ctx-xfl/resize-xfl rob-scale-x rob-scale-y %tests/____/obrazovky/ %tests/____/obrazovky-rsz/
;rszxfl %25_mozkovna
halt
foreach file all-files [
	;optxfl file
	 rszxfl file
	 ]

;ctx-xfl/resize-xfl .31 .31 %tests/rob2/ %tests/rob2_31-rsz/
halt
;optxfl %09_venek2_ovladac
rob-scale-x: rob-scale-y: .65 .7 0.8 ;.7
foreach file [
	;%inventorar_wii
	;%06_vezeni_trezor
	;%06_vezeni_ovladac
	;%09_venek2_ovladac
	;%12_predhernou_puzzle
	;%kniha
	;%14_vodarna_trubky ;0.8
	;%kursor
	; %navod-wii %menu_EN_wii
	;%24_bomba_detail ;.65
	%25_mozkovna_trezor ;.65
][ 
	optxfl file
	 rszxfl file ]

halt
;ctx-xfl/resize-xfl rob-scale-x rob-scale-y %/f/SVN/machinarium/XFL/dalekohled_pohled/ %/f/SVN/machinarium-wii/XFL/dalekohled_pohled/
;ctx-xfl/resize-xfl .5 .5 %tests/mafian/ %tests/mafian-rsz/

;rszxfl %01_skladka
;
;foreach file all-files [rszxfl file	]

comment {
with ctx-xfl [
	foreach [src trg] files-to-build [
		init/into-dir src trg
		opt-symbols
	]
]
}

