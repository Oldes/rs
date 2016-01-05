rebol [
	title: "Proxy-server-test"
]
attempt [
	proxy: make object! [
		port-spec: make port! [
		        scheme: 'tcp
		        port-id: 80
		        proxy: make system/schemes/default/proxy []
		]
		if any [system/schemes/default/proxy/host system/schemes/http/proxy/host] [
		    proxy-spec: make port! [scheme: 'http]
		    port-spec/proxy: make proxy-spec/proxy copy []
		]

		responses: make object! [
			filtered: {HTTP/1.0 200 OK
Content-Type: text/html
Content-Length: 29

<html>Link filtered.</html>}
		]

		comment {
		link-handler: func[port /local bytes target response-line data][
			;print ["link" mold port]
			print "$$$$$$$$$$$$$$$$$$$$$LINKJ$$$$$$$$$$$$$$$$$$$$$$$$$$$"
			either none? port/state/inBuffer [
				port/state/inBuffer: make string! 2 + port/state/num: 10000
				port/user-data: make object! [
					http-get-header: make string! 1000
					partner: none ;data source connection
				]
			][
				clear port/state/inBuffer
			]
			bytes: read-io port port/state/inBuffer port/state/num
			either bytes <= 0 [
				networking/remove-port port
				;if port? port/user-data/partner [
				;	networking/remove-port port/user-data/partner
				;]
			][
				either none? port/user-data/partner [
					append port/user-data/http-get-header port/state/inBuffer
					data: port/user-data/http-get-header
					print ["GET header:" mold data]
					if parse/all data [
						thru "GET " copy target to " " to end
					][
						print ["TARGET:" target]
				        replace/all target "!" "%21" ; hexify '!' character
				        either error? err: catch [
				            port-spec/host: port-spec/path: port-spec/target: none
				            tgt: net-utils/URL-Parser/parse-url port-spec target
				        ] [
				        	print "Error in port-spec parse"
				        	probe disarm err
				        	;print 'error if debug-request [print "DEATH!!!"]]
			        	][
				        	print [tab "Parsed target:" port-spec/host port-spec/path port-spec/target]
				        ]
				        
				        either error? err: try [
			                all [system/schemes/http/proxy/type <> 'generic
			                    system/schemes/default/proxy/type <> 'generic
			                    tmp: find data "http://"
			                    remove/part tmp find find/tail tmp "//" "/"]
			
			                Root-Protocol/open-proto port-spec
			                print [tab "Opened port to:" port-spec/target]
			                port/user-data/partner: port-spec/sub-port
			            ] [
			            	insert port "HTTP/1.0 400 Bad Request^/^/"
			            	networking/remove-port port
			            	print "Death!"
			            	probe disarm err
			            ] [
			                ;if no-keep-alive [
			                ;    if tmp: find data "Proxy-Connection" [remove/part tmp find/tail tmp newline]
			                ;]
			                ; send the request
			                if not empty? data [
			                	write-io port/user-data/partner data length? data
			                	print "Sending request"
			                    probe data clear data
			                ]
			                ; add the pair of connections to the link list
							port/user-data/partner/user-data: port
							networking/add-port port/user-data/partner :partner-handler
						]
					]
				][
					probe to-string port/state/inBuffer
				]
				;probe port/user-data/http-get-header
				;parse to-string port/state/inBuffer
				;net-utils/net-log ["low level read of " bytes "bytes"]
				;print responses/filtered
				;insert port proxy/responses/filtered
				;networking/remove-port port
				;insert port "ok^@"
			]
		]
		}
		
		partner-handler: func[port /local bytes subport][
			;if port? port [
				;print "=====partner===="
				either none? port/state/inBuffer [
					port/state/inBuffer: make binary! 2 + port/state/num: 10000
				][
					clear port/state/inBuffer
				]
				;? port
				bytes: read-io port port/state/inBuffer port/state/num
				either bytes <= 0 [
					;print "Closing by proxy partner"
					;networking/remove-port port/user-data
					close port/user-data
					networking/remove-port port
				][
					;probe port/state/inBuffer
					write-io port/user-data port/state/inBuffer bytes
	
					net-utils/net-log ["proxy partner low level read of " bytes "bytes"]
				]
			;]
		]
		size: 10000
		data: make string! 10000
		server-handler: func[port /local bytes subport partner][
			if port? subport: first port [
				print ["PROXY: new connection" subport/host subport/port-id]
				read-io subport data size
				print ["GET header:" mold data]
				if parse/all data [
					thru "GET " copy target to " " to end
				][
					print ["TARGET:" target]
			        replace/all target "!" "%21" ; hexify '!' character
			        either error? err: catch [
			            port-spec/host: port-spec/path: port-spec/target: none
			            tgt: net-utils/URL-Parser/parse-url port-spec target
			            port-spec/scheme: 'tcp
			        ] [
			        	print "Error in port-spec parse"
			        	probe disarm err
			        	;print 'error if debug-request [print "DEATH!!!"]]
		        	][
			        	;print [tab "Parsed target:" port-spec/host port-spec/path port-spec/target]
			        ]
			        
			        either error? err: try [
		                all [system/schemes/http/proxy/type <> 'generic
		                    system/schemes/default/proxy/type <> 'generic
		                    tmp: find data "http://"
		                    remove/part tmp find find/tail tmp "//" "/"]
		                Root-Protocol/open-proto port-spec
		               ; print [tab "Opened port to:" port-spec/target]
		                ;replace target "http://" "tcp://"
		                ;probe head target
		                partner: port-spec/sub-port
		            ] [
		            	insert subport "HTTP/1.0 400 Bad Request^/^/"
		            	close subport clear data
		            	print "Death!"
		            	probe disarm err
		            ] [
		                ;if no-keep-alive [
		                ;    if tmp: find data "Proxy-Connection" [remove/part tmp find/tail tmp newline]
		                ;]
		                ; send the request
		                if tmp: find data "Proxy-Connection" [remove/part tmp find/tail tmp newline]
		                if not empty? data [
		                	partner/user-data: subport
		                	networking/add-port partner :partner-handler
		                	write-io partner data length? data
		                	;print "Sending request"
		                    ;probe data
		                    clear data
		                ]
		                ; add the pair of connections to the link list
						
						
					]
				]

			
				
				
				;networking/add-port subport get in proxy 'link-handler
			]
		]
		server-port: open/direct/no-wait tcp://:9005
		
		networking/add-port server-port :server-handler
	]

]

comment {

set-net  [none none none "192.168.0.1" 9005 'generic]
length? x: read/binary http://192.168.0.1/imgz/divka.gif
print read http://192.168.0.1/
}