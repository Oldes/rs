REBOL [
    Title: "Networking"
    Date: 17-Jun-2003/16:37:33+2:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: none
    Purpose: none
    Comment: none
    History: none
    Language: none
    Type: none
    Content: none
    Email: oliva.david@seznam.cz
	Require: [
		rss-project 'console-port 0.1.0
		rss-project 'error-handler
	]
	preprocess: true
]

#include %networking.r

networking/add-port ctx-console/port [ctx-console/process]
ctx-console/on-escape: func[][networking/close-ports halt]

networking/do-events