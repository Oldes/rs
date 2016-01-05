REBOL [
    Title: "Console-port"
    Date: 20-Jun-2004/15:12:21+2:00
    Name: none
    Version: 0.2.0
    File: none
    Home: none
    Author: "oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: none
    Purpose: {This console port emulates standart Rebol's console while processing Rebol code}
    Comment: none
    History: none
    Language: none
    Type: none
    Content: none
    Email: oliva.david@seznam.cz
]
;if exists? %debug.txt [delete %debug.txt]
;debug: func[msg][
;	write/append %debug.txt msg
;]



set 'ctx-console make object! [
	system/console/busy: none
	system/console/break: false
	buffer: make string! 512
	history: system/console/history
	prompt: "## " ;system/console/prompt
	spec-char: none
	port: open/binary [	scheme: 'console ]
	print-line: func[][
		s-prin rejoin [	prompt head buffer "^(1B)[" length? buffer "D"]
	]
	set 's-print get in system/words 'print
	set 's-prin  get in system/words 'prin
	clear-line: func[][
		;error? try [xdebug rejoin ["ib:" index? buffer " lb:" length? buffer " lp:" length? prompt]]
		;debug reform ["####clear-line-> " empty? head buffer (index? buffer) "+" length? prompt mold prompt newline]
		s-prin rejoin ["^(1B)[" ((index? buffer) + (length? prompt) + (length? buffer)) "D^(1B)[K" ]
		;error? try [
		;	xdebug rejoin ["p:" mold prompt]
		;	xdebug rejoin ["b:" mold buffer]
		;]
		;s-prin rejoin ["^(1B)[" (-1 + index? buffer) + length? prompt "D^(1B)[K" ]
		;prompt: rejoin ["[" now/time "-" length? networking/wait-list "]>"]
	]
	xdebug: func[str][
		;ctx-irc/irc-port-send ["PRIVMSG #rebol :DB:" str]
	]
	key-actions: make block! [
		#{08} [;BACK
			if 0 < length? head buffer [
				buffer: remove back buffer
				;xdebug buffer
				s-prin rejoin ["^(back)^(1B)[K" buffer "^(1B)[" length? buffer "D"]
			]
		]
		#{7E} [;HOME
			s-prin rejoin ["^(1B)[" (index? buffer) - 1 "D"]
			buffer: head buffer
		]
		#{7F} [;DELETE
			buffer: remove buffer
			s-prin rejoin ["^(1B)[K" buffer "^(1B)[" length? buffer "D"]
		]
		#{1B} [;ESCAPE
			spec-char: copy/part port 1
			either spec-char = #{1B} [
				print "ESCAPE"
				clear-line
				set 'print :s-print
				set 'prin  :s-prin
				system/console/break: true
				on-escape
			][
				switch append spec-char copy/part port 1 [
					#{5B41} [;ARROW UP
						if not tail? history [
							clear-line
							clear head buffer
							s-prin join prompt buffer: copy history/1
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
						s-prin join prompt buffer
						buffer: tail buffer
					]
					#{5B43} [;ARROW RIGHT
						if not tail? buffer [
							s-prin "^(1B)[C"
							buffer: next buffer
						]
					]
					#{5B44} [;ARROW LEFT
						if 1 < index? buffer [
							s-prin "^(1B)[D"
							buffer: back buffer
						]
					]
				]
			]
		]
	]
	do-command: func[comm][
		set/any 'e attempt compose [do (comm)]
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
	on-enter: func[input-str /local e][
		print rejoin [system/console/prompt input-str]
		do-command input-str
	]
	on-escape: func[][halt]
	process: func[/local ch c tmp spec-char err][
		ch: to-char pick port 1
		either (ch = newline) or (ch = #"^M") [;ENTER
			tmp: copy head buffer
			if empty? tmp [return none]
			history: head history
			if any [empty? history tmp <> first history ] [
				insert history tmp
			]
			clear-line
			buffer: head buffer
			clear buffer
			print-line
			on-enter tmp
		][
			;xdebug mold to-binary ch
			switch/default to-binary ch key-actions [
				either tail? buffer [
					s-prin ch ;either local-echo [ch]["*"]
				][
					s-prin rejoin ["^(1B)[@" ch]
				]
				buffer: insert buffer ch
			]
		]
	]
	set 'prin func[msg /err /inf /user user-data][
		ctx-console/clear-line
		;s-print type? msg
		;debug reform [mold msg " ---> " mold reform msg newline]
		s-prin reform msg
		;if block? msg [msg: rejoin msg]
		;either err [insert msg "!!! "][if inf [insert msg "*** "]]
		;ctx-console/clear-line
		;insert ctx-console/port msg
		;ctx-console/s-prin msg
		ctx-console/print-line
	]
	set 'print func[msg /err /inf /user user-data][
		prin join reform msg newline
	]
]