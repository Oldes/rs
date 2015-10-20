REBOL [
    Title: "UCS-2 (CP1250 charset only!)"
    Date: 5-Oct-2004/14:20:09+2:00
    Name: 'ucs2
    Version: 1.1.0
    File: %ucs2.r
    Home: none
    Author: "oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: {
		print ["encoded string:" mold tmp: ucs2/encode "ŠšÈÌÏØÙìïèøùò¾"]
		print ["decoded string:" mold to-string ucs2/decode tmp]
    }
    Purpose: {
    	To encode/decode strings to 2-byte representation of a characters in UCS (Unicode)
    	acording CP1250 charset
    }
    History: none
    Language: none
    Type: none
    Content: none
    Email: oliva.david@seznam.cz
    preprocess: true
]

ucs2: context [
	charmap: "cp1250"

	result: c: none

	encode-rule: #include-block %/i/rebol/rs/projects/ucs2/latest/charmaps/cp1250.e.rb
	decode-rule: #include-block %/i/rebol/rs/projects/ucs2/latest/charmaps/cp1250.d.rb
	
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
]

