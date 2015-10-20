; ASMO_449 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ASMO_449
any [
#{24} (insert tail result #{00A4}) | 
#{2C} (insert tail result #{060C}) | 
#{3B} (insert tail result #{061B}) | 
#{3F} (insert tail result #{061F}) | 
#{41} (insert tail result #{0621}) | 
#{42} (insert tail result #{0622}) | 
#{43} (insert tail result #{0623}) | 
#{44} (insert tail result #{0624}) | 
#{45} (insert tail result #{0625}) | 
#{46} (insert tail result #{0626}) | 
#{47} (insert tail result #{0627}) | 
#{48} (insert tail result #{0628}) | 
#{49} (insert tail result #{0629}) | 
#{4A} (insert tail result #{062A}) | 
#{4B} (insert tail result #{062B}) | 
#{4C} (insert tail result #{062C}) | 
#{4D} (insert tail result #{062D}) | 
#{4E} (insert tail result #{062E}) | 
#{4F} (insert tail result #{062F}) | 
#{50} (insert tail result #{0630}) | 
#{51} (insert tail result #{0631}) | 
#{52} (insert tail result #{0632}) | 
#{53} (insert tail result #{0633}) | 
#{54} (insert tail result #{0634}) | 
#{55} (insert tail result #{0635}) | 
#{56} (insert tail result #{0636}) | 
#{57} (insert tail result #{0637}) | 
#{58} (insert tail result #{0638}) | 
#{59} (insert tail result #{0639}) | 
#{5A} (insert tail result #{063A}) | 
#{60} (insert tail result #{0640}) | 
#{61} (insert tail result #{0641}) | 
#{62} (insert tail result #{0642}) | 
#{63} (insert tail result #{0643}) | 
#{65} (insert tail result #{0645}) | 
#{66} (insert tail result #{0646}) | 
#{67} (insert tail result #{0647}) | 
#{68} (insert tail result #{0648}) | 
#{69} (insert tail result #{0649}) | 
#{6A} (insert tail result #{064A}) | 
#{6B} (insert tail result #{064B}) | 
#{6C} (insert tail result #{064C}) | 
#{6D} (insert tail result #{064D}) | 
#{6E} (insert tail result #{064E}) | 
#{6F} (insert tail result #{064F}) | 
#{70} (insert tail result #{0650}) | 
#{71} (insert tail result #{0651}) | 
#{72} (insert tail result #{0652}) | 
#{7E} (insert tail result #{203E}) | 
copy c 1 skip (insert tail result join #{00} c)
]