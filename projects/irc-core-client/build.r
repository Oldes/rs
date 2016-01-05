rebol [title: "irc-core-client build"]

if not exists? build-dir: %/d/www/cgi-bin/system/html/rss/builds/irc-core-client/ [
	make-dir/deep build-dir
]

;write/binary build-dir/whois_ctx.gz compress mold rss/build/args 'ipinfo [file %ipinfo_ctx.r version 0.1.3]

rss/build/compressed/args/save/to
;rss/build/args/save/to
 'irc-core-client [] build-dir/irc-core-client.r
 
probe checksum/secure read build-dir/irc-core-client.r
