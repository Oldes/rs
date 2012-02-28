#include <stdio.h>

inline unsigned char asChar(unsigned int i)
 {
   return 255 < i ? 255 : i;
 }
     
extern "C" __declspec(dllexport)
      void premultiply(unsigned char *buf, int len)
	  {
		unsigned int a;
		unsigned int n;

		for (n = 0; n < len; n++) {
			a = buf[n]; n++;
			buf[n] = (unsigned char)((buf[n] * a) / 255); n++;
			buf[n] = (unsigned char)((buf[n] * a) / 255); n++;
			buf[n] = (unsigned char)((buf[n] * a) / 255);;
		}
	  }
extern "C" __declspec(dllexport)
      void demultiply(unsigned char *buf, int len)
	  {
		unsigned int a;
		unsigned int n;

		for (n = 0; n < len; n++) {
			a = buf[n]; n++;
			if(a==0){
				n++;
				n++;
			} else {
				a = a << 8;
				buf[n] = asChar((buf[n] << 16) / a); n++;
				buf[n] = asChar((buf[n] << 16) / a); n++;
				buf[n] = asChar((buf[n] << 16) / a);
			}
		}
	  }
