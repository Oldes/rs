; JIS_X0201 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/JIS_X0201
any [
#{5C} (insert tail result #{00A5}) | 
#{7E} (insert tail result #{203E}) | 
#{A1} (insert tail result #{3002}) | 
#{A2} (insert tail result #{300C}) | 
#{A3} (insert tail result #{300D}) | 
#{A4} (insert tail result #{3001}) | 
#{A5} (insert tail result #{30FB}) | 
#{A6} (insert tail result #{30F2}) | 
#{A7} (insert tail result #{30A1}) | 
#{A8} (insert tail result #{30A3}) | 
#{A9} (insert tail result #{30A5}) | 
#{AA} (insert tail result #{30A7}) | 
#{AB} (insert tail result #{30A9}) | 
#{AC} (insert tail result #{30E3}) | 
#{AD} (insert tail result #{30E5}) | 
#{AE} (insert tail result #{30E7}) | 
#{AF} (insert tail result #{30C3}) | 
#{B0} (insert tail result #{30FC}) | 
#{B1} (insert tail result #{30A2}) | 
#{B2} (insert tail result #{30A4}) | 
#{B3} (insert tail result #{30A6}) | 
#{B4} (insert tail result #{30A8}) | 
#{B5} (insert tail result #{30AA}) | 
#{B6} (insert tail result #{30AB}) | 
#{B7} (insert tail result #{30AD}) | 
#{B8} (insert tail result #{30AF}) | 
#{B9} (insert tail result #{30B1}) | 
#{BA} (insert tail result #{30B3}) | 
#{BB} (insert tail result #{30B5}) | 
#{BC} (insert tail result #{30B7}) | 
#{BD} (insert tail result #{30B9}) | 
#{BE} (insert tail result #{30BB}) | 
#{BF} (insert tail result #{30BD}) | 
#{C0} (insert tail result #{30BF}) | 
#{C2} (insert tail result #{30C4}) | 
#{C3} (insert tail result #{30C6}) | 
#{C4} (insert tail result #{30C8}) | 
#{C5} (insert tail result #{30CA}) | 
#{C6} (insert tail result #{30CB}) | 
#{C7} (insert tail result #{30CC}) | 
#{C8} (insert tail result #{30CD}) | 
#{C9} (insert tail result #{30CE}) | 
#{CA} (insert tail result #{30CF}) | 
#{CB} (insert tail result #{30D2}) | 
#{CC} (insert tail result #{30D5}) | 
#{CD} (insert tail result #{30D8}) | 
#{CE} (insert tail result #{30DB}) | 
#{CF} (insert tail result #{30DE}) | 
#{D0} (insert tail result #{30DF}) | 
#{D1} (insert tail result #{30E0}) | 
#{D2} (insert tail result #{30E1}) | 
#{D3} (insert tail result #{30E2}) | 
#{D4} (insert tail result #{30E4}) | 
#{D5} (insert tail result #{30E6}) | 
#{D6} (insert tail result #{30E8}) | 
#{D7} (insert tail result #{30E9}) | 
#{D8} (insert tail result #{30EA}) | 
#{D9} (insert tail result #{30EB}) | 
#{DA} (insert tail result #{30EC}) | 
#{DB} (insert tail result #{30ED}) | 
#{DC} (insert tail result #{30EF}) | 
#{DD} (insert tail result #{30F3}) | 
#{DE} (insert tail result #{309B}) | 
#{DF} (insert tail result #{309C}) | 
copy c 1 skip (insert tail result join #{00} c)
]