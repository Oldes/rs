rebol []

;texty: load %pisne.rb


bondy-start: func[][

	new-puppet "Bondy" 10

	text: read %bondy.txt
	trim/head/tail text
	rec-buffer: parse/all text "^/"
	scheduler/add-action 'rec (now + 0:0:10 ) [pokracuj-v-reci]
]


konec-textu: func[][
	s " "
	current-puppet: "Oldes"
	;scheduler/add-action 'bondy-start (now + 0:0:10 + random 0:1:30) [bondy-start]
]

rychlost-cteni: 0:0:0.09

pokracuj-v-reci: func[][
	if all [block? rec-buffer not empty? rec-buffer][
		tmp: first rec-buffer
		trim/head/tail tmp
		either parse tmp ["[" copy ppt to "]" 1 skip end][
			current-puppet: ppt
		][
			either empty? tmp [
				insert/dup tmp " " 10
			][
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
scheduler/remove-action 'bondy-start
scheduler/add-action 'bondy-start (now + 0:0:2) [bondy-start]


