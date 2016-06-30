
--辅助接口
LXZDoFile("LXZHelper.lua");
LXZDoFile("serial.lua");

--每帧调用,root窗口status中IsActive设置为true,即可触发OnUpdate事件。
local function OnUpdate(window, msg, sender)
	UpdateWindow();
end

--更新目录子目录或者文件列表
local function UpdateDirectry(dir)
	local root = HelperGetRoot();
	
	--set current dir.	
	lfs.chdir(dir);
	HelperSetWindowText(root:GetLXZWindow("directry"), dir);
	
	--
	local items = root:GetLXZWindow("folders:area:items"); --目录文件容器
	local item = root:GetLXZWindow("folders:item"); --目录文件项	
	local path = lfs.currentdir();
	
	--清除容器中内容
	items:ClearChilds();
	
	--遍历该目录下的子目录文件
	local cnt = 0;
	for file in lfs.dir(lfs.currentdir()) do
		local wnd = item:Clone(); --克隆一个目录文件项"folders:item"
		wnd:Show();                      --显示
		HelperSetWindowText(wnd:GetChild("text"), file); --设置目录或者文件名
		items:AddChild(wnd);		 --加入items容器中
			
		local f = path.."\\"..file;
		local attr = lfs.attributes(f);				
		if attr and attr.mode=="directory" then
			wnd:GetChild("icon"):SetState(0); --通过0状态设置目录图标
		else
			wnd:GetChild("icon"):SetState(1);--通过1状态设置文件名图标
		end		
		
		if attr then			
			HelperSetWindowText(wnd:GetChild("access time"), os.date("%c", attr.access) );
			HelperSetWindowText(wnd:GetChild("modify time"), os.date("%c", attr.modification));
			HelperSetWindowText(wnd:GetChild("change time"), os.date("%c", attr.change));
			HelperSetWindowText(wnd:GetChild("permissions"), attr.permissions);
		end
		
		cnt=cnt+1;
	end
	
	--如果无法访问该目录，则添加"."与".."
	if cnt==0 then
		local wnd = item:Clone();
		wnd:Show();
		HelperSetWindowText(wnd:GetChild("text"), ".");
		items:AddChild(wnd);		
		wnd:GetChild("icon"):SetState(0);
		
		local wnd = item:Clone();
		wnd:Show();
		HelperSetWindowText(wnd:GetChild("text"), "..");
		items:AddChild(wnd);		
		wnd:GetChild("icon"):SetState(0);
	end
	
	--垂直滚动条适应内容大小。
	local msg = CLXZMessage:new_local();
	local wnd = root:GetLXZWindow("folders:vertical slider");
	wnd:ProcMessage("OnReset", msg, wnd);
	
end

--获取扩展名  
function getextension(filename)  
    return filename:match(".+%.(%w+)$")  
end  

--鼠标进入
local function OnMouseEnterItem(window, msg, sender)
	local file=HelperGetWindowText(sender:GetChild("text"));
	local path = lfs.currentdir();
	
	local f = path.."\\"..file;
	 local attr,err = lfs.attributes (f)
	 if attr== nil then
		LXZMessageBox("error:"..err);
		return;
	 end
	 
	 local root = HelperGetRoot();	
     assert (type(attr) == "table");
	 local ext = getextension(file);
	 
	 LXZAPI_OutputDebugStr("OnMouseEnterItem:"..f.." mode:"..attr.mode);
	 
     if attr.mode == "file" and (ext=="png" or ext=="PNG" or ext=="jpg") then --如果是图片文件
		LXZAPI_OutputDebugStr("OnMouseEnterItem:"..f.." ext:"..ext.." mode:"..attr.mode);
		local wnd = root:GetLXZWindow ("folders:show picture");
		HelperSetWindowPictureFile(wnd,f);
		wnd:Show();
		HelperCoroutine(function(thread)
			AddWndUpdateFunc(wnd, EffectFaceOut, {from=255, End=200,step=3, old=255, hide=true}, thread);		
			coroutine.yield();
			local texture = ILXZTexture:GetTexture(f);
			if texture then
				texture:RemoveTexture();
			end
		end);
	 end
end

--点击目录或者文件项
local function OnClickItem(window, msg, sender)
	local file=HelperGetWindowText(sender:GetChild("text"));
	local path = lfs.currentdir();
	
	local f = path.."\\"..file;
	 local attr,err = lfs.attributes (f)
	 if attr== nil then
		LXZMessageBox("error:"..err);
		return;
	 end
	 
	-- LXZMessageBox("type(attr)"..type(attr).."f:"..f)
     assert (type(attr) == "table");
     if attr.mode == "directory" then --如果是目录
		UpdateDirectry(f);		
	 end

end

--ui加载时触发该事件
local function OnLoad(window, msg, sender)
	local root = HelperGetRoot();
	
	--set default.
	local default_dir = "c:\\";
	HelperSetWindowText(root:GetLXZWindow("directry"), default_dir);
	
	--set folder list.
	UpdateDirectry(default_dir);
	
end

--事件与接口绑定
local event_callback = {}
event_callback ["OnUpdate"] = OnUpdate;
event_callback ["OnLoad"] = OnLoad;
event_callback ["OnClickItem"] = OnClickItem;
event_callback ["OnMouseEnterItem"] = OnMouseEnterItem;

--事件分发器
function main_dispacher(window, cmd, msg, sender)
---	LXZAPI_OutputDebugStr("cmd 1:"..cmd);
	if(event_callback[cmd] ~= nil) then
--		LXZAPI_OutputDebugStr("cmd 2:"..cmd);
		event_callback[cmd](window, msg, sender);
	end
end

