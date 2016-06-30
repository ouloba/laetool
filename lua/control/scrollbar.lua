
local function HelperGetSliderWidth(parent, wnd)
	if parent:GetWidth()>wnd:GetWidth() then
		return parent:GetWidth()-wnd:GetWidth();
	end
	return wnd:GetWidth()-parent:GetWidth();
end

local function HelperGetSliderHeight(parent, wnd)
	if parent:GetHeight()>wnd:GetHeight() then
		return parent:GetHeight()-wnd:GetHeight();
	end
	return wnd:GetHeight()-parent:GetHeight();
end

local perio_callback={};
function HelperPerioProc(name, fn, window, msg, sender)	
	if perio_callback[name]==nil then
		perio_callback[name]=HelperCoroutine(function(thread)
			local corecfg = ICGuiGetLXZCoreCfg();
			AddWndUpdateFunc(window,function(w,tblParam)
					if corecfg.IsClickDown==false  then
						perio_callback[name]=nil;
						return true;
					end
					
					if tblParam.time==nil then
						tblParam.time=LXZAPI_timeGetTime()+30;
					end
					
					if LXZAPI_timeGetTime()>tblParam.time then						
						tblParam.time=LXZAPI_timeGetTime()+30;
						fn(window, msg, sender);
					end					
				end
				, {}, thread);
			coroutine.yield();		
			perio_callback[name]=nil;
		end);
	end
end

local function HelperContrain(parent, child,offset, IsHorization)
	local parentRc = LXZRect:new_local();
	local childRc    = LXZRect:new_local();
	parent:GetRect(parentRc);
	child:GetRect(childRc);
	
	local pt = LXZPoint:new_local();		
	local parent_pt=parentRc:TopLeft();
	local child_pt=childRc:TopLeft();
	
	--reset to origin position.
	if IsHorization then
		pt.x = parent_pt.x-child_pt.x;
	else
		pt.y = parent_pt.y-child_pt.y;
	end
	
	childRc:OffsetPoint(pt);
		
	if IsHorization then
		pt.x = offset;
		pt.y = 0;
	else
		pt.y=offset
		pt.x = 0;
	end
	
	childRc:OffsetPoint(pt);
		
	if IsHorization then
		pt.y = 0;
		if parentRc:Width()>=childRc:Width() then
			if offset>0 then
					if childRc.right> parentRc.right then
						pt.x = parentRc.right-childRc.right;
						childRc:OffsetPoint(pt);
						LXZAPI_OutputDebugStr("1 offset x:"..pt.x.." y:"..pt.y.." offset:"..offset.." ("..childRc.left..","..childRc.top..","..childRc.right..","..childRc.bottom..")");
					end
			else
				if childRc.left<parentRc.left then
					pt.x = parentRc.left-childRc.left;
					childRc:OffsetPoint(pt);
					LXZAPI_OutputDebugStr("2 offset x:"..pt.x.." y:"..pt.y.." offset:"..offset.." ("..childRc.left..","..childRc.top..","..childRc.right..","..childRc.bottom..")");
				end							
			end
		else
			if offset>0 then
					if childRc.left> parentRc.left then
						pt.x = parentRc.left-childRc.left;
						childRc:OffsetPoint(pt);
						LXZAPI_OutputDebugStr("3 offset x:"..pt.x.." y:"..pt.y.." offset:"..offset.." ("..childRc.left..","..childRc.top..","..childRc.right..","..childRc.bottom..")");
					end
			else
				if childRc.right<parentRc.right then
					pt.x = parentRc.right-childRc.right;
					childRc:OffsetPoint(pt);
					LXZAPI_OutputDebugStr("4 offset x:"..pt.x.." y:"..pt.y.." offset:"..offset.." ("..childRc.left..","..childRc.top..","..childRc.right..","..childRc.bottom..")");
				end							
			end		
		end
		
		child:SetHotPos(childRc:Center(),true);
		return;
	end
	
	pt.x = 0;
	if parentRc:Height()>=childRc:Height() then
		if offset>0 then
				if childRc.bottom> parentRc.bottom then
					pt.y = parentRc.bottom-childRc.bottom;
					childRc:OffsetPoint(pt);
				end
		else
			if childRc.top<parentRc.top then
				pt.y = parentRc.top-childRc.top;
				childRc:OffsetPoint(pt);
			end							
		end
	else
		if offset>0 then
				if childRc.top> parentRc.top then
					pt.y = parentRc.top-childRc.top;
					childRc:OffsetPoint(pt);
				end
		else
			if childRc.bottom<parentRc.bottom then
				pt.y = parentRc.bottom-childRc.bottom;
				childRc:OffsetPoint(pt);
			end							
		end		
	end
	child:SetHotPos(childRc:Center(),true);	
