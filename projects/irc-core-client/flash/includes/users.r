rebol []

update-users: func[cname /slide /local ch i j l tmp users lines][
	either any [
		none? cname
		none? ch: get-channel cname
		not ctx-irc/is-channel? cname
		empty? head ch/users
	][
		btn_users/selected?: false
		btn_users/state: 4
		hide m-users
		show btn_users
	][
		i: 1
		users: sort head ch/users
		lines: length? users
		if not slide [m-users-slider/data: 0]
		m-users-slider/redrag max 0.2 (min 1 (9 / lines))
		users: skip users to-integer (m-users-slider/data * (lines - 9))
		forall users [
			n: users/1
			tmp: m-users-list/pane/:i
			tmp/text: n
			tmp/show?: true
			tmp/pane/effect/crop: either n/1 = #"@" [
				tmp/text: copy next n
				14x0
			][	0x0 ]
			i: i + 1
			if i > 9 [break]
		]
		for j i 9 1 [
			tmp: m-users-list/pane/:j
			tmp/show?: false
		]
		if cname = output-channel [
			btn_users/selected?: true
			btn_users/state: 2
			show [m-users btn_users]
		]
		
	]
]

set-users: func[cname users /local ch][
	if not none? ch: get-channel cname [
		ch/users: copy users
		;probe ch/users
		update-users cname
	]
]

remove-user: func[cname nick /local users ch n][
	if not none? ch: get-channel cname [
		users: ch/users
		forall users [
			if parse users/1 compose [opt "@" (nick)][
				remove users
				break
			]
		]
		ch/users: head users 
		error? try [remove find ch/users n]
		;probe ch/users
		update-users cname
	]
]

rename-user: func[oldnick newnick /local channels users nick][
	channels: head lay_channels/pane
	forall channels [
		if not none? users: channels/1/users [
			forall users [
				parse users/1 [opt [#"@" | #"+"] copy nick to end]
				if oldnick = nick [
					change users either users/1/1 = #"@" [join #"@" newnick][newnick]
				]
			]
			channels/1/users: head users
		]
		if channels/1/data = output-channel [
			update-users channels/1/data
		]
	]
]

signoff-user: func[nick params /local channels users onick][
	channels: head lay_channels/pane
	forall channels [
		if not none? users: channels/1/users [
			forall users [
				parse users/1 [opt [#"@" | #"+"] copy onick to end]
				if onick = nick [
					users: remove users
					cprint/inf/channel [
						"Signoff: " ctx-irc/nick " (" ctx-irc/user ") "
						either all [
							not none? params/1
							find/part params/1 "WinSock error" 13
						][params/2][reform params]
					] channels/1/data
				]
			]
			channels/1/users: head users
		]
		if channels/1/data = output-channel [
			update-users channels/1/data
		]
	]
]

process-mode: func[cname mode][

]
change-user-mode: func[args /local ch users nick][
	if all[
		not none? ch: get-channel args/1
		not none? users: ch/users
	][
		forall users [
			parse users/1 [opt #"@" copy nick to end]
			if nick = args/3 [
				switch args/2 [
					"+o" [change users join #"@" nick]
					"-o" [change users nick]
				]
				update-users args/1
				break
			]
		]
		ch/users: head users
	]
]