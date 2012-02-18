#include <stdio.h>

#define WINDOWS

#include <windows.h>

     
extern "C" __declspec(dllexport)
      void premultiply(unsigned char *buf, int len)
	  {
		int a;
		int n;

		for (n = 0; n < len; n++) {
			a = buf[n]; n++;
			buf[n] = (unsigned char)((buf[n] * a) / 255); n++;
			buf[n] = (unsigned char)((buf[n] * a) / 255); n++;
			buf[n] = (unsigned char)((buf[n] * a) / 255);;
		}
	  }

