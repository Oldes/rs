rebol [
	title: "Color rules for RSWF"
]

rswf-actions-rule: [
	some [
       astr:
       some [" " | tab] anew: (emit copy/part astr anew) |
       newline (emit newline)|
       #";" [thru newline | to end] anew: 
           (emit-class 'cc1 astr anew) |
       [#"[" | #"("] (emit first astr) rswf-actions-rule |
       [#"]" | #")"] (emit first astr) |
       skip (
			set [value anew] load/next astr
			parse/all join copy [] value [any[
				  [set-path! | set-word!] (
            	  	emit-class 'cc10 astr anew
            	)
            	| string! (
            		emit-class 'cc8 astr anew
            	)
            	| [file! | url!] (emit-class 'cc11 astr anew)
            	| 'rebol (
            		set [value anew] load/next anew
            		emit-class 'cc7 astr anew
        		)
        		| 'constantPool (
            		set [value anew] load/next anew
            		emit-class 'cc9 astr anew
        		)
            	| skip
            	(
            		emit copy/part astr anew
           			astr: anew
            	)
       		]]
       ) :anew
    ]
]
rswf-blk-rule: [
    some [
        str:
        some [" " | tab] new: (emit copy/part str new) |
        newline (emit newline)|
        #";" [thru newline | to end] new: 
            (emit-class 'cc1 str new) |
        [#"[" | #"("] (emit first str) rswf-blk-rule |
        [#"]" | #")"] (emit first str) |
        skip (
            set [value new] load/next str
            parse/all join copy [] value [any[
            	  [set-path! | set-word!] (
            	  	emit-class 'cc3 str new
            	  )
            	| ['actions | 'doAction] (
            		emit copy/part str new
            		str: new
            		set [value new] load/next str
            		emit [{-[} {-span class=cc2-} {]-}]
            		parse/all copy/part str new rswf-actions-rule
            		emit ["-[" "-/span-" "]-"]
            	)
            	| 'DoInitAction (
            		loop 2 [
            			emit copy/part str new
            			str: new
            			set [value new] load/next str
            		]
            		emit [{-[} {-span class=cc2-} {]-}]
            		parse/all copy/part str new rswf-actions-rule
            		emit ["-[" "-/span-" "]-"]
            	)
            	| 'shape (
            		emit copy/part str new
            		str: new
            		set [value new] load/next str
            		emit-class 'cc4 str new
            	)
            	| 'EditText (
            		emit copy/part str new
            		str: new
            		set [value new] load/next str
            		emit-class 'cc10 str new
            		str: new
            		set [value new] load/next str
            		emit copy/part str new
            		str: new
            		set [value new] load/next str
               		emit-class 'cc5 str new
            	)
            	| ['ShowFrame | 'end | 'stop] (
            		emit-class 'cc6 str new
            	)
            	| 'show (
            		tmp: new
            		set [value new] load/next new
            		either value = 'frame [
            			emit-class 'cc6 str new
        			][
        				either integer? value [
        					set [value new] load/next new
        					emit-class 'cc6 str new
    					][
        					emit copy/part str tmp
    					]
    				]
            	)
            	| ['rebol | 'layout] (
            		set [value new] load/next new
            		emit-class 'cc7 str new
        		)
            	| string! (
            		emit-class 'cc8 str new
            	)
            	| 'comment (
            		set [value new] load/next new
            		emit-class 'cc1 str new
            	)
            	| ['require | 'include] (
            		set [value new] load/next new
            		emit-class 'cc11 str new
            	)
            	| [file! | url!] (emit-class 'cc11 str new)
            	| skip
            	(
            		either parse/all form value [any [
            			["txt_" | "spr_" | "bmp_" | "shp_" | "fnt_" | "img_" | "frm_" | "snd_" | "btn_"] to end
        			]][
        				emit-class 'cc10 str new
    				][
            			;print [ "###" mold copy/part str new mold copy/part new 10]
            			emit copy/part str new
            			str: new
        			]
            	)
        	]]
            ;emit-color :value str new
        ) :new
    ]
	]