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
dir_imagemagick: %"/x/UTILS/ImageMagick-6.8.0-Q16/"
;It's used by imagick to load MagickWand's dll or the convert app

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