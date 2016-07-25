// uiWin32.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include "LXZWindowAPI.h"
#include "zmouse.h"
#include <MMSYSTEM.H>
#include "WINUSER.H"
#include <stdlib.h>
#include <stdio.h>
#include <Psapi.h>
#pragma comment (lib,"Psapi.lib")
#include <list>
#include "LXZLock.h"
//#include <ObjBase.h>

//#define __STDC_CONSTANT_MACROS

#ifdef WIN32
//#pragma comment(lib,"alut.lib ")
#pragma comment(lib,"OpenAL32.lib")
#endif


void printf_msg(const char* msg){
	MessageBox(NULL, msg, "msg", MB_OK);
}


void toggle_fullscreen(const char* parma, ILXZAlloc* alloc){
	static bool isfullscreen = false;
	static int old_w = 0;
	static int old_h = 0;
	
	ILXZCoreCfg* cfg = LXZGetCfg();
	HWND window = (HWND)cfg->GetObj("HWND", NULL, NULL, NULL);
	uiHWND hRoot = LXZWindowMgr_GetRoot();

	if (old_w == 0){
		old_w=LXZWindowGetWidth(hRoot);
		old_h = LXZWindowGetHeight(hRoot);
	}

	if (!isfullscreen){
		isfullscreen = true;
		int scrWidth, scrHeight;
		RECT rect;
		scrWidth = GetSystemMetrics(SM_CXSCREEN);
		scrHeight = GetSystemMetrics(SM_CYSCREEN);
		int w = scrWidth;
		int h = scrHeight;
		//GetWindowRect(window, &rect);
		rect.left = (scrWidth - w) / 2;
		rect.top = (scrHeight - h) / 2;
		rect.right = rect.left + w;
		rect.bottom = rect.top + h;
		//移动窗口到指定的位置
		//SetWindowPos(window, HWND_TOPMOST, rect.left, rect.top, rect.right, rect.bottom, SWP_SHOWWINDOW);
		MoveWindow(window, rect.left, rect.top, w, h, TRUE);
		cfg->SetInt("nScreenHeight", NULL, h);
		cfg->SetInt("nScreenWidth", NULL, w);
		LXZWindowSetHeight(hRoot, h);
		LXZWindowSetWidth(hRoot, w);
		ICGUIDCCreate(w, h, window);
	}
	else{
		isfullscreen = false;
		int scrWidth, scrHeight;
		RECT rect;
		scrWidth = GetSystemMetrics(SM_CXSCREEN);
		scrHeight = GetSystemMetrics(SM_CYSCREEN);
		int w = old_w;
		int h = old_h;
		//GetWindowRect(window, &rect);
		rect.left = (scrWidth - w) / 2;
		rect.top = (scrHeight - h) / 2;
		rect.right = rect.left + w;
		rect.bottom = rect.top + h;
		//移动窗口到指定的位置
		//SetWindowPos(window, HWND_TOPMOST, rect.left, rect.top, rect.right, rect.bottom, SWP_SHOWWINDOW);
		MoveWindow(window, rect.left, rect.top, w, h, TRUE);
		cfg->SetInt("nScreenHeight", NULL, h);
		cfg->SetInt("nScreenWidth", NULL, w);
		LXZWindowSetHeight(hRoot, h);
		LXZWindowSetWidth(hRoot, w);
		ICGUIDCCreate(w, h, window);
	}
}

