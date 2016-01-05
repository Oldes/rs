rebol [
	title: "Console port"
	author: "Oldes"
	version: 0.1.1
]

	buffer: make string! 512
	history: make block! 1000
	prompt: func[][
		either none? active-irc [">>"][
			rejoin [active-irc/user-data/nick "@" active-irc/user-data/tchannel/name ">> "]
		]
	]
	port: open/binary [	scheme: 'console ]
	print-line: func[][prin rejoin [prompt head buffer "^(1B)[" length? buffer "D"]]
	;clear-line: func[][	loop (length? buffer) + (length? prompt) [prin "^(back) ^(back)"]]
	clear-line: func[][
		error? try [xdebug rejoin ["ib:" index? buffer " lb:" length? buffer " lp:" length? prompt]]
		prin rejoin ["^(1B)[" (index? buffer) + length? prompt "D^(1B)[K" ]
	]
	;xdebug: func[str][
	;	ctx-irc/irc-port-send ["PRIVMSG #rebol :DB:" str]
	;]
	process: func[/local ch c tmp spec-char err][
		ch: to-char pick port 1
		either (ch = newline) or (ch = #"^M") [;ENTER
			buffer: head buffer
			tmp: copy buffer
			if empty? tmp [return none]
			history: head history
			if any [empty? history tmp <> first history ] [
				insert history tmp
			]
			clear-line
			clear buffer
			ctx-irc/current-port: active-irc
			ctx-irc/parse-user-input tmp
		][
			;xdebug mold to-binary ch
			switch/default to-binary ch [
				#{08} [;BACK
					if 0 < length? head buffer [
						
						buffer: remove back buffer
						;xdebug buffer
						prin rejoin ["^(back)^(1B)[K" buffer "^(1B)[" length? buffer "D"]
					]
				]
				#{7E} [;HOME
					prin rejoin ["^(1B)[" (index? buffer) - 1 "D"]
					buffer: head buffer
				]
				#{7F} [;DELETE
					buffer: remove buffer
					prin rejoin ["^(1B)[K" buffer "^(1B)[" length? buffer "D"]
				]
				#{1B} [;ESCAPE
					spec-char: copy/part port 1
					if spec-char = #{1B} [
						ctx-irc/current-port: active-irc: none
						cprint/inf "Closing ports..."
						foreach port wait-list [
							error? try [close port]
						]
						clear wait-list
						system/console/break: true
						halt
					]
					switch append spec-char copy/part port 1 [
						#{5B41} [;ARROW UP
							if not tail? history [
								clear-line
								clear head buffer
								prin join prompt buffer: copy history/1
								history: next history
								buffer: tail buffer
							]
						]
						#{5B42} [;ARROW DOWN
							clear-line
							buffer: head buffer
							clear buffer
							if all [not error? try [history: back history] not none? history/1] [
								;clear-line
								buffer: copy history/1
								
							]
							prin join prompt buffer
							buffer: tail buffer
						]
						#{5B43} [;ARROW RIGHT
							if not tail? buffer [
								prin "^(1B)[C"
								buffer: next buffer
							]
						]
						#{5B44} [;ARROW LEFT
							if 1 < index? buffer [
								prin "^(1B)[D"
								buffer: back buffer
							]
						]
					]
				]
				;#{09} [ prin ""];TAB
			][
				
				either tail? buffer [
					prin ch ;either local-echo [ch]["*"]
				][
					
					prin rejoin ["^(1B)[@" ch]
				]
				buffer: insert buffer ch
			]
		]
	]
