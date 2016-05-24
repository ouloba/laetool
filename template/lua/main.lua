LXZDoFile("LXZHelper.lua");
LXZDoFile("serial.lua");


local function OnTest(window, msg, sender)
	LXZMessageBox("OnTest:"..sender:GetName());
end

local event_callback = {}
event_callback ["OnTest"] = OnTest;

function main_dispacher(window, cmd, msg, sender)
---	LXZAPI_OutputDebugStr("cmd 1:"..cmd);
	if(event_callback[cmd] ~= nil) then
--		LXZAPI_OutputDebugStr("cmd 2:"..cmd);
		event_callback[cmd](window, msg, sender);
	end
end

