rebol []

clean-path2: func[path [string! file! url!] /local parts part set-part ][
	parts: make block! 10
	set-part: func[][parts: insert parts any [part ""]]
	parse to-string path [
		any [
			"../" (parts: remove back parts)
			| "./"
			| copy part to "/" skip  (set-part)
		]
		copy part to end (set-part)
	]
	out: make string! 100
	foreach part (head parts) [
		insert tail out join "/" part
	]
	to type? path copy remove head out
]