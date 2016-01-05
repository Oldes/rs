rebol [
	title: "TCP-server-test"
]
attempt [
	networking/add-port conn: open/direct/no-wait tcp://:5000 func[port /local bytes subport ][
		if port? subport: first port [
			print ["new connection" subport/host subport/port-id]
			networking/add-port subport func[port /local bytes ud][
				either none? port/state/inBuffer [
					port/state/inBuffer: make binary! 10000
				][
					clear port/state/inBuffer
				]
				port/state/num: 10000
				bytes: read-io port port/state/inBuffer port/state/num + 2
				either bytes <= 0 [
					networking/remove-port port
				][
					probe to-string port/state/inBuffer
					net-utils/net-log ["low level read of " bytes "bytes"]
					insert port "ok^@"
				]
			]
		]
	]
]