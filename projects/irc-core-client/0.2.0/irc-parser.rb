rebol [
	title: "IRC Core Client - commands rules example"
	purpose: {This is the key IRC commands handler! Here is what to do with incomming IRC commands.}
	author: "Oldes"
	means: [
		[string! "Command ID"] [block! "Command handler"]
	]
]
		"PING" [irc-port-send ["PONG " params]]
		"JOIN" [
			tchannel/name: copy first params
			cprint/inf either user = botuser [
				["You have joined channel " tchannel/name]
			][
				insert tchannel/users nick
				[nick " (" user "@" host ") has joined channel " tchannel/name]
			]
		]
		"PART" [
			cprint/inf rejoin [nick " has left channel " params/1]
		]
		"PRIVMSG" [
			cprint rejoin either params/1 = tchannel/name [
				either "^AACTION" = copy/part params/2 7 [
					["* " nick skip params/2 7]
				][	["<" nick "> " params/2] ]
				
			][ ["*" nick "* " params/2] ]
			chat-parser params/2
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
			if tchannel/name = params/1 [tchannel/mode: copy next params]
		]
		"NICK" [
			cprint/inf either nick = botname [
				["You are now known as " params/1]
			][	[nick " is now known as " params/1] ]
			botname: copy params/1
		]
		"QUIT" [
			cprint/inf [
				"Signoff: " nick " (" user ") "
				either find/part params/1 "WinSock error" 13 [params/2][""]
			]
			error? try [remove find tchannel/users nick]
		]
		"INVITE" [
			cprint/inf [nick " invites you to channel " last params]
		]
		"TOPIC" [
			cprint/inf either nick = botname [
				["You have changed the topic on channel " params/1 " to " params/2]
			][	[nick " has changed the topic on channel " params/1 " to " params/2] ]
		]
		"KICK" [
			cprint/inf [
				either botname = params/2 ["You have"][rejoin [params/2 " has"]]
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
		"431" [cprint/err [ params/2]] ;ERR_NONICKNAMEGIVEN
        "432" [cprint/err [ params/2 " - " params/3]] ;ERR_ERRONEUSNICKNAME
        "433" [cprint/err [ params/1 " - " params/2]] ;ERR_NICKNAMEINUSE
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
		"251" [cprint/inf params/2 irc-port-send ["JOIN " joinchannel]];RPL_LUSERCLIENT
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
			if tchannel/name = params/3 [tchannel/users: copy params/4]
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
		"001" [cprint/inf params/2 error? try [close idents] ]
		"002" [cprint/inf params/2]
		"003" [cprint/inf params/2]
		"004" [cprint/inf reform next params]