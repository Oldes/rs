rebol [
	title: "Color rules for RSWF"
]

ch_none: charset ""
ch_all:  complement ch_none
ch_digits: charset "0123456789"
ch_paren-start: charset "("
ch_paren-end: charset ")"
ch_parens: union ch_paren-start ch_paren-end
ch_content: complement ch_parens
ch_space: charset " ^-"
ch_spaceornewline: charset " ^-^/^M"
rl_paren: [any ch_space ch_paren-start  parse-rules-blk-rule  ch_paren-end opt [any ch_space ["^M^/" | #"^M" | #"^/"]] ]

paren-level: 0
parse-rules-blk-rule: [
    some [
        str:
        
        ["^M^/" | #"^M" | #"^/"] (emit newline)
        	opt [#";" to newline] ;skip comments which are not indented
        |
        #";" [thru newline | to end] new: 
            (emit-class 'cc1 str new)
        |
        #"[" (emit first str) parse-rules-blk-rule
        |
        #"]" (emit first str)
        |
        any ch_space #"(" (paren-level: paren-level + 1) parse-rules-blk-rule
        |
        any ch_space #")" any ch_spaceornewline (paren-level: paren-level - 1)
        |
        some ch_space new: (emit copy/part str new)
        |
        skip (
        	;probe copy/part str 100
            if error? set/any 'err try [
            	set [value new] load/next str
        	][
        		;probe copy/part str 20
        		throw err
        		
    		]
           ; probe value
           if paren-level = 0 [
	            parse/all join copy [] value [any[
	            	skip (
	            		emit copy/part str new
	            		str: new
	            		)
	        	]]
        	]
            ;probe value

            ;emit-color :value str new
        ) :new
    ]
]