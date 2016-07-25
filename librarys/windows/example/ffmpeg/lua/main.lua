LXZDoFile("LXZHelper.lua");
LXZDoFile("serial.lua");

AppData = {};

OFN_READONLY = 0x00000001
OFN_OVERWRITEPROMPT  =  0x00000002
OFN_HIDEREADONLY  = 0x00000004
OFN_NOCHANGEDIR =  0x00000008
OFN_SHOWHELP = 0x00000010
OFN_ENABLEHOOK  =  0x00000020
OFN_ENABLETEMPLATE  =  0x00000040
OFN_ENABLETEMPLATEHANDLE = 0x00000080
OFN_NOVALIDATE =  0x00000100
OFN_ALLOWMULTISELECT =  0x00000200
OFN_EXTENSIONDIFFERENT =   0x00000400
OFN_PATHMUSTEXIST =  0x00000800
OFN_FILEMUSTEXIST  =   0x00001000
OFN_CREATEPROMPT  =    0x00002000
OFN_SHAREAWARE =    0x00004000
OFN_NOREADONLYRETURN =   0x00008000
OFN_NOTESTFILECREATE   =  0x00010000
OFN_NONETWORKBUTTON  =     0x00020000
OFN_NOLONGNAMES =    0x00040000  --  // force no long names for 4.x modules
OFN_EXPLORER   =     0x00080000    -- // new look commdlg
OFN_NODEREFERENCELINKS  =   0x00100000
OFN_LONGNAMES     =    0x00200000   --  // force long names for 3.x modules

local callbackthread= {};
LXZAPI_HookSystemNotify("xxxOnSystemNotify");
function xxxOnSystemNotify(token, param,thread)
	if callbackthread[token]~= nil then
		coroutine.resume(callbackthread[token],param);
	end
	local corecfg = ICGuiGetLXZCoreCfg();
	local root = HelperGetRoot();	
	if token=="seekpos" then
		local wnd = root:GetLXZWindow("bottom:progress");
		local pos = tonumber(param);
		local x = pos*wnd:GetWidth()/10000;
		local pt = LXZPoint:new_local();
		wnd:GetChild("dot"):GetHotPos(pt);
		pt.x = x;
		wnd:GetChild("dot"):SetHotPos(pt);
		if(pos>=(10000-200) and (corecfg.IsClickDown==0 or corecfg.IsClickDown==false)) then --end
			playing=nil;
			root:GetLXZWindow("bottom:control:play"):SetState(0);
		end
	end
	
end

--获取文件名  
function stripfilename(filename)  
	if LXZAPIGetOS()~="WIN32" then
		local _,__,file= string.find(filename, "[.+/]([^/]*%.%w+)$") -- *nix system 
		if file==nil then
			return filename;
		end
		return file;
	end
	
    local _,__,file= string.find(filename, "[.+\\]([^\\]*%.%w+)$") --*nix system  
	if file==nil then
		return filename;
	end
	
	return file;
end 

local function OnOpen(window, msg, sender)
	local root = HelperGetRoot();	
	HelperCoroutine(function(thread)
		local alloc = ILXZAlloc:new_local();
		local msg = CLXZMessage:new_local();
		msg:uint32(bit.bor(OFN_FILEMUSTEXIST,OFN_EXPLORER));
		alloc:set(msg:getMsgPtr(),msg:getMsgSize());
		callbackthread["OpenFolder"]=thread;
		LXZAPI_CallSystemAPI("OpenFolder","video file (.avi;.mp4;.mov;wmv;)\0*.avi;*.mp4;*.mov;*.wmv;\0\0",alloc);	
		local file = coroutine.yield();		
		if file ~= nil and string.len(file)>0 then
			AppData.current=file;
			playing = nil;
			HelperSetWindowText(root:GetLXZWindow("head:title"),stripfilename(file));
		end
	end);
end

local function OnPlay(window, msg, sender)
	if playing== nil then
		if AppData.current == nil then
			return;
		end
		
		playing=true;
		sender:SetState(1);
		LXZAPI_CallSystemAPI("Play", AppData.current, nil);
	elseif(playing) then
		if pause==nil then
			pause=true;		
			sender:SetState(0);
			LXZAPI_CallSystemAPI("Pause", "", nil);
		else
			pause=nil;		
			sender:SetState(1);
			LXZAPI_CallSystemAPI("Resume", "", nil);
		end
	end
end

