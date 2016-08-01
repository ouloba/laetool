
#ifndef _ILXZCORE_CFG_H
#define _ILXZCORE_CFG_H

#include "ICGui.h"

struct CfgRef{
	int nFixedDelta;
	int dt;
	int t0;
	int IsProfile;
	int language;
	int nDPI;
	int IsClickDown;
	int nClickDownX;
	int nClickDownY;
	int nCurrentX;
	int nCurrentY;
	int nUserSaveX;
	int nUserSaveY;
	int nMoveSum;
	int nClickDownTime;
	int IsAutoScale;	
	int nScreenHeight;
	int nScreenWeight;
	int nScreenWidth;
	int DefaultLanguage;
	int IsNotActive;
	int IsEditTool;
	int fAutoScaleY;
	int fAutoScaleX;
	int nAutoOffsetX;
	int nAutoOffsetY;
	int IsRemoteDebug;
	int IsNotUpdate;
	int hwnd;
	int IsBlendDestop;
	int notcaption;
	int locale;
	int nLongClickTime;
	int IsDebuging;
	int landscape;
	int nWinDPI;
	int DebugUI;
	int version;
	int remote_debug_ref;
};

struct ILXZCoreCfg
{	
	virtual bool GetSaveFlag(int ref)=0;
	virtual void SetSaveFlag(int ref, bool IsCanBeSaved)=0;
	virtual int   Ref(const char* name, const char* alias=NULL) = 0;
	virtual void* GetObj(const char*name, int* ref, const char* alias = NULL, void* def = NULL) = 0;
	virtual void* SetObj(const char*name, int* ref,void* v) = 0;
	virtual float GetFloat(const char*name, int* ref, const char* alias = NULL, float def = 0.0f) = 0;
	virtual int   GetInt(const char*name, int* ref, const char* alias = NULL, int def = 0) = 0;
	virtual unsigned int  GetUint(const char*name, int* ref, const char* alias = NULL, unsigned int def = 0) = 0;
	virtual unsigned int  SetUint(const char*name, int* ref, unsigned int v) = 0;
	virtual bool  GetBool(const char* name, int* ref, const char* alias = NULL, bool def = false) = 0;
	virtual const char*  GetCString(const char* name, int* ref, const char* alias = NULL, const char* def = "") = 0;
	virtual float SetFloat(const char*name, int* ref, float v) = 0;
	virtual int   SetInt(const char*name, int* ref, int v) = 0;
	virtual bool  SetBool(const char* name, int* ref, bool v) = 0;
	virtual const char*  SetCString(const char* name, int* ref, const char* v) = 0;
	virtual void destroy() = 0;
	virtual void release() = 0;
	virtual void save(const char* filename)=0;
	virtual bool load(const char* filename) = 0;
	CfgRef* ref;
};

#define GetCfgInt(r,a) int r=cfg->GetInt(#a,&cfg->ref->a);
#define GetCfgUint(r,a) unsigned int r=cfg->GetUint(#a,&cfg->ref->a);
#define GetCfgBool(r,a)  bool r=cfg->GetBool(#a,&cfg->ref->a);
#define GetCfgFloat(r,a)  float r=cfg->GetFloat(#a,&cfg->ref->a);
#define GetCfgCString(r,a) const char* r=cfg->GetCString(#a,&cfg->ref->a);
#define GetCfgObj(r,a)  void* r=cfg->GetObj(#a,&cfg->ref->a);

#define GetCfgInt_(r,a,b)  int r=cfg->GetInt(#a,&cfg->ref->a,#b);
#define GetCfgUint_(r,a,b)  unsigned int r=cfg->GetUint(#a&cfg->ref->a,#b);
#define GetCfgBool_(r,a,b)  bool r=cfg->GetBool(#a,&cfg->ref->a,#b);
#define GetCfgFloat_(r,a,b)  float r=cfg->GetFloat(#a,&cfg->ref->a,#b);
#define GetCfgCString_(r,a,b)  const char* r=cfg->GetCString(#a,&cfg->ref->a,#b);
#define GetCfgObj_(r,a,b)  void* r=cfg->GetObj(#a,&cfg->ref->a,#b);

#define SetCfgInt(a,r)  int _##a=cfg->SetInt(#a,&cfg->ref->a,(r));
#define SetCfgBool(a,r)  bool _##a=cfg->SetBool(#a,&cfg->ref->a,(r));
#define SetCfgUint(a,r)  unsigned int _##a=cfg->SetUint(#a,&cfg->ref->a,(r));
#define SetCfgFloat(a,r)  float _##a=cfg->SetFloat(#a,&cfg->ref->a,(r));
#define SetCfgCString(a,r)  const char* _##a=cfg->SetCString(#a,&cfg->ref->a,(r));
#define SetCfgObj(a,r)  void* _##a=cfg->SetObj(#a,&cfg->ref->a,(r));


/*
#define GetCfgInt(r,a) static int __ref_##a = -1; int r=cfg->GetInt(#a,NULL);
#define GetCfgUint(r,a) static int __ref_##a = -1; unsigned int r=cfg->GetUint(#a,NULL);
#define GetCfgBool(r,a) static int __ref_##a = -1; bool r=cfg->GetBool(#a,NULL);
#define GetCfgFloat(r,a) static int __ref_##a = -1; float r=cfg->GetFloat(#a,NULL);
#define GetCfgCString(r,a) static int __ref_##a = -1; const char* r=cfg->GetCString(#a,NULL);
#define GetCfgObj(r,a) static int __ref_##a = -1; void* r=cfg->GetObj(#a,NULL);

#define GetCfgInt_(r,a,b) static int __ref_##a = -1; int r=cfg->GetInt(#a,NULL,#b);
#define GetCfgUint_(r,a,b) static int __ref_##a = -1; unsigned int r=cfg->GetUint(#a,NULL,#b);
#define GetCfgBool_(r,a,b) static int __ref_##a = -1; bool r=cfg->GetBool(#a,NULL,#b);
#define GetCfgFloat_(r,a,b) static int __ref_##a = -1; float r=cfg->GetFloat(#a,NULL,#b);
#define GetCfgCString_(r,a,b) static int __ref_##a = -1; const char* r=cfg->GetCString(#a,NULL,#b);
#define GetCfgObj_(r,a,b) static int __ref_##a = -1; void* r=cfg->GetObj(#a,NULL,#b);

#define SetCfgInt(a,r) static int __xref_##a = -1; int _##a=cfg->SetInt(#a,NULL,(r));
#define SetCfgBool(a,r) static int __xref_##a = -1; bool _##a=cfg->SetBool(#a,NULL,(r));
#define SetCfgUint(a,r) static int __xref_##a = -1; unsigned int _##a=cfg->SetUint(#a,NULL,(r));
#define SetCfgFloat(a,r) static int __xref_##a = -1; float _##a=cfg->SetFloat(#a,NULL,(r));
#define SetCfgCString(a,r) static int __xref_##a = -1; const char* _##a=cfg->SetCString(#a,NULL,(r));
#define SetCfgObj(a,r) static int __xref_##a = -1; void* _##a=cfg->SetObj(#a,NULL,(r));*/
#endif