end

local function HorizationNormalizePosition(window, pt)
	local len=window:GetWidth()-window:GetChild("slider"):GetWidth();
	if pt.x<0 then
		pt.x=0;
	elseif pt.x>len then
		pt.x=len;
	end	
	window:GetChild("slider"):SetPos(pt);	
end

local function HorizationScrollBySliderPosition(window, wnd)
	local pt = window:GetChild("slider"):GetPos();
	local size = HelperGetSliderWidth( wnd:GetParent(),  wnd);
	local len=window:GetWidth()-window:GetChild("slider"):GetWidth();
	local stepmove =  pt.x*size/len;
	HelperContrain(wnd:GetParent(), wnd, -stepmove, true);
end



local function OnLeft(window, msg, sender)
	local cfg = window:GetCfg();
	local step = cfg:GetInt("page");
	local count = cfg:GetInt("count");	
	local wnd = window:GetParent():GetLXZWindow(window:GetAddString());
	if wnd == nil then
		LXZAPI_OutputDebugStr("OnLeft window:"..window:GetLongName().." add string:"..window:GetAddString());
		return;
	end
		

	local pt = window:GetChild("slider"):GetPos();		
	local len=window:GetWidth()-window:GetChild("slider"):GetWidth();
	pt.x=pt.x-step*len/count;
	HorizationNormalizePosition(window, pt);		
	HorizationScrollBySliderPosition(window, wnd);
	
	HelperPerioProc("OnLeft", OnLeft, window, msg, sender);	
end

local function OnRight(window, msg, sender)
	local cfg = window:GetCfg();
	local step = cfg:GetInt("page");
	local count = cfg:GetInt("count");	
	local wnd = window:GetParent():GetLXZWindow(window:GetAddString());
	if wnd == nil then
		LXZAPI_OutputDebugStr("OnRight window:"..window:GetLongName().." add string:"..window:GetAddString());
		return;
	end
	
	local pt = window:GetChild("slider"):GetPos();
	local len=window:GetWidth()-window:GetChild("slider"):GetWidth();
	pt.x=pt.x+step*len/count;
	HorizationNormalizePosition(window, pt);	
	HorizationScrollBySliderPosition(window, wnd);
	
	HelperPerioProc("OnRight", OnRight, window, msg, sender);	
end



local function OnHorizationSliderMove(window, msg, sender)
	local wnd = window:GetParent():GetLXZWindow(window:GetAddString());
	if wnd == nil then
		LXZAPI_OutputDebugStr("OnHorizationSliderMove window:"..window:GetLongName().." add string:"..window:GetAddString());
		return;
	end
			
	HorizationScrollBySliderPosition(window, wnd);
end

local function OnClickHorizationBar(window, msg, sender)
	local x = msg:int();
	local y = msg:int();
	
	local wnd = window:GetParent():GetLXZWindow(window:GetAddString());
	if wnd == nil then
		return;
	end
			
	local rc = window:GetRect();
	local pt = window:GetChild("slider"):GetPos();
	pt.x = x-rc.left-window:GetChild("slider"):GetWidth()/2;
	HorizationNormalizePosition(window, pt);		
	HorizationScrollBySliderPosition(window, wnd);
