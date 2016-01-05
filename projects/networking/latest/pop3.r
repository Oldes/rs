rebol [
	title: "POP3 port"
	note: {
		related documents:
		RFC1939: Post Office Protocol - Version 3
	}
]

error? try [networking/remove-port POP3-port]

POP3-port: open/lines/with/direct tcp://:110 "^M^/"

POP3-users: ["tim"]
POP3-passs: ["t"  ]


POP3-port-handler: func[port /local bytes ud ][
		if port? subport: first port [
			print ["POP3  : new connection" subport/host subport/port-id]
			subport/user-data: make object! [
				cmd:  none
				logged?: false
				user: none
			]
			insert-port: func[port msg][
				print ["POP3-S:" msg]
				insert port msg
			]
			networking/add-port subport func[port /local c tmp][
				c: pick port 1
				either none? c [
					print "POP3-C: closing"
					networking/remove-port port
				][
					print ["POP3-C:" c]
					parse/all c [
						  "USER " copy tmp to end (
						  	insert-port port either find POP3-users tmp [
						  		port/user-data/user: tmp
						  		"+OK"
					  		][	join "-ERR sorry, no mailbox for " tmp ]
						)
						| "PASS " copy tmp to end (
							either port/user-data/logged? [
								insert-port port "-ERR already logged in"
							][
								insert-port port either all [
									not none? i: find POP3-users port/user-data/user
									tmp = pick POP3-passs index? i
								][
									port/user-data/logged?: true
									"+OK"
								][	"-ERR" ]
							]
						)
						| "STAT" (
							insert-port port "+OK 2 20"
						)
						| "LIST" (
							insert-port port "+OK 2 messages (320 octets)"
							insert-port port "1 120"
							insert-port port "2 200"
							insert-port port "."
						)
						| "RETR " copy tmp to end (
							insert-port port "-ERR"
						)
						| "NOOP" (insert-port port "+OK")
						| "AUTH " copy tmp to end (
							insert-port port "-ERR Unrecognized authentication type"
						)
						| "QUIT" (
							insert-port port "+OK POP3 server signing off"
							networking/remove-port port
						)
					]
				]
			]
			insert subport "+OK POP3 server ready"
		]
]

networking/add-port pop3-port :pop3-port-handler	