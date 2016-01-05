rebol [
	title: "IRC Core client - multi connection version"
	author: "Oldes"
	e-mail: "oliva.david at seznam.cz"
	date: 20-Jun-2004/15:01:47+2:00
	version: 2.0.1
	purpose: {
	There already are some Rebol IRC clients, but what I know, there was no clients
	running only in the console... so there is one...}
	comment: {
	Thanks to Paul Tretter for inspiration (some parts of this script as the
	IRC identification are based on his work [REBBOT])}
	history: [
		2.0.1 "oldes" ["Using rss-projects so it's more systemic"]
		1.0.0 "oldes" ["Bug fixing (console clear-line, cprint/inf)"]
		0.6.0 "oldes" ["Source is now using preprocessing"]
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
	
	Require: [
		rss-project 'console-port 0.2.0
		rss-project 'error-handler 0.1.0
		rss-project 'networking 0.0.4
	]
	
	preprocess: true
]

system/console/busy: none
system/console/break: false
random/seed now/time/precise

cprint?: true
debug?: off

active-irc: none ;to which irc-port are send the console commands

ctx-irc: make object! #include-block %ctx-irc.rb




cprint: func[msg /err /inf /user user-data][
	if all [cprint? any [err user ctx-irc/current-port = active-irc]]  [
		msg: copy msg
		if block? msg [msg: rejoin msg]
		either err [insert msg "!!! "][if inf [insert msg "*** "]]
		ctx-console/clear-line
		if not none? ctx-irc/current-port [
			if not user [user-data: ctx-irc/current-port/user-data]
			s-prin rejoin [user-data/nick "@" user-data/tchannel/name "=>"]
		]
		s-print ctx-irc/preptxt msg
		ctx-console/print-line
	]
]	

dprint: func[msg /force ][
	if any [debug? force][
		ctx-console/clear-line
		if not none? ctx-irc/current-port [
			s-prin rejoin [ctx-irc/current-port/user-data/nick "@" ctx-irc/current-port/user-data/tchannel/name "=>"]
		]
		s-print msg
		ctx-console/print-line
	]
]

pad: func[txt c][head insert/dup tail txt " " c - length? txt]


;---------------------------------------------------------------------------------------------------

networking/add-port ctx-console/port [ctx-console/process]
ctx-console/on-escape: func[][
	print "Closing..."
	networking/close-ports
	networking/stop?: true
]
ctx-console/on-enter: func[input-str /local e][
	ctx-irc/current-port: active-irc
	ctx-irc/parse-user-input input-str
]
ctx-console/prompt: func[][
	either any[
		none? active-irc
		none? active-irc/user-data/tchannel/name
	] [">> "][
		rejoin [active-irc/user-data/nick "@" active-irc/user-data/tchannel/name ">> "]
	]
]

#include %scheduler.r
#include %ident.r


ready?: false

while [not ready?][
	print {Enter IRC server which you want to use (for example: irc.glassbilen.net)}
	while [empty? server: ask "IRC Sever: "][]
	
	either error? try [
		ctx-irc/connect/with server system/user/name [
			chat-rules: [
				[]["kuk" end][say "kuku"]
			]
		]
	][
		print ["** Access Error: Cannot connect to" server]
	][
		ready?: true
	]
]

;ctx-irc/connect "127.0.0.1" "test1"
;ctx-irc/connect/with 127.0.0.1 "test2" [
	;user: "OLDES"
	;chat-rules: load %chat-rules.rb
;]

insert/only networking/timeout-actions [scheduler/process]

networking/do-events
