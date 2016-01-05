REBOL [
    Title: "Networking"
    Date: 2-Jun-2004/16:30:04+2:00
    Name: none
    Version: 0.0.3
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
	Require: [rss-project 'error-handler 0.1.0]
]
;trace/net on

set 'networking make object! [
	timeout-actions: make block! 10
	port-block: make block! 10
	stop?: false ;set this value to true if you want to stop networking loop
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
		stop?: false
		forever [
			attempt [ready: wait/all wait-list]
			if ready [
			    foreach port ready [
					attempt [do select port-block port port]
				]
			]
			if stop? [close-ports break]
			;timeout actions
			foreach action timeout-actions [
				attempt reduce action
			]
		]
	]
]


;do %test1.r ;tcp-server-test
;do %test2.r ;http download
;do %test3.r ;telnet
;do %test4.r ;udp-server
;do %test7.r ;proxy test
;networking/do-events
