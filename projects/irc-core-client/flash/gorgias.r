rebol []

;texty: load %pisne.rb


gorgias-start: func[][

	new-puppet "Sokrates" 10
	new-puppet "Kallikles" 11
	new-puppet "Chairefon" 12
	new-puppet "Gorgias" 13
	new-puppet "Polos" 14

	text: read %gorgias-final.txt
	trim/head/tail text
	rec-buffer: parse/all text "^/"
	scheduler/add-action 'rec (now + 0:0:10 ) [pokracuj-v-reci]
]


konec-textu: func[][
	s " "
	current-puppet: "Oldes"
	;scheduler/add-action 'gorgias-start (now + 0:0:10 + random 0:1:30) [gorgias-start]
]

rychlost-cteni: 0:0:0.09

pokracuj-v-reci: func[][
	if all [block? rec-buffer not empty? rec-buffer][
		tmp: first rec-buffer
		trim/head/tail tmp
		either parse tmp ["[" copy ppt to "]" 1 skip end][
			current-puppet: ppt
		][
			if not empty? tmp [
				print [current-puppet ":" mold tmp]
				s tmp
			]
		]
		remove rec-buffer
		either empty? rec-buffer [
			scheduler/add-action 'rec (now + 0:0:1 + (rychlost-cteni * length? tmp)) [konec-textu]
		][
			scheduler/add-action 'rec (now + 0:0:1 + (rychlost-cteni * length? tmp)) [pokracuj-v-reci]
		]
	]
]

;vyber-text
;vyber-text/cislo length? texty
scheduler/remove-action 'gorgias-start
scheduler/add-action 'gorgias-start (now + 0:0:2) [gorgias-start]


