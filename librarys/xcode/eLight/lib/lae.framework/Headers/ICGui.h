

#ifndef _ICGUI_H
#define _ICGUI_H

typedef unsigned    char        LXZbyte;
typedef	signed		char		LXZsint8;
typedef	unsigned	char		LXZuint8;
typedef	signed		short		LXZsint16;
typedef	unsigned	short		LXZuint16;
typedef	signed		int		    LXZsint32;
typedef	signed		int		    LXZuint;
typedef	    		int		    LXZfixed;
typedef	unsigned	int	    	LXZuint32;
typedef signed		int  		LXZsint;
typedef unsigned    int         LXZsize_t;
typedef float                   LXZfloat;
//typedef bool                    LXZbool;
typedef	unsigned	int		    LXZHANDLE;

#if defined(_MSC_VER)
typedef unsigned __int64 LXZuint64;
#elif defined(__symbian__)
typedef long long LXZuint64;
#else
#include <stdint.h>
typedef uint64_t LXZuint64;
#endif


typedef LXZuint32  utf32;
typedef LXZuint8   utf8;
typedef LXZuint16  utf16;



typedef enum {uifalse = 0, uitrue} uiboolean;

#ifdef __cplusplus
#define LXZAPI extern "C"
#else
#define LXZAPI extern "C++"
#endif

typedef enum
{		
	SM_WRITE = 0,
	SM_READ,
}ISerialMode;

#ifndef NULL
#ifdef __cplusplus
#define NULL    0
#else
#define NULL    ((void *)0)
#endif
#endif

#define UNUSED(t)


#ifdef WIN32
#ifndef USE_STATIC
#ifdef ICGUIDLL_EXPORTS
#define DLL_CLS //__declspec(dllexport)
#else
#define DLL_CLS //__declspec(dllimport)
#endif
#else
#define DLL_CLS
#endif
#else
#define DLL_CLS
#endif


#define DLL_CLASS DLL_CLS

#ifdef WIN32
#ifndef LXZ_CALL
#  if defined(WIN32) || defined(_WIN32)
#    define LXZ_CALL //__stdcall
#  else
#    define LXZ_CALL
#  endif
#endif
#else
#define LXZ_CALL
#endif

// Export functions from the DLL
#ifndef DLL_FUNCTION_DECL
#  if defined(WIN32) || defined(_WIN32)
#    ifdef ICGUIDLL_EXPORTS
#      define DLL_FUNCTION_DECL //__declspec(dllexport)
#    else
#      define DLL_FUNCTION_DECL
#    endif
#  else
#    define DLL_FUNCTION_DECL
#  endif
#endif


typedef void* uiHWND;
typedef void* uiHMSG;
typedef void* uiHRENDER;
struct DLL_CLASS _LXZPoint{
	int x;
	int y;
};

struct DLL_CLASS _LXZRect{
	int left;
	int top;
	int right;
	int bottom;
};

#define uimin(a,b) (((a) < (b)) ? (a) : (b))
#define uimax(a,b) (((a) > (b)) ? (a) : (b))
#define uiabs(a) ((a<0)?-a:a)

enum
{
	ALIGNED_LEFT   = 0x00,
	ALIGNED_RIGHT  = 0x01,
	ALIGNED_HCENTER= 0x02,
	ALIGNED_TOP    = 0x00,
	ALIGNED_BOTTOM = 0x01,
	ALIGNED_VCENTER= 0x02,
};

struct DLL_CLS LuaCallRet{
	union
	{
		int    i;
		float  f;		
		void*  p;
		const char*  cstr;
	};	
};


struct DLL_CLS LuaEventArg
{
	enum
	{
		ARG_INT = 0,
		ARG_FLOAT,
		ARG_CSTR,
		ARG_USER,		
		ARG_THREAD,
	};

	int t;
	int ref;
	const char* name;

	union
	{
		int    i;
		float  f;		
		void*  p;
		const char*  cstr;
	};	

	void Set(int v) { t = ARG_INT; i=v; ref = -1;}
	void Set(float v) { t = ARG_FLOAT; f=v;  ref = -1;}
	void Set(const char* v, int _ref=-1) { t = ARG_CSTR; cstr=v; ref=_ref;}
	void Setthread(void* v, const char* n, int _ref = -1) { t = ARG_THREAD; p = v;name=n; ref = _ref; }
	void Set(void* v, const char* n, int _ref=-1) { t = ARG_USER; p=v; name=n;  ref=_ref;}
};

