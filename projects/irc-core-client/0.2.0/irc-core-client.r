rebol [
	title: "IRC Core client"
	author: "Oldes"
	e-mail: oliva.david@seznam.cz
	date: 5-Dec-2002/20:08:14+1:00
	version: 0.2.0
	purpose: {
	There already are some Rebol IRC clients, but what I know, there was no clients
	running only in the console... so there is one...}
	comment: {
	Thanks to Paul Tretter for inspiration (some parts of this script as the
	IRC identification are based on his work [REBBOT])
	
	I'm not regular IRC user so it's not well tested yet!}
	
	note: {
	IRC documentations:
	http://www.faqs.org/rfc/rfc1459.txt - "Internet Relay Chat Protocol"
	http://www.faqs.org/rfc/rfc2810.txt - "Internet Relay Chat: Architecture"
	http://www.faqs.org/rfc/rfc2811.txt - "Internet Relay Chat: Channel Management"
	http://www.faqs.org/rfc/rfc2812.txt - "Internet Relay Chat: Client Protocol"
	http://www.faqs.org/rfc/rfc2813.txt - "Internet Relay Chat: Server Protocol"
	and
	http://www.faqs.org/rfc/rfc1413.txt - "Identification Protocol"}
]
system/console/busy: none
random/seed now/time/precise
botname: "RebLeda"
ident-name: join "Reb_" random "abcdefghijklmnopqrstuvwxyz"
botuser: join "Reb" random 1000
joinchannel: "#rebol"

   chat-rules: either exists? %chat-rules.rb [ load %chat-rules.rb ][ copy [] ]
command-rules: either exists? %command-rules.rb [ load %command-rules.rb ][ copy [] ]

;channels: make block! 5
tchannel: make object! [
	name: none
	topic: none
	mode: none
	users: make block! 10
]
cprint?: true
debug?: off 

remove-colors?: either system/version/4 = 3 [true][false]
;it's not possible to see colors in the Windows console:(

escapechar: charset "^Q^C^A" ;there is probably more of them
normalchar: complement escapechar
digits: charset "0123456789"
space: charset [#" "]
non-space: complement space
to-space: [some non-space | end]
chchars: complement charset { ^G^@^M^/,}
is-channel?: func[ch][parse/all ch [[#"#" | #"&"] some chchars]]

idents: none

params: prefix: nick: user: host: servername: none


scheduler: make object! [
	scheduled: make block! 20
	process: func[][
		while [not tail? scheduled][
			either scheduled/1 <= now [
				dprint ["SCHEDULED-ACTION: " mold scheduled/2]
				try-do scheduled/2
				remove/part back scheduled 2
			][	break ]
		]
	]
	add-action: func[when action [block!]][
		insert scheduled reduce [when action]
		sort/skip scheduled 2
		dprint [mold scheduled]
	]
]

preptxt: func[txt /local tmp][
	if not remove-colors? [return txt]
	tmp: make string! 512
	parse/all txt [any [
		  #"^Q"
		| #"^A" ;action
		| #"^C" some digits #"," some digits
		| copy t some normalchar (insert tail tmp t)
	]]
	tmp
]
pad: func[txt c][head insert/dup tail txt " " c - length? txt]

try-do: func[action][if error? set/any 'err try [do action][bot-error disarm err]]

cprint: func[msg /err /inf][
	if cprint? [
		if block? msg [msg: rejoin msg]
		either err [insert msg "!!! "][if inf [insert msg "*** "]]
		if not empty? console/buffer [console/clear-line]
		print preptxt msg
		if not empty? console/buffer [prin console/buffer]
	]
]	
dprint: func[msg][
	if debug? [
		if not empty? console/buffer [console/clear-line]
		print msg
		if not empty? console/buffer [prin console/buffer]
	]
]
parse-user-input: func[msg /local arg][
	try-do [
	parse/all msg [
			#"[" copy msg to end (try-do msg)
		|	"/msg" some space copy arg some non-space some space copy msg to end (say/to msg arg)
		|	"/me" some space copy msg to end (say/action msg 4)
		|	#"/" copy msg to end (irc-port-send msg)
		|	copy msg to end (say msg)
	]]
]
console: make object! [
	buffer: make string! 512
	history: make block! 1000
	port: open/binary [scheme: 'console]
	
	clear-line: func[][	loop length? buffer [prin "^(back) ^(back)"] ]
	process: func[/local ch c tmp spec-char err][
		ch: to-char pick port 1
		either (ch = newline) or (ch = #"^M") [;ENTER
			tmp: copy buffer
			if empty? tmp [return none]
			history: head history
			if any [empty? history tmp <> first history ] [
				insert history tmp
			]
			clear-line
			clear buffer
			parse-user-input tmp
		][
			switch/default to-binary ch [
				#{08} [;BACK
					if 0 < length? buffer [
						prin "^(back) ^(back)"
						remove back tail buffer
					]
				]
				#{1B} [;ESCAPE
					switch spec-char: copy/part port 2 [
						#{5B41} [;ARROW UP
							if not tail? history [
								clear-line
								prin buffer: copy history/1
								history: next history
							]
						]
						#{5B42} [;ARROW DOWN
							if not error? try [history: back history][
								clear-line
								prin buffer: copy history/1
							]
						]
						#{5B44} [;ARROW LEFT
							clear-line
							clear buffer
						]
					]
				]
				;#{09} [ prin ""];TAB
			][
				prin ch ;either local-echo [ch]["*"]
				append buffer ch
			]
		]
	]
]

bot-error: func[err /local type id arg1 arg2 arg3][
	set [type id arg1 arg2 arg3] reduce [err/type err/id err/arg1 err/arg2 err/arg3]
	cprint/err [
		"Bot-" system/error/:type/type ": "
		reduce bind system/error/:type/:id 'arg1
	]
	cprint/err ["** Where: " mold err/where]
	cprint/err ["** Near: " mold err/near]
]
irc-port-send: func[msg [block! string!]][
	msg: either string? msg [msg][rejoin msg]
	dprint ["IRCOUT: " mold msg]
	insert irc-open-port msg
]

say: func[txt /to whom /action][
	try-do [
		if not to [whom: tchannel/name]
		if block? txt [txt: rejoin txt]
		txt: parse/all txt "^/" 
		forall txt [
			irc-port-send either action [
				cprint ["* " botname " " txt/1]
				["PRIVMSG " whom " :^AACTION " txt/1  #"^A" ]
			][
				cprint [either to [rejoin ["-> *" whom "* "]]["> "] txt/1]
				["PRIVMSG " whom " :" txt/1 ]
			]
		]
	]
]
reply: func[txt /action /local whom][
	whom: either params/1 = botname [nick][params/1]
	either action [say/action/to txt whom][say/to txt whom]
]

chat-parser: func[msg /local err tmp][
	foreach [locals rule action] chat-rules [
		use locals [
			if parse/all msg rule [	try-do action ]
		]
    ]
]

irc-parser: func[msg /local tmp][
	params: make block! 10
	prefix: none
	parse/all msg [
		opt [#":"  copy prefix some non-space some space ]
		copy command some non-space
		any [
			   some space #":" copy tmp to end (append params tmp)
			 | some space copy tmp to-space (append params tmp)
		]
	]
	nick: user: host: servername: none
	if not none? prefix [
		either found? find prefix "@" [
			set [nick user host] parse prefix "!@" 
		][	servername: copy prefix]
	]
	dprint msg
	dprint reform ["PARSED: " mold prefix mold command mold params]
	switch/default command command-rules [cprint msg]
]
getirc-port-data: does [
    either error? getirc-port-data-error: try [irc-input-buffer: copy/part irc-open-port 1] [
        getirc-port-data-error: disarm getirc-port-data-error
        error-proc getirc-port-data-error
        cprint "Error Generated at GETIRC-PORT-DATA function!"
        return ""
    ][
        if type? irc-input-buffer = block! [irc-input-buffer: to-string irc-input-buffer]
		if irc-input-buffer = "none" [
			;disconnected
			cprint/inf "Connection closed"
			close irc-open-port
			close console/port
			halt
		]
    ]
	return irc-input-buffer
]

handshake:  does [
    irc-port-send ["NICK " botname] cprint ["Bot is sending " botname]
    irc-port-send ["USER " botuser " " system/network/host-address " ircserv :" system/user/name]
    cprint "Bot is sending USER data"
    ;irc-port-send ["JOIN " joinchannel] cprint ["Bot is joining " joinchannel]
]

start-ident: does [
	not error? try [
	    idents: open/direct/lines tcp://:113
	    cprint "IDENT SERVER IS NOW ON"
	]
] 

www-listen-port: open/lines tcp://:90  ; port used for web connections


send-page: func [data mime] [
    insert data rejoin ["HTTP/1.0 200 OK^/Content-type: " mime "^/^/"]
    write-io http-port data length? data
] 

buffer: make string! 1024  ; will auto-expand if needed



connect-to-irc: func[host /port p /channel ch][
	if channel [joinchannel: ch unset 'ch]
	irc-port: compose [
		scheme: 'tcp
		host: (host)
		port-id: (either port [p][6667])
		user-data: 'irc
	]
	start-ident
	irc-open-port: open/lines/direct/no-wait irc-port
	error? try [console/port: open/binary [scheme: 'console]]
	handshake

	forever [
		ready: wait/all waitports: [irc-open-port www-listen-port console/port idents 0:0:1]
		either ready [
		    foreach port ready [
				if port = www-listen-port [
					http-port: first port
					clear buffer
					while [not empty? request: first http-port][
						repend buffer [request newline]
					]
					print buffer
					send-page "OK" "text/plain"
					close http-port
				]
		       	if port = console/port  [console/process]
				if port = irc-open-port [try-do [irc-parser getirc-port-data]]
				if port = idents [
					cprint/inf "Ident request!"
					ident-connection: first idents
					ident-buffer: first ident-connection
					if find/any reform ident-buffer "*,*" [
					    insert ident-connection rejoin [ident-buffer " : USERID : REBOL : " ident-name]
					]
				]
		    ]
		][
			;timeout actions
			try-do [scheduler/process]
		]
	]
]

connect-to-irc/channel 127.0.0.1 "#rebol"
;connect-to-irc/channel "irc.sh.cvut.cz" "#lebeda"