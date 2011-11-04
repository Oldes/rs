rebol [
	title: "RSWF script uploader"
	file: %upload-script.r
	name: 'upload-rswf-script
	purpose: "To upload script to web"
	comment: ""
	author: "oldes"
	date: 7-10-2005
	require: [
		rs-project %url-encode
	]
]

rs/run 'url-encode

do %colorize-rswf.r

rswf-web-url: http://box.lebeda.web/~hmm/rswf/
upload-rswf-script: func[rswf-file [file!] /box /local data swf-version rswfdata][
	print ["Uploading:" rswf-file]
	file-parts: split-path rswf-file
	if not parse form last file-parts [copy name to ".rswf" 5 skip end][
		print "The file must be .rswf dialect file!"
		return false
	]
	
	rswf/string-replace-pairs: either box [
		rswf-web-url: http://box.lebeda.ws/~hmm/rswf/
		[
			"http://127.0.0.1:81/projects-web/box.lebeda.ws/latest/web/"
			"http://box.lebeda.ws/"
			
			"http://box.lebeda.web/"
			"http://box.lebeda.ws/"
		]
	][
		rswf-web-url: http://box.lebeda.web/~hmm/rswf/
		[]
	
	]
	
	swfdata: make-swf/compressed rswf-file
	rswfdata: read rswf-file
	
	set [header code] load/next/header rswf-file
	
	if not integer? swf-version: header/type [
		if none? swf-version: select [
			swf  4
			swf4 4
			swf5 5
			swf6 6
			mx   6
			mx2004 7
			swf7 7
			swf8 8
		] swf-version [ swf-version: 6 ]
	]
	clrdata: colorize-rswf code
	
	foreach [s t] rswf/string-replace-pairs [
		clrdata: replace/all clrdata s t
	]
	
	to-sql-date: func[value [date!]][
		rejoin [value/year "-" value/month "-" value/day
			either value: value/time [
				rejoin [" " value/hour	":" value/minute ":" value/second]
			][""]
		]
	]

	print read/custom rswf-web-url/submit.php reduce [
		'post rejoin [
			"type="         "example"
			"&name="        url-encode name
			"&title="       url-encode form either error? try [header/title][name][header/title]
			"&author="      url-encode form either error? try [header/author][""][header/author]
			"&email="       url-encode form either error? try [header/email ][""][header/email ]
			"&bgcolor="     copy/part skip form to-binary
							either error? try [header/background ][255.255.255][header/background ]
							2 6
			"&swfversion="  swf-version
			"&swfwidth="    header/size/x
			"&swfheight="   header/size/y
			"&swfrate="     header/rate
			"&created="     url-encode to-sql-date either none? header/date [modified? rswf-file][header/date ]
			"&modified="    url-encode to-sql-date modified? rswf-file
			"&purpose="     url-encode form either none? header/purpose [""][header/purpose]
			"&comment="     url-encode form either none? header/comment [""][header/comment]
			"&jscode="      url-encode form either error? try [header/js ][""][header/js]
			"&related="
			"&swf="			url-encode enbase/base swfdata  64
			"&code="        url-encode enbase/base rswfdata 64
			"&colorized="   url-encode enbase/base clrdata  64
		]
	]
	rswf/string-replace-pairs: none
]

comment {
	id			SERIAL,
	name		VARCHAR(50) NOT NULL,
	type		VARCHAR(20),
	status		SMALLINT,
	title		TEXT,
	author		TEXT,
	email		TEXT,
	bgcolor		CHAR(7),
	swfversion	SMALLINT,
	swfwidth	SMALLINT,
	swfheight	SMALLINT,
	swfsize		INT,
	rswfsize	INT,
	created		TIMESTAMP,
	modified	TIMESTAMP,
	purpose		TEXT,
	comment		TEXT,
	jscode		TEXT,
	related		TEXT[],
	code		TEXT,
	colorized	TEXT,
}
;upload-rswf-script %../test.rswf

do %/i/rebol/rs/utils/foreach-file.r

upload-all-rswfs: func[/local errors value][
	errors: []
	foreach-file %examples/ [
		if parse/all form file ["swf" thru ".rswf" end] [
			probe file
			if error? set/any 'value try [
				upload-rswf-script/box rejoin [rswf-root-dir %examples/ file]
			][
				print "!!! ERRROR: "
        		probe value: disarm value none
				append errors file
				append errors value
			]
		]
	]
	if not empty? errors [
		print ["### ERRORS:" mold errors]
	]
]