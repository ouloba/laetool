#ifndef CORONA_UTILITY_H
#define CORONA_UTILITY_H

#include "Types.h"



// DLLs in Windows should use the standard calling convention
#ifndef COR_CALL
#  if defined(WIN32) || defined(_WIN32)
#    define COR_CALL __stdcall
#  else
#    define COR_CALL
#  endif
#endif

// Export functions from the DLL
#ifndef COR_DECL
#  if defined(WIN32) || defined(_WIN32)
#    ifdef CORONA_EXPORTS
#      define COR_DECL __declspec(dllexport)
#    else
#      define COR_DECL
#    endif
#  else
#    define COR_DECL
#  endif
#endif


// evil "identifier is too long in debug information" warning
#ifdef _MSC_VER
#pragma warning(disable : 4786)
#endif

#define COR_FUNCTION(ret) extern "C" COR_DECL ret COR_CALL
#define COR_EXPORT(ret)  COR_FUNCTION(ret)

#pragma pack(push,1)
   struct RGB {
    byte red;
    byte green;
    byte blue;
  };
#pragma pack(pop)

 #pragma pack(push,1)
  struct RGBA {
    byte red;
    byte green;
    byte blue;
    byte alpha;
  };
#pragma pack(pop)

#pragma pack(push,1)
  struct BGR {
    byte blue;
    byte green;
    byte red;
  };
#pragma pack(pop)

#pragma pack(push,1)
  struct BGRA {
    byte blue;
    byte green;
    byte red;
    byte alpha;
  };
#pragma pack(pop)

#endif
