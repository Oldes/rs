rebol []

texty: load %pisne.rb
insert texty load %palla.rb
insert texty load %blatny.rb

new-puppet "platon" 0
current-puppet: "platon"
new-puppet "mila" 6
new-puppet "jano" 4


vyber-text: func[/cislo p][
	;scheduler/remove-action 'vyber-text
	text: pick texty either cislo [p][random length? texty]
	
	trim/head/tail text
	rec-buffer: parse/all text "^/"
	;probe rec-buffer
	scheduler/add-action 'rec (now + 0:0:10 ) [pokracuj-v-reci]
]

konec-textu: func[][
	s " "
	current-puppet: "platon"
	scheduler/add-action 'vyber-text (now + 0:0:10 + random 0:1:30) [vyber-text]
]

rychlost-cteni: 0:0:0.045

pokracuj-v-reci: func[][
	if all [block? rec-buffer not empty? rec-buffer][
		tmp: first rec-buffer
		trim/head/tail tmp
		if tmp = "." [tmp: " "]
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
scheduler/remove-action 'vyber-text
scheduler/add-action 'vyber-text (now + 0:0:2) [vyber-text]


