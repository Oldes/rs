REBOL [
    Title: "Make DUCET"
    Date: 27-Feb-2006/12:48:37+1:00
    Name: 'ucs2
    Version: 1.2.0
    File: %make-ducet.r
    Home: none
    Author: "oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Purpose: {
    	To create Unicode Collation Element Table in Rebol format
    }

    History: none
    Language: none
    Type: none
    Content: none
    Email: oliva.david@seznam.cz
]

do-thru http://box.lebeda.ws/~hmm/rebol/ucs2_latest.r

make-ducet: func[][
	allkeys: read-thru/to http://www.unicode.org/Public/UCA/latest/allkeys.txt %allkeys.txt
	ducet: make block! 30000
	parse/all allkeys [
		thru {@version} copy version to {^/} 1 skip thru {^/} (probe version)
		any [
			copy uc to " " thru {[} 1 skip copy ucweight to {]} to {^/} 1 skip (
				if 4 = length? uc [
					replace/all ucweight "." ""
					uc: load rejoin ["#{" uc "}"]
					ucweight: load rejoin ["#{" copy/part ucweight 12 "}"]
					insert tail ducet reduce [uc ucweight]
				]
			)
		]
	]
	ducet
]
;make-ducet
;save %ducet.rb new-line/skip ducet true 2

;ducet: make hash! (load decompress read/binary %ducet.rbc)
ducet: make hash! (load decompress read-thru/to http://box.lebeda.ws/~hmm/rebol/projects/ucs2/latest/ducet.rbc %ducet.rbc)

ucs2-to-ucs2w: func[str /case ][
	while [not tail? str][
		ucw: select ducet either case [lowercase copy/part str 2][copy/part str 2]
		insert str either none? ucw [#{000000000000}][ucw]
		str: skip str 8
	]
	head str
]

ucs2w-to-ucs2: func[str][
	while [not tail? str][
		remove/part str 6
		str: skip str 2
	]
	head str
]

get-ucs2w-insensitive: func[str /local ucs2w ch][
	ucs2w: make string! (2 * length? str)
	while [not tail? str][
		ch: copy/part str 2
		ucw: select ducet (lowercase ch)
		insert tail ucs2w either none? ucw [#{0000000000000000}][join ucw ch]
		str: skip str 2
	]
	str: head str
	ucs2w
]


test-block: random [
  "Anton"
    "Antonín"
    "antonín"
    "Boromír"
    "cech"
    "èech"
    "Cecil"
    "Èenda"
    "chyt"
    "czech"
    "David"
]

test-sort: func[b][
	forall b [change b ucs2-to-ucs2w ucs2/encode b/1]
	b: head b
	b: sort/case/all b
	forall b [change b to-string ucs2/decode ucs2w-to-ucs2 b/1]
	b: head b
]

test-sort2: func[b /local tmp][
	forall b [insert b get-ucs2w-insensitive ucs2/encode b/1 b: skip b 1]
	b: head b
	b: sort/case/all/skip b 2
	while [not tail? b][
		remove b b: skip b 1
	]
	b: head b
]

test-sort3: func[b][
	forall b [change b ucs2-to-ucs2w/case ucs2/encode b/1]
	b: head b
	b: sort/case/all b
	forall b [change b to-string ucs2/decode ucs2w-to-ucs2 b/1]
	b: head b
]

print "Original block:"
probe test-block
print "Normal sort:"
probe sort copy test-block
print "Sort/case:"
probe sort/case copy test-block
print "ucs2 sort:"
probe test-sort copy test-block
print "ucs2 sort2 (case insensitive):"
probe test-sort2 test-block
print "ucs2 sort3 (case insensitive):"
probe test-sort2 test-block


