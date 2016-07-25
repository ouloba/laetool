#ifndef _Linux_Win_Lock_
#define _Linux_Win_Lock_

#ifdef WIN32
#include <windows.h>
#define LINUX_WIN_LOCk_MUTEX CRITICAL_SECTION
#define LINUX_WIN_LOCk_MUTEXINIT(m) InitializeCriticalSection(&m)
#define LINUX_WIN_LOCk_MUTEXLOCK(m) EnterCriticalSection(&m)
#define LINUX_WIN_LOCk_MUTEXUNLOCK(m) LeaveCriticalSection(&m)
#define LINUX_WIN_LOCk_MUTEXDESTROY(m)DeleteCriticalSection(&m)
#else
#include <pthread.h>
#include <semaphore.h>
#include <memory.h>
#define LINUX_WIN_LOCk_MUTEX pthread_mutex_t
#define LINUX_WIN_LOCk_MUTEXINIT(m) pthread_mutex_init(&m,NULL)
#define LINUX_WIN_LOCk_MUTEXLOCK(m) pthread_mutex_lock(&m)
#define LINUX_WIN_LOCk_MUTEXUNLOCK(m) pthread_mutex_unlock(&m)
#define LINUX_WIN_LOCk_MUTEXDESTROY(m)pthread_mutex_destroy(&m)
#endif

#include "ICGui.h"

class DLL_CLASS Linux_Win_Lock
{
public:
	Linux_Win_Lock(void)
	{
		LINUX_WIN_LOCk_MUTEXINIT(this->pFMutexLock); 
	}

	virtual ~Linux_Win_Lock(void)
	{
		LINUX_WIN_LOCk_MUTEXDESTROY(this->pFMutexLock);
	}
public:
	void Linux_Win_Locked(void)
	{
		LINUX_WIN_LOCk_MUTEXLOCK(this->pFMutexLock);
	}
	
	void Linux_Win_UnLocked(void)
	{
		LINUX_WIN_LOCk_MUTEXUNLOCK(this->pFMutexLock);
	}

private:
	LINUX_WIN_LOCk_MUTEX pFMutexLock ;
};

class DLL_CLASS Linux_Win_Event
{
public:
	Linux_Win_Event()
	{
#ifdef WIN32
		hEvent = NULL;
		memset(szName, 0x00, sizeof(szName));
#elif ANDROID
		memset(&SemObj, 0x00, sizeof(SemObj));
		pSem = NULL;
#else
		pSem = NULL;
		memset(szName, 0x00, sizeof(szName));
#endif
	}

	~Linux_Win_Event()
	{
#ifdef WIN32
		if(hEvent)
		{
			CloseHandle(hEvent);
		}
#elif ANDROID
		sem_destroy(pSem);
#elif __APPLE__
		sem_unlink(szName);
		sem_close(pSem);
#endif
	}

	bool  Initialize(const char* name)
	{
#ifdef WIN32
		 hEvent = ::CreateEvent(NULL,FALSE,FALSE,NULL);
#elif ANDROID
		int semRet = sem_init(&SemObj, 0, 0);
		if (semRet < 0) {
			//CCLog("Init HttpRequest Semaphore failed");
			return false;
		}

		pSem = &SemObj;
#elif __APPLE__
		pSem = sem_open(name, O_CREAT, 0644, 0);
		if (pSem == SEM_FAILED) {
			//CCLog("Open HttpRequest Semaphore failed");
			pSem = NULL;
			return false;
		}

		strcpy(szName, name);
#endif
		return true;
	}

	int  Wait(LXZuint32 uMillionSec)
	{
#ifdef WIN32
		if(hEvent == NULL)
			return -1;

		if(::WaitForSingleObject(hEvent, uMillionSec)==WAIT_TIMEOUT)
			return 0;
#else
		int semWaitRet = sem_wait(pSem);
		if (semWaitRet < 0) {
			//CCLog("HttpRequest async thread semaphore error: %s\n", strerror(errno));
			//break;
			return -1;
		}
#endif

		return 0;

	}

	void SetEvent()
	{
#ifdef WIN32 
		if(hEvent)
			::SetEvent(hEvent);
#else
		sem_post(pSem);
#endif
	}

private:
	char szName[256];
#ifdef WIN32
	HANDLE hEvent;
#elif ANDROID
	sem_t SemObj;
	sem_t* pSem;
#elif __APPLE__
	sem_t* pSem;	
#endif

};


#endif
