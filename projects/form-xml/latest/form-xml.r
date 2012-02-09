REBOL [
    Title: "Form-xml"
    Date: 9-Feb-2012/13:34:18+1:00
	file: none
    Version: 0.2.0
    Author: "David 'Oldes' Oliva"
	purpose: {Converts XML DOM structure in nested REBOL block back to string with possible indentation}
	comment: {
		The script forms string value of SCRIPT tag into CDATA.
		It would be better to add proper detection when CDATA is required!
	}
	require: [
		rs-project 'ajoin
		rs-project 'xml-parse
	]
	usage: [
		print "^/Original XML:"
		probe original-xml-string: "<a>foo<b><c/><d></d></b><b><script><![CDATA[bar]]></script></b></a>"
		print "^/Loaded XML:"
		probe loaded-xml-string:   parse-xml+ original-xml-string
		print "^/Formed XML:"
		print form-xml/no-indent third loaded-xml-string
		print "^/Formed XML with simple indentation:"
		print form-xml third loaded-xml-string
	]
]

ctx-form-xml: context [
	out:  make string! 2048
	tabs: none
	
	emitxml: func[
		dom [block!] "XML DOM block"
		/local value
	][
		foreach node dom [
			either string? node [
				if tabs [clear skip out negate length? tabs]
				out: insert tail out node ;;There was: join node #" " ;;I'm not sure why;;
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
						out: insert out either tabs [
							append tabs #"^-"
							join #">" tabs
						][	#">" ]

						either all [
							name = "script"
							1 = length? content
							string? content/1
						][	
							out: insert tail out rejoin [{<![CDATA[} content {]]>}]
						][
							emitxml content
							if tabs [remove back tail out]
							
						]
						if tabs [remove back tail tabs]
						
						out: insert out ajoin ["</" name #">" any [tabs ""]]
					][
						out: insert out join "/>" any [tabs ""]
					]
				]
			]
		]
	]
	set 'form-xml func[
		"Converts XML DOM value (nested block structure) to a string"
		dom [block!] "XML DOM block"
		/no-indent "Does not tries to add tab indentation"
	][
		clear head out
		tabs: either no-indent [none][copy "^/"]
		emitxml dom
		head out
	]
]
