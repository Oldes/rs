REBOL [
	title: "Start RS in console"
]

with: func[obj body][do bind body obj]

do %rs.r
halt