rebol [
	title: "Download test"
]

test-download: func[url][
	networking/add-port open/direct/no-wait url func[port /local bytes ud][
		either port? port/sub-port [
			either none? port/state/inBuffer [
				port/state/inBuffer: make binary! 2 + port/state/num: 4000
				port/user-data: make binary! 1000
			][
				clear port/state/inBuffer
			]
			bytes: read-io port/sub-port port/state/inBuffer port/state/num
			ud: port/user-data
			either bytes < 1 [
				print "loaded"
				networking/remove-port port
				write/binary %/d/test.gif ud
			][
				insert tail ud port/state/inBuffer
			]
		][
			networking/remove-port port
		]
	]
]

test-download http://192.168.0.1/imgz/divka.gif