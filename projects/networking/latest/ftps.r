rebol [
	title: "FTP port"
	note: {
		related documents:
		RFC1939: Post Office Protocol - Version 3
	}
]

error? try [networking/remove-port FTP-CMD-port]
error? try [networking/remove-port FTP-Data-port]

ftp-timeout: func[][
	foreach port FTP-upload-ports [
		Data-upload-handler port
	]
	true
]

if none? find networking/timeout-actions :ftp-timeout [
	insert networking/timeout-actions :ftp-timeout
]

ftp-root-dir: what-dir  ;%/d/
if not exists? ftp-root-dir [make-dir/deep ftp-root-dir]

;ftp-related functions
make-list-dir: func[dir /local list-dir attr inf ts][
	list-dir: make block! 100
	ts: 0
	foreach file read dir [
		attr: copy "-rw-------"
		inf: info? dir/:file
		if inf/type <> 'file [
			change attr "d"
			file: head remove back tail file
		]
		append list-dir rejoin [
			head attr " 1 owner group "  inf/size " "
			pick ["Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"] inf/date/month " "
			inf/date/day " " inf/date/time/hour ":" inf/date/time/minute " "
			file
		]
		ts: ts + inf/size
	]
	insert list-dir rejoin ["total " ts]
	head list-dir
]

get-full-path: func[pwd tmp][
	rejoin [
		ftp-root-dir
		clean-url-path join either empty? pwd [pwd][dirize pwd] tmp
	]
]
clean-url-path: func[path [string! file! url!] /local parts part set-part out][
	parts: make block! 10
	out: make string! 100
	set-part: func[][parts: insert parts any [part ""]]
	parse to-string path [
		any [
			"../" (parts: remove back parts)
			| "./"
			| copy part to "/" skip  (set-part)
		]
		copy part to end (set-part)
	]
	foreach part (head parts) [
		insert tail out join "/" part
	]
	to type? path copy remove head out
]
	
;---------------------


FTP-CMD-port: open/lines/with/direct tcp://:21 "^M^/"
FTP-Data-port: open/lines/direct tcp://:20 

FTP-users: ["anonymous" "tim" "root"]
FTP-passs: [""          "t"   ""]

FTP-Data-port-handler: func[port /local insert-port p subport][
	if port? subport: first port [
		print ["DTP : new connection" subport/host subport/port-id]
		subport/user-data: make object! [
			cmd-port: none
			target: none
			source: none
		]
		insert-port: func[port msg][
			print ["DTP-S:" msg]
			insert port msg
		]
		forall FTP-DTPs-to-connect [
			p: first FTP-DTPs-to-connect
			print ["DTP :" p/host subport/host]
			if p/host = subport/host [
				switch p/user-data/type [
					"A" [set-modes subport [binary: false lines: true]]
					"I" [set-modes subport [binary: true lines: false]]
				]
				subport/user-data/cmd-port: p
				insert p/user-data/dports subport
				remove FTP-DTPs-to-connect
				networking/add-port subport none
				break
			]
		]
		FTP-DTPs-to-connect: head FTP-DTPs-to-connect
	]
]

Data-upload-handler: func[port /local bytes ud][
	port/state/outBuffer: copy/part port/user-data/source 30000
	either none? port/state/outBuffer [
		remove find FTP-upload-ports port
		insert port/user-data/cmd-port "226 Closing data connection."
		networking/remove-port port
	][
		bytes: write-io port port/state/outBuffer length? port/state/outBuffer
	]
]

FTP-upload-ports: make block! 3

FTP-DTPs-to-connect: make block! 3

