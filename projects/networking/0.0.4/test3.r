rebol [
	title: "Telnet test"
]

	telnet-port: open/direct/no-wait tcp://127.0.0.1:4000

	telnet-port-handler: func[port /local bytes ud ][
			either none? port/state/inBuffer [
				port/state/inBuffer: make binary! port/state/num: 4000
			][
				clear port/state/inBuffer
			]
			bytes: read-io port port/state/inBuffer 10000
			ud: port/user-data
			either bytes = 0 [
				print "loaded"
				networking/remove-port port
			][
				prin to-string port/state/inBuffer
			]

	]
	networking/add-port telnet-port :telnet-port-handler