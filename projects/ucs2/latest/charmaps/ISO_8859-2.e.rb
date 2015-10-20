; ISO_8859-2 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ISO_8859-2
; created: 13-Oct-2003/10:23:16+2:00
any [
#{A1} (insert tail result #{0104}) | ; LATIN CAPITAL LETTER A WITH OGONEK
#{A2} (insert tail result #{02D8}) | ; BREVE
#{A3} (insert tail result #{0141}) | ; LATIN CAPITAL LETTER L WITH STROKE
#{A5} (insert tail result #{013D}) | ; LATIN CAPITAL LETTER L WITH CARON
#{A6} (insert tail result #{015A}) | ; LATIN CAPITAL LETTER S WITH ACUTE
#{A9} (insert tail result #{0160}) | ; LATIN CAPITAL LETTER S WITH CARON
#{AA} (insert tail result #{015E}) | ; LATIN CAPITAL LETTER S WITH CEDILLA
#{AB} (insert tail result #{0164}) | ; LATIN CAPITAL LETTER T WITH CARON
#{AC} (insert tail result #{0179}) | ; LATIN CAPITAL LETTER Z WITH ACUTE
#{AE} (insert tail result #{017D}) | ; LATIN CAPITAL LETTER Z WITH CARON
#{AF} (insert tail result #{017B}) | ; LATIN CAPITAL LETTER Z WITH DOT ABOVE
#{B1} (insert tail result #{0105}) | ; LATIN SMALL LETTER A WITH OGONEK
#{B2} (insert tail result #{02DB}) | ; OGONEK
#{B3} (insert tail result #{0142}) | ; LATIN SMALL LETTER L WITH STROKE
#{B5} (insert tail result #{013E}) | ; LATIN SMALL LETTER L WITH CARON
#{B6} (insert tail result #{015B}) | ; LATIN SMALL LETTER S WITH ACUTE
#{B7} (insert tail result #{02C7}) | ; CARON (Mandarin Chinese third tone)
#{B9} (insert tail result #{0161}) | ; LATIN SMALL LETTER S WITH CARON
#{BA} (insert tail result #{015F}) | ; LATIN SMALL LETTER S WITH CEDILLA
#{BB} (insert tail result #{0165}) | ; LATIN SMALL LETTER T WITH CARON
#{BC} (insert tail result #{017A}) | ; LATIN SMALL LETTER Z WITH ACUTE
#{BD} (insert tail result #{02DD}) | ; DOUBLE ACUTE ACCENT
#{BE} (insert tail result #{017E}) | ; LATIN SMALL LETTER Z WITH CARON
#{BF} (insert tail result #{017C}) | ; LATIN SMALL LETTER Z WITH DOT ABOVE
#{C0} (insert tail result #{0154}) | ; LATIN CAPITAL LETTER R WITH ACUTE
#{C3} (insert tail result #{0102}) | ; LATIN CAPITAL LETTER A WITH BREVE
#{C5} (insert tail result #{0139}) | ; LATIN CAPITAL LETTER L WITH ACUTE
#{C6} (insert tail result #{0106}) | ; LATIN CAPITAL LETTER C WITH ACUTE
#{C8} (insert tail result #{010C}) | ; LATIN CAPITAL LETTER C WITH CARON
#{CA} (insert tail result #{0118}) | ; LATIN CAPITAL LETTER E WITH OGONEK
#{CC} (insert tail result #{011A}) | ; LATIN CAPITAL LETTER E WITH CARON
#{CF} (insert tail result #{010E}) | ; LATIN CAPITAL LETTER D WITH CARON
#{D0} (insert tail result #{0110}) | ; LATIN CAPITAL LETTER D WITH STROKE
#{D1} (insert tail result #{0143}) | ; LATIN CAPITAL LETTER N WITH ACUTE
#{D2} (insert tail result #{0147}) | ; LATIN CAPITAL LETTER N WITH CARON
#{D5} (insert tail result #{0150}) | ; LATIN CAPITAL LETTER O WITH DOUBLE ACUTE
#{D8} (insert tail result #{0158}) | ; LATIN CAPITAL LETTER R WITH CARON
#{D9} (insert tail result #{016E}) | ; LATIN CAPITAL LETTER U WITH RING ABOVE
#{DB} (insert tail result #{0170}) | ; LATIN CAPITAL LETTER U WITH DOUBLE ACUTE
#{DE} (insert tail result #{0162}) | ; LATIN CAPITAL LETTER T WITH CEDILLA
#{E0} (insert tail result #{0155}) | ; LATIN SMALL LETTER R WITH ACUTE
#{E3} (insert tail result #{0103}) | ; LATIN SMALL LETTER A WITH BREVE
#{E5} (insert tail result #{013A}) | ; LATIN SMALL LETTER L WITH ACUTE
#{E6} (insert tail result #{0107}) | ; LATIN SMALL LETTER C WITH ACUTE
#{E8} (insert tail result #{010D}) | ; LATIN SMALL LETTER C WITH CARON
#{EA} (insert tail result #{0119}) | ; LATIN SMALL LETTER E WITH OGONEK
#{EC} (insert tail result #{011B}) | ; LATIN SMALL LETTER E WITH CARON
#{EF} (insert tail result #{010F}) | ; LATIN SMALL LETTER D WITH CARON
#{F0} (insert tail result #{0111}) | ; LATIN SMALL LETTER D WITH STROKE
#{F1} (insert tail result #{0144}) | ; LATIN SMALL LETTER N WITH ACUTE
#{F2} (insert tail result #{0148}) | ; LATIN SMALL LETTER N WITH CARON
#{F5} (insert tail result #{0151}) | ; LATIN SMALL LETTER O WITH DOUBLE ACUTE
#{F8} (insert tail result #{0159}) | ; LATIN SMALL LETTER R WITH CARON
#{F9} (insert tail result #{016F}) | ; LATIN SMALL LETTER U WITH RING ABOVE
#{FB} (insert tail result #{0171}) | ; LATIN SMALL LETTER U WITH DOUBLE ACUTE
#{FE} (insert tail result #{0163}) | ; LATIN SMALL LETTER T WITH CEDILLA
#{FF} (insert tail result #{02D9}) | ; DOT ABOVE (Mandarin Chinese light tone)
copy c 1 skip (insert tail result join #{00} c)
]