FTP-CMD-port-handler: func[port /local subport insert-port][
		if port? subport: first port [
			print ["FTP  : new connection" subport/host subport/port-id]
			subport/user-data: make object! [
				cmd:  none
				logged?: false
				user: none
				type: "A"
				host: none
				dports: make block! 3
				passive: none
				time: now
				pwd: %""
			]
			insert-port: func[port msg][
				print ["FTP-S:" msg]
				insert port msg
			]
			networking/add-port subport func[port /local c tmp][
				c: pick port 1
				either none? c [
					print "FTP-C: closing"
					networking/remove-port port
				][
					print ["FTP-C:" mold c]
					parse/all c [
						  "USER " copy tmp to end (
						  	insert-port port either find FTP-users tmp [
						  		port/user-data/user: tmp
						  		"331 User name okay, need password."
					  		][	reform ["530" tmp "not logged in" ]]
						)
						| "PASS " copy tmp to end (
							either port/user-data/logged? [
								insert-port port "230 Already logged in."
							][
								insert-port port either any [
									port/user-data/user = "anonymous"
									all [
										not none? i: find FTP-users port/user-data/user
										tmp = pick FTP-passs index? i
									]
								][
									port/user-data/logged?: true
									"230 User logged in, proceed."
								][	"530 Not logged in" ]
							]
						)
						| "SYST" (insert-port port "215 REBOL")
						| "PWD" (insert-port port join "257 " either empty? port/user-data/pwd ["./"][port/user-data/pwd])
						| "CWD " copy tmp to end (
							either empty? port/user-data/pwd [
								port/user-data/pwd: dirize tmp
							][
								port/user-data/pwd: join dirize port/user-data/pwd tmp
							]
							probe port/user-data/pwd
							probe port/user-data/pwd: copy dirize clean-url-path dirize port/user-data/pwd
							port/user-data/pwd: head remove back tail port/user-data/pwd
							if not none? tmp: find/tail port/user-data/pwd what-dir [
								port/user-data/pwd: tmp
							]
							
							insert-port port join "257 " port/user-data/pwd
						)
						| "PORT " copy tmp to end (
							tmp: parse tmp ","
							port/user-data/host: rejoin [
								tmp/1 "." tmp/2 "." tmp/3 "." tmp/4
								":" (256 * load fifth tmp) + load last tmp
							]
							insert port/user-data/dports open/direct/binary join tcp:// port/user-data/host
							networking/add-port first port/user-data/dports none
							insert-port port "200 OK"
						)
						| "PASV" (
							use [a-check][
								a-check: form reduce port/host 
	                    		append a-check rejoin [
	                    			"." form to-integer (FTP-Data-port/port-id / 256)
	                    			"." (FTP-Data-port/port-id // 256)
	                    		] 
	                    		replace/all a-check #"." #","
	                    		port/user-data/passive: true
								insert-port port rejoin ["227 Entering Passive Mode. (" a-check ")"]
								if none? find FTP-DTPs-to-connect port [
									insert tail FTP-DTPs-to-connect port
								]
							]
						)
						| "TYPE " copy tmp to end (
							port/user-data/type: tmp
							insert-port port "200 OK"
						)
						| "LIST" opt #" " copy tmp to end (
							either port? port/user-data/dports/1 [
								insert-port port "125 Data connection already open; transfer starting."
								
							][
								insert-port port "150 File status okay; about to open data connection."
								either port/user-data/passive [
									
								][
									insert port/user-data/dports open/lines/direct join tcp:// port/user-data/host
									networking/add-port first port/user-data/dports none
								]
								
							]
							if port? first port/user-data/dports [
								;set-modes port/user-data/dport [binary: false lines: true]
								port/user-data/dports/1/state/with: "^M^/"
								port/user-data/dports/1/state/flags: 524867 ;?? direct/lines ??
								use [l][
									l:  make-list-dir dirize join ftp-root-dir port/user-data/pwd
									forall l [insert port/user-data/dports/1 l/1]
								]
								insert-port port "226 Closing data connection."
								networking/remove-port port/user-data/dports/1
								remove port/user-data/dports
							]
						)
						| "RETR " copy tmp to end (
							either port? port/user-data/dports/1 [
								insert-port port "125 Data connection already open; transfer starting."
								port/user-data/dports/1/state/with: ""
							][
								insert-port port "150 File status okay; about to open data connection."
								either port/user-data/passive [
									
								][
									insert port/user-data/dports open/direct/binary join tcp:// port/user-data/host
									port/user-data/dports/1/port-flags: system/standard/port-flags/direct or system/standard/port-flags/pass-thru or 32 or 2051
									port/user-data/dports/1/state/with: ""
								]
								
							]
							if port? port/user-data/dports/1 [
								use [src][
									probe src: rejoin [dirize join ftp-root-dir port/user-data/pwd tmp]
									either exists? src [
										networking/change-handler port/user-data/dports/1 :Data-upload-handler
										probe xxx: port/user-data/dports/1
										port/user-data/dports/1/user-data/source: open/direct/binary/no-wait src
										append FTP-upload-ports port/user-data/dports/1
										Data-upload-handler port/user-data/dports/1
									][
										insert-port port "450 File unavailable"
									]
								]
								;networking/remove-port port/user-data/dport
								;port/user-data/dport: none
								;insert-port port "226 Closing data connection."
							]
						)
						| "STOR " copy tmp to end (
							either port? port/user-data/dports/1 [
								insert-port port "125 Data connection already open; transfer starting."
								port/user-data/dports/1/state/with: ""
							][
								insert-port port "150 File status okay; about to open data connection."
								either port/user-data/passive [
									
								][
									insert port/user-data/dports open/direct join tcp:// port/user-data/host
									port/user-data/dports/1/state/with: ""
									
								]
								
							]
							if port? port/user-data/dports/1 [
								use [trg][
									trg: rejoin [dirize join ftp-root-dir port/user-data/pwd tmp]
									write/binary trg copy port/user-data/dports/1
								]
								
								networking/remove-port port/user-data/dports/1
								remove port/user-data/dports
								insert-port port "226 Closing data connection."
							]
						)
						| "MKD " copy tmp to end (
							use [src][
								probe src: get-full-path port/user-data/pwd tmp
								either exists? src [
									;delete src
									;insert-port port "250 Requested file action okay, completed."
									insert-port port reform ["521" tmp "directory already exists"]
								][
									make-dir/deep src
									insert-port port reform ["257" tmp "directory created"]
								]
							]
						)
						| "DELE " copy tmp to end (
							use [src][
								probe src: get-full-path port/user-data/pwd tmp
								either any [
									exists? src
								] [
									either error? try [
										if error? try [delete src][delete dirize src]
									][	insert-port port "450 File unavailable"][
										insert-port port "250 Requested file action okay, completed."
									]
								][
									insert-port port "450 File unavailable"
								]
							]
						)
						| "QUIT" (
							insert-port port "221 Service closing control connection"
							foreach port port/user-data/dports [
								networking/remove-port port
							]
							networking/remove-port port
						)
						
						| "SITE IDLE" (insert-port port "1000")
						| copy tmp to end (
							insert-port port "502 Command not implemented."
						)
						
					]
				]
			]
			insert-port subport "220 OK"
		]
]

networking/add-port FTP-CMD-port  :FTP-CMD-port-handler
networking/add-port FTP-Data-port :FTP-Data-port-handler