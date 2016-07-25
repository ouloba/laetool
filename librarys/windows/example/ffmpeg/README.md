1、Lae界面与c++交互
	c++
	LXZSystem_RegisterAPI("Play", ccPlay);
	LXZSystem_RegisterAPI("Pause", ccPause);
	LXZSystem_RegisterAPI("seekpos", ccSeekpos);
	LXZSystem_RegisterAPI("Resume", ccResume);
	LXZSystem_RegisterAPI("skipfront", ccSkipNext);
	LXZSystem_RegisterAPI("skipback", ccSkipBack);	
	LXZSystem_RegisterAPI("toggle_muted", ccMutex);
	LXZSystem_RegisterAPI("volume", ccSetVolume);
	LXZSystem_RegisterAPI("toggle_fullscreen", toggle_fullscreen);
	
	lua
	LXZAPI_CallSystemAPI("skipfront", "", nil);
	LXZAPI_CallSystemAPI("toggle_fullscreen", "", nil);
	
	
	2、Lae下载位置
	http://download.csdn.net/detail/ouloba_cs/9390870
	
	3、用Lae可以所见即所得修改播放器的界面
	打开ffmpeg.ui
	
	4、如何使用lae?
	可看视频	http://www.tudou.com/programs/view/AaqZ81jIt-k