end

local function OnHorizationLoad(window, msg, sender)
	LXZAPI_OutputDebugStr("OnHorizationLoad 11111111111");
	local cfg = window:GetCfg();
	local page = cfg:GetInt("page");
	if page==0 then
		cfg:SetInt("page", -1, 10);
		cfg:SetInt("step", -1, 5);
		cfg:SetInt("count",-1, 100);
	end
	LXZAPI_OutputDebugStr("OnHorizationLoad:"..window:GetLongName());
end

local function OnHorMouseWheel(window, msg, sender)
	local x = msg:int();
	local y = msg:int();
	local delta = msg:int();
	
	local corecfg = ICGuiGetLXZCoreCfg();
	if corecfg.IsClickDown==true then
		LXZAPI_OutputDebugStr("OnHorMouseWheel 0");
		return;
	end
	
	local wnd = window:GetParent():GetLXZWindow(window:GetAddString());
	if wnd == nil or wnd:IsVisible()==false then
		LXZAPI_OutputDebugStr("OnHorMouseWheel 1");
		return;
	end
	
	local rc = window:GetRect();
	if rc:IsIncludePoint(x,y)==false then
		LXZAPI_OutputDebugStr("OnHorMouseWheel  2");
		return;
	end
	
	local pt = window:GetChild("slider"):GetPos();
	pt.x = pt.x-delta;	
	HorizationNormalizePosition(window,pt);
	HorizationScrollBySliderPosition(window, wnd);	
end

local event_callback = {}
event_callback ["OnLoad"] = OnHorizationLoad;
event_callback ["OnLeft"] = OnLeft;
event_callback ["OnRight"] = OnRight;
event_callback ["OnHorMouseWheel"] = OnHorMouseWheel;
event_callback ["OnHorizationSliderMove"] = OnHorizationSliderMove;
event_callback ["OnClickHorizationBar"] = OnClickHorizationBar;
function horization_scrollbar_main_dispacher(window, cmd, msg, sender)
---	LXZAPI_OutputDebugStr("cmd 1:"..cmd);
	if(event_callback[cmd] ~= nil) then
--		LXZAPI_OutputDebugStr("cmd 2:"..cmd);
		event_callback[cmd](window, msg, sender);
	end
end

local function VerticalScrollBySliderPosition(window, wnd)
	local pt = window:GetChild("slider"):GetPos();
	local size = HelperGetSliderHeight( wnd:GetParent(),  wnd);
	local len=window:GetHeight()-window:GetChild("slider"):GetHeight();
	local stepmove =  pt.y*size/len;	
	HelperContrain(wnd:GetParent(), wnd, -stepmove, false);	
end

local function VerticalNormalizePosition(window, pt)
	local len=window:GetHeight()-window:GetChild("slider"):GetHeight();
	if pt.y<0 then
		pt.y=0;
	elseif pt.y>len then
		pt.y=len;
	end	
	window:GetChild("slider"):SetPos(pt);	
end

local function OnUp(window, msg, sender)
	local cfg = window:GetCfg();
	local step = cfg:GetInt("step");
	local count = cfg:GetInt("count");	
	local wnd = window:GetParent():GetLXZWindow(window:GetAddString());
	if wnd == nil then
		return;
	end
	
	local size=window:GetHeight()-window:GetChild("slider"):GetHeight();	
	local offset = step*size/count;	
	local pt = window:GetChild("slider"):GetPos();
	pt.y = pt.y-offset;
	VerticalNormalizePosition(window,pt);
	VerticalScrollBySliderPosition(window, wnd);	
	
	HelperPerioProc("OnUp", OnUp, window, msg, sender);
end

