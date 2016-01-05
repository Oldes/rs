rebol [
	title: "IRC Core client - multi connection version"
	author: "Oldes"
	e-mail: "oliva.david at seznam.cz"
	date:  30-Nov-2004/23:14:54+1:00
	version: 3.0.0
	purpose: {
	There already are some Rebol IRC clients, but what I know, there was no clients
	running only in the console... so there is one...}
	comment: {
	Thanks to Paul Tretter for inspiration (some parts of this script as the
	IRC identification are based on his work [REBBOT])}
	history: [
		3.0.0 "oldes" [
			"Built using the latest versions of rss-projects (networking, console-port, ident)"
			"Better support for connections to specified channel after succesful connection"
		]
		2.1.1 "oldes" ["Fixed topic bug and bug on quit command"]
		2.0.1 "oldes" ["Using rss-projects so it's more systemic"]
		1.0.0 "oldes" ["Bug fixing (console clear-line, cprint/inf)"]
		0.6.0 "oldes" ["Source is now using preprocessing"]
		0.5.0 "oldes" ["Handles multiple IRC connections / not finished"]
	]
	note: {
	IRC documentations:
	http://www.faqs.org/rfc/rfc1459.txt - "Internet Relay Chat Protocol"
	http://www.faqs.org/rfc/rfc2810.txt - "Internet Relay Chat: Architecture"
	http://www.faqs.org/rfc/rfc2811.txt - "Internet Relay Chat: Channel Management"
	http://www.faqs.org/rfc/rfc2812.txt - "Internet Relay Chat: Client Protocol"
	http://www.faqs.org/rfc/rfc2813.txt - "Internet Relay Chat: Server Protocol"
	and
	http://www.faqs.org/rfc/rfc1413.txt - "Identification Protocol"}
	
	Require: [
		rss-project 'console-port 
		rss-project 'error-handler
		rss-project 'networking 
	]
	
	preprocess: true
]

system/user/name: join "rb" random 1000
trace/net on
#include %/d/view/sdk-2-6-2/source/prot-utils.r
#include %irc-core-client.r