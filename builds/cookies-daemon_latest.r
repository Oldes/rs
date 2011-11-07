REBOL [
    Title: "Cookies-daemon" 
    Date: 7-Nov-2011/8:31:09+1:00 
    Name: none 
    Version: 1.2.2 
    File: none 
    Home: none 
    Author: "Oldes" 
    Owner: none 
    Rights: none 
    Needs: none 
    Tabs: none 
    Usage: {
    Cookies are handled transparently, so you can use any http related commands.
    Additionaly it's possible to send multipart encoded data:
^-    ;sending single file:
^-^-read/custom target-url [multipart [myfile %somefile.txt]]   ;== same like <INPUT TYPE=FILE NAME=myfile>
^-^-;sending normal fields:
^-^-read/custom target-url [multipart [field1 "some value" field2 "another value]]
^-^-;sending multivalue:
^-^-read/custom target-url [multipart ["field[]" "some value" "field[]" "another value]]
^-^-;sending file with field value:
^-^-read/custom target-url [multipart [myfile %somefile.txt field1 "some value"]]
^-} 
    Purpose: {
    ^-Universal cookies handler.
    ^-It automatically GETs and SETs cookies if you read or just open a HTTP port.} 
    Comment: {It's possible that it will not work with some old Rebol versions!} 
    History: [
        8-Jun-2003 0.1.0 "First version" 
        23-May-2005 1.0.0 {Modified for compatibility with HTTP scheme from REBOL/View 1.2.110.3.1 (Core 2.6.1)} 
        29-Jan-2006 1.0.1 "Fixed bug in 'expires' date parser" 
        6-Apr-2006 1.1.0 {Added support to post data in multipart/form-data Content-Type} 
        7-Apr-2006 1.1.1 "Fixed local variables in http-patch" 
        5-Apr-2007 1.1.2 "Added 307 response to the http scheme" 
        27-Mar-2008 1.2.0 {Modified for compatibility with HTTP scheme from REBOL 2.7.6} 
        27-Sep-2010 1.2.1 {Fixed REBOL's bug in port-id handling with HTTPS scheme to avoid infinite loop in: read https://sourceforge.net} 
        3-Nov-2010 1.2.3 "Allowing @ char in user's name"
    ] 
    Language: none 
    Type: none 
    Content: none 
    preprocess: true 
    require: none
] 
insert net-utils/URL-Parser/user-char #"@" 
insert net-utils/URL-Parser/path-char #"!" 
set 'cookies-daemon make object! [
    comment {
#### Include: %http-patch.r
#### Title:   "HTTP handler patch"
#### Author:  ""
----} 
    system/schemes/http/user-agent: {Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.10) Gecko/20100914 Firefox/3.6.10} 
    tmp: [
        open: func [
            port "the port to open" 
            /local http-packet http-command response-actions success error response-line 
            target headers http-version post-data result generic-proxy? sub-protocol 
            build-port send-and-check create-request line continue-post 
            tunnel-actions tunnel-success response-code forward proxyauth page
        ] [
            unless port/locals [port/locals: make object! [list: copy [] headers: none querying: no]] 
            generic-proxy?: all [port/proxy/type = 'generic not none? port/proxy/host] 
            build-port: func [] [
                sub-protocol: either port/scheme = 'https ['ssl] ['tcp] 
                open-proto/sub-protocol/generic port sub-protocol 
                either port/scheme = 'https [
                    port/url: rejoin [lowercase to-string port/scheme "://" port/host either port/port-id <> 443 [join #":" port/port-id] [copy ""] slash]
                ] [
                    port/url: rejoin [lowercase to-string port/scheme "://" port/host either port/port-id <> 80 [join #":" port/port-id] [copy ""] slash]
                ] 
                if found? port/path [append port/url port/path] 
                if found? port/target [append port/url port/target] 
                if sub-protocol = 'ssl [
                    if generic-proxy? [
                        HTTP-Get-Header: make object! [
                            Host: join port/host any [all [port/port-id (not find [80 443] port/port-id) join #":" port/port-id] #]
                        ] 
                        user: get in port/proxy 'user 
                        pass: get in port/proxy 'pass 
                        if string? :user [
                            HTTP-Get-Header: make HTTP-Get-Header [
                                Proxy-Authorization: join "Basic " enbase join user [#":" pass]
                            ]
                        ] 
                        http-packet: reform ["CONNECT" HTTP-Get-Header/Host "HTTP/1.1^/"] 
                        append http-packet net-utils/export HTTP-Get-Header 
                        append http-packet "^/" 
                        net-utils/net-log http-packet 
                        insert port/sub-port http-packet 
                        continue-post/tunnel
                    ] 
                    system/words/set-modes port/sub-port [secure: true]
                ]
            ] 
            http-command: either port/locals/querying ["HEAD"] ["GET"] 
            create-request: func [/local target user pass u file-content file-name boundary multipart-data] [
                HTTP-Get-Header: make object! [
                    Accept: "*/*" 
                    Connection: "close" 
                    User-Agent: get in get in system/schemes port/scheme 'user-agent 
                    Host: join port/host any [all [port/port-id (not find [80 443] port/port-id) join #":" port/port-id] #]
                ] 
                if all [block? port/state/custom post-data: select port/state/custom 'header block? post-data] [
                    HTTP-Get-Header: make HTTP-Get-Header post-data
                ] 
                HTTP-Header: make object! [
                    Date: Server: Last-Modified: Accept-Ranges: Content-Encoding: Content-Type: 
                    Content-Length: Location: Expires: Referer: Connection: Authorization: none
                ] 
                http-version: "HTTP/1.0^/" 
                all [port/user port/pass HTTP-Get-Header: make HTTP-Get-Header [Authorization: join "Basic " enbase join port/user [#":" port/pass]]] 
                user: get in port/proxy 'user 
                pass: get in port/proxy 'pass 
                if all [generic-proxy? string? :user] [
                    HTTP-Get-Header: make HTTP-Get-Header [
                        Proxy-Authorization: join "Basic " enbase join user [#":" pass]
                    ]
                ] 
                if port/state/index > 0 [
                    http-version: "HTTP/1.1^/" 
                    HTTP-Get-Header: make HTTP-Get-Header [
                        Range: rejoin ["bytes=" port/state/index "-"]
                    ]
                ] 
                target: next mold to-file join (join "/" either found? port/path [port/path] [""]) either found? port/target [port/target] [""] 
                post-data: none 
                either all [block? port/state/custom multipart-data: find port/state/custom 'multipart multipart-data/2] [
                    net-utils/net-log ["POST files:" multipart-data/2] 
                    http-command: "POST" 
                    boundary: rejoin ["REBOL_" system/version "_" checksum form now/precise] 
                    post-data: make string! 100000 
                    foreach [fname fvalue] multipart-data/2 [
                        either file? fvalue [
                            if error? try [
                                file-content: to-string system/words/read/binary fvalue 
                                file-name: split-path fvalue 
                                insert tail post-data rejoin [
                                    "--" boundary CRLF 
                                    {content-disposition: form-data; name="} fname {"; filename="} last file-name {"} CRLF 
                                    either any [error? try [content-type: get-content-type fvalue] none? content-type] [""] [
                                        rejoin ["Content-type: " content-type CRLF]
                                    ] 
                                    "Content-Transfer-Encoding: binary" CRLF 
                                    CRLF 
                                    file-content CRLF
                                ]
                            ] [
                                net-utils/net-log ["Error - file not posted:" fvalue]
                            ]
                        ] [
                            insert tail post-data rejoin [
                                "--" boundary CRLF 
                                {content-disposition: form-data; name="} fname {"} CRLF CRLF 
                                fvalue CRLF
                            ]
                        ]
                    ] 
                    append post-data rejoin ["--" boundary "--"] 
                    HTTP-Get-Header: make HTTP-Get-Header append [
                        Content-Type: join "multipart/form-data, boundary=" boundary 
                        Content-Length: length? post-data
                    ] either error? try [HTTP-Get-Header/referer] [Referer: either find port/url #"?" [head clear find copy port/url #"?"] [port/url]] [[]] 
                    http-packet: reform [http-command either generic-proxy? [port/url] [target] http-version] 
                    append http-packet net-utils/export HTTP-Get-Header 
                    append http-packet cookies-daemon/get-cookies port
                ] [
                    if all [block? port/state/custom post-data: find port/state/custom 'post post-data/2] [
                        net-utils/net-log ["POST data:" post-data/2] 
                        http-command: "POST" 
                        HTTP-Get-Header: make HTTP-Get-Header append append [
                            Content-Type: "application/x-www-form-urlencoded" 
                            Content-Length: length? post-data/2
                        ] 
                        either block? post-data/3 [post-data/3] [[]] 
                        either error? try [HTTP-Get-Header/referer] [Referer: either find port/url #"?" [head clear find copy port/url #"?"] [port/url]] [[]] 
                        post-data: post-data/2
                    ] 
                    http-packet: reform [http-command either generic-proxy? [port/url] [target] http-version] 
                    append http-packet net-utils/export HTTP-Get-Header 
                    append http-packet cookies-daemon/get-cookies port 
                    http-packet
                ]
            ] 
            send-and-check: func [] [
                net-utils/net-log http-packet 
                insert port/sub-port http-packet 
                if post-data [write-io port/sub-port post-data length? post-data] 
                continue-post
            ] 
            continue-post: func [/tunnel /local digit space] [
                response-line: system/words/pick port/sub-port 1 
                net-utils/net-log response-line 
                either none? response-line [do error] [
                    digit: charset "1234567890" 
                    space: charset " ^-" 
                    either parse/all response-line [
                        "HTTP/" digit "." digit some space copy response-code 3 digit to end
                    ] [
                        response-code: to integer! response-code 
                        result: select either tunnel [tunnel-actions] [response-actions] response-code 
                        either none? result [do error] [do get result]
                    ] [
                        port/status: 'file
                    ]
                ]
            ] 
            tunnel-actions: [
                200 tunnel-success
            ] 
            response-actions: [
                100 continue-post 
                200 success 
                201 success 
                204 success 
                206 success 
                300 forward 
                301 forward 
                302 forward 
                303 forward 
                304 success 
                305 forward 
                307 forward 
                407 proxyauth
            ] 
            tunnel-success: [
                while [(line: pick port/sub-port 1) <> ""] [net-utils/net-log line]
            ] 
            success: [
                headers: make string! 500 
                while [(line: pick port/sub-port 1) <> ""] [append headers join line "^/"] 
                port/locals/headers: headers: Parse-Header/multiple HTTP-Header headers 
                port/size: 0 
                if port/locals/querying [if headers/Content-Length [port/size: load headers/Content-Length]] 
                if error? try [port/date: parse-header-date headers/Last-Modified] [port/date: none] 
                if not error? try [port/locals/headers/Set-Cookie] [
                    port/locals/headers/Set-Cookie: cookies-daemon/set-cookies port
                ] 
                port/status: 'file
            ] 
            error: [
                system/words/close port/sub-port 
                net-error reform ["Error.  Target url:" port/url "could not be retrieved.  Server response:" response-line]
            ] 
            forward: [
                page: copy "" 
                while [(str: pick port/sub-port 1) <> ""] [append page reduce [str newline]] 
                headers: Parse-Header HTTP-Header page 
                if not error? try [headers/Set-Cookie] [
                    headers/Set-Cookie: cookies-daemon/set-cookies port
                ] 
                either block? port/state/custom [
                    clear port/state/custom 
                    http-command: either port/locals/querying ["HEAD"] ["GET"]
                ] [
                    insert port/locals/list port/url
                ] 
                either found? headers/Location [
                    either any [find/match headers/Location "http://" find/match headers/Location "https://"] [
                        port/path: port/target: port/port-id: none 
                        net-utils/URL-Parser/parse-url/set-scheme port to-url port/url: headers/Location 
                        if not port/port-id: any [port/port-id all [in system/schemes port/scheme get in get in system/schemes port/scheme 'port-id]] [
                            net-error reform ["HTTP forwarding error: Scheme" port/scheme "for URL" port/url "not supported in this REBOL."]
                        ]
                    ] [
                        either (first headers/Location) = slash [
                            comment {
                      ^-port/path: none remove headers/Location ;;<--- I really don't know why that was there
                      ^-}
                        ] [
                            either port/path [
                                insert port/path "/"
                            ] [port/path: copy "/"]
                        ] 
                        port/target: headers/Location 
                        port/url: rejoin [lowercase to-string port/scheme "://" port/host either port/path [port/path] [""] either port/target [port/target] [""]]
                    ] 
                    if find/case port/locals/list port/url [net-error reform ["Error.  Target url:" port/url {could not be retrieved.  Circular forwarding detected}]] 
                    system/words/close port/sub-port 
                    build-port 
                    create-request 
                    send-and-check
                ] [
                    do error
                ]
            ] 
            proxyauth: [
                system/words/close port/sub-port 
                either all [generic-proxy? (not string? get in port/proxy 'user)] [
                    port/proxy/user: system/schemes/http/proxy/user: port/proxy/user 
                    port/proxy/pass: system/schemes/http/proxy/pass: port/proxy/pass 
                    if not error? try [result: get in system/schemes 'https] [
                        result/proxy/user: port/proxy/user 
                        result/proxy/pass: port/proxy/pass
                    ]
                ] [
                    net-error reform ["Error. Target url:" port/url {could not be retrieved: Proxy authentication denied}]
                ] 
                build-port 
                create-request 
                send-and-check
            ] 
            build-port 
            create-request 
            send-and-check
        ] 
        query: func [port] [
            if not port/locals [
                port/locals: make object! [list: copy [] headers: none querying: yes] 
                open port 
                attempt [close port]
            ] 
            none
        ]
    ] 
    system/schemes/http/handler: make system/schemes/http/handler tmp 
    error? try [system/schemes/https/handler: make system/schemes/https/handler tmp] 
    clear tmp 
    tmp: none 
    comment "---- end of include %http-patch.r ----" 
    cookies: make block! 100 
    name: value: expires: cookie-value: domain: path: none 
    digits: charset [#"0" - #"9"] 
    chars: charset [#"A" - #"Z" #"a" - #"z"] 
    cookie-pair-rule: [copy name to "=" skip [copy value to #";" skip | copy value to end]] 
    cookie-data: make block! 5 
    parse-cookie: func [cookie-str /local tmp flag] [
        clear cookie-data 
        comment {
Some cookies want to live on your machine forever do you want them here more then one day?
If so, change the expires value to other date:} 
        expires: now + 1 
        flag: none 
        parse cookie-str [
            cookie-pair-rule (cookie-data: reduce [name cookie-value: value]) 
            any [
                cookie-pair-rule (
                    switch/default name [
                        "expires" [
                            parse/all value [
                                some [
                                    opt [3 chars ", "] 
                                    mark: 2 digits [" " | "-"] 3 chars [" " | "-"] 4 digits [" " | "-"] 2 digits ":" 2 digits ":" 2 digits (
                                        mark/3: #"-" 
                                        mark/7: #"-" 
                                        mark/12: #"/" 
                                        expires: (to-date copy/part mark 20) + now/zone
                                    ) 
                                    | skip
                                ]
                            ]
                        ] 
                        "path" [
                            path: either value/1 = #"/" [remove value] [join path value]
                        ] 
                        "domain" [if not none? value [domain: value]]
                    ] [
                    ]
                ) 
                | "secure" (flag: 'Secure) 
                | "HttpOnly" (flag: 'HttpOnly)
            ]
        ] 
        if #"." <> first domain [insert domain #"."] 
        insert cookie-data reduce [expires domain path] 
        append cookie-data flag 
        head cookie-data
    ] 
    get-cookies: func [port /local tmp out host scheme] [
        tmp: make block! 6 
        domain: join "." copy port/host 
        path: any [port/path ""] 
        scheme: port/scheme 
        cookies: head cookies 
        while [not tail? cookies] [
            either cookies/1 <= now [
                net-utils/net-log ["Cookie" "deleteGet" cookies/1 cookies/2 path cookies/3 cookies/4 cookies/5 cookies/6] 
                cookies: remove/part cookies 6
            ] [
                parse cookies/2 [copy host to ":" | copy host to end] 
                either all [
                    not none? find/part/reverse tail domain host length? host 
                    any [
                        empty? cookies/3 
                        not none? find/part path dirize cookies/3 1 + length? cookies/3
                    ]
                ] [
                    if any [
                        none? cookies/6 
                        all [cookies/6 = 'HttpOnly find [http https] scheme] 
                        all [cookies/6 = 'Secure find [http] scheme]
                    ] [
                        insert tail tmp reduce [cookies/3 rejoin [cookies/4 "=" cookies/5 "; "]]
                    ]
                ] [
                    net-utils/net-log ["Cookie" "bad" cookies/2 path cookies/3 cookies/4 cookies/5 cookies/6]
                ] 
                cookies: skip cookies 6
            ]
        ] 
        cookies: head cookies 
        tmp: sort/skip/reverse tmp 2 
        out: make string! 300 
        foreach [path cookie] tmp [insert tail out cookie] 
        either empty? out [""] [
            rejoin ["Cookie: " head remove back tail out "^/"]
        ]
    ] 
    set-cookies: func [port /local tmp dom host-cookies new-cookies new-cookie new? host cooks] [
        tmp: make block! 4 
        new-cookies: make block! 4 
        cooks: make block! 6 
        foreach [name value] header-rules/head-list [
            if "Set-Cookie" = to-string name [
                append cooks value
            ]
        ] 
        foreach value cooks [
            domain: copy port/host 
            path: port/path 
            tmp: copy parse-cookie value 
            parse tmp/2 [copy host to ":" | copy host to end] 
            dom: parse host "." 
            if none? tmp/3 [poke tmp 3 copy ""] 
            if none? tmp/4 [poke tmp 4 copy ""] 
            if none? tmp/5 [poke tmp 5 copy ""] 
            either all [
                not none? find/part/reverse tail join "." port/host host length? host 
                none? find tmp/3 "./" 
                any [
                    all [
                        none? find ["COM" "EDU" "NET" "ORG" "GOV" "MIL" "INT"] last dom 
                        3 < length? dom
                    ] 
                    2 < length? dom
                ] 
                4000 > length? tmp/3 
                4000 > length? tmp/4 
                4000 > length? tmp/5
            ] [
                insert/only tail new-cookies tmp 
                net-utils/net-log ["Cookie" "new" value]
            ] [
                net-utils/net-log ["Cookie" "refused" value]
            ]
        ] 
        while [not tail? new-cookies] [
            new-cookie: new-cookies/1 
            cookies: head cookies 
            new?: true 
            while [not tail? cookies] [
                either cookies/1 <= now [cookies: remove/part cookies 6] [
                    either all [
                        new-cookie/2 = cookies/2 
                        new-cookie/3 = cookies/3 
                        new-cookie/4 = cookies/4
                    ] [
                        either new-cookie/1 <= now [
                            cookies: remove/part cookies 6
                        ] [
                            cookies/1: new-cookie/1 
                            cookies/5: new-cookie/5 
                            cookies/6: new-cookie/6
                        ] 
                        new?: false 
                        break
                    ] [
                        cookies: skip cookies 6
                    ]
                ]
            ] 
            if all [new? new-cookie/1 > now] [
                insert head cookies new-cookie
            ] 
            new-cookies: next new-cookies
        ] 
        cookies: head cookies
    ] 
    delete: func [domain path name] [
        while [not tail? cookies] [
            cookies: either any [
                cookies/1 <= now 
                all [
                    cookies/2 = domain 
                    cookies/3 = path 
                    cookies/4 = name
                ]
            ] [
                net-utils/net-log ["Cookie" "deleting" domain path name cookies/5] 
                remove/part cookies 6
            ] [
                skip cookies 6
            ]
        ] 
        cookies: head cookies
    ] 
    get-value: func [domain path name /local result] [
        result: none 
        while [not tail? cookies] [
            either cookies/1 <= now [
                net-utils/net-log ["Cookie" "deleting" domain path name cookies/5] 
                cookies: remove/part cookies 6
            ] [
                either all [
                    cookies/2 = domain 
                    cookies/4 = name
                ] [
                    result: cookies/5 
                    break
                ] [
                    cookies: skip cookies 6
                ]
            ]
        ] 
        cookies: head cookies 
        result
    ] 
    list-cookies: func [] [
        while [not tail? cookies] [
            either cookies/1 <= now [cookies: remove/part cookies 6] [
                print rejoin [cookies/1 " " cookies/2 "/" cookies/3 " " cookies/4 "=" cookies/5 " " cookies/6] 
                cookies: skip cookies 6
            ]
        ] 
        cookies: head cookies
    ]
]