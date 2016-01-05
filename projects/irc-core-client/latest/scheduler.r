rebol [
	title: "Scheduler"
]

scheduler: make object! [
	scheduled: make block! 20
	process: func[][
		while [not tail? scheduled][
			either scheduled/1 <= now [
				dprint ["SCHEDULED-ACTION: " mold scheduled/2/2]
				attempt scheduled/2/2
				remove/part back scheduled 2
			][	break ]
		]
	]
	add-action: func[id when [date!] action [block!]][
		insert/only scheduled reduce [id action]
		insert scheduled when
		sort/skip scheduled 2
		dprint [mold scheduled]
	]
	remove-action: func[id /local f][
		while [not tail? scheduled][
			either scheduled/2/1 = id [
				remove/part scheduled 2
			][	scheduled: skip scheduled 2 ]
		]
		dprint [mold scheduled]
	]
]