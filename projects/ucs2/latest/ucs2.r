REBOL [
    Title: "UCS-2"
    Date: 20-Oct-2004/14:20:09+2:00
    Name: 'ucs2
    Version: 1.2.0
    File: %ucs2.r
    Home: none
    Author: "oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: {
		;## for example if you want to convert using cp1250
		
		ucs2/create-rules "cp1250"
		
		;## this will try to create new rules for you and save them in the %charmaps/ directory
		;## in your system/home/local dir
		;## ...then you can use it:
		
		print ["encoded string:" mold tmp: ucs2/encode "äçéöù»ÃœÿŸÏÔË¯û˘Úæ"]
		print ["decoded string:" mold to-string ucs2/decode tmp]
		
		;## if the rules already exists, next time you can just load them using:
		
		ucs2/load-rules "cp1250"
    }
    Purpose: {
    	To encode/decode strings to 2-byte representation of a characters in UCS (Unicode)
    	acording specified 'Character Set List' (charmap). By default the Latin-1 map is used.
    	If you need to convert string using different charset, there are two other functions:
    	create-rules - which will try to create parsing rule according
    	               the character set list specification from
    	               #### ftp://dkuug.dk/i18n/charmaps/ ####
    	               (with hope that these informations are correct
    	                and will be available in the future as well)
    	load-rules - to load already created parsing rules
    }
    Comment: {
    	Usually you will need to encode UCS2 octets to UTF-8
    	You may want to use another script: %utf-8.r which should be somewhere in the library.
    }
    History: none
    Language: none
    Type: none
    Content: none
    Email: oliva.david@seznam.cz
]

ucs2: context [
	charmap: "ISO-8859-1"
	charmaps-url: http://box.lebeda.ws/~hmm/rebol/projects/ucs2/latest/charmaps/
	charmaps-dir: join system/script/path %charmaps/
	if not exists? charmaps-dir [make-dir/deep charmaps-dir]
	
	result: c: none
	encode-rule: [
		any [copy c 1 skip (insert tail result join #{00} c)]
	]
	decode-rule: [
		any [
			#{00} copy c 1 skip (insert tail result c) |
			copy c 2 skip (
				insert tail result c
				;print rejoin [{!!! Unknown UCS-2 octet: } mold c]
			)
		]
	]
	decodeUnknownChar: func[c][
		insert tail result rejoin ["&#x" copy/part skip form to-binary c 2 4 ";"]
	]
	encode: func[
		"Encodes any text to UCS-2 octet string acording the charset"
		str [string! binary!] "String to encode"
	][
		str: to-binary str
		result: make binary! 2 * length? str
		parse/all/case str encode-rule
		result
	]	
	decode: func[
		"Decodes any text to UCS-2 octet string acording the charset"
		str [string! binary!] "String to encode"
	][
		result: make binary! 2 * length? str
		parse/all/case str decode-rule
		result
	]
	load-rules: func[
		"Loads encoding/decoding parsing rules for specified charmap"
		cmap /local old-encode-rule old-decode-rule old-charmap
	][
		old-encode-rule: copy encode-rule
		old-decode-rule: copy decode-rule
		old-charmap: copy charmap
		;probe
		charmap: cmap
		if error? try [
			encode-rule: load rejoin [charmaps-dir cmap ".e.rb"]
			bind encode-rule (in self 'result)
			decode-rule: load rejoin [charmaps-dir cmap ".d.rb"]
			bind decode-rule (in self 'result)
		][
			if error? try [
				encode-rule: load-thru/to rejoin [charmaps-url cmap ".e.rb"] rejoin [charmaps-dir cmap ".e.rb"]
				bind encode-rule (in self 'result)
				decode-rule: load-thru/to rejoin [charmaps-url cmap ".d.rb"] rejoin [charmaps-dir cmap ".d.rb"]
				bind decode-rule (in self 'result)
			][
				;print "!! Unknown charmap !!"
				encode-rule: copy old-encode-rule
				decode-rule: copy old-decode-rule
				charmap: copy old-charmap
				return false
			]
		]
		true
	]
	swap-bytes: func[str [string! binary!] "swaps each two bytes in the string (little<-->big endian conversion)" /local c][
		while [not tail? str] [str: skip reverse/part str 2 2]
		head str
	]
	load-rules "cp1250"
]

latin2-to-cp1250: func[file [file! string!] /local tmp f][
	ucs2/load-rules "iso-8859-2"
	tmp: ucs2/encode read f: to-rebol-file file
	ucs2/load-rules "cp1250"
	write f ucs2/decode tmp
]

cp1250-to-latin2: func[file [file! string!] /local tmp f][
	ucs2/load-rules "cp1250"
	tmp: ucs2/encode read f: to-rebol-file file
	ucs2/load-rules "iso-8859-2"
	write f ucs2/decode tmp
]

