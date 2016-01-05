rebol [
	title: "IDENT server"
]

ctx-ident: make object! [
	idents: none
	ident-name: rejoin [system/network/host "\" system/user/name]
	start: func[
		"Starts the IDENTs server which is sometimes necessary to conect"
		/stop time {The server will be closed after specified time (should be long enough to reply to the IDENT request)}
	] [
		if none? idents [
			attempt [
				networking/add-port idents: open/direct/lines tcp://:113 func[/local ident-connection ident-buffer][
					cprint/inf "Ident request!"
					ident-connection: first idents
					ident-buffer: first ident-connection
					if find/any reform ident-buffer "*,*" [
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
	close: func[] [networking/remove-port idents idents: none]
]