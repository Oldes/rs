rebol []
	do-crops: func[
		/local
		 bmp bmp-file minx miny maxx maxy imgsz
		 a b c d tx ty tmp ai bi ci di txi tyi xA yA xB yB xC yC xD yD
		 nminx nminy nmaxx nmaxy x y w h
	][
		;probe bmpFills
		;probe Media
		;ask ""
		crops: copy []
		xxx: copy []
		foreach [id minx miny maxx maxy sx sy rx ry tx ty] bmpFills [
			print ["???" id minx miny maxx maxy sx sy rx ry tx ty]
			unless find noCrops id [
				minx: minx / 20
				miny: miny / 20
				maxx: maxx / 20
				maxy: maxy / 20
				a: sx / 20
				c: ry / 20
				b: rx / 20
				d: sy / 20
				tx: tx
				ty: ty

				tmp: (a * d) - (b * c)
				ai:   d / tmp
				bi: - b / tmp
				ci: - c / tmp
				di:   a / tmp
				txi: ((c * ty) - (d * tx)) / tmp
				tyi: -((a * ty) - (b * tx)) / tmp
				
				xA: (minx * ai) + (miny * ci) + txi
				yA: (minx * bi) + (miny * di) + tyi
				
				xB: (maxx * ai) + (miny * ci) + txi
				yB: (maxx * bi) + (miny * di) + tyi
				
				xC: (maxx * ai) + (maxy * ci) + txi
				yC: (maxx * bi) + (maxy * di) + tyi
				
				xD: (minx * ai) + (maxy * ci) + txi
				yD: (minx * bi) + (maxy * di) + tyi
				
			;	print "============="
			;	print [xA yA]
			;	print [xB yB]
			;	print [xC yC]
			;	print [xD yD]
				
				nminx: to-integer min xD min xC min xA xB
				nmaxx: to-integer max xD max xC max xA xB
				nminy: to-integer min yD min yC min yA yB
				nmaxy: to-integer max yD max yC max yA yB
				
				
				
				;print [nminx nminy nmaxx nmaxy]
				x: xc: round/floor nminx
				y: yc: round/floor nminy
				w: round/ceiling(nmaxx - x)
				h: round/ceiling(nmaxy - y)
				
				
				if bmp: select media id [
					bmp-file: bmp/("sourceExternalFilepath")
					unless exists? xfl-folder-new/(bmp-file) [
						export-media-item bmp
					]
					imgsz: get-image-size xfl-folder-new/(bmp-file)
					if xc < 0 [xc: imgsz/1 + (xc // imgsz/1)]
					if yc < 0 [yc: imgsz/2 + (yc // imgsz/2)]
					if xc > imgsz/1 [xc: xc // imgsz/1]
					if yc > imgsz/2 [yc: yc // imgsz/2]
					if xc > 1 [x: x - 2 xc: xc - 2 w: w + 2]
					if yc > 1 [y: y - 2 yc: yc - 2 h: h + 2]
					if (xc + w) < imgsz/1 [w: w + 2]
					if (yc + h) < imgsz/2 [h: h + 2]
					;print [xc yc w h]
				]
				
				print ["crop:" x y w h tab "===" tab nminx nminy nmaxx nmaxy]
;ask ""
			;	print ["===" x y w h sx sy rx ry tx ty]
			
				either tmp: select xxx id [
					repend tmp [xc yc (xc + w) (yc + h) x y]
				][
					append xxx id
					repend/only xxx [xc yc xc + w yc + h x y]
				]
			
				either none? tmp: select crops id [
					append crops id
					repend/only crops [xc yc xc + w yc + h x y]
				][
					change tmp reduce [
						min tmp/1 xc
						min tmp/2 yc
						max tmp/3 (xc + w)
						max tmp/4 (yc + h)
						min tmp/5 x
						min tmp/6 y
					]
				]
				;if error? try [md5: last select swfBitmaps id][md5: none]
				;print ["BMP" id md5 w h as-pair x y as-pair x + w y + h]
			]
		]
		print "============CROP=============="
		;probe xxx
		;save %crops.rb xxx
		clear Media-to-remove
		;probe media
		;ask ""
		foreach [id sizes] crops [
			if bmp: select media id [
				print ["crop bitmap type:" mold bmp]
				probe sizes
				either probe tmp: crop-images
					xfl-folder-new/(bmp/("sourceExternalFilepath"))
					sizes/1
					sizes/2
					sizes/3 - sizes/1
					sizes/4 - sizes/2
				[
					import-media-img/dom/smoothing tmp select bmp "allowSmoothing"
					append sizes second split-path to-rebol-file tmp
					append Media-to-remove id
				][
					print ["!!!" id]
					append noCrops id
				]
			]
		]
		print "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
		probe noCrops: unique noCrops
		probe crops
		foreach id sort/reverse noCrops [
			print ["noCrop:" id]
			;probe select swfBitmaps id
			if tmp: find crops id [
				print ["noCrop:" mold tmp/2]
				remove/part tmp 2
			]
		]
		probe crops
		;ask ""
	]