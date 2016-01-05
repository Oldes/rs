rebol [
	title: "IRC Core Client - chat rules example"
	author: "Oldes"
	version: 0.0.0
	means: [
		[block! "Local variables"] [block! "Parse rule"]
	]
]

;	[][thru "kurva" to end][reply "ale no tak, kurva se nerika!"]
;	[][thru "kolik je hodin" to end][say rejoin ["Ja mam ted: " now/time]]
;	[][thru "co je za den" to end][
;		say rejoin["dnes je " pick ["nedele" "pondeli" "utery" "ctvrtek" "patek" "sobota"] now/day]
;	]
;	[][thru "co ted" to end][say "ted se budem flakat?"]
;	[]["hmm"][say first random ["HMM je jenom jeden!" "jo, copak hmm" "aaaach" "huaaaahmmm"]]
;	[][thru "a cos myslel" to end][say/action "nemysli!"]
;	[][thru "jezis" to end][say "Jezis je BUH!"]
;	[][thru "proc?"][say first random ["a proc ne?" "jen tak?"]]
;	[][thru "is listening to "][say/action "nic neslysi!"]
;	[]["!top10"][say "A.... zase nekoho zajimaji statistiky:)"]
;	[tmp]["Top10(words): 1. " copy tmp to {(} to end][say rejoin ["ten " tmp " je ale ukecanej!"]]
;	[tmp][thru {pozpatku "} copy tmp to {"} to end][say rejoin [{"} head reverse tmp {"}]]
