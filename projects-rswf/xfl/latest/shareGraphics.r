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

}

level-files: [
	%00_intro
	%01_skladka
	%02_brana
	%03_dno
	%03_dno_ovladac
	%04_pec
	%05_mafodoupe
	%06_vezeni
	%07_bachar
	%08_venek1
	%09_venek2
	%09_venek2_ovladac
	%10_ulicka
	%11_namesti
	%12_predhernou
	%12_predhernou_puzzle
	%13_herna
	%14_vodarna
	%14_voda-mafosi
	%14_vodarna_trubky
	%15_bar
	%16_zed1
	%17_zed2
	%18_zed3
	%19_sklenik
	%20_pata_veze
	%21_mezilevel
	%22_vytah
	%23_foyer
	%23_pohled_bomba
	%24_bomba
	%24_bomba_detail
	%25_mozkovna
	%25_mozkovna_trezor
	%26_strecha
	%27_outro
]

rob-bitmaps: [
	%hlava_zboku1_crop_611x50_197x233.png
	%hlava_zepredu_crop_582x79_193x203.png
	%hlava_zezadu_crop_596x80_193x201.png
	%rob_clanek1_crop_410x448_101x50.png
	%rob_clanek1_crop_410x448_101x50.png
	%rob_clanek2_crop_414x464_99x49.png
	%rob_clanek3_crop_412x486_95x46.png
	%rob_clanek4_crop_412x518_98x54.png
	%rob_nohy_crop_408x520_105x153.png
	%rob_ramena_crop_385x427_152x59.png
	%rob_ruka_crop_174x443_154x75.png
	%rob_ramenaskladkos_crop_495x439_42x41.png
]

with ctx-XFL [
	analyse-imgs: func[dir][
		print ["*******" dir]
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
				;probe item-file: copy any [
				;	select item/2 "sourceExternalFilepath"
				;	join "./LIBRARY/" item/2/("href")
				;]
				;unless find ["png" "jpg"] last parse item-file "." [append item-file %.png]
				;probe full-file: join dir item-file
				probe name: select item/2 "name"
				;linkageImportForRS="true" linkageExportInFirstFrame="false" linkageIdentifier="hlava" linkageURL="share2.swf"
				if all [
					find rob-bitmaps to-file name
					none? select item/2 "linkageImportForRS"
				][
					changed?: true
					probe item/2
					repend item/2 [
						"linkageImportForRS" "true"
						"linkageExportInFirstFrame" "false"
						"linkageIdentifier" name
						"linkageURL" "00/11111100.011"
					]
					probe item/2
				]
				if tmp: find item/2 "useImportedJPEGData" [
					remove/part tmp 2
					changed?: true
				]
				if tmp: find item/2 "compressionType" [
					remove/part tmp 2
					changed?: true
				]
				unless find item/2 "allowSmoothing" [
					repend item/2 ["allowSmoothing" "true"]
					changed?: true
				]
				if none? bitmap-levels: select all-bitmaps name [
					append/only append all-bitmaps name bitmap-levels: copy []
				]
				
				append bitmap-levels last parse dir "/"
			]
		]
		if changed? [
			write/binary trg-folder/DOMDocument.xml xmltree-to-str xmldom
		]
	]

	;fix-imgs %/f/svn/machinarium/xfl/02_brana/
	;fix-png-names %/f/svn/machinarium/xfl/25_mozkovna/
	;halt
	xfls: %/d\RS\projects-mm\robotek\wii-final\XFL\ %/d/svn/machinarium/xfl_orig/  ;%/f/svn/machinarium/xfl/
	all-bitmaps: copy []
	level-files: [%09_venek2]
	foreach level level-files [
		if exists? join dirize xfls/:level %DOMDocument.xml [
			analyse-imgs xfls/:level
		]
	]
	sort/skip all-bitmaps 2
	new-line/skip all-bitmaps true 2
	foreach [file levels] all-bitmaps [
		if all [
			1 < length? levels
			;find rob-bitmaps to-file file
			find file "rob_"
		] [
			new-line levels true
			print [file mold levels]
		]
	]
	;probe all-bitmaps
	   ;join what-dir %tests/02_brana/ ;%/f/svn/machinarium/xfl_orig/02_brana/    %07_bachar/
]


