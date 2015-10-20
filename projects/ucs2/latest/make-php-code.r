rebol [
	title: "Build PHP UTF8 converter"
	file: %make-php-code.r
	author: "oldes"
	require: [rs-project %utf-8]
]
	charmaps-dir: %charmaps-src/
	make-php-code: func[
		"Creates PHP code for UCS2 encoding from charmap specification"
		cmap /local cs-spec-file cs-spec b u c
	][
		charmap: cmap
		either exists? cs-spec-file: join charmaps-dir charmap [
			cs-spec: read cs-spec-file
		][
			write/binary cs-spec-file cs-spec: read/binary join ftp://dkuug.dk/i18n/charmaps/ charmap
		]
		encode-rule: make string! 5000
		insert encode-rule rejoin [
			{<?^/}
			{$utf8_} charmap { = Array (^/}
			{// } charmap { UTF8 encoding rule^/}
			{// source:  ftp://dkuug.dk/i18n/charmaps/} charmap {^/}
			{// created: } now { by } system/user/name { using Rebol^/}
		]
		parse/all cs-spec [
			thru {CHARMAP^/}
			any [	
				thru {/x} copy b to { }
				thru {<U} copy u to {>}
				1 skip copy c to newline
				(
					b: load rejoin ["#{" b "}"]
					u: load rejoin ["#{" u "}"]
					;print [b u u/1 u/1 = 0 u/2 > 127]	
					if any [
						not find/reverse/part tail u b 2
						all [u/1 = 0 u/2 > 127]
					][
						
						u2: utf-8/encode-2 u
						tmp: make string! 20
						foreach x u2 [
							append tmp rejoin [".chr(" x ")"]
						]
						;probe to-integer u2/1
						insert tail encode-rule rejoin [
							"^-chr(" to-integer b ")=>" next tmp ", //" c "^/"
						]
					]
				)
			]
		]
		remove find/last encode-rule ","
		insert tail encode-rule {);^/echo strtr("èeština je krásný jazyk", $utf8_cp1250);^/?>}
		write clipboard:// encode-rule
		encode-rule
	]