REBOL [
	title: "Start RS in console"
]

with: func[obj body][do bind body obj]
drc:  does[do read clipboard://]
tm:   func[count [integer!] code [block!] /local t][t: now/time/precise loop count code probe now/time/precise - t]
ls: :list-dir
cd: :change-dir

dir_lib:         join what-dir %lib/     ;used to store external libraries

;Change this variable to your location:
dir_imagemagick: %"/c/Program Files (x86)/ImageMagick-6.7.5-Q16/"
;It's used by imagick to load MagickWand's dll or the convert app

do %rs.r
print "RS ready"

halt