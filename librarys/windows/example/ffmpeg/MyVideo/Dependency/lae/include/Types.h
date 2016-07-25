#ifndef CORONA_TYPES_H
#define CORONA_TYPES_H



	// VC++-specific types
#ifdef _MSC_VER

	typedef unsigned char    byte;
	typedef unsigned __int16 u16;
	typedef unsigned __int32 u32;

	// reasonable defaults
	// should work on any 32-bit platform
#else

	typedef unsigned char  byte;
	typedef unsigned short u16;
	typedef unsigned long  u32;

#endif

namespace LXZCore{
	/**
	  * File formats supported for reading or writing.
	  */
	enum FileFormat {
		FF_AUTODETECT = 0x0100,
		FF_PNG = 0x0101,
		FF_JPEG = 0x0102,
		FF_PCX = 0x0103,
		FF_BMP = 0x0104,
		FF_TGA = 0x0105,
		FF_GIF = 0x0106,
	};

	/**
	 * Pixel format specifications.  Pixel data can be packed in one of
	 * the following ways.
	 */
	enum PixelFormat {
		PF_DONTCARE = 0x0200,  /**< special format used when specifying a
									desired pixel format */
									PF_R8G8B8A8 = 0x0201,  /**< RGBA, channels have eight bits of precision */
									PF_R8G8B8 = 0x0202,  /**< RGB, channels have eight bits of precision  */
									PF_I8 = 0x0203,  /**< Palettized, 8-bit indices into palette      */
									PF_B8G8R8A8 = 0x0204,  /**< BGRA, channels have eight bits of precision */
									PF_B8G8R8 = 0x0205,  /**< BGR, channels have eight bits of precision  */
	};

	/**
	 * Axis specifications.  The image can be flipped along the following
	 * axes.
	 */
	enum CoordinateAxis {
		CA_X = 0x0001,
		CA_Y = 0x0002,
	};
}

#endif
