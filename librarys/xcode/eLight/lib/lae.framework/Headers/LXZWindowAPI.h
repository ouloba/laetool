

#ifndef _LXZWindowAPI_H
#define _LXZWindowAPI_H

#include "ICGui.h"

//#include "LXZRect.h"
#include "ILXZAlloc.h"
#include "ILXZCoreCfg.h"

extern "C"{
	/*
	*/
	 uiboolean  LXZWindowIsFocus(uiHWND hWnd);
	 uiHWND     LXZWindowClone(uiHWND hWnd);
	 uiHWND     LXZWindowNew();
	 void       LXZWindowDelete(uiHWND hWnd);
	 uiHWND     LXZWindowGetParent(uiHWND hWnd);
	 void       LXZWindowSetWidth(uiHWND hWnd, int width);
	 int        LXZWindowGetWidth(uiHWND hWnd);
	 void       LXZWindowSetHeight(uiHWND hWnd, int height);
	 int        LXZWindowGetHeight(uiHWND hWnd);
	 void       LXZWindowSetPos(uiHWND hWnd, int x, int y);
	 _LXZPoint   LXZWindowGetPos(uiHWND hWnd);
	 void       LXZWindowSetHotPos(uiHWND hWnd, _LXZPoint& pt, bool screen = false);
	 _LXZPoint   LXZWindowGetHotPos(uiHWND hWnd, bool screen = false);
	 _LXZPoint   LXZWindowGetScreenPos(uiHWND hWnd);
	 void       LXZWindowAddChild(uiHWND hWnd, uiHWND hChild);
	 void       LXZWindowDelChild(uiHWND hWnd, uiHWND hChild);
	 void       LXZWindowDelAllChilds(uiHWND hWnd);
	 int        LXZWindowGetChildCount(uiHWND hWnd);
	 uiHWND     LXZWindowGetICWnd(uiHWND hWnd,const char* nameLst);//parent:child:..
	 uiHWND     LXZWindowGetChild(uiHWND hWnd,const char* name);
	 uiHWND     LXZWindowGetRoot();
	 uiboolean  LXZWindowIsChild(uiHWND hWnd, uiHWND hChild);

	 void       LXZWindowInvalidate(uiHWND hWnd, _LXZRect& rc, uiboolean IsAtonce);
	 uiboolean  LXZWindowIsVisible(uiHWND hWnd);
	 void       LXZWindowShow(uiHWND hWnd);
	 void       LXZWindowHide(uiHWND hWnd);

	 void       LXZWindowSetState(uiHWND hWnd, int nState, uiboolean IsTrigger);
	 int        LXZWindowGetState(uiHWND hWnd);
	 int        LXZWindowGetOldState(uiHWND hWnd);

	 void       LXZWindowLayerTop(uiHWND hWnd, uiHWND hChild);
	 void       LXZWindowLayerUp(uiHWND hWnd, uiHWND hChild);
	 void       LXZWindowLayerDown(uiHWND hWnd, uiHWND hChild);

		_LXZRect   LXZWindowGetRect(uiHWND hWnd);
		_LXZRect   LXZWindowGetFrame(uiHWND hWnd);
		int       LXZWindowGetDepth(uiHWND hWnd);
		int       LXZWindowProcMessage(uiHWND hWnd, const char* cmd, const char* param, int paramLen, uiHWND sender, bool bForce = false);



		uiHWND  LXZWindowHitTest(uiHWND hWnd, int x, int y);

		void         LXZWindowSetName(uiHWND hWnd, const char* name);
		const char*  LXZWindowGetName(uiHWND hWnd);
		const char*  LXZWindowGetClassName(uiHWND hWnd);
		void         LXZWindowSetClassName(uiHWND hWnd, const char* name);

		void  LXZWindowClipChildren(uiHWND hWnd, uiboolean IsCliped);
		uiboolean   LXZWindowIsClipChildren(uiHWND hWnd);

		int     LXZWindowGetChildIndex(uiHWND hWnd);

	// render
		void  LXZWindowRenderLayerUp(uiHWND hWnd, uiHRENDER hIRender);
		void  LXZWindowRenderLayerDown(uiHWND hWnd, uiHRENDER hIRender);
		void  LXZWindowAddRender(uiHWND hWnd, uiHRENDER hIRender);
		void  LXZWindowDelRender(uiHWND hWnd, uiHRENDER hIRender);

		void  LXZWindowOnLoad(uiHWND hWnd);
		void  LXZWindowOnUnload(uiHWND hWnd);

	//
	 void   LXZWindowUpdate(uiHWND hWnd, int delta);
	 void  LXZWindowSetHookProc(LXZWindowProc proc);

	// file
		uiboolean  LXZWindowMgr_LoadFromMemory(char* buf, int len);
		uiboolean  LXZWindowMgr_Load(const char* file_name);
		uiboolean  LXZWindowMgr_Save(const char* file_name);
		void       LXZFileSystem_SetBase(const char* base_dirname);
		void       LXZFileSystem_SetWritePath(const char* write_dirname);

	void  LXZAPI_NewThread(void(*fn)(void* data), void* data);
	void* LXZAPI_GetNowLaeContext();
	void  LXZAPI_AsyncCallback(void(*fnCallFunc)(const char* cmd, void* ctx, void* data),const char* cmd, void* ctx, void* data);

	 void       LXZSystem_SetKeyTransferFunc(LXZuint32(*LocalKeyToLXZKey)(LXZuint32 localKey));
	 void  LXZSystem_Notify(const char* token, const char* param);
	 void  LXZSystem_DelayNotify(const char* token, const char* param, void* ctx = NULL, bool edittool = false);
	 void  LXZSystem_RegisterAPI(const char* token, fnCallSystemAPI fn);
	 fnCallSystemAPI LXZSystem_GetRegisterAPI(const char* token);
	 void  LXZSystem_SetIMESelect(void(*setIMESelect)(int start, int end));
	 void  LXZSystem_setIMEState(void(*setIMEState)(int bOpenIME, const char* textContext));
	 void  LXZSystem_setIMEParamter(void(*setIMEParamter)(int inputMode, int returnMode));

	//
	 void      ICGUIDCSetZOrder(float zorder);
	 float     ICGUIDCGetZOrder();
	 void      ICGUIDCCreate(int w, int h, void* handle, void* param = NULL);
	 void      ICGUIDCResume();
	 void      ICGUIDCInvalidate();

	 int       ICGuiGetSystemDPI();
	 uiboolean ICGuiCheckLanguage();
	 uiboolean ICGuiRun(eRender render, bool bEditMode, const char* cfgName = NULL);
	 int       ICGuiUpdateState();
	 void      ICGuiRender();
	 uiboolean ICGuiDestroy();
	 bool      ICGuiAutoScale();
	 void      ICGuiTransferXY(int& x, int& y);
	 void      ICGuiResume();
	 void      ICGuiPause();
	 const char*  LXZICGuiAppGetValue(const char* mainKey, const char* key);

	 ILXZAlloc* LXZAPI_CreateAlloc();
	 ILXZCoreCfg* LXZAPI_CreateLXZCfg();
	 ILXZCoreCfg* LXZGetCfg();
	 void       LXZOutputDebugStr(const char* str);
	 int        LXZAPI_utf16_to_utf8(const utf16* in, int len, utf8* out, int o_len);
	 int        LXZAPI_utf8_to_utf16(const utf8* in, int len, utf16* out, int o_len);
	 int        LXZAPI_utf8_to_cstring(const utf8* in, int len, char* out, int o_len);
	 int        LXZAPI_utf8_len(const utf8* s, int max_size);

	 //
	 void* LXZAPI_NewContext();
	 
	// root
		uiHWND   LXZWindowMgr_GetRoot();
		void     LXZWindowMgr_SetRoot(uiHWND hRoot);
		uiHWND  LXZWindowMgr_GetLXZWindow(const char* name);

	// update
		void  LXZWindowMgr_Render();

	// mouse event	
	   uiboolean  LXZWindowMgr_OnLClickDown(int x, int y);
		uiboolean  LXZWindowMgr_OnLClickUp(int x, int y);
		uiboolean  LXZWindowMgr_OnLDBClick(int x, int y);
		uiboolean  LXZWindowMgr_OnRClickDown(int x, int y);
		uiboolean  LXZWindowMgr_OnRClickUp(int x, int y);
		uiboolean  LXZWindowMgr_OnRDBClick(int x, int y);
		uiboolean  LXZWindowMgr_OnMouseMove(int x, int y);
		uiboolean  LXZWindowMgr_OnMouseWheel(int x, int y, int delta);

	// key event	
		uiboolean  LXZWindowMgr_OnKeyDown(LXZuint32 u4Key);
		uiboolean  LXZWindowMgr_OnKeyUp(LXZuint32 u4Key);
		uiboolean  LXZWindowMgr_OnChar(LXZuint32 u4Char);

	//
	 int LXZAPI_InvokeFunc(void* pObj, const char* className, const char* func, CLuaArgs& args, LuaCallRet* ret = NULL);

	// timer
	 float LXZAPI_GetDPIScale();
	 LXZuint32 LXZAPI_timeGetTime();       // game time
	 LXZuint32 LXZAPI_timeGetSystemTime(); // system time
	 LXZHANDLE LXZAPI_SetTimer(uiHWND hWnd, const char* transmg, int interval, LXZuint32 count = -1, int delay = 0, uiHMSG msg = NULL);
	 void      LXZAPI_SetTimer1(LXZHANDLE hTimer, int interval, LXZuint32 count);
	 void      LXZAPI_KillTimer(LXZHANDLE hTimer);
	 void      LXZAPI_UpdateTimer(int delta);
	 void      LXZAPI_Download(const char* _url, const char* _local_file, const char* _token, void* luathread, bool edit = false);

	// zip
	 void*      LXZAPI_CreateZip(const char* name, const char* password);
	 void*      LXZAPI_OpenZip(const char* name, const char* password);
	 void       LXZAPI_CloseZip(void* hz);
	 void       LXZAPI_AddZip(void* hz, const char* file);
	 void       LXZAPI_UnZip(void* hz);
	 void       LXZAPI_SetUnzipBaseDir(void* hz, const char* dir);

	// input for simulate or system
	 void LXZAPI_SetSystemInput(uiboolean IsSystemInput);
	 uiboolean LXZAPI_IsSystemInput();

	// frame
	 void LXZAPI_SetSysFrameTime(int frame);
	 int  LXZAPI_GetSystemFrameTime();

	 void LXZAPI_SetFrame(int frame);
	 int  LXZAPI_GetFrame();
	 int  LXZAPI_GetFrameTime();
	 void LXZAPI_SetFrameTime(int time);
	 void LXZAPI_IncrementFrame();

	 void LXZAPI_timeSetPrevTime(LXZuint32 time);
	 LXZuint32 LXZAPI_timeGetPrevTime();
	 void LXZAPI_UpdateTexture(const char* name, RGBA* buf, int w, int h,bool usebuf=false);

	//
	 int GetPrivateUserData(const char* name);
	 void SetPrivateUserData(const char* name, int data);

	//
	 int LXZAPI_RandomInt(int min, int max);
	 void LXZAPI_SetRandomSeed(LXZuint32 seed);
	 LXZuint32 LXZAPI_GetRandomSeed();
}

#endif