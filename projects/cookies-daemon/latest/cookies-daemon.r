REBOL [
    Title: "Cookies-daemon"
    Date: 4-Oct-2010/22:36:41+2:00
    Name: none
    Version: 1.2.2
    File: none
    Home: none
    Author: "Oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: {
    Cookies are handled transparently, so you can use any http related commands.
    Additionaly it's possible to send multipart encoded data:
	    ;sending single file:
		read/custom target-url [multipart [myfile %somefile.txt]]   ;== same like <INPUT TYPE=FILE NAME=myfile>
		;sending normal fields:
		read/custom target-url [multipart [field1 "some value" field2 "another value]]
		;sending multivalue:
		read/custom target-url [multipart ["field[]" "some value" "field[]" "another value]]
		;sending file with field value:
		read/custom target-url [multipart [myfile %somefile.txt field1 "some value"]]
	}
    Purpose: {
    	Universal cookies handler.
    	It automatically GETs and SETs cookies if you read or just open a HTTP port.}
    Comment: {It's possible that it will not work with some old Rebol versions!}
    History: [
    	08-06-2003 0.1.0 "First version"
    	23-05-2005 1.0.0 "Modified for compatibility with HTTP scheme from REBOL/View 1.2.110.3.1 (Core 2.6.1)"
    	29-01-2006 1.0.1 "Fixed bug in 'expires' date parser"
    	6-Apr-2006 1.1.0 "Added support to post data in multipart/form-data Content-Type"
    	7-Apr-2006 1.1.1 "Fixed local variables in http-patch"
    	5-Apr-2007 1.1.2 "Added 307 response to the http scheme"
    	27-03-2008 1.2.0 "Modified for compatibility with HTTP scheme from REBOL 2.7.6"
    	27-Sep-2010 1.2.1 "Fixed REBOL's bug in port-id handling with HTTPS scheme to avoid infinite loop in: read https://sourceforge.net"
		3-Nov-2010  1.2.3 "Allowing @ char in user's name"
   	]
    Language: none
    Type: none
    Content: none
    preprocess: true
]

insert net-utils/URL-Parser/user-char #"@"
insert net-utils/URL-Parser/path-char #"!"


set 'cookies-daemon make object! [
	#include %http-patch.r

	cookies: make block! 100 ;[expires domain path name value 
	
	name: value: expires: cookie-value: domain: path: none
	digits: charset [#"0" - #"9"]
	chars: charset [#"A" - #"Z" #"a" - #"z"]

	cookie-pair-rule: [copy name to "=" skip [copy value to #";" skip | copy value to end]]
	cookie-data: make block! 5
	
	parse-cookie: func[cookie-str /local tmp flag][
		;probe cookie-str
		clear cookie-data
comment {
Some cookies want to live on your machine forever do you want them here more then one day?
If so, change the expires value to other date:}
		expires: now + 1 ;default expires date for this cookie if none is specified
		flag: none
		parse cookie-str [
			cookie-pair-rule (cookie-data: reduce [name cookie-value: value])
			any [
				cookie-pair-rule (
					switch/default name [
						"expires" [
							parse/all value [
								some [
									opt [3 chars ", "]
									mark: 2 digits [" " | "-"] 3 chars [" " | "-"] 4 digits [" " | "-"] 2 digits ":" 2 digits ":" 2 digits (
										mark/3: #"-"
										mark/7: #"-"
										mark/12: #"/"
										expires: (to-date copy/part mark 20) + now/zone
									)
									| skip
								]
							]

						]
						"path" [
							path: either value/1 = #"/" [remove value][join path value]
						]
						"domain" [if not none? value [domain: value]]
					][
						;print [name mold value]
						;append cookie-data value
					]
				)
				| "secure"   (flag: 'Secure) ;(append cookie-data true)
				| "HttpOnly" (flag: 'HttpOnly)
			]
		]
		;print ["Cookie:" mold cookie-data "value:" mold cookie-value "exp:" expires "flag:" flag "path:" mold path]
		;if none? cookie-data/2 [insert tail cookie-data path]
		;if none? cookie-data/3 [insert tail cookie-data domain]
		;cookie-data
		if #"." <> first domain [insert domain #"."]
		insert cookie-data reduce [expires domain path]
		append cookie-data flag
		;print ["Cookie:" mold head cookie-data]
		head cookie-data
	]
	get-cookies: func[port /local tmp out host scheme][
		tmp: make block! 6
		domain: join "." copy port/host
		path: any [port/path ""]
		scheme: port/scheme
		
		;print ["Get cookies for port:" port/host]
		cookies: head cookies
		
		while [not tail? cookies] [
			either cookies/1 <= now [
				net-utils/net-log ["Cookie" "deleteGet" cookies/1 cookies/2 path cookies/3 cookies/4 cookies/5 cookies/6]
				cookies: remove/part cookies 6
			][
				parse cookies/2 [copy host to ":" | copy host to end]
				;print ["???" domain host path]
				either all [
					not none? find/part/reverse tail domain host length? host
					any [
						empty? cookies/3
						not none? find/part path dirize cookies/3 1 + length? cookies/3
					]
				][
					if any [
						none? cookies/6
						;all [scheme = 'http  cookies/6 = 'HttpOnly]
						;all [scheme = 'https cookies/6 = 'Secure]
						all [cookies/6 = 'HttpOnly find [http https] scheme]
						all [cookies/6 = 'Secure   find [http] scheme]
					][
						insert tail tmp reduce [cookies/3 rejoin [cookies/4 "=" cookies/5 "; "]]
					]
				][
					net-utils/net-log ["Cookie" "bad" cookies/2 path cookies/3 cookies/4 cookies/5 cookies/6]
				]
				cookies: skip cookies 6
			]
		]
		cookies: head cookies
		tmp: sort/skip/reverse tmp 2
		out: make string! 300
		foreach [path cookie] tmp [	insert tail out cookie	]
		either empty? out [""][
			rejoin [{Cookie: } head remove back tail out "^/"]
		]
	]
	set-cookies: func[port /local tmp dom host-cookies new-cookies new-cookie new? host cooks][
		;probe header-rules/head-list
		tmp: make block! 4
		new-cookies: make block! 4
		cooks: make block! 6
		;probe header-rules/head-list
		foreach [name value] header-rules/head-list [
			if "Set-Cookie" = to-string name [
				append cooks value
			]
		]
		foreach value cooks [
				domain: copy port/host
				path: port/path
				tmp: copy parse-cookie value
				parse tmp/2 [copy host to ":" | copy host to end]
				dom: parse host "."
				if none? tmp/3 [poke tmp 3 copy ""]
				if none? tmp/4 [poke tmp 4 copy ""]
				if none? tmp/5 [poke tmp 5 copy ""]
				;print ["Domain test:"not none? find/part/reverse tail join "." port/host tmp/2 length? tmp/2]
				either all [
					not none? find/part/reverse tail join "." port/host host length? host
					none? find tmp/3 "./"
					any [
						all [
							none? find ["COM" "EDU" "NET" "ORG" "GOV" "MIL" "INT"] last dom
							3 < length? dom
						]
						2 < length? dom
					]
					4000 > length? tmp/3
					4000 > length? tmp/4
					4000 > length? tmp/5
				][
					insert/only tail new-cookies tmp
					net-utils/net-log ["Cookie" "new" value]
				][
					net-utils/net-log ["Cookie" "refused" value]
				]		
		]	
		;print ["NC:" mold new-cookies]

		while [not tail? new-cookies ][
			new-cookie: new-cookies/1
			;print ["Cookie:" mold new-cookie]
			cookies: head cookies
			new?: true
			while [not tail? cookies][
				either cookies/1 <= now [cookies: remove/part cookies 6][
					;print "going thru new cookies"
					
					either all [
						new-cookie/2 = cookies/2
						new-cookie/3 = cookies/3
						new-cookie/4 = cookies/4
					][
						either new-cookie/1 <= now [
							cookies: remove/part cookies 6
							;print "...removed"
						][
							cookies/1: new-cookie/1
							cookies/5: new-cookie/5
							cookies/6: new-cookie/6
							;cookies: skip cookies 6
							;print "...updated"
						]
						new?: false
						break
					][
						cookies: skip cookies 6
					]
				]
			]
			if all [new? new-cookie/1 > now][
				insert head cookies new-cookie ;print "...new"
			]
			new-cookies: next new-cookies
		]
		cookies: head cookies
	]
	delete: func[domain path name][
		while [not tail? cookies][
			cookies: either any [
				cookies/1 <= now
				all [
					cookies/2 = domain
					cookies/3 = path
					cookies/4 = name
				] 
			][
				net-utils/net-log ["Cookie" "deleting" domain path name cookies/5]
				remove/part cookies 6
			][
				skip cookies 6
			]
		]
		cookies: head cookies
	]
	get-value: func[domain path name /local result][
		result: none
		while [not tail? cookies][
			;print ["AAA" cookies/1 now cookies/1 <= now]
			either cookies/1 <= now [
				net-utils/net-log ["Cookie" "deleting" domain path name cookies/5]
				cookies: remove/part cookies 6
			][
				;print ["??" cookies/1 cookies/2 cookies/4 domain name]
				either all [
					cookies/2 = domain
					;cookies/3 = path
					cookies/4 = name
				][
					result: cookies/5
					break
				][
					cookies: skip cookies 6
				]
			]
		]
		cookies: head cookies
		result
	]
	list-cookies: func[][
		while [not tail? cookies][
			either cookies/1 <= now [cookies: remove/part cookies 6][
				print rejoin [cookies/1 " " cookies/2 "/" cookies/3 " " cookies/4 "=" cookies/5 " " cookies/6]
				cookies: skip cookies 6
			]
		]
		cookies: head cookies
	]
]

;read url: http://127.0.0.1:85/test/cookie.php

