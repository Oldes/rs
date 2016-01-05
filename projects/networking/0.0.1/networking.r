REBOL [
    Title: "Networking"
    Date: 17-Jun-2003/16:37:33+2:00
    Name: none
    Version: 0.0.1
    File: none
    Home: none
    Author: "oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: none
    Purpose: none
    Comment: none
    History: none
    Language: none
    Type: none
    Content: none
    Email: oliva.david@seznam.cz
	Require: [rss-project 'console-port]
]
trace/net on

attempt: func[value ][
	either error? set/any 'value try :value [
		print-error disarm value none
	][get/any 'value]
	;if error? set/any 'err try [do action][print-error disarm err none]
]

print-error: func[err /local type id arg1 arg2 arg3][
	set [type id arg1 arg2 arg3] reduce [err/type err/id err/arg1 err/arg2 err/arg3]
	print [
		system/error/:type/type ": "
		reduce bind system/error/:type/:id 'arg1
	]
	print ["** Where: " mold err/where]
	print ["** Near: " mold err/near]
]

set 'networking make object! [
	timeout-actions: make block! 10
	port-block: make block! 10
	
	wait-list:  make block! 10
	insert wait-list 0:0:1 ;for timeout
	
	
	add-port: func[port handler][
		net-utils/net-log rejoin ["Adding port: " port/scheme "://" port/host ":" port/port-id]
		insert wait-list port
		insert port-block reduce [port :handler]
	]
	remove-port: func[port][
		either port? port [
			net-utils/net-log rejoin ["Closing port: " port/scheme "://" port/host ":" port/port-id] 
			attempt [
				port/user-data: none
				remove find head wait-list port
				remove/part find port-block port 2
				error? try [close port]
			]
		][	remove find head wait-list port ]
	]
	change-handler: func[port handler /local f][
		if not none? f: find/tail port-block port [
			change f :handler
		]
	]
	close-ports: func[][
		foreach port wait-list [
			if port? port [
				net-utils/net-log rejoin ["Closing port: " port/scheme "://" port/host ":" port/port-id] 
				attempt [close port]
			]
		]
		clear wait-list
		clear port-block
	]
	
	do-events: func["Process all events."][
		forever [
			attempt [ready: wait/all wait-list]
			if ready [
			    foreach port ready [
					attempt [do select port-block port port]
				]
			]
			;timeout actions
			foreach action timeout-actions [
				attempt reduce action
			]
		]
	]
]

;insert/only networking/timeout-actions [
;	ctx-console/clear-line
;	ctx-console/print-line
;]

networking/add-port ctx-console/port [ctx-console/process]
ctx-console/on-escape: func[][networking/close-ports halt]

;rss/run/file %amf %AMFserver.r
;do %test1.r ;tcp-server-test
;do %test2.r ;http download
;do %test3.r ;telnet
;do %test4.r ;udp-server
;do %test7.r ;proxy test
networking/do-events

;rss/run %networking