REBOL [
    Title: "REBOL HTTP Proxy"
    Date: 13-Jul-2001
    Name: "Proxy Server"
    Version: 1.0.0
    File: %proxy.r
    Author: "Sterling Newton"
    Purpose: {This script serves many purposes.
1.  Act as an HTTP proxy
2.  See what your broswer sends out as an HTTP request
3.  Add data filters to remove Javascript pop-up windows,
remove banner ads, and more...
Uncomment line towards the bottom of the script marked for JavaScript
to enable JavaScript popup window death!!}
    History: {

^-13-Jul-2001 New build.  There's a couple of new filters in here so
^-take a look at it below where all the true/false assignments are.
^-Those flags turn all of the filters on and off.  The big stuff is
^-ad filtering.  Don't you hate it when your page doesn't load
^-because some ad server is bogged down?  Yeah, me too until
^-recently. :) Most filters are off by default so turn on the ones
^-you want.

^-3-Aug-2000 Added many comments about the filters and added filter
^-flags to turn them on and off as desired.

^-27-July-2000 Added some chars to the URL parser for this script.
^-REBOL, as of Core 2.3 still strips all hex encoding in the scanner
^-so some data is lost for the URL parser.  Special characters were
^-added to prevent blowouts but the solution is not optimal.

^-2-Dec-1999 Added some error catching to make the system more
^-stable.  Added line to kill JavaScript popup windows.
}
    Email: sterling@rebol.com
    Category: [web tcp 4]
]

Comment [{
    To make this script work, you need to do the following:

    1.  configure your browser to have an HTTP proxy set to localhost
    on port XXXX, where XXXX is 9005 (set below) or whatever port number
    you change it to.

    2.  add the right network setup to this script so it can use any proxy
    you already have.

    The first thing you want to do is set up your network proxy
    (if you have one) using set-net.  The next section of code simply
    checks out your proxy settings to use them if needed.  There are
    two debug values that may be set in order to have the proxy print
    out the outgoing request from your browser and/or the incoming page
    response from the web.

    The main loop of the script is more simple than it appears.  It waits
    for an incoming request from the browser, then connects to the target
    machine directly (if no proxy is set) or by going through the proxy.  It
    then waits on both the port to the web and the port to the browser and
    passes all data that comes in one to the other.  When it gets a read of
    zero bytes, the socket to the outside is closed and it closes its ports
    and cycles again.}
]

; !!! do network setup with set-net here

system/console/busy: none ; turn off the spinner so we can page back
;;; set up the network

;;; add some chars to the url parsing scheme
;;; temporary hack since all hex escapes are gone by the time we see the url
insert net-utils/url-parser/path-char "^-[]{};\<>"

