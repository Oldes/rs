rebol [
	title: "TCP-server-test"
]
attempt [
	AMF_responses: make object! [
		ok: {HTTP/1.0 200 OK
Content-Type: application/x-amf
Content-Length: 29

}
	]
		
	networking/add-port conn: open/direct/no-wait tcp://:5000 func[port /local bytes subport ][
		if port? test: subport: first port [
		
			print ["new connection" subport/host subport/port-id]
			networking/add-port subport func[port /local bytes ud header content w v][
				either none? port/state/inBuffer [
					port/state/inBuffer: make binary! 10000
					port/user-data: make object! [
						header: none
						content: make string! 1000
					]
				][
					;clear port/state/inBuffer
				]
				port/state/num: 10000
				bytes: read-io port port/state/inBuffer port/state/num + 2
				either bytes <= 0 [
					networking/remove-port port
				][
					probe to-string port/state/inBuffer
					either all [
						none? port/user-data/header
						parse/all port/state/inBuffer [
							copy header to {^M^/^M^/} 4 skip
							copy content to end
						]
					][
						hdr: make block! []
						parse/all header [
							
							any[
								thru "^M^/"
								copy w to #":" 2 skip copy v [to "^M^/"  | to end] (
									insert tail hdr reduce [
										to-set-word w  v
									]
								)
							]
						]
						port/user-data/header: make (make object! [Content-Length: 0]) hdr
						port/user-data/header/Content-Length: to-integer port/user-data/header/Content-Length
						probe port/user-data/header
						if not none? content [
							probe content
							probe length? content
							insert tail port/user-data/content content
						]
						clear port/state/inBuffer		
					][
						insert tail port/user-data/content port/state/inBuffer
						clear port/state/inBuffer
					]
					net-utils/net-log ["low level read of " bytes "bytes"]
					attempt [
						print [port/user-data/header/Content-Length  length? port/user-data/content]
						if port/user-data/header/Content-Length <= length? port/user-data/content [
							probe port/user-data/content
							probe to-binary port/user-data/content
							insert port xxx: rejoin [
								{HTTP/1.0 200 OK^M}
								{Content-Type: application/x-amf^M}
								{Content-Length: } length? port/user-data/content {^M^M}
								port/user-data/content
							]
							networking/remove-port port
						]
					]
				]
			]
		]
	]
]