REBOL [
    Title: "UTF8-CP1250"
    Date: 5-Dec-2007/12:33:39+1:00
    Name: none
    Version: 1.0.0
    File: none
    Home: none
    Author: "Oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: [
    	probe as-string utf8/decode probe utf8/encode "abcdìšèøžýáíé"
	]
    Purpose: {
    	Fast UTF8<->CP1250 encoder/decoder based on prepared parse rules so no math is required
    }
    Comment: {There is still space for farther optimization - using char frequencies in the parse rules}
    History: none
    Language: none
    Type: none
    Content: none
    Email: oliva.david@seznam.cz
    preprocess: true
]

UTF8: context [
	ASCII: charset [#"^(00)" - #"^(7F)"]

	result: c: none

	encode-rule: #include-block %utf8-cp1250.e.rb
	decode-rule: #include-block %utf8-cp1250.d.rb
	
	encode: func[
		"Encodes text from CP1250 charset to UTF8 string"
		str [string! binary!] "String to encode"
	][
		str: to-binary str
		result: make binary! 2 * length? str
		parse/all/case str encode-rule
		result
	]	
	decode: func[
		"Decodes UTF8 encoded text to CP1250 charset"
		str [string! binary!] "String to encode"
	][
		result: make binary! length? str
		parse/all/case str decode-rule
		result
	]
]