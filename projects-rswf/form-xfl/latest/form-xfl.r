REBOL [
    Title: "Form-XFL"
    Date: 6-Mar-2012/13:09:17+1:00
	file: none
    Version: 0.2.1
    Author: "David 'Oldes' Oliva"
	purpose: {Converts XML DOM structure in nested REBOL block back to string with possible indentation}
	comment: {
		This version is simplified form-xml script, where I removed the indentation - as in XFL it may cause problems.
		
		The script forms string value of SCRIPT tag into CDATA.
		It would be better to add proper detection when CDATA is required!
	}
	require: [
		rs-project 'ajoin
		rs-project 'xml-parse
	]
]

ctx-form-xfl: context [
	out:  make string! 20048

	emitxfl: func[
		dom [block!] "XML DOM block"
		/local value
	][
		foreach node dom [
			either string? node [
				out: insert tail out node
			][	
				foreach [ name atts content ] node [
					out: insert out ajoin [{<} name #" "]
					if block? atts [
						foreach [att value] atts [ 
							value: to string! any [value ""]
							out: insert out ajoin either find value #"^"" [
								[att {='} value {' }]
							][	[att {="} value {" }]]
						]
					]
					out: remove back out
					
					either all [content not empty? content] [
						out: insert out #">"
						case [
							all [
								name = "script"
								1 = length? content
								string? content/1
							][	
								out: insert tail out rejoin [{<![CDATA[} content {]]>}]
							]
							'default [
								emitxfl content
							]
						]
						out: insert out ajoin ["</" name #">"]
					][
						out: insert out "/>"
					]
				]
			]
		]
	]
	set 'form-xfl func[
		"Converts XFL DOM value (nested block structure) to a string"
		dom [block!] "XFL DOM block"
	][
		clear head out
		emitxfl dom
		head out
	]
]
