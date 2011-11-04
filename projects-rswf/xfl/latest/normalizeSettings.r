rebol []

{
<DOMBitmapItem name="hlava_zboku1_crop_611x50_197x233.png" itemID="4cf9f5ab-00000009" sourceExternalFilepath=".\LIBRARY\hlava_zboku1_crop_611x50_197x233.png.png" sourceLastImported="1291449788" originalCompressionType="lossless" href="hlava_zboku1_crop_611x50_197x233.png" bitmapDataHRef="My 1 12894689.dat" frameRight="2300" frameBottom="2660"/>

<DOMBitmapItem name="hlava_zboku1_crop_611x50_197x233.png" itemID="4cf9f5ab-00000009"  sourceExternalFilepath=".\LIBRARY\hlava_zboku1_crop_611x50_197x233.png.png" sourceLastImported="1291449788" originalCompressionType="lossless" href="hlava_zboku1_crop_611x50_197x233.png" bitmapDataHRef="My 1 12894689.dat" frameRight="2300" frameBottom="2660"/>

linkageImportForRS="true" linkageExportInFirstFrame="false" linkageIdentifier="hlava" linkageURL="share2.swf"

;defaultni jpeg kvalita:
<DOMBitmapItem name="hlava_zboku1_crop_611x50_197x233.png" itemID="4cf9f5ab-00000009" sourceExternalFilepath=".\LIBRARY\hlava_zboku1_crop_611x50_197x233.png.png" sourceLastImported="1291449788" originalCompressionType="lossless" href="hlava_zboku1_crop_611x50_197x233.png" bitmapDataHRef="My 1 12894689.dat" frameRight="2300" frameBottom="2660"/>

;defaultni jpeg kvalita s vyhlazenim:
<DOMBitmapItem name="hlava_zboku1_crop_611x50_197x233.png" itemID="4cf9f5ab-00000009" sourceExternalFilepath=".\LIBRARY\hlava_zboku1_crop_611x50_197x233.png.png" sourceLastImported="1291449788" allowSmoothing="true" originalCompressionType="lossless" href="hlava_zboku1_crop_611x50_197x233.png" bitmapDataHRef="My 1 12894689.dat" frameRight="2300" frameBottom="2660"/>

;png s vyhlazenim:
<DOMBitmapItem name="hlava_zboku1_crop_611x50_197x233.png" itemID="4cf9f5ab-00000009" sourceExternalFilepath=".\LIBRARY\hlava_zboku1_crop_611x50_197x233.png.png" sourceLastImported="1291449788" allowSmoothing="true" useImportedJPEGData="false" compressionType="lossless" originalCompressionType="lossless" href="hlava_zboku1_crop_611x50_197x233.png" bitmapDataHRef="My 1 12894689.dat" frameRight="2300" frameBottom="2660"/>

useImportedJPEGData="false" compressionType="lossless" originalCompressionType="lossless"

JPG:
<DOMBitmapItem name="00_HINT.png" itemID="4cd2aaf5-00000072" sourceExternalFilepath=".\LIBRARY\00_HINT.png" sourceLastImported="1288646940" externalFileSize="7978" originalCompressionType="lossless" quality="50" href="00_HINT.png" bitmapDataHRef="M 4 1288874738.dat" frameRight="980" frameBottom="1220"/>
PNG:
<DOMBitmapItem name="00_HINT.png" itemID="4cd2aaf5-00000072" sourceExternalFilepath="./LIBRARY/00_HINT.png" sourceLastImported="1288646940" externalFileSize="7978" useImportedJPEGData="false" compressionType="lossless" originalCompressionType="lossless" quality="50" href="00_HINT.png" bitmapDataHRef="M 4 1288874738.dat" frameRight="980" frameBottom="1220"/>

DIFF:
useImportedJPEGData="false" compressionType="lossless"

}

level-files: [
	%00_intro
	%01_skladka
	%02_brana
	%03_dno
	%04_pec
	%05_mafodoupe
	%06_vezeni
	%07_bachar
	%08_venek1
	%09_venek2
	%10_ulicka
	%11_namesti
	%12_predhernou
	%13_herna
	%14_vodarna
	%15_bar
	%16_zed1
	%17_zed2
	%18_zed3
	%19_sklenik
	%20_pata_veze
	%21_mezilevel
	%22_vytah
	%23_foyer
	%23_foyer_wc
	%24_bomba
	%25_mozkovna
	%26_strecha
	%27_outro
]

with ctx-XFL [
	normalizeBitmapSettings: func[dir][
		print ["^/^/*******" dir]
		src-folder: 
		xfl-folder:
		xfl-folder-new:
		trg-folder:	dirize dir ;dirize join %/f/SVN/machinarium/XFL_ORIG/ file
	
		DOMDocument: as-string read/binary src-folder/DOMDocument.xml
		
		changed?: false
		
		xmldom: third parse-xml+/trim DOMDocument
		;change-dir trg-folder
		if items: get-nodes xmldom %DOMDocument/media/DOMBitmapItem [
			foreach item items [
				probe name: select item/2 "name"

				;comment {
				;TO JPGs:
				;if tmp: find item/2 "useImportedJPEGData" [
				;	remove/part tmp 2
				;	changed?: true
				;]
				if tmp: find item/2 "compressionType" [
					remove/part tmp 2
					changed?: true
				]
				either tmp: find item/2 "quality" [
					unless find ["90" "80"] item/2/("quality") [
						item/2/("quality"): "80"
						changed?: true
					]
				][
					changed?: true
					append item/2 ["quality" "80"]
				]
				;}
				;TO PNGs:
				comment {
				unless find item/2 "useImportedJPEGData" [
					append item/2 ["useImportedJPEGData" "false"]
					changed?: true
				]
				unless find item/2 "compressionType" [
					append item/2 ["compressionType" "lossless"]
					changed?: true
				]
				}
			]
		]
		if changed? [
			write/binary trg-folder/DOMDocument.xml.bac DOMDocument
			write/binary trg-folder/DOMDocument.xml xmltree-to-str xmldom
		]
	]
normalizeBitmapSettings %/d/ipad/machinarium/assets/Animace/animend/
halt
	xfls: %/d/ipad/machinarium/assets/levels/ ;%/d\RS\projects-rswf\xfl\latest\tests\  ;%/f/svn/machinarium/xfl/

	;level-files: [%../MachinariumNoPreload]
	foreach level level-files [
		if exists? join dirize xfls/:level %DOMDocument.xml [
			normalizeBitmapSettings xfls/:level
		]
		comment {
		if exists? file: join dirize xfls/:level %PublishSettings.xml [
			xml: read/binary file
			parse/all xml [
				thru {<OmitTraceActions>}   s: to {</} e: (change/part s "1"  e)
				thru {<StreamFormat>}       s: to {</} e: (change/part s "3"  e)
				thru {<StreamCompress>}     s: to {</} e: (change/part s "16" e) ;16 = 128, 17 = 160
				thru {<EventFormat>}        s: to {</} e: (change/part s "3"  e)
				thru {<EventCompress>}      s: to {</} e: (change/part s "16" e)
				thru {<DebuggingPermitted>} s: to {</} e: (change/part s "0"  e)
			]
			write/binary file xml
		]
		}
	]

]