//LXZAPI_UpdateTexture("___destop", buf, _destop.GetWidht(), _destop.GetHeight());
extern "C" LXZuint32 Win32KeyToLXZKey(LXZuint32 wkey);
static LRESULT CALLBACK LXZGuiProc(HWND window,
	UINT msg,
	WPARAM wParam,
	LPARAM lParam)
{
	// root
	uiHWND hRoot = LXZWindowMgr_GetRoot();

	switch (msg)
	{
		case WM_CLOSE:
		{
			PostQuitMessage(0);
			DestroyWindow(window);
			break;
		}
		case WM_CREATE:
		{
		int scrWidth, scrHeight;
		RECT rect;
		scrWidth = GetSystemMetrics(SM_CXSCREEN);
		scrHeight = GetSystemMetrics(SM_CYSCREEN);
		GetWindowRect(window, &rect);
		rect.left = (scrWidth - rect.right) / 2;
		rect.top = (scrHeight - rect.bottom) / 2;
		//移动窗口到指定的位置
		SetWindowPos(window, HWND_TOP, rect.left, rect.top, rect.right, rect.bottom, SWP_SHOWWINDOW);

		/*

		ILXZCoreCfg* cfg = LXZGetCfg();
		uiHWND hRoot = LXZWindowMgr_GetRoot();
		int w = LXZWindow_GetWidth(hRoot);
		int h = LXZWindow_GetHeight(hRoot);

		char buf[1024] = {0};
		sprintf(buf,"ScreenW:%d ScreenH:%d ScaleX:%f ScaleY:%f nOffsetX:%d nOffsetY:%d w:%d h:%d\r\n",
		cfg->nScreenWidth,
		cfg->nScreenHeight,
		cfg->fAutoScaleX,
		cfg->fAutoScaleY,
		cfg->nAutoOffsetX,
		cfg->nAutoOffsetY,
		w,
		h);

		MessageBox(NULL, buf, "log", MB_OK);*/
		}
		break;
	case (WM_USER + 300) :
		{
		 ICGuiRender();
		 break;
		}
	case WM_ERASEBKGND:
		//DefWindowProc(window, msg, wParam, lParam);
		return TRUE;
		break;
	case WM_CAPTURECHANGED:
		{
		}
		break;
	case WM_MOVE:
		{
		}
		break;
	case WM_PAINT:
		{
			RECT rect;
			if (GetUpdateRect(window, &rect, FALSE) == TRUE)
			{
				_LXZRect rc;
				//COPY_RECT(rc, rect);
				rc.left = rect.left;
				rc.top = rect.top;
				rc.right = rect.right;
				rc.bottom = rect.bottom;
				LXZWindowInvalidate(hRoot, rc, uitrue);
				ICGUIDCInvalidate();
			}
			break;
		}
	case WM_SIZE:
		{
			static bool bPause = false;
			switch (wParam)
			{
			case SIZE_RESTORED:
				{
					int w = LOWORD(lParam);
					int h = HIWORD(lParam);
					ILXZCoreCfg* cfg = LXZGetCfg();
					if (bPause)
					{
						bPause = false;
						ICGUIDCResume();
						ICGUIDCCreate(w, h, window);
						ICGuiResume();
					}
					else
					{
						ICGUIDCCreate(w, h, window);
					}
				}
				break;
			case SIZE_MINIMIZED:
				{
								//		bPause = true;
								//		ICGuiPause();
								//	   SC_MINIMIZE
				}
				break;
			default:
				{
					static LXZuint32 time_ = 0;
					if (LXZAPI_timeGetSystemTime() > time_ + 1000){
						time_ = LXZAPI_timeGetSystemTime();
						uiHWND hRoot = LXZWindowMgr_GetRoot();
						ILXZCoreCfg* cfg = LXZGetCfg();
						int w = LOWORD(lParam);
						int h = HIWORD(lParam);
						int scrWidth, scrHeight;
						RECT rect;
						scrWidth = GetSystemMetrics(SM_CXSCREEN);
						scrHeight = GetSystemMetrics(SM_CYSCREEN);
						//GetWindowRect(window, &rect);
						rect.left = (scrWidth - w) / 2;
						rect.top = (scrHeight - h) / 2;
						rect.right = rect.left + w;
						rect.bottom = rect.top + h;
						//移动窗口到指定的位置
						//SetWindowPos(window, HWND_TOPMOST, rect.left, rect.top, rect.right, rect.bottom, SWP_SHOWWINDOW);
						MoveWindow(window, rect.left, rect.top, w, h, TRUE);
						cfg->SetInt("nScreenHeight", NULL, h);
						cfg->SetInt("nScreenWidth", NULL, w);
						LXZWindowSetHeight(hRoot, h);
						LXZWindowSetWidth(hRoot, w);
						ICGUIDCCreate(w, h, window);
					}
				}
				break;
			//	return 0;
			}

		break;
		}
	case WM_LBUTTONDOWN:
		{
			int x = LOWORD(lParam);
			int y = HIWORD(lParam);
			LXZWindowMgr_OnLClickDown(x, y);
			break;
		}
	case WM_LBUTTONUP:
		{
			int x = LOWORD(lParam);
			int y = HIWORD(lParam);
			LXZWindowMgr_OnLClickUp(x, y);

			//
			/*	static int ref = -1;
			CLuaArgs args;
			LuaCallRet ret;
			uiHWND hRoot = LXZWindowMgr_GetRoot();
			LXZAPI_RunObjFunc(hRoot,"CLXZWindow", ref,"GetWidth",args,&ret);

			char buf[32];
			sprintf(buf, "width=%d", ret.i);
			MessageBox(NULL, buf, "Width", MB_OK);*/

			//
			break;
		}
	case WM_LBUTTONDBLCLK:
		{
			int x = LOWORD(lParam);
			int y = HIWORD(lParam);
			LXZWindowMgr_OnLDBClick(x, y);
			break;
		}
	case WM_RBUTTONDOWN:
		{
			int x = LOWORD(lParam);
			int y = HIWORD(lParam);
			LXZWindowMgr_OnRClickDown(x, y);
			break;
		}
	case WM_RBUTTONUP:
		{
			int x = LOWORD(lParam);
			int y = HIWORD(lParam);
			LXZWindowMgr_OnRClickUp(x, y);
			break;
		}
	case WM_RBUTTONDBLCLK:
		{
			int x = LOWORD(lParam);
			int y = HIWORD(lParam);
			LXZWindowMgr_OnRDBClick(x, y);
			break;
		}
	case WM_MOUSEMOVE:
		{
			int x = LOWORD(lParam);
			int y = HIWORD(lParam);
			LXZWindowMgr_OnMouseMove(x, y);
			break;
		}
	case WM_MOUSEWHEEL:
		{
			int x = LOWORD(lParam);
			int y = HIWORD(lParam);
			LXZWindowMgr_OnMouseWheel(x, y, wParam);
			break;
		}
	case WM_KEYDOWN:
		{
			LXZWindowMgr_OnKeyDown(wParam);
			break;
		}
	case WM_KEYUP:
		{
			LXZWindowMgr_OnKeyUp(wParam);
			break;
		}
	case WM_CHAR:
		{
			LXZWindowMgr_OnChar(wParam);
			break;
		}
	default:
		return DefWindowProc(window, msg, wParam, lParam);
	}

	return DefWindowProc(window, msg, wParam, lParam);
}