;;; get proxy info so we can go through it if needed
port-spec: make port! [
        scheme: 'tcp
        port-id: 80
        proxy: make system/schemes/default/proxy []
]
if any [system/schemes/default/proxy/host system/schemes/http/proxy/host] [
    proxy-spec: make port! [scheme: 'http]
    port-spec/proxy: make proxy-spec/proxy copy []
]

serv: open tcp://:9005
size: 10000 ; size of read buffer
data: make string! size
conn-list: make block! 20
link-list: make block! 20

;;; filters to run
debug-request: true         ; print out connection info - it's fun to "watch" the web!
debug-all: true
show-packets: true          ; just prints out dots as each incoming "packet" is analyzed for
                            ; HTML filters
no-html-colors: false        ; strips all color tags from HTML
no-banner-ads: false         ; changes in personal images for banner ads
                            ; set logo-dir var below if true
no-javascript-popups: true  ; kills off javascript popup windows
no-stat-cookies: false       ; prints out all incoming cookies
                            ; removes cookies from doubleclick (I hate them)
                            ; not sure this is really working perfectly
no-keep-alive: false         ; removes the Proxy-Connection: Keep-Alive header from the requests
no-web-trackers: false       ; don't visit links that are from tracking sites like doubleclick.net -- I hate these guys
no-adservers: false          ; filters on sites like "adserver.*" "ads.*", etc. (add your own!)

;;; directory of image files to replace banner ads with
;;; all files in this directory are used at random and
;;; should all be banner ad sized (apporximately)
;;; banner ad replacement follows these criteria for
;;; image size (w = width; h = height):
;;; all [w > 325 w < 700 h > 30 h < 85 temp: w / h temp < 24 temp > 4]
;logo-dir: %some dir where your logos are

insert conn-list serv
while [true] [
    if error? err: try [
        conn: wait reduce conn-list
    ] [probe disarm err]
    if block? conn [conn: first conn]
    either conn = serv [ ; new connection so we need to connect it
        if debug-request [print "==================== NEW CONNECTION ===================="]
        conn: first serv
        read-io conn data size
        target: second parse copy/part data find data "^/" none
        if debug-request [print [tab "Connection target:" target]]
        replace/all target "!" "%21" ; hexify '!' character
        if error? err: catch [
            port-spec/host: port-spec/path: port-spec/target: none
            tgt: net-utils/URL-Parser/parse-url port-spec target
        ] [print 'error if debug-request [print "DEATH!!!"]]
        if debug-request [print [tab "Parsed target:" port-spec/host port-spec/path port-spec/target]]

        either any [
; filter out stupid webtrackers
            all [no-web-trackers find port-spec/host "doubleclick.net"]
; don't even read stuff that comes from ad servers... what a waste of time and bandwidth
            all [no-adservers any [
                    find/any port-spec/host "adserver.*"
                    find/any port-spec/host "ads.*"
                ]
            ]
        ] [
            insert conn {HTTP/1.0 200 OK
Content-Type: text/html
Content-Length: 29

<html>Link filtered.</html>}
            close conn clear data
            print ["** NOT reading an evil web-tracker or ad link:" target]
        ] [
            either error? err: try [
                
                all [system/schemes/http/proxy/type <> 'generic
                    system/schemes/default/proxy/type <> 'generic
                    tmp: find data "http://"
                    remove/part tmp find find/tail tmp "//" "/"]

                Root-Protocol/open-proto port-spec
                if debug-request [print [tab "Opened port to:" port-spec/target]]
                partner: port-spec/sub-port
            ] [insert conn "HTTP/1.0 400 Bad Request^/^/" close conn clear data print "Death!" probe disarm err] [
                if no-keep-alive [
                    if tmp: find data "Proxy-Connection" [remove/part tmp find/tail tmp newline]
                ]
                ; send the request
                if not empty? data [write-io partner data length? data
                    if debug-request [probe data] clear data]
                ; add the pair of connections to the link list
                insert/only tail link-list reduce [conn partner] 

                append conn-list conn ; add the connections to the connection list
                append conn-list partner ; add the connections to the connection list
            ]
        ]
    ] [ ; just data to transfer so do it
        ; find the match to the connection we're working with
        repeat x length? link-list [ 
            any [
                all [conn = link-list/:x/1 partner: link-list/:x/2 index: x break]
                all [conn = link-list/:x/2 partner: link-list/:x/1 index: x break]
            ]
        ]
        len: read-io conn data size
        if all [find/match data "HTTP/" tmp: find/tail data "Content-type: "] [
            conn/user-data: copy/part tmp find tmp charset "^M^J"
        ]
        either len > 0 [
;;; kill JavaScript popup windows (should get 99% of 'em)
            if no-javascript-popups [
                if find data "window.open" [print "** Killing java window.open" replace/all data "window.open" "void"]
            ]
;;; print out incoming cookies and remove those from doubleclick
            if no-stat-cookies [
                srch: data while [srch: find srch "Set-Cookie"] [
                    print mold srch
                    print copy/part srch any [end: find srch newline tail srch]
                    ; kill off all .doubleclick.net cookies (I hate being a statistic)
                    if find/part srch ".doubleclick.net" end [print "^-Removing last cookie" remove/part srch next end end: srch] srch: end
                ]
            ]
;;; some sites will send back gzip'd data for HTML pages (Yahoo, for example)
;;; so we have to determine if this is an editable file... more tricky than one might assume
            if any [
                all [conn/user-data find ["text/html"] conn/user-data]
                none? conn/target
                not find tmp: skip tail conn/target -5 #"."
                find tmp "htm"
                find tmp "asp"
                ".r" = skip tail tmp -2
                conn/target = "/"
                find conn/target #"?"
            ] [ ; should we include CGI? sometimes is a binary, right?
                ; do html only mods (don't touch binaries or other files)
                if show-packets [prin #"."]
;;; kill all text, background, and link coloring
                if no-html-colors [
                    list: [["COLOR=" "XCLOR="] ["TEXT=" "XTXT="] ["BGCOLOR=" "NOCOLOR="] ["color:" "XCLOR:"]
                                               ["LINK=" "XLNK="] ["ALINK=" "XALNK="] ["VLINK=" "XVLNK="] ["<LINK" "<LXNK"]]
                    forall list [replace/all data list/1/1 list/1/2]
                    list: head list
                ]
;;; now lets change banner ads into personal banners
                if no-banner-ads [
                    tmp: data
                    while [tmp] [
                        if error? try [
                            either all [tmp: find tmp "<img" end: find tmp #">"] [
                                tag: parse copy/part next tmp end "="
                                h: to-integer select tag "height"
                                w: to-integer select tag "width"
                                all [w h w > 325 w < 700 h > 30 h < 85 temp: w / h temp < 24 temp > 4
                                     change/part next tmp rejoin ["img src=file:" logo-dir pick read logo-dir random size? logo-dir] end
                                ]
                                tmp: skip tmp 30
                            ] [tmp: false]
                        ] [tmp: false]
                    ]
                ]
            ]
;;; now send the filtered data to the browser
            write-io partner data length? data
            if debug-all [print ["----------" newline data newline "----------" newline]]
        ] [
            print ["closing ports..." divide (length? conn-list) - 1 2 "open"]
            if error? err: catch [
                close conn close partner
                true
            ] [probe disarm err]
            remove skip link-list index - 1
            remove find conn-list conn
            remove find conn-list partner
        ]
        clear data
    ]
]
