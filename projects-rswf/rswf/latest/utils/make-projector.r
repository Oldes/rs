rebol [
	title: "Flash Projector maker"
	author: "Oldes"
	email: oliva.david@seznam.cz
	date: 21-9-2003
	purpose: {To create Flash Projector from the Flash File:-))}
	
	copyrignt: {Macromedia(r) and Flash(tm) are trademarks or registered trademarks of Macromedia, Inc. in the United States and/or other countries.}
	
	comment: {
	This script is able to make just the Windows version of the projector, because I don't know the structure of the *.hqx files at all.

	Sizes for Flash5:
		test.swf ->     258 Bytes
		test.exe -> 377 098 Bytes
		test.hqx -> 692 281 Bytes :-))
		
	Important: There are no security limitations in the Windows Flash Projector so it may for example run programs and so on... be careful about launching these files, but that's normal for all *.exe files where you don't see the source, especially if they are send to you by email as attachments:-)

	BTW: You can simply modify this script to recognize if some file is really Windows FlashProjector or to extract the swf code from it.
	
	PS: The two binary files download from this URL: http://oldes.multimedia.cz/swf/
	}
]

make-projector: func[
	"Returns the Flash Projector as binary"
	swf-file [file! url!] "file that you want to make as the Projector"
	/version ver [integer!] "Version of the Flash Projector (4 5 6 7)"
	/local swf-bin
][
	swf-bin: read/binary swf-file
	insert tail swf-bin join #{563412FA} int-to-ui32 length? swf-bin
	head insert swf-bin read/binary rejoin [
		rswf-root-dir %bin/swfpr either none? version [swf-bin/4][ver] %-win.bin
	]
]