rebol [
	title: "UDP-server test"
]

	udp-server-port: open/direct/no-wait udp://:1111
	set-modes udp-server-port [receive-buffer-size: 2000000]
	udp-server-port-handler: func[port /local bytes ud ][
		bytes: copy port
		print ["UDP read" length? bytes "bytes"]
	]
	networking/add-port udp-server-port :udp-server-port-handler