rebol [
	title: "System/port test"
]

	networking/add-port system/ports/system func[port][
		print ["System-port:" mold first port]
		ask "press-enter"
	]