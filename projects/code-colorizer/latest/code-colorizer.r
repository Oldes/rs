REBOL [
    Title:   "Rebol Code colorizer"
    Date:    2-Feb-2009/2:47:10+1:00
    Name:    "Rebol Code colorizer"
    Version: 0.9.6
    File:    %code-colorizer.r
    Author:  "David 'Oldes' Oliva"
    Email:   oliva.david@seznam.cz
    Home:    http://rebol.desajn.net/
    Owner:   none
    Rights:  none
    Needs:   none
    Tabs:    none
    encoding: 'cp1250
    Usage:   [
		code-colorizer/remove-parens?: off
		code-colorizer/footer-final: {
		<script src="http://www.google-analytics.com/urchin.js" type="text/javascript"></script>
		<script type="text/javascript">_uacct = "UA-1886645-1";urchinTracker();</script>}
		
		colorize/save/title
		    %code-colorizer.r
		    %code-colorizer.html
		    "Rebol Code Colorizer"
	]
    Purpose: {To convert Rebol script into html with colorized code. Using string based parsing.}
    Comment: {
    	To change colors, download this CSS style: http://rebol.desajn.net/css/rebolcc.css
    	modify it and use it (change code-colorizer/css-file to your new version)
    }
    History: [
    	0.9.6 2-Feb-2009 {
    		- Fixed bug with escape inside multiline string
    		- Replaced 'rejoin with faster R3's 'ajoin
    	}
    	0.9.5 20-Jan-2009 {
    		- Using hash! table to get word's classes instead of parse rules
    		- Using <i> tags instead of <span>
    		- Updated 'seo-name function
    		- Fixed special char! notation like #"^(60)"
    	}
    	0.9.2 12-Mar-2008 {
    		- Fixed bug with single escape character in string ( "^^" )
    	}
    	0.9.1 8-Mar-2008 {
    		- Fixed bug with conversion of REBOL word to url
    		- Added new color class .iss for issue! datatype.
    	}
    	0.9.0 28-Sep-2007 {
    		Complete remake of the script using string based parsing (besause of recursions limits in the old code)}
    	0.0.1 29-Oct-2003 {
    		%colorize-rswf.r script inspired by Carl's %color-code.r file but was designed
    		to colorize using CSS classes instead of font tags
    	}
	]
    Language: none
    Type:     none
    Content:  none
	library: [
		level:        'intermediate
		platform:     'all
		type:         [tool]
		domain:       [html parse text-processing visualization web]
		tested-under: none
		support:      none
		license:      'public-domain
		see-also:     none
	]
;    preprocess: true
;    require: [
;    	rs-project 'seo-name
;	]
]

;### ajoin
comment {
#### RS include: %ajoin.r
#### Title:   "ajoin"
----} 
unless value? 'ajoin [
	ajoin: func[
		"Faster way how to create string from a block (in R3 it's native!)"
		block [block!]
	][make string! reduce block]
]
comment "---- end of RS include %ajoin.r ----" 

;### Seo-name
comment {
#### RS include: %seo-name.r
#### Title:   "seo-name"
----} 
unless value? 'seo-name [
	seo-name: func [
		"Creates SEO friendly version of string with diacritics"
		str
		/local new normal-chars trans-chars other-char pos pos2
	][
		was-type?: type? str
	    new: lowercase copy as-string str 
	    normal-chars: charset [#"A" - #"Z" #"a" - #"z" #"0" - #"9" #"_" #"."] 
	    trans-chars:  charset "ÏÈÎöúËÊ¯‡ûü˝·‰ÌÈÛˆÔùÚ˙˘¸Á"
	    other-char: complement (union normal-chars trans-chars)
	    parse/all new [
		some [
		    some normal-chars 
		    | some [
			pos: [
			      ["Ï" | "È" | "Î"] (change pos "e") 
			    | ["ö" | "ú"]       (change pos "s") 
			    | ["Ë" | "Ê" | "Á"] (change pos "c") 
			    | ["¯" | "‡"]       (change pos "r") 
			    | ["û" | "ü"]       (change pos "z") 
			    | "˝"               (change pos "y") 
			    | "Ì"               (change pos "i") 
			    | ["Û" | "ˆ"]       (change pos "o") 
			    | ["·" | "‰"]       (change pos "a") 
			    | ["˘" | "˙" | "¸"] (change pos "u") 
			    | "Ô"               (change pos "d") 
			    | "ù"               (change pos "t") 
			    | "Ú"               (change pos "n")
			]
		    ] 
		    | some other-char pos2: (pos2: change/part pos "-" pos2) :pos2
		]
	    ] 
	    to was-type? head new
	] 
]
comment "---- end of RS include %seo-name.r ----" 