local function OnLoad(window, msg, sender)
	local root = HelperGetRoot();
	HelperCoroutine(function(thread)	
		root:GetLXZWindow("video"):Hide();		
		root:GetLXZWindow("head"):Hide();		
		root:GetLXZWindow("bottom"):Hide();		
		HelperSetWindowText(root:GetLXZWindow("head:title"), "");
		AddWndUpdateFunc(window, EffectFaceInOut, {from=100,to=255,framecount=60, old=255}, thread);	
		coroutine.yield();		
		root:GetLXZWindow("head"):Show();		
		root:GetLXZWindow("bottom"):Show();		
		root:GetLXZWindow("video"):Show();
		root:GetLXZWindow("bottom:control:play"):SetState(0);
	end);
end

local function OnUpdate(window, msg, sender)
	UpdateWindow();
end


local function OnMinSize(window, msg, sender)
	local corecfg = ICGuiGetLXZCoreCfg();	
	if corecfg.IsEditTool==0 or corecfg.IsEditTool==false then
		--LXZMessageBox("OnMinSize");
		WM_SYSCOMMAND=0x0112;
		SC_MINIMIZE = 0xF020;
		LXZAPI_PostWin32Message(WM_SYSCOMMAND, SC_MINIMIZE, 0);
		sender:SetState(0);
	end
end

IsMuted=false;
local function OnMuted(window, msg, sender)	
	IsMuted=(IsMuted==false);
	LXZAPI_CallSystemAPI("toggle_muted", "", nil);	
	if IsMuted then
		sender:SetState(1) 
	else
		sender:SetState(0);
	end
	
end

IsFullScreen =  false;
local function OnMaxSize(window, msg, sender)
	--LXZMessageBox("OnMaxSize");
	--LXZAPI_CallSystemAPI("fullscreen", "", nil);	
	local root = HelperGetRoot();
	local corecfg = ICGuiGetLXZCoreCfg();		
	if corecfg.IsEditTool==0 or corecfg.IsEditTool==false then			
		LXZAPI_CallSystemAPI("toggle_fullscreen", "", nil);
		if IsFullScreen==false then
			IsFullScreen = true;
			HelperSetWindowPictureFile(root:GetLXZWindow("head:max_btn"), "exit_max.png");
		else
			IsFullScreen=false;
			HelperSetWindowPictureFile(root:GetLXZWindow("head:max_btn"), "enter_max.png");
		end
	end

end

local function OnClose(window, msg, sender)
	local corecfg = ICGuiGetLXZCoreCfg();	
	if corecfg.IsEditTool==0 or corecfg.IsEditTool==false then
		--LXZMessageBox("OnClose");
		WM_CLOSE = 0x0010;
		LXZAPI_PostWin32Message(WM_CLOSE, 0, 0);
	end
end

local function OnFastSkipFront(window, msg, sender)
	LXZAPI_CallSystemAPI("skipfront", "", nil);
end

local function OnFastSkipBack(window, msg, sender)
	LXZAPI_CallSystemAPI("skipback", "", nil);
end

local function OnSeekPos(window, msg, sender)
	local pt = LXZPoint:new_local();
	pt.x = msg:int();
	pt.y = msg:int();	
	sender:ScreenToWindowPos(pt);	
	
	local wnd = sender:GetChild("dot");	
	wnd:SetHotPos(pt);
	
	local pos = math.floor(100*pt.x/sender:GetWidth());	
	LXZAPI_CallSystemAPI("seekpos", tostring(pos), nil);
end

local function OnMovieItem(window, msg, sender)

end

local function OnScrollItems(window, msg, sender)

end

local function OnSliderPos(window, msg, sender)
	local pt = LXZPoint:new_local();
	sender:GetHotPos(pt);
	local pos = math.floor(100*pt.x/sender:GetWidth());	
	LXZAPI_CallSystemAPI("seekpos", tostring(pos), nil);
end


local event_callback = {}
event_callback ["OnLoad"] = OnLoad;
event_callback ["OnPlay"] = OnPlay;
event_callback ["OnUpdate"] = OnUpdate;
event_callback ["OnMinSize"] = OnMinSize;
event_callback ["OnClose"] = OnClose;
event_callback ["OnOpen"] = OnOpen;
event_callback ["OnMaxSize"] = OnMaxSize;
event_callback ["OnFastSkipFront"] = OnFastSkipFront;
event_callback ["OnFastSkipBack"] = OnFastSkipBack;
event_callback ["OnSeekPos"] = OnSeekPos;
event_callback ["OnSliderPos"] = OnSliderPos;

event_callback ["OnMuted"] = OnMuted;
event_callback ["OnScrollItems"] = OnScrollItems;


function main_dispacher(window, cmd, msg, sender)
---	LXZAPI_OutputDebugStr("cmd 1:"..cmd);
	if(event_callback[cmd] ~= nil) then
--		LXZAPI_OutputDebugStr("cmd 2:"..cmd);
		event_callback[cmd](window, msg, sender);
	end
end

