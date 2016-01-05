rebol [
	title: "HTTP test"
]
rss/run/fresh %httpd

networking/add-port http-port :http-port-handler	