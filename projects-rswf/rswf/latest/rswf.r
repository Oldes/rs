REBOL [
	Title:		"Rebol/Flash dialect (RSWF)"
	Name:       "rswf"
	File:       %rswf.r
	Date:		20-Jan-2010
	Version:	2.17.0
	Author:		"oldes"
	Email:		oldes@amanita-design.net
	License: "BSD-3 - https://github.com/Oldes/rs/blob/master/BSD-3-License.txt"
	Rights:		{
Copyright (C) 2000-2012 David 'Oldes' Oliva.

REBOL is a Trademark of REBOL Technologies
Adobe(r) Flash(r) is a Trademark of Adobe Systems Incorporated}
	Home:		[
		https://github.com/Oldes/rs/tree/master/projects-rswf
		http://rebol.desajn.net/rswf/
	]
	Purpose: {
To create Flash file (SWF) using own Rebol dialect
which is specified by the 'action and 'tag parsing rules.}
	Usage: {
There are these methods how to make the swf file:
	a) using 'create-swf
		create-swf/rate 100x100 [dialect data] 20
	b) 'rswf/compile & 'create-swf
		if the dialect data are dynamicly created, you can use:
		rswf/init
		loop 10 [ rswf/compile [some dialect] ]
		create-swf 100x100 rswf/body
	c) using 'make-swf
		if the dialect is in special file... rate and size are in the header...
		make-swf %flash-file.rswf
	For examples of the dialect see:
	http://rebol.desajn.net/rswf/
}
	Category:	[file util 4]
	Comment:	{
special thanks belongs to Ladislav Mecir for help with the new actions parser used since version 2.0.0
and Gabriele Santilli for help with the older parser (so I could start at least)
Note, that even it's now version 2.0.0, it's not finished, there is still a lot of things to do.
The main goal now is to finish correct usage of aDefineFunc2 action tag used since SWF7}

	History: [
	2.17.0 [20-Jan-2010  "oldes" [
		{This is the version I used to compile Machinarium game (www.machinarium.net)}
	]]
	2.16.0 [5-May-2008  "oldes" [
		{Reviewed text related tags code (moved to separate file + added default font tag creation if not created yet)}
		{Removed ieee context (now using struct! to convert double decimal to-ieee64)}
	]]
	2.15.0 [22-Apr-2008 "oldes" [
		{Internal source files rearrangement, small bug fixing (fixed SWF-parser to propper import shapes with focal-point gradients)}
	]]
	2.14.0 [4-Jan-2008 "oldes" [
		{Added support for loading ICO,BMP and PNG images without need to use Rebol/View. It's possible that some types of these images will not be loaded correctly yet, as I didn't tested all possibilities. The 'KEY word is not supported now with ImageCore loader, use PNG instead if you want transparent images. Also all images are stored as DefineBitsLossless2 type (with alpha).}
	]]
	2.13.0 [20-Dec-2007 "oldes" [
		{Speed optimalizations}
	]]
	2.12.0 [16-11-2007 "oldes" [
		{Implemented FOR..IN action}
		{Added type checking actions:
			integer? number? logic? function? date? string?	MovieClip? block? color? sound? object?
		}
		{A lot of layout internal improvements and fixes}
	]]
	2.11.0 [26-10-2007 "oldes" [
		{improved ImageStream command}
	]]
	2.10.0 [25-10-2007 "oldes" [
		{new ImageStream command to create a Sprite with sequence of images on each frame}
		{It's now possible to use setLocalConstant in acompiler to specify own local-constants}
	]]
	2.9.0  [24-10-2007 "oldes" [
		{Updated layouter (now with new 'DateChooser and 'TextButton GUIs)}
		{Fixed bug in 'IF compilation in case when it's after 'EITHER block}
	]]
	2.8.0  [19-10-2007 "oldes" [
		{Updated layouter (now with new 'Field, 'Password and 'Area GUIs)}
	]]
	2.7.0  [17-10-2007 "oldes" [
		{Fixed bug import-swf (while importing swf file with ExportAssets tag)}
		{Updated layouter (now with new 'Text, 'Scroller, 'ClipHandler and 'ScrollPane GUIs)}
	]]
	2.6.0  [10-10-2007 "oldes" [
		{Fixed bug in Acompiler's trans-make-object so functions now can be defined inside "make object!" definition}
		{First version of GUI layouter added (buttons only)}
	]]
	2.5.0  [8-10-2007 "oldes" [
		{New swf-parser included which replaces old exam-swf function (useful for importing foreign SWF files)}
		{Added implementation of Class definitions for SWF versions 6 and higher}
		{Added new 'trace function into actions (which can be use to compile swf files with or without trace calls easily)}
		{'require and 'include now accepts block of files or urls}
	]]
	2.0.0  [13-9-2007 "oldes" [
		{first public version with new actions parser}
	]]
	1.0.10 [21-2-2007 "oldes" [
		{Implemented automatic ConstantPool conversion}
	]]
	1.0.9 [17-2-2007 "oldes" [
		{Reviewed and fixed interpretations of "control flow" and finaly made correct interpretation of "breaks"}
	]]
	1.0.8 [31-5-2006 "oldes" [
		{Fixed bug with missing 'pop' opcode after calling function inside 'if' block}
	]]
	1.0.7 [27-3-2006 "oldes" [
		{Added missing stringEquals operator ( string1 eq string2 )}
	]]
	1.0.6 [17-3-2006 "oldes" [
		{Added new tag rule used to override the default settings for
maximum recursion depth and ActionScript time-out: 'ScriptLimits integer! integer!}
	]]
	1.0.5 [16-3-2006 "oldes" [
		{Added new tag rule used to set local-with-networking flag: 'UseNetwork [on | off]}
	]]
	1.0.4 [18-10-2005 "oldes" [
		{Review of import-swf function (part of the swf-importer object)}
		{Added new tag rule for swf import: 'impor-swf [file! | url!]}
	]]
	1.0.3 [13-10-2005 "oldes" [
		{Added missing utf-8 encoding to ExportAssets names}
		{Quick review of extended-image code (but would like to make it again as it can be done better in the future)}
		{Fixed conversion of 4digit-issues (for example #00FF0000 where the first byte is alpha channel)}
	]]
	1.0.2 [12-10-2005 "oldes" [
		{Improved download of includes and other parts of the code from the web site}
		{Added shortcuts for making flash8 internal objects - for example:
	make ColorMatrixFilter! [matrix]
instead of:
	make flash.filters.ColorMatrixFilter [matrix]
Check this example for complete list of shortcuts:
http://box.lebeda.ws/~hmm/rswf/index.php?example=swf8-colormatrix}
		{Added rswf/string-replace-pairs variable for possibility to modify strings during compilation}
	]]
	1.0.1 [7-10-2005 "oldes" [
		{Fixed bug in 'process-for function for swf4 version}
		{Included experimental 'extended-image and 'make-window functions}
	]]
	1.0.0 [5-10-2005 "oldes" [
		{Enhanced 'place tag to accept Flash8 blending}
		{Builded with ucs-2 support for CP1250 charset only}
	]]
	0.9.5 [4-10-2005 "oldes" [
      {Modified the 'process-for function to produce code more consistent
with Flash's 'for cycles}
	]]
	0.9.5 [20-9-2005 "oldes" [
      {Fixed bug in ints-to-sbs function.}
	]]
	0.9.4 [5-06-2005 "oldes" [
      {Fixed bug in process-while loop function}
	]]
	0.9.3 [19-04-2005 "oldes" [
      {Changed twips conversion:
moved the twips? value and to-twips from 'shape compilation into rswf values.
Now I can set that placeObject is using twips values as well. I'm not checking
the other values as I don't need them at this moment.}
	]]
	0.9.2 [19-08-2004 "oldes" [
      "Various fixes"
      "New action command 'reform"
      "New shape: box rounded 10 only [1 2] 0x0 100x100 ;this will create box with only top corners rounded"
	]]
	0.9.0 [15-03-2004 "oldes" "All in one file release"]
	0.0.3 [21-11-2001 "oldes" "First release" ]
	]
	require: [
		rs-project 'stream-io 'write
		rs-project 'read-stripped-jpg
		rs-project 'binary-conversions
		rs-project 'ImageCore
		;rs-project 'ucs2cp1250
		;rs-project 'utf-8
		rs-project 'utf8-cp1250
		;rs-project 'ucs2
		;rs-project 'zlib
		;rs-project 'ieee
		rs-project 'ajoin
		rs-project 'acompiler 'new ; 0.6.0 ;'new
		rs-project 'swf-parser
		;rs-project 'imagick 'minimal ;TEMP REMOVE!!
	]
	preprocess: true
]
;print "RSWF...loading"
;change rs/was-dir 
set 'rswf-project-dir what-dir
set 'rswf-root-dir what-dir
unless value? 'rswf-web-url [
	set 'rswf-web-url http://rebol.desajn.net/rswf/
]
system/options/quiet: true

;print {
;make-swf/save %test.rswf exam-swf/file %test.swf run %test.swf
;}



rswf: context [
	body: last-id: action-bin:
	swf-framerate: including: included-files: animations: action-bin-buff:
	sprite-recursion-buff: max-bits: set-word-buff: current-set-word: set-word: last-depth:
	used-ids: stream: names-ids-table: placed-images: placed-objects: WindowClassCreated?: none
	
	tmp: v: v2: v3: val: val2: val3: twips?: fixed-bounds?: FillStyles: def-LineSt: cur-LineSt: to-twips:
	prepare-pos: draw-curves: draw-arc: n-gon: n-star: draw-box: update-gradient: get-fill: sc:
	set-fill-style: set-line-style: shp-rules: bf: id-word: exported-assets: shp-size: FileAttributes: ScriptLimits: none
	
	search-paths: reduce [what-dir]
	
	compile-actions: get in system/words 'compile-actions

	;#include %../../../projects/ucs2/latest/ucs2cp1250only.r
	
	#include %include/sound-fce.rinc
	#include %include/png-to-bll.rinc
	tag-rules: #include-block %swf-tag-rules_enczes.rb ;%swf-tag-rules.rb
	#include %make-swf.r
	#include %include/bitmaps.rinc
	#include %include/place.rinc
	#include %include/shape.rinc
	#include %include/import.rinc
	#include %include/image-stream.rinc
	#include %include/layout.rinc
	#include %include/text.rinc
	#include %utils/compress-swf.r
	;#include %utils/exam-swf.r
	#either [system/version > 1.2.2] [
		#include %include/img-to-bll2.rinc
	][
		#include %include/img-to-bll.rinc
	]
	;#include %extended-image.rinc
]

;print system/script/header/usage
;print "RSWF...ready"