;### Code-colorizer

code-colorizer: context [

;## Default settings
	remove-parens?: off ;removes parens from code (used to document big parsing rules)
	remove-newline-comments?: on ;removes all comments which start at newline
	index-comments?: on ;creates index from special comments
	break-on-error?: on ;stops parsing if founds invalid code

    out: str: x:   none
	output?:       true
	level-block:  
	level-paren:  
	level-string:  0
	string-type:   none
	string-buffer: make string! 10000
	index-html:    make string! 1000
	index-type:    none
	css-file:      http://rebol.desajn.net/css/rebolcc.css
	footer-final:  none ;using this to add final note (for example counter) on HTML page
    
;## Basic charsets
;** These charsets are used in string based parse in Colorize function

	ch_word-dividers: charset " ^-^/^M{}[]()^"^^;"
	ch_newlines:      charset "^/^M"
	ch_space:         charset " ^-"
	ch_spaces:        charset " ^-^/^M"
	ch_numbers:       charset "0123456789"
	ch_binary2:       charset "01"
	ch_alpha:         charset [#"a" - #"z" #"A" - #"Z"]
	ch_hexadecimal:   charset [#"a" - #"f" #"A" - #"F" "0123456789"]
	ch_tonewline:     complement ch_newlines
	ch_word:          complement ch_word-dividers
	ch_anychar:       complement charset ""
	ch_alphanum: union ch_alpha ch_numbers
	ch_base64:   union ch_alphanum union charset "+/=" ch_spaces

;## Rules used for parsing
	rl_integer:   [some ch_numbers]
	rl_word:      [some ch_word]
	rl_binary2:   [ "2#{" any [8 [ch_binary2  any ch_spaces]] "}"]
	rl_binary32:  [  "#{" any [2 [ch_alphanum any ch_spaces]] "}"]
	rl_binary64:  ["64#{" any ch_base64 "}"]
	rl_binary: [
		  rl_binary2
		| rl_binary32
		| rl_binary64
		| ["#{" | "2#{" | "64#{"] (
			if level-string = 0 [
				print ["!!! Invalid binary --" copy/part str 20]
				print [level-string level-block level-paren]
				if break-on-error? [break]
			]
		)
	]
	rl_pair: [some ch_numbers #"x" some ch_numbers]
	rl_char: [
		{#"} ["^^(" 2 ch_hexadecimal #")" | #"^^" 1 ch_anychar | 1 ch_anychar ] {"}
	]
	
;** These are groups with words used in Rebol

	rl_comparison: [
		"<="  "<>"  "<"  "=="  "=?"  "="  ">"  ">="  "equal?"  "greater-or-equal?" 
		"greater?"  "lesser-or-equal?"  "lesser?"  "maximum-of"  "minimum-of" 
		"not-equal?"  "same?"  "sign?"  "strict-equal?"  "strict-not-equal?"
	]
	rl_context: ["alias"  "bind"  "context"  "get"  "in"  "set"  "unset"  "use"  "value?"]
	rl_control: [
		"all"  "any"  "opt"  "attempt"  "break"  "catch"  "compose"  "disarm"  "dispatch" 
		"do-events"  "does"  "either"  "else"  "exit"  "forall"  "foreach"  "for"  
		"forever"  "forskip"  "func"  "function"  "halt"  "has"  "if"  "launch"  "loop" 
		"next"  "quit"  "reduce"  "remove-each"  "repeat"  "return"  "secure"  "switch" 
		"throw"  "try"  "until"  "wait"  "while"  "do"
	]
	rl_help: [
		"?"  "??"  "about"  "comment"  "dump-face"  "dump-obj"  "help" 
		"license"  "probe"  "source"  "trace"  "usage"  "what"
	]
	rl_logic: [
		"all"  "and"  "any"  "complement"  "found?"  "not"  "or"  "random"  "xor" 
		"on"  "off"  "true"  "false"  "none"
	]
	rl_math: [
		"**"  "*"  "+"  "-"  "//"  "/"  "abs"  "absolute"  "add"  "and"  "arccosine" 
		"arcsine"  "arctangent"  "complement"  "cosine"  "divide"  "even?"  "exp" 
		"log-10"  "log-2"  "log-e"  "maximum-of"  "maximum"  "max"   "min"  "minimum" 
		"minimum-of"  "multiply"  "negate"  "negative?"  "not"  "odd?"  "or" 
		"positive?"  "power"  "random"  "remainder"  "sign?"  "sine"  "square-root" 
		"subtract"  "tangent"  "xor"  "zero?"
	]
	rl_io: [
		"ask"  "change-dir"  "clean-path"  "close"  "confirm"  "connected?" 
		"delete"  "dir?"  "dirize"  "dispatch"  "do"  "echo"  "exists?"  "get-modes" 
		"info?"  "input"  "input?"  "list-dir"  "load"  "make-dir"  "modified?" 
		"open"  "pick"  "poke"  "prin"  "print"  "query"  "read"  "read-io"  "rename" 
		"resend"  "save"  "script?"  "secure"  "send"  "set-modes"  "set-net"  "size?" 
		"split-path"  "suffix?"  "to-local-file"  "to-rebol-file"  "update"  "wait" 
		"what-dir"  "write-io"  "write" 
	]
	rl_series: [
		"alter"  "append"  "array"  "at"  "back"  "change"  "clear"  "copy"  "difference" 
		"ajoin" "empty?"  "exclude"  "extract"  "fifth"  "find"  "first"  "found?"  "fourth" 
		"free"  "head?"  "head"  "index?"  "insert"  "intersect"  "join"  "last"  "length?" 
		"load"  "maximum-of"  "minimum-of"  "offset?"  "parse"  "pick"  "poke"  "random" 
		"rejoin"  "remove"  "remove-each"  "repend"  "replace"  "reverse"  "second" 
		"select"  "skip"  "sort"  "switch"  "tail?"  "tail"  "third"  "union"  "unique"
	]
	rl_dataset: [
		"alter"  "charset"  "difference"  "exclude"  "extract"  "intersect"  "union"  "unique"
	]
	rl_specialstring: [
		"build-tag"  "checksum"  "clean-path"  "compress"  "debase"  "decode-cgi"  "decompress" 
		"dehex"  "detab"  "dirize"  "enbase"  "entab"  "find"  "form"  "import-email"  "lowercase" 
		"mold"  "parse-xml"  "reform"  "remold"  "split-path"  "suffix?"  "trim"  "uppercase"
	]
	rl_system: [
		"browse"  "component?"  "link?"  "now"  "protect"  "protect-system"  "recycle" 
		"unprotect"  "upgrade"
	]
	rl_datatype: [
		"any-block?"  "any-function?"  "any-string?"  "any-type?"  "any-word?"  "as-pair" 
		"binary?"  "bitset?"  "block?"  "char?"  "construct"  "datatype?"  "date?"  "decimal?" 
		"dump-obj"  "email?"  "error?"  "event?"  "file?"  "function?"  "get-word?"  "hash?" 
		"image?"  "integer?"  "issue?"  "library?"  "list?"  "lit-path?"  "lit-word?"  "logic?" 
		"make"  "money?"  "native?"  "none?"  "number?"  "object?"  "op?"  "pair?"  "paren?" 
		"path?"  "port?"  "refinement?"  "routine?"  "series?"  "set-path?"  "set-word?" 
		"string?"  "struct?"  "tag?"  "time?"  "to-binary"  "to-bitset"  "to-block" 
		"to-char"  "to-date"  "to-decimal"  "to-email"  "to-file"  "to-get-word"  "to-hash" 
		"to-hex"  "to-idate"  "to-image"  "to-integer"  "to-issue"  "to-list"  "to-lit-path" 
		"to-lit-word"  "to-logic"  "to-money"  "to-pair"  "to-paren"  "to-path"  "to-refinement" 
		"to-set-path"  "to-set-word"  "to-string"  "to-tag"  "to-time"  "to-tuple"  "to-url" 
		"to-word"  "tuple?"  "type?"  "unset?"  "url?"  "word?"  "to" 
	]
	rl_view: [
		"alert"  "as-pair"  "brightness?"  "caret-to-offset"  "center-face"  "choose"  "clear-fields" 
		"do-events"  "dump-face"  "flash"  "focus"  "hide-popup"  "hide"  "in-window?"  "inform" 
		"layout"  "link?"  "load-image"  "make-face"  "offset-to-caret"  "request-color"  "request" 
		"request-date"  "request-download"  "request-file"  "request-list"  "request-pass"  "request-text" 
		"show-popup"  "show"  "size-text"  "span?"  "stylize"  "unfocus"  "unview"  "viewed?"  "view"  "within?"
	]
	word-classes: copy []
	foreach [group class] reduce [
		rl_comparison 'kw2
		rl_context    'kw3
		rl_control    'kw4
		rl_help       'kw5
		rl_logic      'kw6
		rl_math       'kw7
		rl_io         'kw8
		rl_series     'kw9
		rl_dataset    'kw10
		rl_specialstring 'kw11
		rl_system     'kw12
		rl_datatype   'kw13
		rl_view       'kw14
	][	foreach word group [repend word-classes [word class] ] ]
	word-classes: make hash! word-classes

;## escape-html
	escape-html: func[data][
		data: to string! reduce data
		foreach [from to] [ "&" "&amp;" "<" "&lt;" ">" "&gt;"][
			replace/all data from to
		]
		data
	]
;## emit
	emit: func [data /class cl /html] [
;print ["EMIT:" mold data cl (mold copy/part str 5)]
		case [
			level-string > 0 [
				append string-buffer data
			]
			output? [
	       		repend out either class [
	       			[
	       				{<i class=} cl {>}
	       				escape-html data
	       				"</i>"
	   				]
				][
					either html [data][	escape-html data ]
				]
	       	]
		]
	]

;## add-index-comment
	add-index-comment: func[x /local st n][
		parse/all x [
			[
				  "###" (st: 'co2)
				| "##"  (st: 'co3)
				| "**"  (st: 'co4)
				| "*"   (st: 'co5)
				| "-"   (st: 'co6)
			] copy x some ch_tonewline (
				if st = 'co3 [
					;use only content to paren
					parse/all x [copy x to "(" to end]
				]
				
				case [
					st = 'co2 [
						
						append index-html ajoin [
							case [
								none? index-type ["<ol class=index>"]
								;index-type <> 'co2 ["</ol>^/"]
								all [
									not empty? index-html
									#"," = last index-html
								][ remove back tail index-html]
								true [""]
							]
							{<li class=co2><a href="#m_} n: seo-name x: trim/head/tail x {" class=a1>} x {</a>}
						]
						append out ajoin [{<a name="m_} n {"></a>}]
						index-type: 'co2
					]
					st = 'co3 [
						append index-html ajoin [
							;either index-type = 'co2 ["^/<ol class=co3>^/"][""]
							;{^-<li class=co3><a href="#s_} n: seo-name x {">} x {</a>}
							{^/<a href="#s_} n: seo-name x: trim/head/tail x {" class=a2>} x {</a>,}
						]
						append out ajoin [{<a name="s_} n {"></a>}]
						index-type: 'co3
					]
					
				]
				emit/class join ";" x st
			)
		]
	]

;## colorize
	set 'colorize func[source /save outfile /title ttl /local source-file text x tmp][
		text: either any [file? source url? source][
			source-file: source
			read/binary  source
		][	source ]
		out: make string! 3 * length? text

		level-block:  
		level-paren:  
		level-string: 0
		string-type: index-type: none
		clear string-buffer
		clear index-html
		
		loop 1 [ ;<-- to be able break parsing
			parse/all detab text [
				any [
					str: ;(print [">>>" mold copy/part str 10])
					  #"^^" [
					  	#"(" some ch_hexadecimal #")" x: (
					  		emit/class copy/part str x 'se
					  	)
					  	|
					  	copy x 1 skip (emit/class join "^^" x 'se)
					  	|
					  	#"{" (
					  		case [
					  			level-string = 0 [
					  				emit #"^^"
					  				string-type: #"{"
									level-string: 1
									emit #"{"
								]
								true [
									emit/class "^^{" 'se
								]
							]
						)
						| #"^"" (
							case [
								level-string = 0 [
									emit #"^^"
									string-type: #"^""
									level-string: 1
									emit {"}
								]
								true [
									emit/class {^^"} 'se
								]
							]
						)
						| copy x 1 skip (emit/class join "^^" x 'se)
					]
					| copy x rl_char     (emit/class x 'ch )
					| {"}  (
						either level-string = 0 [
							string-type: #"^""
							level-string: level-string + 1 emit {"}
						][
							emit {"}
							if string-type = #"^"" [
								level-string: 0
								string-type: none
								emit/class string-buffer 'st0
								clear string-buffer
							]
						] 
					)
					| copy x rl_binary   (emit/class x 'bi0)
					
					| copy x rl_word     (
						case [
							#":" = last x [emit/class x 'sw]
							#"!" = last x [emit/class x 'dt]
							parse/case x ["REBOL"][ emit/html {<a href="http://www.rebol.com">REBOL</a>} ]
							true [
								;probe x
								either tmp: select word-classes x [
									emit/class x tmp
								][
									parse x [
										  rl_pair (emit/class x 't1)
										| some ch_numbers (emit/class x 'nu0)
										| #"#" to end  (emit/class x 'iss)
										| [#"%" | "http://" | "ftp://" | "https://"] to end (emit/class x 'fl)
										| #"'" to end (emit/class x 'lw)
										| (emit x)
									]
								]
								
							]
						]
					)
					| #"[" (
						level-block:  level-block  + 1
						either level-string > 0 [
							emit #"["
						][	emit/class #"[" 'br0 ]
					)
					| #"]" (
						level-block:  level-block  - 1
						either level-string > 0 [
							emit #"]"
						][	emit/class #"]" 'br0 ]
					)
					| #"(" (
						if remove-parens? [ output?: off ]
						level-paren:  level-paren  + 1
						either level-string > 0 [
							emit #"("
						][	emit/class #"(" 'br0 ]
					)
					| #")" (
						either level-string > 0 [
							emit #")"
						][	emit/class #")" 'br0 ]
						if 0 = (level-paren:  level-paren  - 1) [output?: on]
						
					)

					| #"{" (
						either level-string = 0 [
							emit/class #"{" 'br1
							string-type: #"{"
						][
							emit #"{"
						]
						
						if string-type = #"{" [
							level-string: level-string + 1
						]
						
					)
					| #"}" (
						either string-type = #"{" [
							level-string: level-string - 1
							either level-string = 0 [
								emit/class string-buffer 'st0
								emit/class #"}" 'br1
								string-type: none
								clear string-buffer
							][
								emit #"}"
							]
						][
							emit #"}"
						]
					)
					| #";" copy x [any ch_space any ch_tonewline] new: (
						if none? x [x: ""]
						either level-string = 0 [
							case [
								all [
									index-comments?
									add-index-comment x
								] none
								
								all [remove-newline-comments? (find ch_newlines first back str)][
									;remove this comment from output with the newline as well
									parse/all new [some ch_newlines new: to end]
								]
								
								true [
									emit/class join ";" x 'co1
								]
							]
						][
							emit #";"
							new: next str
						]
					) :new
					| copy x some ch_newlines (
						either string-type = #"^"" [
							print ["!!! Invalid string --" mold copy/part string-buffer 20]
							if break-on-error? [break]
						][	emit x ]
					)
					| copy x some ch_spaces (emit x)
					
					()
				]
				(
					if level-string > 0 [print ["!!! Invalid string!" level-string mold string-type] ]
					if break-on-error? [break]
				)
			]
		]
		
		if not empty? index-html [append index-html "</ol>"]
	    if save [

	    	write/binary outfile ajoin [
	    		{<html><head>}
	    		{<LINK rel="stylesheet" href="} css-file {"/>}
	    		{<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=windows-1250">}
				{<title>} any [ttl "a Rebol code"] {</title>}
	    		{</head>^/}
	    		{<body bgcolor="#ffffff">}
	    		{<div class=header>}
	    		either title [ajoin ["<h1>" ttl "</h1>"]][""]
	    		either none? source-file [""][
	    			ajoin [
	    				{Source: <b><a href="} source-file {">} last split-path source-file {</a></b> modified: <b>} modified? source-file {</b>}
	    			]
	    		]
	    		either remove-parens? ["<div style='color:#F00;'>Parens were removed from the source!</div>"][""]
	    		{</div>^/}
	    		index-html
	    		{<pre class=rebol>}
	    		out
	    		{</pre>^/}
	    		{<div class=footer>Generated } now
	    		{ by <a href="http://rebol.desajn.net/script/code-colorizer.r">%code-colorizer.r</a> Rebol script</div>}
	    		any [footer-final ""]
	    		{</body></html>}
    		]
		]
		out
	]
	
	
]

;print colorize/save %test-code.txt %test.html
;colorize/save %code-colorizer.r %test.html
;code-colorizer/remove-parens?: off
;code-colorizer/footer-final: {
;<script src="http://www.google-analytics.com/urchin.js" type="text/javascript"></script>
;<script type="text/javascript">_uacct = "UA-1886645-1";urchinTracker();</script>}

;colorize/save/title
;	%code-colorizer.r
;	%code-colorizer.html
;	"Rebol Code Colorizer"

;colorize/save/title
;	to-rebol-file "I:\rebol\rs\projects-rswf\rswf\new\swf-tag-rules_enczes.rb"
;	%rswf-main-rules-full-code.html
;	"Rebol/Flash Dialect (RSWF) main rules"

;### Test code
comment [
	;some code to test if it works
	{str{nasted} and escaped ^{}
	"^^" "^(1f)" 
	multilined-string: {
		some text
		on more
		lines
		with code inside:
		x: sine 1 + 2
	}
	
	x: sine 1 + 2
	
	;pair datatype:
	320x240
	
	;char! datatype:
	#"A"
	;with escape:
	#"^-" = tab
	
	;tuple! datatype:
	red: 255.0.0
	
	;tag!:
	[<tag> 'hello </tag>]
	
	;valid word with escape	char
	word^s
	"string escaped^" char "
	;test
	to image!
	#{}
	#{1
	2}
	64#{Eg==}
	2#{00000000}
	
	;issue
	#FF0000 ;red
	
	table: [
	    q0: "# # L" q0
	        "1 1 L" q0
	        "+ 1 R" q1
	    q1: "1 1 R" q1
	        "# # L" q2
	    q2: "1 # L" q3
	    q3: "1 1 L" q3
	        "+ 1 R" q1
	        "# # R" q4
	    q4: "1 1 R" q4
	        "# # R" q5
	    q5: "# # L" stop
	]
	
	
]
