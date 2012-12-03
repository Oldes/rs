REBOL [
    Title: "Rebol-cheatsheet"
    Date: 2-Dec-2012/21:49:35+1:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: none
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: none
    Purpose: {Just a simple remake of original Carl's reference sheet page to enable popups}
    Comment: none
    History: none
    Language: none
    Type: none
    Content: none
    Email: none
]

if not exists? dir-functions: %functions/ [
	make-dir %functions/
]

either exists? %reference.html [
	tmp: read/binary %reference.html
][
	tmp: read/binary http://www.rebol.com/docs/reference.html
	write/binary %reference.html  tmp
]

parse/all tmp [
	to {<div class="main">}
	copy html-reference
	to {<div class=nav-bar>}
]

parse/all html-reference [
	any [
		thru {<td class=refcard>} any [
			{<a href="/r3/docs/functions/} copy f to {"} thru {>} copy name to {</a>} 4 skip opt #" " pos:  (
				print [f tab name]
				tmp: none
				attempt [
					either exists? dir-functions/:f [
						tmp: read/binary dir-functions/:f
					][
						write/binary dir-functions/:f tmp: read/binary probe join http://rebol.com/r3/docs/functions/ f
					]
				]
				if tmp [
					unless parse/all tmp [to {<div class="args">} copy args thru {</div>} to end][
						args: copy {<div class="args"></div>}
					]
					pos: insert pos args
				]
			) :pos
		]
	]
]
write %cheatsheet.html rejoin [
{<head>
    <title>REBOL CheatSheet</title>
    <link rel="stylesheet" type="text/css" charset="utf-8" href="http://www.rebol.com/wip3.css"/>
    <link rel="stylesheet" href="http://www.rebol.com/r3/docs/docs.css" type="text/css" charset="utf-8">
    <style type="text/css">
        .args {display: none}
        .funcDecription {position:absolute; display: none; background-color:#eee; padding:15px; width:600px; border: 4px solid #888;}  
    </style>
	<base href="http://www.rebol.com/">
    <script type="text/javascript" src="http://rebol.desajn.net/js/jquery-1.3.2.min.js"></script>
    <script type="text/javascript" src="http://rebol.desajn.net/js/main.js"></script>
</head>
<body>
<div class=funcDecription></div>}
	html-reference
{</body>}
]