class DLL_CLS CLuaArgs
{
	enum{eMaxArgs = 10};
public:
	CLuaArgs(){ index = 0;}
	~CLuaArgs(){;}

	void Push(int i) { LuaEventArg a; a.Set(i);  arrArgs[index]=a; index++;}
	void Push(float i) { LuaEventArg a; a.Set(i); arrArgs[index]=a; index++;}
	void Push(const char* i, int _ref=-1) { LuaEventArg a; a.Set(i, _ref);  arrArgs[index]=a; index++;}
	void Push(void* pData, const char* name, int _ref = -1) { LuaEventArg a; a.Set(pData,name, _ref);  arrArgs[index]=a; index++;}

	int index;
	LuaEventArg arrArgs[eMaxArgs];
};


enum eRender
{
	eOpenGLES = 0,
	eWin32DC,
	eWin32Dx,
};

enum eTexture
{
	TEX_ID_IMAGE=0,
	TEX_ID_OPENGLES,
	TEX_ID_DX9,
};

#ifdef ANDROID
#include <android/log.h>
#define LOGV(...) __android_log_print(ANDROID_LOG_VERBOSE, "Androidapp", __VA_ARGS__)
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG  , "Androidapp", __VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO   , "Androidapp", __VA_ARGS__)
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN   , "Androidapp", __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR  , "Androidapp", __VA_ARGS__)
#else
#define LOGV(...)
#define LOGD(...)
#define LOGI(...)
#define LOGW(...)
#define LOGE(...)

#endif

typedef int (*LXZWindowProc)(uiHWND, const char*,char*,int, uiHWND);

 #include "LUtility.h"

/*
** LXZ-key codes
*/
#define MAX_KEY 256

// key defines
#define LXZKEY_ESCAPE     1
#define LXZKEY_F1         2
#define LXZKEY_F2         3
#define LXZKEY_F3         4
#define LXZKEY_F4         5
#define LXZKEY_F5         6
#define LXZKEY_F6         7
#define LXZKEY_F7         8
#define LXZKEY_F8         9
#define LXZKEY_F9         10
#define LXZKEY_F10        11
#define LXZKEY_F11        12
#define LXZKEY_F12        13
#define LXZKEY_TILDE      14
#define LXZKEY_0          15
#define LXZKEY_1          16
#define LXZKEY_2          17
#define LXZKEY_3          18
#define LXZKEY_4          19
#define LXZKEY_5          20
#define LXZKEY_6          21
#define LXZKEY_7          22
#define LXZKEY_8          23
#define LXZKEY_9          24
#define LXZKEY_MINUS      25
#define LXZKEY_EQUALS     26
#define LXZKEY_BACKSPACE  27
#define LXZKEY_TAB        28
#define LXZKEY_A          29
#define LXZKEY_B          30
#define LXZKEY_C          31
#define LXZKEY_D          32
#define LXZKEY_E          33
#define LXZKEY_F          34
#define LXZKEY_G          35
#define LXZKEY_H          36
#define LXZKEY_I          37
#define LXZKEY_J          38
#define LXZKEY_K          39
#define LXZKEY_L          40
#define LXZKEY_M          41
#define LXZKEY_N          42
#define LXZKEY_O          43
#define LXZKEY_P          44
#define LXZKEY_Q          45
#define LXZKEY_R          46
#define LXZKEY_S          47
#define LXZKEY_T          48
#define LXZKEY_U          49
#define LXZKEY_V          50
#define LXZKEY_W          51
#define LXZKEY_X          52
#define LXZKEY_Y          53
#define LXZKEY_Z          54
#define LXZKEY_SHIFT      55
#define LXZKEY_CTRL       56
#define LXZKEY_ALT        57
#define LXZKEY_SPACE      58
#define LXZKEY_OPENBRACE  59
#define LXZKEY_CLOSEBRACE 60
#define LXZKEY_SEMICOLON  61
#define LXZKEY_APOSTROPHE 62
#define LXZKEY_COMMA      63
#define LXZKEY_PERIOD     64
#define LXZKEY_SLASH      65
#define LXZKEY_BACKSLASH  66
#define LXZKEY_ENTER      67
#define LXZKEY_INSERT     68
#define LXZKEY_DELETE     69
#define LXZKEY_HOME       70
#define LXZKEY_END        71
#define LXZKEY_PAGEUP     72
#define LXZKEY_PAGEDOWN   73
#define LXZKEY_UP         74
#define LXZKEY_RIGHT      75
#define LXZKEY_DOWN       76
#define LXZKEY_LEFT       77

#endif