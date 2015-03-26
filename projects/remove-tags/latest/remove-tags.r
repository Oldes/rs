REBOL [
    Title: "Remove-tags"
    Date: 7-May-2008/17:35:16+2:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "David Oliva (commercial)"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: none
    Purpose: none
    Comment: none
    History: none
    Language: none
    Type: none
    Content: none
    Email: oliva.david@seznam.cz
]

remove-tags: func[html /except allowed-tags /base domain /local new x tag name spaces tagchars attchars attr attributes tagstart][
	if not string? html [return html]
	new: make string! length? html
	spaces: charset " ^-^/^M"
	tagchars:  charset [#"a" - #"z" #"A" - #"Z"]
	skipchars: complement charset "<&"
	
	attchars: difference complement spaces charset "/>"
	attributes: copy ""
	if all [base #"/" <> last domain][append domain "/"]
	parse/all html [
		any [
			pos:
			{<} copy tag thru {>} (
				;if x [insert tail new x]
				parse/all tag [
					copy tagstart opt ["/" | none  ]
					copy name some tagchars
					(clear attributes)
					any [
						spaces
						copy attr some tagchars "=" [
							  "'" copy val to "'" 1 skip
							| {"} copy val to {"} 1 skip
							| copy val some attchars
						]
						(
							if find [ "href" "url" "src" "align"] attr [ ;"type"
								if all [
									base
									find ["href" "url" "src"] attr
									not parse val [["http://" | "mailto:" | "ftp://"] to end]
								][	
									insert val domain
									val: simple-clean-path to-url val
								]
								append attributes rejoin [" " attr {="} val {"}]
							]
							;print reduce [attr val]
						)
					]
					copy val to ">" (if found? val [append attributes val])
					to end
				]
				either all [
					except
					find allowed-tags name
				][
					insert tail new rejoin ["<" any [tagstart ""] name attributes ">"]
				][
					switch name [
						"H" "BR" "DIV" "TABLE" [
							unless find spaces pos/-1 [
								insert tail new " "
							]
						]
					]
				]
			)
			|
			"&" (
				if x [insert tail new x]
				insert tail new "&amp;"
			)
			| copy x some skipchars (if x [insert tail new x])
			| skip
		]
		copy x to end (if x [insert tail new x])
	]
	new
] 