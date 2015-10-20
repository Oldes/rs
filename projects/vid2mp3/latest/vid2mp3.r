REBOL [
    Title: "Vid2mp3"
    Date: 3-Dec-2014/23:24:37+1:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "A Rebol"
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
    Email: none
    require: [
        rs-project %cookies-daemon
        rs-project %url-encode
    ]
]

page: read http://www.vidtomp3.com/

vidurl: https://www.youtube.com/watch?v=vtRTdGm_t9s&list=ALBTKoXRg38BDIvCywpi6Gkfjz8cVRiQzY&index=4

page2: read/custom http://www.vidtomp3.com/process.php reduce [
    'post url-encode vidurl
]