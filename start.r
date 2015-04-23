REBOL [
	title: "Start RS in console"
]

with: func[obj body][do bind body obj]
drc:  does[do read clipboard://]
tm:   func[count [integer!] code [block!] /local t][t: now/time/precise loop count code probe now/time/precise - t]
ls: :list-dir
cd: :change-dir

dir_lib:         join what-dir %lib/     ;used to store external libraries


;Change this variable to your ImageMagick installation location if needed
dir_imagemagick: %"/c/dev/UTILS/ImageMagick-6.9.0-Q16/"
;It's used by imagick to load MagickWand's dll or the convert app

crypt: func [
    "Encrypts or decrypts data and returns the result."
    data [any-string!] "Data to encrypt or decrypt"
    akey [binary!] "The encryption key"
    /decrypt "Decrypt the data"
    /binary "Produce binary decryption result."
    /local port
][
    port: open [
        scheme: 'crypt
        direction: pick [encrypt decrypt] not decrypt
        key: akey
        padding: true
    ]
    insert port data
    update port
    data: copy port
    close port
    if all [decrypt not binary] [data: to-string data]
    data
]
do %rs.r
print "RS ready"
rs/run 'wav-to-mp3
rs/run 'xfl-remove-duplicates
rs/run 'xfl-shapes-to-symbols
print {
	xfl-shapes-to-symbols
	xfl-remove-duplicates
	wav-to-mp3 %
	wmc
}
halt