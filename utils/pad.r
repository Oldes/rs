rebol [title: "pad"]
pad: func [arg /left /delka d /with w /local txt][
	txt: make string! 10
	if not with [w: #" "]
	if not delka [d: 14]
	loop absolute (length? form arg) - d [append txt w]
	either left [
		insert head txt arg
	][
		append txt arg
	]
	txt
]

pad-time: func[t /local s ms][
	s: to-string ((round t/second * 1000) / 1000)
	parse s [copy s to "." 1 skip copy ms to end | copy s to end]
	s: pad/delka/with copy s 2 "0"

	ms: either none? ms ["000"][pad/delka/with/left ms 3 "0"]
	rejoin [
		pad/delka/with to-string t/hour 2 "0"
		":"
		pad/delka/with to-string t/minute 2 "0"
		":"	s "," ms
	]
]