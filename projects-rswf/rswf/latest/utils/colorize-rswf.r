rebol [
	title: "Colorize RSWF code"
	author: "Oldes"
	file: %colorize-rswf.r
	date: 29-Oct-2003/15:16:50+1:00
	version: 0.0.1
	note: {This script was inspired by Carl's %color-code.r file but was designed
	to colorize using CSS classes instead of font tags}
	comment: {
		You will need the %cc.css file with color classes definition!
	}
]

rswf-color-coder: make object! [

    out: none
    emit: func [data] [repend out data]
    emit-class: func [class start stop][
        emit [
        	{-[} {-span class=} class {-} {]-}
            copy/part start stop "-[" "-/span-" "]-"
        ]
    ]
    astr: anew: str: new: value: tmp: none
	actions-rule: [
		some [
	       astr:
	       some [" " | tab] anew: (emit copy/part astr anew) |
	       newline (emit newline)|
	       #";" [thru newline | to end] anew: 
	           (emit-class 'cc1 astr anew) |
	       [#"[" | #"("] (emit first astr) actions-rule |
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
	blk-rule: [
        some [
            str:
            some [" " | tab] new: (emit copy/part str new) |
            newline (emit newline)|
            #";" [thru newline | to end] new: 
                (emit-class 'cc1 str new) |
            [#"[" | #"("] (emit first str) blk-rule |
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
                		parse/all copy/part str new actions-rule
                		emit ["-[" "-/span-" "]-"]
                	)
                	| 'DoInitAction (
                		loop 2 [
                			emit copy/part str new
                			str: new
                			set [value new] load/next str
                		]
                		emit [{-[} {-span class=cc2-} {]-}]
                		parse/all copy/part str new actions-rule
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
	set 'colorize-rswf func [
		text	"string of code to colorize"
	][
		out: make string! 3 * length? text
		parse/all detab text blk-rule
	    foreach [from to] reduce [ ; (join avoids the pattern)
	        "&" "&amp;" "<" "&lt;" ">" "&gt;"
	        join "-[" "-"  "<" join "-]" "-" ">"
	    ][
	        replace/all out from to
	    ]
		out
	    ;insert out {<html><head><LINK rel="stylesheet" href="cc.css"/></head><body bgcolor="#ffffff"><pre>}
	    ;append out {</pre></body></html>}
	]
]
