
local AppData = {};
AppData.isclickdown=false;
AppData.org = LXZPoint:new_local();

local function OnLClickDown(window, msg, sender)
	local pt = LXZPoint:new_local();
	pt.x = msg:int();
	pt.y = msg:int();

	local root = HelperGetRoot();
	local wnd = sender:GetParent();
	if wnd == nil then	
		return;
	end
		
	AppData.isclickdown=true;	
	AppData.org.x = pt.x;
	AppData.org.y = pt.y;

	if sender:GetAddString()=="left" then
		HelperSetCursorState(HelperGetCursorState("horization"));
	elseif sender:GetAddString()=="right" then
		HelperSetCursorState(HelperGetCursorState("horization"));
	elseif sender:GetAddString()=="top" then
		HelperSetCursorState(HelperGetCursorState("vertical"));
	elseif sender:GetAddString()=="bottom" then
		HelperSetCursorState(HelperGetCursorState("vertical"));	
	end
	
end

local function OnMouseMove(window, msg, sender)
	local pt = LXZPoint:new_local();
	pt.x = msg:int();
	pt.y = msg:int();

		
	if AppData.isclickdown==false then	
		if sender:HitTest(pt.x,pt.y) == nil then
			return;
		end
	
		if sender:GetAddString()=="left" then
			state=HelperGetCursorState("horization");
		elseif sender:GetAddString()=="right" then
			state=HelperGetCursorState("horization");
		elseif sender:GetAddString()=="top" then
			state=HelperGetCursorState("vertical");
		elseif sender:GetAddString()=="bottom" then
			state=HelperGetCursorState("vertical");	
		end	
		HelperSetCursorState(state);
		return;
	end
					
	local offset_x = pt.x-AppData.org.x;
	local offset_y = pt.y-AppData.org.y;
	
	local wnd = sender:GetParent();

	--set size
	if sender:GetAddString()=="left" then
		local pos_wnd = LXZPoint:new_local();
		wnd:GetPos(pos_wnd);		
		pos_wnd.x=pos_wnd.x+offset_x;		
		wnd:SetPos(pos_wnd);
		wnd:SetWidth(wnd:GetWidth()-offset_x);
	elseif sender:GetAddString()=="right" then
		wnd:SetWidth(wnd:GetWidth()+offset_x);
	elseif sender:GetAddString()=="top" then		
		local pos_wnd = LXZPoint:new_local();
		wnd:GetPos(pos_wnd);
		pos_wnd.y=pos_wnd.y+offset_y;
		wnd:SetPos(pos_wnd);
		wnd:SetHeight(wnd:GetHeight()-offset_y);
	elseif sender:GetAddString()=="bottom" then
		wnd:SetHeight(wnd:GetHeight()+offset_y);	
	end
	
	--
	AppData.org.x = pt.x;
	AppData.org.y = pt.y;
end

local function OnLClickUp(window, msg, sender)
	local x = msg:int();
	local y = msg:int();
	AppData.isclickdown=false;
end

local function OnMouseLeave(window, msg, sender)
	local x = msg:int();
	local y = msg:int();
	if AppData.isclickdown==false then
		--LXZMessageBox("OnMouseLeave");
		HelperSetCursorState(1);
	end
end


local event_callback = {}
event_callback ["OnLClickDown"] = OnLClickDown;
event_callback ["OnSizeBarMouseMove"] = OnMouseMove;
event_callback ["OnLClickUp"] = OnLClickUp;
event_callback ["OnSizeBarMouseLeave"] = OnMouseLeave;

function sizebar_main_dispacher(window, cmd, msg, sender)
---	LXZAPI_OutputDebugStr("cmd 1:"..cmd);
	if(event_callback[cmd] ~= nil) then
--		LXZAPI_OutputDebugStr("cmd 2:"..cmd);
		event_callback[cmd](window, msg, sender);
	end
end
