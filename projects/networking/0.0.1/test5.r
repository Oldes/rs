rebol [
	title: "MYSQL test"
]
	rss/run %mysql-protocol
	db: open mysql://skejtak:open@127.0.0.1/skateshop
	mysql-handler: func[port /local bytes ud ][
		probe bytes: copy/part port 10
		
		print ["MySQL read" length? bytes "bytes"]
	]
	networking/add-port db :mysql-handler