extern void ccPlay(const char* param, ILXZAlloc* strResult);
extern  void ccSeekpos(const char* param, ILXZAlloc* strResult);
extern  void ccResume(const char* param, ILXZAlloc* strResult);
extern  void ccPause(const char* param, ILXZAlloc* strResult);

extern  void ccSkipNext(const char* param, ILXZAlloc* strResult);
extern  void ccSkipBack(const char* param, ILXZAlloc* strResult);
extern  void ccMaxSize(const char* param, ILXZAlloc* strResult);
extern  void ccMutex(const char* param, ILXZAlloc* strResult);
extern  void ccSetVolume(const char* param, ILXZAlloc* strResult);


template<typename T, typename U>
void assign(T& dest, U src)
{
	dest = (T&)src;
}

int APIENTRY WinMain(HINSTANCE hInstance,
	HINSTANCE hPrevInstance,
	LPSTR     lpCmdLine,
	int       nCmdShow)
{
	//::CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);
	// Load  resource
	//LoadIcon(GetModuleHandle(NULL), MAKEINTRESOURCE(IDR_MAINFRAME));
	HCURSOR hArrow = LoadCursor(NULL, IDC_ARROW);
	SetCursor(hArrow);

	//
	int w = 0;
	int h = 0;

	int iscaption = -1;
	int len = strlen(lpCmdLine);
	ILXZCoreCfg* cfg = LXZGetCfg();
	if (len>3)
	{
		int island = 0;
		char* szDebugUI = new char[len + 1];
		memset(szDebugUI, 0x00, len + 1);
		sscanf(lpCmdLine, "%s %dx%d %d %d", szDebugUI, &w, &h, &island, &iscaption);

		char szTmp[256];
		char fileName[1024];
		char szBasePath[1024] = { 0 };
		GetModuleFileName(NULL, fileName, MAX_PATH);
		_splitpath(szDebugUI, szBasePath, szTmp, NULL, NULL);
		strcat(szBasePath, szTmp);
		LXZFileSystem_SetBase(szBasePath);

		//ILXZCoreCfg* cfg = LXZGetCfg();
		if (island == 0)
		{
			cfg->SetInt("nScreenHeight", NULL, h);
			cfg->SetInt("nScreenWidth", NULL, w);
		}
		else
		{
			cfg->SetInt("nScreenHeight", NULL, w);
			cfg->SetInt("nScreenWidth", NULL, h);
		}

		//	strcpy(szDebugUI, lpCmdLine);
		cfg->SetCString("DebugUI", NULL, (const char*)szDebugUI);
		cfg->SetInt("nDPI", NULL, ICGuiGetSystemDPI());

		//char buf[256];
		//sprintf(buf, "%s, %d, %d", szDebugUI, w, iscaption);
		//MessageBox(NULL, buf, "log", MB_OK);

		//
		if (iscaption == 1){
			SetCfgBool(notcaption, false);
		}
		else{
			SetCfgBool(notcaption, true);
		}
	}

	//	
	HANDLE hProcess = ::GetCurrentProcess();
	TCHAR* procName = new TCHAR[MAX_PATH];
	memset(procName, 0x00, sizeof(TCHAR)*MAX_PATH);
	GetProcessImageFileName(hProcess, procName, MAX_PATH);
	int  s = strlen(procName);
	s--;
	while (s > 0){
		if (procName[s] == '\\' || procName[s] == '/'){
			break;
		}

		s--;
	}

	//
	char* shortName = new TCHAR[MAX_PATH]; //[MAX_PATH] = { 0 };
	memset(shortName, 0x00, sizeof(TCHAR)*MAX_PATH);
	memcpy(shortName, &procName[s + 1], strlen(&procName[s + 1]) - 4);
	//MessageBox(NULL, shortName, "log", MB_OK);

	char iconfile[256] = { 0 };
	strcpy(iconfile, shortName);
	strcat(iconfile, ".ico");

	//
	HICON hIcon = (HICON)LoadImage( // returns a HANDLE so we have to cast to HICON
		NULL,             // hInstance must be NULL when loading from a file
		iconfile,         // the icon file name
		IMAGE_ICON,       // specifies that the file is an icon
		0,                // width of the image (we'll specify default later on)
		0,                // height of the image
		LR_LOADFROMFILE |  // we want to load a file (as opposed to a resource) LR_DEFAULTSIZE |   // default metrics based on the type (IMAGE_ICON, 32x32)		
		LR_SHARED         // let the system release the handle when it's no longer used
		);

	// register the window class
	WNDCLASSEX wc;
	wc.cbSize = sizeof(WNDCLASSEX);
	wc.style = CS_HREDRAW | CS_VREDRAW | CS_DBLCLKS | CS_OWNDC;
	wc.lpfnWndProc = LXZGuiProc;
	wc.cbClsExtra = 0;
	wc.cbWndExtra = 0;
	wc.hInstance = GetModuleHandle(NULL);;
	wc.hIcon = hIcon;
	wc.hCursor = hArrow;
	wc.hbrBackground = NULL;
	wc.lpszMenuName = NULL;
	wc.lpszClassName = "LXZGame";
	wc.hIconSm = hIcon;

	if (RegisterClassEx(&wc) == 0)
	{
		MessageBox(NULL, "Error: Could not register the window class", "Engulf", MB_OK);
		return 0;
	}

	GetCfgInt(xxnScreenWidth, nScreenWidth);
	GetCfgInt(xxnScreenHeight, nScreenHeight);

	if (strcmp(shortName, "LXZWin32R") == 0){
		ICGuiRun(eOpenGLES, false, "default.cfg");
	}
	else{
		char cfg_name[MAX_PATH];
		strcpy(cfg_name, shortName);
		strcat(cfg_name, ".cfg");
		ICGuiRun(eOpenGLES, false, cfg_name);
	}

	LXZAPI_SetFrameTime(10);
	LXZOutputDebugStr("RegisterClass Success!\r\n");

	uiHWND hRoot = LXZWindowMgr_GetRoot();
	//	ILXZCoreCfg* cfg = LXZGetCfg();
	SetCfgBool(IsAutoScale, true);
	//GetCfgInt(_xnScreenHeight, nScreenHeight);
	if (xxnScreenWidth <= 0)
	{
		float fScale = LXZAPI_GetDPIScale();
		cfg->SetInt("nScreenHeight", NULL, LXZWindowGetHeight(hRoot)*fScale);
		cfg->SetInt("nScreenWidth", NULL, LXZWindowGetWidth(hRoot)*fScale);
	}

	//
	LXZSystem_RegisterAPI("Play", ccPlay);
	LXZSystem_RegisterAPI("Pause", ccPause);
	LXZSystem_RegisterAPI("seekpos", ccSeekpos);
	LXZSystem_RegisterAPI("Resume", ccResume);

	LXZSystem_RegisterAPI("skipfront", ccSkipNext);
	LXZSystem_RegisterAPI("skipback", ccSkipBack);	
	LXZSystem_RegisterAPI("toggle_muted", ccMutex);
	LXZSystem_RegisterAPI("volume", ccSetVolume);
	LXZSystem_RegisterAPI("toggle_fullscreen", toggle_fullscreen);
	
	

	GetCfgBool(notcaption, notcaption);
	//char buf[256];
	//sprintf(buf, "%d, %d", notcaption, iscaption);
	//MessageBox(NULL, buf, "log", MB_OK);

	DWORD style = WS_POPUP;
	if (iscaption == -1){
		if (!notcaption){
			style = WS_CAPTION | WS_POPUPWINDOW | WS_MINIMIZEBOX;
		}
		else if (notcaption){
			iscaption = 0;
		}
	}
	else{
		if (iscaption){
			style = WS_CAPTION | WS_POPUPWINDOW | WS_MINIMIZEBOX;
		}
	}

	// create the game window
	//GetCfgInt(nScreenWidth, nScreenWidth);
	int nScreenWidth = cfg->GetInt("nScreenWidth", NULL);
	int nScreenHeight = cfg->GetInt("nScreenHeight", NULL);
	HWND hWnd = CreateWindowEx(WS_EX_APPWINDOW | WS_EX_WINDOWEDGE,
		"LXZGame",
		shortName,
		style,
		CW_USEDEFAULT,
		0,
		(iscaption == 1) ? nScreenWidth + 8 : nScreenWidth,
		(iscaption == 1) ? nScreenHeight + 30 : nScreenHeight,
		NULL,
		NULL,
		GetModuleHandle(NULL),
		NULL);


	HWND hDesktop = GetDesktopWindow();
	LXZWindowOnLoad(hRoot);
	ICGuiAutoScale();
	ICGuiCheckLanguage();

	//
	LXZSystem_SetKeyTransferFunc(Win32KeyToLXZKey);

	SetForegroundWindow(hWnd);
	SetFocus(hWnd);
	SetTimer(hWnd, WM_TIMER, 60, NULL);
	SetCfgObj(hwnd, hWnd);
	SetCfgBool(IsBlendDestop, false);
	
	while (TRUE)
	{
		MSG		msg;
		if (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
		{
			if (msg.message == WM_QUIT)
				break;

			TranslateMessage(&msg);
			DispatchMessage(&msg);
			continue;
		}
		else
		{
			ICGuiUpdateState();
			Sleep(2);
		}
	}

	ICGuiDestroy();

	return 0;
}



