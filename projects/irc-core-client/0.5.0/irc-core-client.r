rebol [
	title: "IRC Core client - multi connection version"
	author: "Oldes"
	e-mail: oliva.david@seznam.cz
	date: 7-Jan-2003/21:10:03+1:00
	version: 0.5.0
	purpose: {
	There already are some Rebol IRC clients, but what I know, there was no clients
	running only in the console... so there is one...}
	comment: {
	Thanks to Paul Tretter for inspiration (some parts of this script as the
	IRC identification are based on his work [REBBOT])
	
	I'm not regular IRC user so it's not well tested yet!}
	history: [
		0.5.0 "oldes" ["Handles multiple IRC connections / not finished"]
	]
	note: {
	IRC documentations:
	http://www.faqs.org/rfc/rfc1459.txt - "Internet Relay Chat Protocol"
	http://www.faqs.org/rfc/rfc2810.txt - "Internet Relay Chat: Architecture"
	http://www.faqs.org/rfc/rfc2811.txt - "Internet Relay Chat: Channel Management"
	http://www.faqs.org/rfc/rfc2812.txt - "Internet Relay Chat: Client Protocol"
	http://www.faqs.org/rfc/rfc2813.txt - "Internet Relay Chat: Server Protocol"
	and
	http://www.faqs.org/rfc/rfc1413.txt - "Identification Protocol"}
	;require: [%command-rules.rb]
]

system/console/busy: none
system/console/break: false
random/seed now/time/precise

cprint?: true
debug?: off

active-irc: none ;to which irc-port are send the console commands

console: context load %ctx-console.rb
ctx-irc: context load %ctx-irc.rb

cprint: func[msg /err /inf /user user-data][
	if all [cprint? any [err user ctx-irc/current-port = active-irc]]  [
		if block? msg [msg: rejoin msg]
		either err [insert msg "!!! "][if inf [insert msg "*** "]]
		console/clear-line
		if not none? ctx-irc/current-port [
			if not user [user-data: ctx-irc/current-port/user-data]
			prin rejoin [user-data/nick "@" user-data/tchannel/name "=>"]
		]
		print ctx-irc/preptxt msg
		console/print-line
	]
]	
dprint: func[msg /force ][
	if any [debug? force][
		console/clear-line
		if not none? ctx-irc/current-port [
			prin rejoin [ctx-irc/current-port/user-data/nick "@" ctx-irc/current-port/user-data/tchannel/name "=>"]
		]
		print msg
		console/print-line
	]
]

pad: func[txt c][head insert/dup tail txt " " c - length? txt]

try-do: func[action][if error? set/any 'err try [do action][bot-error disarm err]]

bot-error: func[err /local type id arg1 arg2 arg3][
	set [type id arg1 arg2 arg3] reduce [err/type err/id err/arg1 err/arg2 err/arg3]
	cprint/err [
		"Bot-" system/error/:type/type ": "
		reduce bind system/error/:type/:id 'arg1
	]
	cprint/err ["** Where: " mold err/where]
	cprint/err ["** Near: " mold err/near]
]
;---------------------------------------------------------------------------------------------------
scheduler: make object! [
	scheduled: make block! 20
	process: func[][
		while [not tail? scheduled][
			either scheduled/1 <= now [
				dprint ["SCHEDULED-ACTION: " mold scheduled/2/2]
				try-do scheduled/2/2
				remove/part back scheduled 2
			][	break ]
		]
	]
	add-action: func[id when [date!] action [block!]][
		insert/only scheduled reduce [id action]
		insert scheduled when
		sort/skip scheduled 2
		dprint [mold scheduled]
	]
	remove-action: func[id /local f][
		while [not tail? scheduled][
			either scheduled/2/1 = id [
				remove/part scheduled 2
			][	scheduled: skip scheduled 2 ]
		]
		dprint [mold scheduled]
	]
]

;---------------------------------------------------------------------------------------------------
show-active-ircs: func[][
	foreach port wait-list [
		error? try[
			cprint/inf [port/user-data/user #"@" port/host ]
		]
	]
]
set-active-irc: func[userhost][
	userhost: to-string userhost
	foreach port wait-list [
		error? try[
			if any [
				userhost = rejoin [port/user-data/user #"@" port/host]
				userhost = rejoin [port/user-data/nick #"@" port/host]
			][
				active-irc: port
				cprint/inf/user ["Active connection: " userhost ] port/user-data
				return true
			]
		]
	]
]
;---------------------------------------------------------------------------------------------------


idents: none
ident-name: "oldes"
start-idents: func[
	"Starts the IDENTs server which is sometimes necessary to conect"
	/stop time {The server will be closed after specified time (should be long enough to reply to the IDENT request)}
] [
	if none? idents [
		add-port idents: open/direct/lines tcp://:113 func[][
			cprint/inf "Ident request!"
			ident-connection: first idents
			ident-buffer: first ident-connection
			if find/any reform ident-buffer "*,*" [
			    insert ident-connection rejoin [ident-buffer " : USERID : REBOL : " ident-name]
			]
		]
	]
	if stop [
		scheduler/remove-action 'idents
		scheduler/add-action  'idents now + time [close-idents]
	]
] 
close-idents: func[] [remove-port idents idents: none]
;---------------------------------------------------------------------------------------------------
wait-list:  make block! 10
port-block: make block! 10
insert wait-list 0:0:1

add-port: func[port handler][
	cprint/inf ["Adding port: " port/scheme ":" port/host ":" port/port-id]
	insert wait-list port
	insert port-block reduce [port :handler]
]
remove-port: func[port][
	either port? port [
		cprint/inf ["Closing port: " port/host ":" port/port-id] 
		remove find head wait-list port
		remove/part find port-block port 2
		close port
	][	remove find head wait-list port ]
	
]

error? try [console/port: open/binary [scheme: 'console]]
add-port console/port [console/process]


;ctx-irc/connect "127.0.0.1" "test1"
;ctx-irc/connect/with 127.0.0.1 "test2" [
;	user: "AHMAD"
;	chat-rules: load %chat-rules.rb
;]

;comment {
ctx-irc/connect/with "irc.sh.cvut.cz" "hmm" [ ;"irc.glassbilen.net"
	user: "Oldes"
	on-connect: func[][irc-port-send "JOIN #lebeda"]
	;chat-rules: load %chat-rules.rb
]
;}

forever [
	ready: wait/all wait-list
	either ready [
	    foreach port ready [
			try-do [do select port-block port port]
		]
	][
		;timeout actions
		try-do [scheduler/process]
	]
]
