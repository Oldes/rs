rebol [
	title: "UCS2 build-parsers"
	Purpose: "To prepare all UCS2 parser rules from source charmaps"
]

do %create-rules.r

charmaps: read %charmaps-src/

names: make block! 200
aliases: make block! 10

out: open/new/direct/write %charmaps.rb

foreach file charmaps [
	clear aliases
	parse read join %charmaps-src/ file [
		thru {<code_set_name> } copy name to newline
		any [
			thru {% alias } copy a to newline
			(insert tail aliases a)
		]
	]
	if all [
		none? find names name
		;name <> "ANSI_X3.110-1983"
	][
		insert tail names name
		insert/only tail names aliases
		print [name mold aliases]
		append out rejoin [mold name tab mold aliases newline]
		ucs2-create-rules/no-describe name
	]
]
close out
names
