package
{

//--------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------
// MD5 component
// v 1.1
// 3/20/2003
//--------------------------------------------------------------------------------------------
// An implementation of the RSA Data Security, Inc. MD5 Message
// Digest Algorithm, as defined in RFC 1321.
// Version 2.1 Copyright (C) Paul Johnston 1999 - 2002.
// Other contributors: Greg Holt, Andrew Kepert, Ydnar, Lostinet
// Distributed under the BSD License
// See http://pajhome.org.uk/crypt/md5 for more info.
//
// Optimized and componentized by Branden J. Hall
// Further optimized by IT GlobalSecure.
// To download the latest version
// or extend security tools for ActionScript, please visit: www.secureplay.com
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------


//
// Configurable variables. You may need to tweak these to be compatible with
// the server-side, but the defaults work in most cases.
//
public class MD5
{
    public function MD5()
    {
    }

    /* hex output format. 0 - lowercase; 1 - uppercase        */
    public var hexcase:Number = 0;
    /* base-64 pad character. "=" for strict RFC compliance   */
    public var b64pad:String  = "";
    /* bits per input character. 8 - ASCII; 16 - Unicode      */
    public var chrsz:Number = 8;  

/*
 * These are the functions you'll usually want to call
 * They take string arguments and return either hex or base-64 encoded strings
 */
public function hex_md5(s:String):String {
return this.binl2hex(this.core_md5(this.str2binl(s), s.length * this.chrsz));
}

public function b64_md5(s:String):String {
return this.binl2b64(this.core_md5(this.str2binl(s), s.length * this.chrsz));
}

public function str_md5(s:String):String {
return this.binl2str(this.core_md5(this.str2binl(s), s.length * this.chrsz));
}

public function hex_hmac_md5(key:String, data:String):String {
return this.binl2hex(this.core_hmac_md5(key, data));
}

public function b64_hmac_md5(key:String, data:String):String {
return this.binl2b64(this.core_hmac_md5(key, data));
}

public function str_hmac_md5(key:String, data:String):String {
return this.binl2str(this.core_hmac_md5(key, data));
}

//
// Perform a simple self-test to see if the VM is working
//
public function md5_vm_test():Boolean{
  return this.hex_md5("abc") == "900150983cd24fb0d6963f7d28e17f72";
}

//
// Calculate the MD5 of an array of little-endian words, and a bit length
//
public function core_md5(x:Array, len:Number):Array{
var olda:Number;
var oldb:Number;
var oldc:Number;
var oldd:Number;

/* append padding */
// x[len >> 5] |= 0x80 << ((len) % 32); // original code
x[len >> 5] |= 0x80 << ((len) & 31); // proposed alternative

x[(((len + 64) >>> 9) << 4) + 14] = len;

var a:Number =  1732584193;
var b:Number = -271733879;
var c:Number = -1732584194;
var d:Number =  271733878;

var max:Number = x.length;
for(var i:Number = 0; i < max; i += 16){
olda = a;
oldb = b;
oldc = c;
oldd = d;

a = this.md5_ff(a, b, c, d, x[i+ 0], 7 , -680876936);
d = this.md5_ff(d, a, b, c, x[i+ 1], 12, -389564586);
c = this.md5_ff(c, d, a, b, x[i+ 2], 17,  606105819);
b = this.md5_ff(b, c, d, a, x[i+ 3], 22, -1044525330);
a = this.md5_ff(a, b, c, d, x[i+ 4], 7 , -176418897);
d = this.md5_ff(d, a, b, c, x[i+ 5], 12,  1200080426);
c = this.md5_ff(c, d, a, b, x[i+ 6], 17, -1473231341);
b = this.md5_ff(b, c, d, a, x[i+ 7], 22, -45705983);
a = this.md5_ff(a, b, c, d, x[i+ 8], 7 ,  1770035416);
d = this.md5_ff(d, a, b, c, x[i+ 9], 12, -1958414417);
c = this.md5_ff(c, d, a, b, x[i+10], 17, -42063);
b = this.md5_ff(b, c, d, a, x[i+11], 22, -1990404162);
a = this.md5_ff(a, b, c, d, x[i+12], 7 ,  1804603682);
d = this.md5_ff(d, a, b, c, x[i+13], 12, -40341101);
c = this.md5_ff(c, d, a, b, x[i+14], 17, -1502002290);
b = this.md5_ff(b, c, d, a, x[i+15], 22,  1236535329);

a = this.md5_gg(a, b, c, d, x[i+ 1], 5 , -165796510);
d = this.md5_gg(d, a, b, c, x[i+ 6], 9 , -1069501632);
c = this.md5_gg(c, d, a, b, x[i+11], 14,  643717713);
b = this.md5_gg(b, c, d, a, x[i+ 0], 20, -373897302);
a = this.md5_gg(a, b, c, d, x[i+ 5], 5 , -701558691);
d = this.md5_gg(d, a, b, c, x[i+10], 9 ,  38016083);
c = this.md5_gg(c, d, a, b, x[i+15], 14, -660478335);
b = this.md5_gg(b, c, d, a, x[i+ 4], 20, -405537848);
a = this.md5_gg(a, b, c, d, x[i+ 9], 5 ,  568446438);
d = this.md5_gg(d, a, b, c, x[i+14], 9 , -1019803690);
c = this.md5_gg(c, d, a, b, x[i+ 3], 14, -187363961);
b = this.md5_gg(b, c, d, a, x[i+ 8], 20,  1163531501);
a = this.md5_gg(a, b, c, d, x[i+13], 5 , -1444681467);
d = this.md5_gg(d, a, b, c, x[i+ 2], 9 , -51403784);
c = this.md5_gg(c, d, a, b, x[i+ 7], 14,  1735328473);
b = this.md5_gg(b, c, d, a, x[i+12], 20, -1926607734);

a = this.md5_hh(a, b, c, d, x[i+ 5], 4 , -378558);
d = this.md5_hh(d, a, b, c, x[i+ 8], 11, -2022574463);
c = this.md5_hh(c, d, a, b, x[i+11], 16,  1839030562);
b = this.md5_hh(b, c, d, a, x[i+14], 23, -35309556);
a = this.md5_hh(a, b, c, d, x[i+ 1], 4 , -1530992060);
d = this.md5_hh(d, a, b, c, x[i+ 4], 11,  1272893353);
c = this.md5_hh(c, d, a, b, x[i+ 7], 16, -155497632);
b = this.md5_hh(b, c, d, a, x[i+10], 23, -1094730640);
a = this.md5_hh(a, b, c, d, x[i+13], 4 ,  681279174);
d = this.md5_hh(d, a, b, c, x[i+ 0], 11, -358537222);
c = this.md5_hh(c, d, a, b, x[i+ 3], 16, -722521979);
b = this.md5_hh(b, c, d, a, x[i+ 6], 23,  76029189);
a = this.md5_hh(a, b, c, d, x[i+ 9], 4 , -640364487);
d = this.md5_hh(d, a, b, c, x[i+12], 11, -421815835);
c = this.md5_hh(c, d, a, b, x[i+15], 16,  530742520);
b = this.md5_hh(b, c, d, a, x[i+ 2], 23, -995338651);

a = this.md5_ii(a, b, c, d, x[i+ 0], 6 , -198630844);
d = this.md5_ii(d, a, b, c, x[i+ 7], 10,  1126891415);
c = this.md5_ii(c, d, a, b, x[i+14], 15, -1416354905);
b = this.md5_ii(b, c, d, a, x[i+ 5], 21, -57434055);
a = this.md5_ii(a, b, c, d, x[i+12], 6 ,  1700485571);
d = this.md5_ii(d, a, b, c, x[i+ 3], 10, -1894986606);
c = this.md5_ii(c, d, a, b, x[i+10], 15, -1051523);
b = this.md5_ii(b, c, d, a, x[i+ 1], 21, -2054922799);
a = this.md5_ii(a, b, c, d, x[i+ 8], 6 ,  1873313359);
d = this.md5_ii(d, a, b, c, x[i+15], 10, -30611744);
c = this.md5_ii(c, d, a, b, x[i+ 6], 15, -1560198380);
b = this.md5_ii(b, c, d, a, x[i+13], 21,  1309151649);
a = this.md5_ii(a, b, c, d, x[i+ 4], 6 , -145523070);
d = this.md5_ii(d, a, b, c, x[i+11], 10, -1120210379);
c = this.md5_ii(c, d, a, b, x[i+ 2], 15,  718787259);
b = this.md5_ii(b, c, d, a, x[i+ 9], 21, -343485551);

a = this.safe_add(a, olda);
b = this.safe_add(b, oldb);
c = this.safe_add(c, oldc);
d = this.safe_add(d, oldd);
}
var result:Array = new Array(a, b, c, d);
return result;

}

//
// These functions implement the four basic operations the algorithm uses.
//


public function md5_cmn(q:Number, a:Number, b:Number, x:Number, s:Number, t:Number):Number{
var result:Number = this.safe_add(this.bit_rol(this.safe_add(this.safe_add(a, q), this.safe_add(x, t)), s),b);
return result;
}

public function md5_ff(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number):Number{
return this.md5_cmn((b & c) | ((~b) & d), a, b, x, s, t);
}

public function md5_gg(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number):Number{
  return this.md5_cmn((b & d) | (c & (~d)), a, b, x, s, t);
}

public function md5_hh(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number):Number{
  return this.md5_cmn(b ^ c ^ d, a, b, x, s, t);
}

public function md5_ii(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number):Number{
  return this.md5_cmn(c ^ (b | (~d)), a, b, x, s, t);
}

//
// Calculate the HMAC-MD5, of a key and some data
//
public function core_hmac_md5(key:String, data:String):Array{
var bkey:Array = this.str2binl(key);
if(bkey.length > 16){
bkey = this.core_md5(bkey, key.length * this.chrsz);
}

var ipad:Array = new Array(16), opad:Array = new Array(16);
for(var i:Number = 0; i < 16; i++){
ipad[i] = bkey[i] ^ 0x36363636;
opad[i] = bkey[i] ^ 0x5C5C5C5C;
}

var hash:Array = this.core_md5(ipad.concat(this.str2binl(data)), 512 + data.length * this.chrsz);
return this.core_md5(opad.concat(hash), 512 + 128);
}

//
// Add integers, wrapping at 2^32. This uses 16-bit operations internally
// to work around bugs in some JS interpreters.
//
// !!! Should validate whether this is necessary for ActionScript

public function safe_add(x:Number, y:Number):Number{
var lsw:Number = (x & 0xFFFF) + (y & 0xFFFF);
var msw:Number = (x >> 16) + (y >> 16) + (lsw >> 16);
return (msw << 16) | (lsw & 0xFFFF);
}

//
// Bitwise rotate a 32-bit number to the left.
//
public function bit_rol(num:Number, cnt:Number):Number {
return (num << cnt) | (num >>> (32 - cnt));
}

//
// Convert a string to an array of little-endian words
// If chrsz is ASCII, characters >255 have their hi-byte silently ignored.
//
public function str2binl(str:String):Array {
var bin:Array = new Array();
var mask:Number = (1 << this.chrsz) - 1;
var max:Number = str.length * this.chrsz;
for(var i:Number = 0; i < max; i += this.chrsz){
// bin[i>>5] |= (str.charCodeAt(i / this.chrsz) & mask) << (i%32); // original code
bin[i>>5] |= (str.charCodeAt(i / this.chrsz) & mask) << (i&31); // proposed optimization
}
return bin;
}

/*
 * Convert an array of little-endian words to a string
 */
public function binl2str(bin:Array):String {
var str:String = "";
var mask:Number = (1 << this.chrsz) - 1;
var max:Number = bin.length * 32
for(var i:Number = 0; i < max; i += this.chrsz){
// str += String.fromCharCode((bin[i>>5] >>> (i % 32)) & mask); // original code
str += String.fromCharCode((bin[i>>5] >>> (i & 31)) & mask); // proposed modification
}
return str;
}

/*
 * Convert an array of little-endian words to a hex string.
 */
public function binl2hex(binarray:Array):String {
var hex_tab:String = this.hexcase ? "0123456789ABCDEF" : "0123456789abcdef";
var str:String = "";
var max:Number = binarray.length * 4;
for(var i:Number = 0; i < max; i++){
/* str += hex_tab.charAt((binarray[i>>2] >> ((i%4)*8+4)) & 0xF) +
hex_tab.charAt((binarray[i>>2] >> ((i%4)*8  )) & 0xF);
*/ // original code
str += hex_tab.charAt((binarray[i>>2] >> ((i&3)*8+4)) & 0xF) +
hex_tab.charAt((binarray[i>>2] >> ((i&3)*8  )) & 0xF); // candidate replacement code
}
return str;
}

/*
 * Convert an array of little-endian words to a base-64 string
 */
public function binl2b64(binarray:Array):String {
var tab:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
var str:String = "";
var max:Number = binarray.length * 4;
var m4x:Number = 4*max;
for(var i:Number = 0; i < max; i += 3){
/* var triplet = (((binarray[i   >> 2] >> 8 * ( i   %4)) & 0xFF) << 16)
| (((binarray[i+1 >> 2] >> 8 * ((i+1)%4)) & 0xFF) << 8 )
|  ((binarray[i+2 >> 2] >> 8 * ((i+2)%4)) & 0xFF);
*/ // original code
var triplet:Number = (((binarray[i   >> 2] >> 8 * ( i &3)) & 0xFF) << 16)
| (((binarray[i+1 >> 2] >> 8 * ((i+1)&3)) & 0xFF) << 8 )
|  ((binarray[i+2 >> 2] >> 8 * ((i+2)&3)) & 0xFF);
}
for(var j:Number = 0; j < 4; j++){
// if(i * 8 + j * 6 > binarray.length * 32){ // original code
if(i * 8 + j * 6 > m4x){
str += this.b64pad;
}else{
str += tab.charAt((triplet >> 6*(3-j)) & 0x3F);
}
}
return str;
}
}
}
