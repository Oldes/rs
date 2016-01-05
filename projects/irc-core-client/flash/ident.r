rebol [
	title: "IDENT server"
]

ctx-ident: make object! [
	idents: none
	ident-name: copy/part system/network/host 15
	digits: charset "1234567890 *"
	start: func[
		"Starts the IDENTs server which is sometimes necessary to conect"
		/stop time {The server will be closed after specified time (should be long enough to reply to the IDENT request)}
	] [
		if none? idents [
			attempt [
				networking/add-port idents: open/direct/lines tcp://:113 func[/local ident-connection ident-buffer][
					ident-connection: first idents
					ident-buffer: first ident-connection
					cprint/inf reform ["^C4,14Ident request: " ident-buffer]
					if parse reform ident-buffer [any digits "," any digits] [
					    insert ident-connection rejoin [ident-buffer " : USERID : REBOL : " ident-name]
					]
				]
			]
		]
		if stop [
			scheduler/remove-action 'idents
			scheduler/add-action  'idents now + time [close]
		]
	] 
	close: func[] [
		cprint/inf/channel join "Closing Ident server: " now none
		networking/remove-port idents idents: none
	]
]