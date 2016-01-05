REBOL [
    Title: "Networking"
    Date: 17-Jun-2003/16:37:33+2:00
    Name: none
    Version: none
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
	Require: [
		;rss-project 'console-port
		rs-project 'error-handler
	]
	
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
		port
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
			print "handler changed"
			change f :handler
		]
	]
	close-ports: func[
		"This function should be called at the end of the session to close all opened ports"
	][
		foreach port wait-list [
			if port? port [
				net-utils/net-log rejoin ["Closing port: " port/scheme "://" port/host ":" port/port-id] 
				either port/scheme <> 'console [
					attempt [close port]
				][
					set 'print get in system/words 'print
					set 'prin  get in system/words 'prin
				]
				;close port
			]
		]
		clear wait-list
		clear port-block
		true
	]
	
	do-events: func["Process all events." /local ready][
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
				either block? action [
					attempt reduce action
				][	attempt reduce [action]]
			]
		]
	]
]
