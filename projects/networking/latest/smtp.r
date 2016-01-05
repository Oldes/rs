rebol [
	title: "SMTP test"
]
rss/run/file/fresh %smtp-dump %smtp-port.r

networking/add-port smtp-port :smtp-port-handler	