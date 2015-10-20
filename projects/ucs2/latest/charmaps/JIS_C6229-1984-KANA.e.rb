; JIS_C6229-1984-KANA UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/JIS_C6229-1984-KANA
any [
#{22} (insert tail result #{300C}) | 
#{23} (insert tail result #{300D}) | 
#{26} (insert tail result #{30F2}) | 
#{31} (insert tail result #{30A2}) | 
#{32} (insert tail result #{30A4}) | 
#{33} (insert tail result #{30A6}) | 
#{34} (insert tail result #{30A8}) | 
#{35} (insert tail result #{30AA}) | 
#{36} (insert tail result #{30AB}) | 
#{37} (insert tail result #{30AD}) | 
#{38} (insert tail result #{30AF}) | 
#{39} (insert tail result #{30B1}) | 
#{3A} (insert tail result #{30B3}) | 
#{3B} (insert tail result #{30B5}) | 
#{3C} (insert tail result #{30B7}) | 
#{3D} (insert tail result #{30B9}) | 
#{3E} (insert tail result #{30BB}) | 
#{3F} (insert tail result #{30BD}) | 
#{40} (insert tail result #{30BF}) | 
#{41} (insert tail result #{30C1}) | 
#{42} (insert tail result #{30C4}) | 
#{43} (insert tail result #{30C6}) | 
#{44} (insert tail result #{30C8}) | 
#{45} (insert tail result #{30CA}) | 
#{46} (insert tail result #{30CB}) | 
#{47} (insert tail result #{30CC}) | 
#{48} (insert tail result #{30CD}) | 
#{49} (insert tail result #{30CE}) | 
#{4A} (insert tail result #{30CF}) | 
#{4B} (insert tail result #{30D2}) | 
#{4C} (insert tail result #{30D5}) | 
#{4D} (insert tail result #{30D8}) | 
#{4E} (insert tail result #{30DB}) | 
#{4F} (insert tail result #{30DE}) | 
#{50} (insert tail result #{30DF}) | 
#{51} (insert tail result #{30E0}) | 
#{52} (insert tail result #{30E1}) | 
#{53} (insert tail result #{30E2}) | 
#{54} (insert tail result #{30E4}) | 
#{55} (insert tail result #{30E6}) | 
#{56} (insert tail result #{30E8}) | 
#{57} (insert tail result #{30E9}) | 
#{58} (insert tail result #{30EA}) | 
#{59} (insert tail result #{30EB}) | 
#{5A} (insert tail result #{30EC}) | 
#{5B} (insert tail result #{30ED}) | 
#{5C} (insert tail result #{30EF}) | 
#{5D} (insert tail result #{30F3}) | 
#{5E} (insert tail result #{309B}) | 
#{5F} (insert tail result #{309C}) | 
copy c 1 skip (insert tail result join #{00} c)
]