local function OnDown(window, msg, sender)
	local cfg = window:GetCfg();
	local step = cfg:GetInt("step");
	local count = cfg:GetInt("count");	
	local wnd = window:GetParent():GetLXZWindow(window:GetAddString());
	if wnd == nil then
		return;
	end
	
	local size=window:GetHeight()-window:GetChild("slider"):GetHeight();
	local offset = step*size/count;	
	local pt = window:GetChild("slider"):GetPos();
	pt.y = pt.y+offset;
	LXZAPI_OutputDebugStr("OnDown step:"..step.." count:"..count.." offset:"..offset.." size:"..size);
	VerticalNormalizePosition(window,pt);
	VerticalScrollBySliderPosition(window, wnd);	
	
	HelperPerioProc("OnDown", OnDown, window, msg, sender);
end

local function OnVertMouseWheel(window, msg, sender)
	local x = msg:int();
	local y = msg:int();
	local delta = msg:int();
	
	local corecfg = ICGuiGetLXZCoreCfg();
	if corecfg.IsClickDown==true then
		LXZAPI_OutputDebugStr("OnVertMouseWheel 0");
		return;
	end
	
	local wnd = window:GetParent():GetLXZWindow(window:GetAddString());
	if wnd == nil or wnd:IsVisible()==false then
		LXZAPI_OutputDebugStr("OnVertMouseWheel 1");
		return;
	end
	
	local rc = wnd:GetParent():GetRect();
	if rc:IsIncludePoint(x,y)==false then
		LXZAPI_OutputDebugStr("OnVertMouseWheel  2");
		return;
	end
	
	local pt = window:GetChild("slider"):GetPos();
	pt.y = pt.y-delta;	
	VerticalNormalizePosition(window,pt);
	VerticalScrollBySliderPosition(window, wnd);	
end

local function OnVerticalSliderMove(window, msg, sender)
	local wnd = window:GetParent():GetLXZWindow(window:GetAddString());
	if wnd == nil then
		return;
	end
		
	VerticalScrollBySliderPosition(window, wnd);
end

local function OnClickVerticalBar(window, msg, sender)
	local x = msg:int();
	local y = msg:int();
	local wnd = window:GetParent():GetLXZWindow(window:GetAddString());
	if wnd == nil then
		return;
	end
		
	local rc = window:GetRect();
	local size = HelperGetSliderHeight( wnd:GetParent(),  wnd);
	local len=window:GetHeight()-window:GetChild("slider"):GetHeight();
	local stepmove =  (y-rc.top)*size/len;
	
	local pt = window:GetChild("slider"):GetPos();
	pt.y = y-rc.top-window:GetChild("slider"):GetHeight()/2;	
	VerticalNormalizePosition(window,pt);
	VerticalScrollBySliderPosition(window, wnd);	
end

local function OnVerticalLoad(window, msg, sender)
	local cfg = window:GetCfg();
	local page = cfg:GetInt("page");
	if page==0 then
		cfg:SetInt("page", -1, 10);
		cfg:SetInt("step", -1, 5);
		cfg:SetInt("count",-1, 100);
	end
end

local event_callback = {}
event_callback ["OnLoad"] = OnVerticalLoad;
event_callback ["OnUp"] = OnUp;
event_callback ["OnDown"] = OnDown;
event_callback ["OnVertMouseWheel"] =OnVertMouseWheel;
event_callback ["OnVerticalSliderMove"] = OnVerticalSliderMove;
event_callback ["OnClickVerticalBar"] = OnClickVerticalBar;
event_callback ["OnReset"] = OnVerticalSliderMove;

function vertical_scrollbar_main_dispacher(window, cmd, msg, sender)
---	LXZAPI_OutputDebugStr("cmd 1:"..cmd);
	if(event_callback[cmd] ~= nil) then
--		LXZAPI_OutputDebugStr("cmd 2:"..cmd);
		event_callback[cmd](window, msg, sender);
	end
end
