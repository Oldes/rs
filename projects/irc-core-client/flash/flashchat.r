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
flashsrvport: open/lines/no-wait/with tcp://box.lebeda.ws:9000 "^@"
;flashsrvport: open/lines/no-wait/with tcp://127.0.0.1:9000 "^@"

networking/add-port flashsrvport :flashsrv-port-handler

utf8?: false
s: func[msg][
	insert flashsrvport rejoin [
		{pms } mold current-puppet { "!system" }
		mold either utf8? [msg][to-string utf-8/encode-2 ucs2/encode to-binary msg]
	]
]


sp: func[p m /local t][t: current-puppet current-puppet: p s m current-puppet: t]

do-server: func[cmd [block!]][
	insert flashsrvport replace/all rejoin [{do } compress mold cmd ] "^/" ""
]
;do-server [print ctx-flashd/flashd-server/postav]

puppets: make block! 10
new-puppet: func[name postava-id][
	if none? find puppets name [
		insert flashsrvport reform [{puppet} mold to-string utf-8/encode-2 ucs2/encode to-binary name postava-id]
		insert puppets name
	]
]


comment {
insert flashsrvport {puppet "platon" 16}
insert flashsrvport {puppet "mila" 6}
insert flashsrvport {puppet "jano" 4}
current-puppet: "platon"
}

new-puppet "Oldes" 16



current-puppet: "Oldes"

;s "ahoj"