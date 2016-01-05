rebol [
	title: "FlashChat (Rebol) client"
]

error? try [close flashsrvport]
flashsrv-port-handler: func[port /local tmp][
	either none? tmp: system/words/copy/part port 1 [
		ctx-console/clear-line
		networking/remove-port port
	][
		print first tmp
	]
]
flashsrvport: open/lines/no-wait/with tcp://127.0.0.1:9000 "^@"

networking/add-port flashsrvport :flashsrv-port-handler

insert flashsrvport {puppet "irc"}

do-server: func[cmd [block!]][
	insert flashsrvport replace/all rejoin [{do } compress mold cmd ] "^/" ""
]

;do-server [print ctx-flashd/flashd-server/postav]