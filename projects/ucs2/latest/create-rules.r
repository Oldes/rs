rebol [
	title: "ucs2-create-rules"
	author: "Oldes"
	comment: "This function was removed from UCS2 object as the rules are already created now"
]

charmaps-dir: %charmaps/
charmaps-src: %charmaps-src/ ;ftp://dkuug.dk/i18n/charmaps/
ucs2-create-rules: func[
	"Creates parsing (encode/decode) rules from charmap specification"
	cmap
	/no-describe
	/local cs-spec-file cs-spec b u c
][
	charmap: cmap
	either exists? cs-spec-file: join charmaps-dir charmap [
		cs-spec: read cs-spec-file
	][
		;write/binary cs-spec-file
			cs-spec: read/binary join charmaps-src charmap
	]
	encode-rule: make string! 5000
	decode-rule: make string! 5000
	insert encode-rule rejoin [
		{; } charmap { UCS-2 encoding rule^/}
		{; source:  ftp://dkuug.dk/i18n/charmaps/} charmap {^/}
		;{; created: } now {^/}
		{any [^/}
	]
	insert decode-rule rejoin [
		{; } charmap { UCS-2 decoding rule^/}
		{;  source: ftp://dkuug.dk/i18n/charmaps/} charmap {^/}
		;{; created: } now {^/}
		{any [^/}
	]
	parse/all cs-spec [
		thru {CHARMAP} opt #"^M" {^/}
		any [	
			thru {/x} copy b to { }
			thru {<U} copy u to {>}
			1 skip copy c to newline
			(
				replace/all b "/x" ""
				if not find/reverse/part tail u b 2 [
					;print [b u]
					insert tail encode-rule rejoin [
						"#{" b "} (insert tail result #{" u "}) | " either no-describe [""][join ";" c] "^/"
					]
					insert tail decode-rule rejoin [
						"#{" u "} (insert tail result #{" b "}) | " either no-describe [""][join ";" c] "^/"
					]
				]
			)
		]
	]
	insert tail encode-rule "copy c 1 skip (insert tail result join #{00} c)^/]"
	insert tail decode-rule rejoin [
		"#{00} copy c 1 skip (insert tail result c) | ^/"
		"copy c 2 skip ("
			;insert tail result c
			"decodeUnknownChar c"
		")^/]"
	]
	write join cs-spec-file ".e.rb" encode-rule
	write join cs-spec-file ".d.rb" decode-rule
	;encode-rule: load encode-rule
	;bind encode-rule (in self 'result)
	;decode-rule: load decode-rule
	;bind decode-rule (in self 'result)
	true
]