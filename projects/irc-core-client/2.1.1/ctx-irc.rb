	current-port: none ;will contain irc port which is processed
	ud: none ;shortcut for port/user-data
  	escapechar: charset "^Q^C^A" ;there is probably more of them
	normalchar: complement escapechar
	digits: charset "0123456789"
	space: charset [#" "]
	non-space: complement space
	to-space: [some non-space | end]
	chchars: complement charset { ^G^@^M^/,}
	is-channel?: func[ch][parse/all ch [[#"#" | #"&"] some chchars]]
	
	idents: none
	params: prefix: nick: user: host: servername: command:  none

	remove-colors?: either system/version/4 = 3 [true][false]
	;it's not possible to see colors in the Windows console:(
	
	preptxt: func[txt /local tmp t][
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
	process-rebol-command: func[input-str][
		set/any 'e attempt compose [do (input-str)]
		if all [
			not unset? 'e
			value? 'e
			not object? :e
			not port? :e
			not function? :e
		][
			print head clear skip rejoin [system/console/result mold :e] 127
			if (length? mold :e) > 127 [
				print "...^/"
			]
		]
	]
	parse-user-input: func[msg /local arg][
		attempt [
		parse/all msg [
				#"[" copy msg to end (
					process-rebol-command msg
				)
			|	"/msg" some space copy arg some non-space some space copy msg to end (say/to msg arg)
			|	"/rmsg" some space copy arg some non-space some space opt [#":"] copy msg to end (
				say/to join ":" head reverse msg arg
			)
			|	"/me" some space copy msg to end (say/action msg 4)
			|   "/away" any space opt [#":"] copy msg to end (
				current-port/user-data/away: msg
				irc-port-send ["away" either none? msg [""][join " :" msg]] 
			)
			|	#"/" copy msg to end (irc-port-send msg)
			|	copy msg to end (say msg)
		]]
	]

	irc-port-send: func[msg [block! string!]][
		msg: either string? msg [msg][rejoin msg]
		dprint ["IRCOUT: (" current-port/user ")" mold msg]
		insert current-port msg
	]

	say: func[txt /to whom /action][
		attempt [
			if not to [whom: current-port/user-data/tchannel/name]
			if block? txt [txt: rejoin txt]
			txt: parse/all txt "^/" 
			forall txt [
				irc-port-send either action [
					cprint ["* " current-port/user-data/nick " " txt/1]
					["PRIVMSG " whom " :^AACTION " txt/1  #"^A" ]
				][
					cprint [either to [rejoin ["-> *" whom "* "]]["> "] txt/1]
					["PRIVMSG " whom " :" txt/1 ]
				]
			]
		]
	]
	reply: func[txt /action][
		either action [say/action/to txt whom][say/to txt nick]
	]
	
	ask-for-nickname: func[][
		ctx-console/clear-line
		ud/nick: ask "Enter nick name: "
		irc-port-send ["NICK " ud/nick]
	]
	chat-parser: func[msg chat-rules /local err tmp][
		foreach [locals rule action] current-port/user-data/chat-rules [
			use locals [
				if parse/all msg bind rule 'self [attempt bind action 'say ]
			]
	    ]
	]
	
	command-actions: make block! [
		"PING" [irc-port-send ["PONG " params]]
		"JOIN" [
			ud/tchannel/name: copy first params
			cprint/inf either user = ud/user [
				
				["You have joined channel " ud/tchannel/name]
			][
				insert ud/tchannel/users nick
				[nick " (" user "@" host ") has joined channel " ud/tchannel/name]
			]
		]
		"PART" [
			cprint/inf rejoin [nick " has left channel " params/1]
		]
		"PRIVMSG" [
			cprint rejoin either params/1 = ud/tchannel/name [
				either "^AACTION" = copy/part params/2 7 [
					["* " nick skip params/2 7]
				][	["<" nick "> " params/2] ]
				
			][ ["*" nick "* " params/2] ]
			chat-parser params/2 ud/chat-rules
		]
		"NOTICE" [
			either none? nick [cprint/inf params/2][
				cprint either is-channel? params/1 [
					["-" nick ":" params/1 "- " params/2]
				][	["-" nick "- " params/2]]
			]
		]
		"MODE" [
			cprint/inf [
				{Mode change "} next params {" }
				either is-channel? params/1 ["on channel "]["for user "] params/1 { by } nick
			]
			if ud/tchannel/name = params/1 [ud/tchannel/mode: copy next params]
		]
		"NICK" [
			;dprint ["Nick: " mold nick " ud/nick: " mold ud/nick]
			cprint/inf either nick = ud/nick [
				ud/nick: copy params/1
				["You are now known as " params/1]
			][	[nick " is now known as " params/1] ]
		]
		"QUIT" [
			cprint/inf [
				"Signoff: " nick " (" user ") "
				either all [
					not none? params/1
					find/part params/1 "WinSock error" 13
				][params/2][""]
			]
			error? try [remove find ud/tchannel/users nick]
		]
		"INVITE" [
			cprint/inf [nick " invites you to channel " last params]
		]
		"TOPIC" [
			cprint/inf either nick = ud/nick [
				["You have changed the topic on channel " params/1 " to " params/2]
			][	[nick " has changed the topic on channel " params/1 " to " params/2] ]
		]
		"KICK" [
			cprint/inf [
				either ud/nick = params/2 ["You have"][rejoin [params/2 " has"]]
				" been kicked off channel " params/1 " by " nick " (" params/3 ")"
			]
		]
		;errors:
		"401" [cprint/err [ params/2 " - " params/3]] ;ERR_NOSUCHNICK
		"402" [cprint/err [ params/2 " - " params/3]] ;ERR_NOSUCHSERVER
		"403" [cprint/err [ params/2 " - " params/3]] ;ERR_NOSUCHCHANNEL
		"404" [cprint/err [ params/2 " - " params/3]] ;ERR_CANNOTSENDTOCHAN
		"405" [cprint/err [ params/2 " - " params/3]] ;ERR_TOOMANYCHANNELS
        "406" [cprint/err [ params/2 " - " params/3]] ;ERR_WASNOSUCHNICK
        "407" [cprint/err [ params/2 " - " params/3]] ;ERR_TOOMANYTARGETS
		"409" [cprint/err [ params/2]] ;ERR_NOORIGIN
        "411" [cprint/err [ params/2]] ;ERR_NORECIPIENT
        "412" [cprint/err [ params/2]] ;ERR_NOTEXTTOSEND
        "413" [cprint/err [ params/2 " - " params/3]] ;ERR_NOTOPLEVEL
        "414" [cprint/err [ params/2 " - " params/3]] ;ERR_WILDTOPLEVEL
        "421" [cprint/err [ params/2 " - " params/3]] ;ERR_UNKNOWNCOMMAND
        "422" [cprint/err [ params/2]] ;ERR_NOMOTD
        "423" [cprint/err [ params/2 " - " params/3]] ;ERR_NOADMININFO
        "424" [cprint/err [ params/2]] ;ERR_FILEERROR
		"431" [cprint/err [ params/2] ask-for-nickname] ;ERR_NONICKNAMEGIVEN
        "432" [cprint/err [ params/2 " - " params/3] ask-for-nickname] ;ERR_ERRONEUSNICKNAME
        "433" [cprint/err [ params/1 " - " params/2] ask-for-nickname] ;ERR_NICKNAMEINUSE
        "436" [cprint/err [ params/2 " - " params/3]] ;ERR_NICKCOLLISION
        "441" [cprint/err [ params/2 " " params/3 " - " params/4]] ;ERR_USERNOTINCHANNEL
        "442" [cprint/err [ params/2 " - " params/3]] ;ERR_NOTONCHANNEL
        "443" [cprint/err [ params/2 " " params/3 " - " params/4]] ;ERR_USERONCHANNEL
        "444" [cprint/err [ params/2 " - " params/3]] ;ERR_NOLOGIN
        "445" [cprint/err [ params/2]] ;ERR_SUMMONDISABLED
        "446" [cprint/err [ params/2]] ;ERR_USERSDISABLED
        "451" [cprint/err [ params/2]] ;ERR_NOTREGISTERED
        "461" [cprint/err [ params/2 " - " params/3]] ;ERR_NEEDMOREPARAMS
        "462" [cprint/err [ params/2]] ;ERR_ALREADYREGISTRED
        "463" [cprint/err [ params/2]] ;ERR_NOPERMFORHOST
        "464" [cprint/err [ params/2]] ;ERR_PASSWDMISMATCH
        "465" [cprint/err [ params/2]] ;ERR_YOUREBANNEDCREEP
        "467" [cprint/err [ params/2 " - " params/3]] ;ERR_KEYSET
        "471" [cprint/err [ params/2 " - " params/3]] ;ERR_CHANNELISFULL
        "472" [cprint/err [ params/2 " - " params/3]] ;ERR_UNKNOWNMODE
        "473" [cprint/err [ params/2 " - " params/3]] ;ERR_INVITEONLYCHAN
        "474" [cprint/err [ params/2 " - " params/3]] ;ERR_BANNEDFROMCHAN
        "475" [cprint/err [ params/2 " - " params/3]] ;ERR_BADCHANNELKEY
        "481" [cprint/err [ params/2]] ;ERR_NOPRIVILEGES
        "482" [cprint/err [ params/2 " - " params/3]] ;ERR_CHANOPRIVSNEEDED
        "483" [cprint/err [ params/2]] ;ERR_CANTKILLSERVER
        "491" [cprint/err [ params/2]] ;ERR_NOOPERHOST
        "501" [cprint/err [ params/2]] ;ERR_UMODEUNKNOWNFLAG
        "502" [cprint/err [ params/2]] ;ERR_USERSDONTMATCH
		"999" [cprint/err [ params/2]] ;ERR_COMMNOTFOUND
		;Command responses:
		"300" [];RPL_NONE
		"204" [cprint/inf ["Oper [" params/3 "] ==> " params/4]];RPL_TRACEOPERATOR
		"211" [cprint/inf next params];RPL_STATSLINKINFO
		"212" [cprint/inf next params];RPL_STATSCOMMANDS
		"213" [cprint/inf next params];RPL_STATSCLINE
		"214" [cprint/inf next params];RPL_STATSNLINE
		"215" [cprint/inf next params];RPL_STATSILINE
		"216" [cprint/inf next params];RPL_STATSKLINE
		"218" [cprint/inf next params];RPL_STATSYLINE
		"219" [];RPL_ENDOFSTATS
		"221" [cprint/inf next params];RPL_UMODEIS
		"205" [cprint/inf ["User [" params/3 "] ==>"]];RPL_TRACEUSER
		"242" [cprint/inf next params];RPL_STATSUPTIME
		"243" [cprint/inf next params];RPL_STATSOLINE
		"244" [cprint/inf next params];RPL_STATSHLINE
		"250" [cprint/inf params/2] ;RPL_STATSDLINE
		"251" [cprint/inf params/2 ud/on-connect];RPL_LUSERCLIENT
		"252" [cprint/inf [params/2 " " params/3]] ;RPL_LUSEROP 
        "253" [cprint/inf [params/2 " " params/3]] ;RPL_LUSERUNKNOWN
        "254" [cprint/inf [params/2 " " params/3]] ;RPL_LUSERCHANNELS
        "255" [cprint/inf params/2] ;RPL_LUSERME
        "256" [cprint/inf [params/2 " - " params/3]] ;RPL_ADMINME
        "257" [cprint/inf params/2] ;RPL_ADMINLOC1
        "258" [cprint/inf params/2] ;RPL_ADMINLOC2
        "259" [cprint/inf params/2] ;RPL_ADMINEMAIL
		"301" [cprint/inf [params/2 " is away (" params/3 ")"]];RPL_AWAY
		"303" [cprint/inf either 1 < length? params [["Currently online: " next params]]["Nobody is online"]];RPL_ISON
		"305" [cprint/inf reform next params]
		"306" [cprint/inf reform next params]
		"311" [cprint/inf [params/2 " is " params/3 "@" params/4 " (" last params ")"]];RPL_WHOISUSER
		"312" [cprint/inf ["on irc via server " params/3 " (" params/4 ")"]];RPL_WHOISSERVER
		"313" [cprint/inf [params/2 " is " params/3]];RPL_WHOISOPERATOR
		"315" [];RPL_ENDOFWHO
		"317" [;use [t][
			;t: to-time params/3
			cprint/inf [params/2 " has been idle: " to-time to-integer params/3]
			cprint/inf [params/2 " is online since: " 1-1-1970/0:0:0 + to-time to-integer params/4]
		];];RPL_WHOISIDLE
		"318" [];RPL_ENDOFWHOIS
		"319" [cprint/inf rejoin ["on channels: " mold parse last params ""]] ;RPL_WHOISCHANNELS

		"321" [cprint/inf "Channel    Users  Topic"	];RPL_LISTSTART
		"322" [cprint/inf [pad params/2 11 pad params/3 7 params/4]];RPL_LIST
		"323" [];RPL_LISTEND
		"331" [cprint/inf reform next params];RPL_NOTOPIC
		"332" [cprint/inf ["Topic for " params/2 ": " params/3]];RPL_TOPIC
		"333" [cprint/inf ["Topic set by " params/1 " " 1-1-1970/0:0:0 + to-time to-integer params/4]];RPL_TOPIC_setBy
		"341" [cprint/inf ["Inviting " params/2 " to channel " params/3]];RPL_INVITING
		"351" [cprint/inf ["Server " params/3 ": " params/2 " " params/4]];RPL_VERSION
		"352" [cprint/inf [
			pad params/2 11
			pad params/3 10
			pad params/7 4
			params/6 "@" params/4
			" (" find/tail params/8 " " ")"
		]];RPL_WHOREPLY
		"353" [
			params/4: sort parse params/4 ""
			if ud/tchannel/name = params/3 [ud/tchannel/users: copy params/4]
			cprint/inf ["Users at " pad params/3 10 mold params/4]
		]
		"366" [];RPL_ENDOFNAMES
		"375" [cprint/inf params/2] ;RPL_MOTDSTART
        "372" [cprint/inf reform next params] ;RPL_MOTD
        "376" [];RPL_ENDOFMOTD
		
		"371" [cprint/inf params/2] ;RPL_INFO
		"374" [];RPL_ENDOFINFO
		"381" [cprint/inf last params];RPL_YOUREOPER
		"391" [cprint/inf ["Server (" params/2 ") time: " params/3]]
		
		"392" [cprint/inf params/2];RPL_USERSSTART
		"393" [cprint/inf params/2];RPL_USERS
		"394" [];RPL_ENDOFUSERS
		;Other responses:
		"001" [cprint/inf params/2]
		"002" [cprint/inf params/2]
		"003" [cprint/inf params/2]
		"004" [cprint/inf reform next params]
	]
	irc-parser: func[port msg /local tmp][
		current-port: port
		ud: port/user-data ;just a shortcut
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
		switch/default command command-actions [cprint msg]
	]
	port-handler: func[port /local tmp][
		either none? tmp: system/words/copy/part port 1 [
			ctx-console/clear-line
			;print ["Closing (" port/user-data/nick ")"]
			if active-irc = port [active-irc: none]
			networking/remove-port port
			print "IRC connection closed"
		][
			irc-parser port first tmp
		]
	]
	connect: func[host nick /with settings /local irc-port spec][
		error? try [ctx-ident/start/stop 0:0:20]
		active-irc: current-port: open/lines/direct/no-wait compose/deep [
			scheme: 'tcp
			host: (host)
			port-id: 6667
			user-data:  make object! [
				user: ( system/user/name )
				nick: ( nick )
				ident: ( join "Reb_" system/user/name )
				on-connect: func[][irc-port-send "JOIN #rebol"]
				channels: make block! []
				away: none
				tchannel: make object! [
					name: none
					topic: none
					mode: none
					users: make block! 10
				]
				chat-rules: [
					[][thru "who is bot?" to end][reply "I'm bot!"]
				]
			]
		]
		if with [
			current-port/user-data: make current-port/user-data settings
		]
		networking/add-port active-irc :port-handler
		irc-port-send ["NICK " nick] ;cprint ["Bot is sending " botname]
    	irc-port-send ["USER " active-irc/user-data/user " " system/network/host-address " ircserv :" system/user/name]
	]