rebol [
	title: "DNS test"
]

	networking/add-port dns-port: open/direct dns://127.0.0.1 func[port][
		print ["DNS-port:"]
		
	]
	? dns-port