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
			if(buf[n]==0){
				n+=3;
			} else {
				a = buf[n] << 8; n++;
				buf[n] = asChar((buf[n] << 16) / a); n++;
				buf[n] = asChar((buf[n] << 16) / a); n++;
				buf[n] = asChar((buf[n] << 16) / a);
			}
		}
	  }
