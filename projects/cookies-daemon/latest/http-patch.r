rebol [
	title: "HTTP handler patch"
	purpose: "Patched 'open function to properly set the 'set-cookies header variable"
	comment: {This is modified 'open function from REBOL/View 1.2.57.3.1!}
]

system/schemes/http/user-agent: "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.10) Gecko/20100914 Firefox/3.6.10"
tmp: [
		open: func [
            port "the port to open" 
            /local http-packet http-command response-actions success error response-line 
            target headers http-version post-data result generic-proxy? sub-protocol 
            build-port send-and-check create-request line continue-post
            tunnel-actions tunnel-success response-code forward proxyauth page

        ][
            ; RAMBO #4039: moved QUERYING to locals
			; also now QUERY will initialize port/locals
			unless port/locals [port/locals: make object! [list: copy [] headers: none querying: no]]

            generic-proxy?: all [port/proxy/type = 'generic not none? port/proxy/host] 
            build-port: func [] [
                sub-protocol: either port/scheme = 'https ['ssl] ['tcp] 
                open-proto/sub-protocol/generic port sub-protocol 
                either port/scheme = 'https [
               		port/url: rejoin [lowercase to-string port/scheme "://" port/host either port/port-id <> 443 [join #":" port/port-id] [copy ""] slash] 
           		][
           			port/url: rejoin [lowercase to-string port/scheme "://" port/host either port/port-id <> 80 [join #":" port/port-id] [copy ""] slash] 
       			]
                if found? port/path [append port/url port/path] 
                if found? port/target [append port/url port/target] 
                if sub-protocol = 'ssl [
                    if generic-proxy? [
                        HTTP-Get-Header: make object! [
                            Host: join port/host any [all [port/port-id (not find [80 443] port/port-id) join #":" port/port-id] #]
                        ] 
                        user: get in port/proxy 'user 
                        pass: get in port/proxy 'pass 
                        if string? :user [
                            HTTP-Get-Header: make HTTP-Get-Header [
                                Proxy-Authorization: join "Basic " enbase join user [#":" pass]
                            ]
                        ] 
                        http-packet: reform ["CONNECT" HTTP-Get-Header/Host "HTTP/1.1^/"] 
                        append http-packet net-utils/export HTTP-Get-Header 
                        append http-packet "^/" 
                        net-utils/net-log http-packet 
                        insert port/sub-port http-packet 
                        continue-post/tunnel
                    ] 
                    system/words/set-modes port/sub-port [secure: true]
                ]
            ] 
          	; smarter query
			http-command: either port/locals/querying ["HEAD"] ["GET"]
            create-request: func [/local target user pass u file-content file-name boundary multipart-data] [
                HTTP-Get-Header: make object! [
                    Accept: "*/*" 
                    Connection: "close" 
                    ;Accept-Encoding: "gzip,deflate"
                    ;Accept-Language: "en-us,en;q=0.5"
                    ;Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
                    ;Keep-Alive: "115"
                    ;Connection: "keep-alive"
                    User-Agent: get in get in system/schemes port/scheme 'user-agent 
                    Host: join port/host any [all [port/port-id (not find [80 443] port/port-id) join #":" port/port-id] #]
                ] 
                if all [block? port/state/custom post-data: select port/state/custom 'header block? post-data] [
                    HTTP-Get-Header: make HTTP-Get-Header post-data
                ] 
                HTTP-Header: make object! [
                    Date: Server: Last-Modified: Accept-Ranges: Content-Encoding: Content-Type: 
                    Content-Length: Location: Expires: Referer: Connection: Authorization: none
                ] 
                http-version: "HTTP/1.0^/" 
                all [port/user port/pass HTTP-Get-Header: make HTTP-Get-Header [Authorization: join "Basic " enbase join port/user [#":" port/pass]]] 
                user: get in port/proxy 'user 
                pass: get in port/proxy 'pass 
                if all [generic-proxy? string? :user] [
                    HTTP-Get-Header: make HTTP-Get-Header [
                        Proxy-Authorization: join "Basic " enbase join user [#":" pass]
                    ]
                ] 
       			; range request
                if port/state/index > 0 [
                    http-version: "HTTP/1.1^/" 
                    HTTP-Get-Header: make HTTP-Get-Header [
                        Range: rejoin ["bytes=" port/state/index "-"]
                    ]
                ] 
                target: next mold to-file join (join "/" either found? port/path [port/path] [""]) either found? port/target [port/target] [""] 
                post-data: none 
                
              ; print ["port/state/custom:" mold port/state/custom]
                either all [block? port/state/custom multipart-data: find port/state/custom 'multipart multipart-data/2] [
                	;print "!!!!!!! multipart/form-data !!!!!!!!!"
                	net-utils/net-log ["POST files:" multipart-data/2] 
                    http-command: "POST" 
                    boundary: rejoin ["REBOL_" system/version "_" checksum form now/precise]
                    post-data: make string! 100000
                    foreach [fname fvalue] multipart-data/2 [
                    	either file? fvalue [
 							if error? try [
	                    		file-content: to-string system/words/read/binary fvalue
	                    		file-name: split-path fvalue
	                    		insert tail post-data rejoin [
									{--} boundary CRLF
									{content-disposition: form-data; name="} fname {"; filename="} last file-name {"} CRLF
									either any [error? try [content-type: get-content-type fvalue] none? content-type][""][
										rejoin [{Content-type: } content-type CRLF]
									]
									{Content-Transfer-Encoding: binary} CRLF
									CRLF
									file-content CRLF
								]
		                	][
		                		net-utils/net-log ["Error - file not posted:" fvalue]
	                		]
                		][
                			insert tail post-data rejoin [
								{--} boundary CRLF
								{content-disposition: form-data; name="} fname {"} CRLF CRLF
								fvalue CRLF
							]
            			]
                    	
            		]
					append post-data rejoin [{--} boundary {--}]
					
					
                    HTTP-Get-Header: make HTTP-Get-Header append [
	                    ;Referer: either find port/url #"?" [head clear find copy port/url #"?"] [port/url] 
	                    Content-Type: join "multipart/form-data, boundary=" boundary 
	                    Content-Length: length? post-data
	                ] either error? try [HTTP-Get-Header/referer] [Referer: either find port/url #"?" [head clear find copy port/url #"?"] [port/url]] [[]]
	                http-packet: reform [http-command either generic-proxy? [port/url] [target] http-version] 
	                append http-packet net-utils/export HTTP-Get-Header
					append http-packet cookies-daemon/get-cookies port
					;probe http-packet
					;probe post-data
            	][
	                if all [block? port/state/custom post-data: find port/state/custom 'post post-data/2] [
	                	net-utils/net-log ["POST data:" post-data/2] 
	                    http-command: "POST" 

	                    HTTP-Get-Header: make HTTP-Get-Header append append [
		                   ; Referer: either find port/url #"?" [head clear find copy port/url #"?"] [port/url] 
		                    Content-Type: "application/x-www-form-urlencoded" 
		                    Content-Length: length? post-data/2
		                ] 
		  					either block? post-data/3 [post-data/3] [[]] 
		  					either error? try [HTTP-Get-Header/referer] [Referer: either find port/url #"?" [head clear find copy port/url #"?"] [port/url]] [[]]
		                post-data: post-data/2
	                ]
	                
	                http-packet: reform [http-command either generic-proxy? [port/url] [target] http-version] 
	                append http-packet net-utils/export HTTP-Get-Header
					append http-packet cookies-daemon/get-cookies port
					;probe http-packet
					http-packet
				]
            ] 
            send-and-check: func [] [
            	;print ["#####send-and-check" mold http-packet ]
            	;probe post-data
                net-utils/net-log http-packet 
                insert port/sub-port http-packet 
                if post-data [write-io port/sub-port post-data length? post-data] 
                continue-post
            ] 
			continue-post: func [/tunnel /local digit space] [
				response-line: system/words/pick port/sub-port 1
				net-utils/net-log response-line
				either none? response-line [do error][
					; fixes #3494: should accept an HTTP/0.9 simple response.
					digit: charset "1234567890"
					space: charset " ^-"
					either parse/all response-line [
						; relaxing rule a bit
						;"HTTP/" digit "." digit some space copy response-code 3 digit some space to end
						"HTTP/" digit "." digit some space copy response-code 3 digit to end
					] [
						; valid status line
						response-code: to integer! response-code
						result: select either tunnel [tunnel-actions] [response-actions] response-code
						either none? result [do error] [do get result]
					] [
						; could not parse status line, assuming HTTP/0.9
						port/status: 'file
					]
				]
			]

            tunnel-actions: [
                200 tunnel-success
            ] 
            response-actions: [
                100 continue-post 
                200 success 
                201 success 
                204 success 
                206 success 
                300 forward 
                301 forward 
                302 forward 
                303 forward
                304 success 
                305 forward
                307 forward
                407 proxyauth
            ] 
            tunnel-success: [
            	while [(line: pick port/sub-port 1) <> ""] [net-utils/net-log line]
            ] 
            success: [
                headers: make string! 500 
                while [(line: pick port/sub-port 1) <> ""] [append headers join line "^/"] 
				;probe headers
                port/locals/headers: headers: Parse-Header/multiple HTTP-Header headers 
                port/size: 0 
       			if port/locals/querying [if headers/Content-Length [port/size: load headers/Content-Length]]
                if error? try [port/date: parse-header-date headers/Last-Modified] [port/date: none] 
				if not error? try [port/locals/headers/Set-Cookie][
					port/locals/headers/Set-Cookie: cookies-daemon/set-cookies port
				]
                port/status: 'file
            ] 
            error: [
                system/words/close port/sub-port 
                net-error reform ["Error.  Target url:" port/url "could not be retrieved.  Server response:" response-line]
            ] 
            forward: [
                page: copy "" 
                while [(str: pick port/sub-port 1) <> ""] [append page reduce [str newline]]
                headers: Parse-Header HTTP-Header page
                if not error? try [headers/Set-Cookie][
					headers/Set-Cookie: cookies-daemon/set-cookies port
				]
                either block? port/state/custom [
                	clear port/state/custom
                	http-command: either port/locals/querying ["HEAD"] ["GET"]
            	][
                    insert port/locals/list port/url
                ] 
                either found? headers/Location [
                    either any [find/match headers/Location "http://" find/match headers/Location "https://"] [
                        port/path: port/target: port/port-id: none 
                        net-utils/URL-Parser/parse-url/set-scheme port to-url port/url: headers/Location 
                        if not port/port-id: any [port/port-id all [in system/schemes port/scheme get in get in system/schemes port/scheme 'port-id]] [
                            net-error reform ["HTTP forwarding error: Scheme" port/scheme "for URL" port/url "not supported in this REBOL."]
                        ]
                    ] [
                      either (first headers/Location) = slash [
                      	comment {
                      	port/path: none remove headers/Location ;;<--- I really don't know why that was there
                      	}
                      ][
                      	either port/path [
                      		insert port/path "/"
                      	][	port/path: copy "/"]
                      ] 
                      
                      port/target: headers/Location 
                      port/url: rejoin [lowercase to-string port/scheme "://" port/host either port/path [port/path] [""] either port/target [port/target] [""]]
                    ] 
                    if find/case port/locals/list port/url [net-error reform ["Error.  Target url:" port/url {could not be retrieved.  Circular forwarding detected}]] 
                    system/words/close port/sub-port 
                    build-port 
                    create-request 
                    send-and-check
                ] [
                    do error]
            ] 
            proxyauth: [
                system/words/close port/sub-port 
                either all [generic-proxy? (not string? get in port/proxy 'user)] [
                    port/proxy/user: system/schemes/http/proxy/user: port/proxy/user 
                    port/proxy/pass: system/schemes/http/proxy/pass: port/proxy/pass 
                    if not error? try [result: get in system/schemes 'https] [
                        result/proxy/user: port/proxy/user 
                        result/proxy/pass: port/proxy/pass
                    ]
                ] [
                    net-error reform ["Error. Target url:" port/url {could not be retrieved: Proxy authentication denied}]
                ] 
                build-port 
                create-request 
                send-and-check
            ] 
            build-port 
            create-request 
            send-and-check
        ]
		query: func [port] [
			if not port/locals [
				; RAMBO #4039: query mode is local to port now
				port/locals: make object! [list: copy [] headers: none querying: yes]
				open port
				; port was kept open after query
				; attempt for extra safety
				; also note, local close on purpose
				attempt [close port]
				; RAMBO #3718 - superceded by fix for #4039
				;querying: false
			]
			none
		]
]

system/schemes/http/handler:  make system/schemes/http/handler tmp
error? try [system/schemes/https/handler: make system/schemes/https/handler tmp]
clear tmp
tmp: none