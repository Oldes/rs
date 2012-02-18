REBOL [
    Title: "BBcode"
    Date: 5-Jan-2009/1:06:26+1:00
    Name: 'bbcode
    Version: 0.1.0
    File:    %bbcode.r
    Author:  "David 'Oldes' Oliva"
    Email:   oliva.david@seznam.cz
    Home:    http://box.lebeda.ws/~hmm/
    Owner: none
    Rights: none
    Needs: none
    Tabs: 4
    Usage: [
    	test-cases: [
			{text [b]bold[/b] abc}  {text <b>bold</b> abc}
			{text [b]bold [i]italic[/b]}  {text <b>bold <i>italic</i></b>}
			{[s]strikethrough text[/s]}  {<s>strikethrough text</s>}
			{[url]http://example.org[/url]}  {<a href="http://example.org">http://example.org</a>}
			{[url=http://example.com]Example[/url]}  {<a href="http://example.com">Example</a>}
			{[url=http://example.com][b]Example[/url]}  {<a href="http://example.com"><b>Example</b></a>}
			{[b][ul][li]Jenny[/li][li]Alex[/li][li]Beth[/li][/ul][/b]}  {<b><ul><li>Jenny</li><li>Alex</li><li>Beth</li></ul></b>}
			{[ul][li]bla[li]bla}  {<ul><li>bla</li><li>bla</li></ul>}
			{[ul][li][b]bla[li]bla}  {<ul><li><b>bla</b></li><li>bla</li></ul>}
			{[ul][li]bla[li][ol][li]bla[/ol]}  {<ul><li>bla</li><li><ol><li>bla</li></ol></li></ul>}
			{[code]xx[b]yy[/b]zz[/code]}  {<code>xx[b]yy[/b]zz</code>}
			{[list][*]aaa[*]bbb[/list]}  {<ul><li>aaa</li><li>bbb</li></ul>}
			{[list=a][*]aaa[*]bbb[/list]}  {<ol style="list-style-type: lower-alpha;"><li>aaa</li><li>bbb</li></ol>}
			{[list=A][*]aaa[*]bbb[/list]}  {<ol style="list-style-type: upper-alpha;"><li>aaa</li><li>bbb</li></ol>}
			{[/b]} {}
			{aa[b="]bb} {aa[b="]bb}
			{[quote]blabla} {<fieldset><blockquote>blabla</blockquote></fieldset>}
			{[quote=Carl]blabla} {<fieldset><legend>Carl</legend><blockquote>blabla</blockquote></fieldset>}
			{[img]http://www.google.com/intl/en_ALL/images/logo.gif[/img]} {<img src="http://www.google.com/intl/en_ALL/images/logo.gif" alt="">}
			{[url=http://http://www.google.com/][img]http://www.google.com/intl/en_ALL/images/logo.gif[/url][/img]}
			 {<a href="http://http://www.google.com/"><img src="http://www.google.com/intl/en_ALL/images/logo.gif" alt=""></a>}
			{[img]1.gif [img]2.gif} {<img src="1.gif" alt=""> <img src="2.gif" alt="">}
			{text [size=tiny]tiny} {text <span style="font-size: xx-small;">tiny</span>}
			{[h1]header[/h1]} {<h1>header</h1>}
			{[color]ee[/color][color=#F00]red[color=#00FF00]green} {ee<span style="color: #F00;">red<span style="color: #00FF00;">green</span></span>}
			{<a>}  {&lt;a>}
			{multi^/line}  {multi^/<br>line}
			{invalid [size]size[/size]}  {invalid <span>size</span>}
			{[align=right]right}  {<div style="text-align: right;">right</div>}
			{[email]x@x.cz[/email] [email=x@x.cz]email [b]me[/email]}  {<a href="mailto:x@x.cz">x@x.cz</a> <a href="mailto:x@x.cz">email <b>me</b></a>}
		]
		foreach [src result] test-cases [
			print ["<==" src]
			print ["==>" tmp: bbcode src]
			print either tmp = result ["OK"][join "ERR " result]
			print "---"
		]
	]
    Purpose: {Basic BBCode implementation. For more info about BBCode check http://en.wikipedia.org/wiki/BBCode}
    Comment: none
    History: [
    	0.1.0 5-Jan-2009 "Initial version"
	]
	Type: [tool dialect function]
    Library: [
        level:    'advanced
        platform: 'all
        type:     [tool dialect function]
        domain:   [dialects files html markup parse text text-processing web]
    ]

    Content: none
]

ctx-bbcode: context [
	ch-normal:    complement charset "[<^/"
	ch-attribute: complement charset {"'<>]}
	ch-hexa: charset [#"a" - #"f" #"A" - #"F" #"0" - #"9"]
	ch-name: charset [#"a" - #"z" #"A" - #"Z" #"*" #"0" - #"9"]
	ch-url:  charset [#"a" - #"z" #"A" - #"Z" #"0" - #"9" "./:~+-%#\_=&?@"]
	opened-tags: copy []
	rl-attribute: [#"=" copy attr any ch-attribute]

	allow-html-tags?: false
	attr: none
	html: copy ""
			
	close-tags: func[tags [block!]][
		foreach tag head reverse tags [
			append html case [
				tag = "url" ["</a>"]
				find ["list" "color" "quote" "size" "align" "email"] tag [""]
				
				true [
					rejoin ["</" tag ">"]
				]
			]
		]
	]
	
	enabled-tags: [
		"b" "i" "s" "u" "del" "h1" "h2" "h3" "h4" "h5"
		"ins" "dd" "dt" "ol" "ul" "li" "url" "list" "*"
		"color" "quote" "img" "size" "rebol" "align" "email"
	]
	
	set 'bbcode func["Converts BBCode markup into HTML" code [string! binary! file! url!] "Input with BBCode tags" /local tmp tag][
		clear html
		if any [file? code url? code][code: read/binary code]
		parse/all code [
			any [
				(attr: none)
				copy tmp some ch-normal (append html tmp)
				|
				"[url]" copy tmp some ch-url opt "[/url]" (
					append html rejoin [{<a href="} tmp {">} tmp {</a>}]
				)
				|
				"[email]" copy tmp some ch-url opt "[/email]" (
					append html rejoin [{<a href="mailto:} tmp {">} tmp {</a>}]
				)
				|
				"[img]" copy tmp some ch-url opt "[/img]" (
					append html rejoin [{<img src="} tmp {" alt="">}]
					
				) 
				|
				"[code]" copy tmp to "[/code]" thru "]" (
					append html rejoin [{<code>} tmp {</code>}]
				)
				|
				"[rebol]" copy tmp to "[/rebol]" thru "]" (
					append html rejoin [{<code>} tmp {</code>}]
					;TODO: add REBOL code colorizer
				)
				|
				#"[" [
					;normal opening tags
					copy tag some ch-name opt rl-attribute			
					#"]" (
						if tag = "*" [tag: "li"]
						append html either find enabled-tags tag [
							if find ["li"] tag [
								;closed already opened tag
								if all [
									tmp: find/last opened-tags tag 
									none? find tmp "ol"
									none? find tmp "ul"
								][
									close-tags copy tmp
									clear tmp
								]
							]
							append opened-tags tag
							switch/default tag [
								"url"  [rejoin [{<a href="} attr {">}]]
								"color" [
									either all [attr parse attr [
										#"#" [6 ch-hexa | 3 ch-hexa]
									]][
										append opened-tags "span"
										rejoin [{<span style="color: } attr {;">}]
									][
										;;Should the invalid tag be visible?
										;rejoin either attr [
										;	["[" tag "=" attr "]"]
										;][	["[" tag "]"] ]
										""
									]
								]
								"quote" [
									append opened-tags ["fieldset" "blockquote"]
									either attr [
										rejoin [{<fieldset><legend>} attr {</legend><blockquote>}]
									][
										{<fieldset><blockquote>}
									]
								]
								"list" [
									if none? attr [attr: ""]
									parse/case attr [
										[
											  "a" (tmp: {<ol style="list-style-type: lower-alpha;">})
											| "A" (tmp: {<ol style="list-style-type: upper-alpha;">})
											| "i" (tmp: {<ol style="list-style-type: lower-roman;">})
											| "I" (tmp: {<ol style="list-style-type: upper-roman;">})
											| "1" (tmp: {<ol style="list-style-type: decimal;">})
										] (append opened-tags "ol")
										| (append opened-tags "ul" tmp: {<ul>})
									]
									tmp
								]
								"size" [
									if none? attr [attr: ""]
									parse attr [
										[
											  ["tiny" | "xx-small" | "-2"] (tmp: {<span style="font-size: xx-small;">})
											| ["x-small" | "-1"]         (tmp: {<span style="font-size: x-small;">})
											| ["small" | "normal" | "0"] (tmp: {<span style="font-size: small;">})
											| ["medium" | "1"]           (tmp: {<span style="font-size: medium;">})
											| ["large"  | "2"]           (tmp: {<span style="font-size: large;">})
											| ["x-large" | "huge" | "3"] (tmp: {<span style="font-size: x-large;">})
											| ["xx-large" | "4"]         (tmp: {<span style="font-size: xx-large;">})
											
										] end
										;TODO: other number values (pt,px,em)?
										| to end (tmp: {<span>})
									]
									append opened-tags "span"
									tmp
								]
								"align" [
									if none? attr [attr: ""]
									parse attr [
										[
											  ["right"   | "r"] (tmp: {<div style="text-align: right;">})
											| ["left"    | "l"] (tmp: {<div style="text-align: left;">})
											| ["center"  | "c"] (tmp: {<div style="text-align: center;">})
											| ["justify" | "j"] (tmp: {<div style="text-align: justify;">})
										] end
										| to end (tmp: {<div>})
									]
									append opened-tags "div"
									tmp
								]
								"email" [
									either error? try [tmp: to-email attr][""][
										append opened-tags "a"
										rejoin [{<a href="mailto:} tmp {">}]
									]
								]
							][
								rejoin ["<" tag ">"]
							]
							
						][
							rejoin ["[" tag "]"]
						]
					)
					
					|
					;closing tags
					#"/" 
					copy tag some ch-name
					#"]" (
						either tmp: find/last opened-tags tag [
							close-tags copy tmp
							clear tmp
						][
							;;unopened tag, hidden by default, uncomment next line if you don't want to hide it
							;append html rejoin [{[/} tag {]}] 
						]
					)
					| (append html "[")
				]
				|
				#"<" (append html either allow-html-tags? ["<"]["&lt;"])
				|
				#"^/" (append html "^/<br>")
			]
		]
		unless empty? opened-tags [
			close-tags opened-tags
			clear opened-tags
		]
		copy html
	]
]


