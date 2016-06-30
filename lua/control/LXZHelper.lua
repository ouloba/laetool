
tblUpdateWnd = {};

--render attr ref 
RenderRefDraggingLogic = {};
RenderRefMoveLogic = {};
RenderRefEditBoxLogic = {};
RenderRefWindow= {};
RenderRefPictureLogic = {};
RenderRefRectangleLogic = {};
RenderRefParticleLogic = {};
RenderRefArrayLXZWindow = {};
WindowRefLogic = {};
local mime = require("mime");

function HelperSetAttribute(wnd, rn,name,ref,v)
	local obj = wnd;
	if rn~= nil then
		obj = wnd:GetRender(rn);
	end
	
	if ref == nil then
		ref = obj:GetAttributeNameRef(name);
	end
	
	obj:SetAttribute(ref,v);	
	return ref;
end


function HelperDecodeURI(s)
	if s == nil then
		return;
	end
--	s=mime.unb64(s);	
--	s=string.gsub(s,"([+/=])", function(h) if h=='+' then  return '-'	 elseif h=='/'  then  return '_'  elseif h=='=' then  return '.'  end  end);
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

function HelperEncodeURI(s)
	if s == nil then
		return;
	end
--	s=mime.b64(s);
--	s=string.gsub(s,"([-_.])",function(h) if h=='-' then return '+' elseif h=='_' then return '/' elseif h=='.' then return '='  end end);
    s=string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end


--LXZMessageBox(string.gsub("-_.","[-_.]", function(h) if h=='-' then return '+' elseif h=='_' then return '/' elseif h=='.' then return '='  end end));
--LXZMessageBox(string.gsub("+/=+/=", "[+/=]", function(h) if h=='+' then  return '-'	 elseif h=='/'  then  return '_'  elseif h=='=' then  return '.'  end  end));


LXZAPI_AddSearchPath(LXZAPIGetWritePath());
local json = luaopen_cjson();

local gdb = nil;
local mem = nil;
local json = luaopen_cjson();
function HelperDBIntialize(dbname)
	--require "path"
	LXZDoFile("sqlite3.lua");	
	local corecfg = ICGuiGetLXZCoreCfg();	
	local  dbfullpath = "";
	if(corecfg.IsEditTool==true) then
		dbfullpath = LXZAPIGetWritePath().."Edit"..dbname;
	else
		dbfullpath = LXZAPIGetWritePath()..dbname;
	end
	--LXZMessageBox("dbfullpath:"..dbfullpath);
	gdb = sqlite3.open(dbfullpath);			
	mem = sqlite3.open_memory();
	return gdb,mem;
end

function HelperAppDB()
	return gdb;
end

function HelperDBCreateTable(db, tblname, remove)	
	local sql = nil;	
	if(remove) then
		 db:exec("drop table "..tblname);		
	end
	
	sql = "create table "..string.lower(tblname).."(id INTEGER PRIMARY KEY autoincrement)";
	local d,err = db:exec(sql);	
	if(d==nil) then
		--LXZMessageBox("HelperCreateTable:"..err.." sql:"..sql);
		return false;
	end		
	return true;
end

--INTEGER,TEXT,REAL
function HelperDBAlterTable(db, tblname, addfield, columntype,default)
	local sql = nil;
	if(default) then
		if(type(default)=='string') then
			sql = "alter table "..string.lower(tblname).." add "..addfield.." "..columntype.." default '"..default.."'";
		else
			sql = "alter table "..string.lower(tblname).." add "..addfield.." "..columntype.." default "..default;
		--	LXZMessageBox("sql:"..sql);
		end
	else
		sql = "alter table "..string.lower(tblname).." add "..addfield.." "..columntype;
	end
	return db:exec(sql);	
end

function helperdb_getfirst(rows)
	if(rows==nil) then
		return;
	end
	for row in rows do
		return row;
	end	
end

function helpdb_select(tbl)
	if(type(tbl)~='table') then
		LXZMessageBox("helpdb_formatkv:"..type(tbl));
		return;
	end

	local value = nil;
	for k,v in pairs(tbl) do
		if(value) then
			if(type(v)=="string") then
				value = value.." and "..k.."='"..v.."'";		
			elseif(type(v)=="number") then
				value = value.." and "..k.."="..v;		
			end
		else
			if(type(v)=="string") then
				value =k.."='"..v.."'";		
			elseif(type(v)=="number") then
				value = k.."="..tostring(v);		
			end
		end
	end
	return value;
end


function helpdb_formatkv(tbl)
	if(type(tbl)~='table') then
		LXZMessageBox("helpdb_formatkv:"..type(tbl));
		return;
	end

	local value = nil;
	for k,v in pairs(tbl) do
		if(value) then
			if(type(v)=="string") then
				value = value..","..k.."='"..v.."'";		
			elseif(type(v)=="number") then
				value = value..","..k.."="..v;		
			end
		else
			if(type(v)=="string") then
				value =k.."='"..v.."'";		
			elseif(type(v)=="number") then
				value = k.."="..tostring(v);		
			end
		end
	end
	return value;
end

function HelperDBHaveTable(db, tblname,field)
	local sql1 = "";
	sql1 = "select name from sqlite_master where type='table' and name='"..string.lower(tblname).."'";
	if(helperdb_getfirst(db:rows(sql1))==nil) then
		return false;
	end
		
	if(field~=nil) then
		sql1 = "select "..field.." from "..string.lower(tblname).." limit 1";
		if(helperdb_getfirst(db:rows(sql1))~=nil) then
			return true;
		end		
	end

	--LXZMessageBox(sql1);
	return false;
end

function HelperFindChildByData(wnd, data)
	local w = wnd:GetFirstChild();
	while(w~= nil) do
		if(w:GetAddData()==data) then
			return w;
		end
	
		w = w:GetNextSibling();
	end
end

function HelperDBUpdate(db,tblname, tbl, select, msgbox)
	if(tbl == nil) then
		return;
	end

	local sql = nil;
	if(select~=nil) then		
		local sql1 = "select * from "..tblname.." where "..select;
		if(helperdb_getfirst(db:rows(sql1))~=nil) then
			if(msgbox) then
				LXZMessageBox(sql1);
			end
			sql = "update "..tblname.." set "..helpdb_formatkv(tbl).." where "..select;
			if(msgbox) then
				LXZMessageBox(sql);
			end
			 assert(db:exec(sql));
			 return;
		end		
	end
		
	sql = "insert into "..tblname.."("..helpdb_getfield(tbl)..") values("..helpdb_getvalue(tbl)..")";	
	if(msgbox) then
		LXZMessageBox(sql);
	end
	
	local _d,err = db:exec(sql);
	if(_d==nil) then
		LXZMessageBox(err.." "..sql);	
	end
	
end

function HelperDBBackup(from,to, tname)
	HelperDBExecute(to, "delete from "..tname);
	local tf=HelperDBSelect(from, "select * from ".. tname, true);
	if(tf == nil or from == nil or to == nil) then
		LXZMessageBox("HelperDBBackup:"..tname.." fail");
		return;
	end
	
	--LXZMessageBox("HelperDBBackup:"..tname.." "..table.getn(tf));	
	for i = 1, table.getn(tf),1 do
		HelperDBUpdate(to, tname, tf[i]);
	end
end

function HelperIPairToKVPair(tbl, fn)
	local ntbl = {};
	for i,v in ipairs(tbl) do
		ntbl[fn(v)] = v;
	end
	return ntbl;
end


function HelperDBSelect(db, sql, t)	
	if(t~= nil) then
		local tbl = {};
		local rows = db:rows(sql);
		if(rows==nil) then
			return tbl;
		end
		
		for row in  rows do
			table.insert(tbl, deepcopy(row));
		end
		return tbl;
	end
	
	return db:rows(sql);
end

function HelperDBExecute(db, sql,msgbox)
	if msgbox then
		LXZMessageBox(sql);
	end
	return db:exec(sql);
end

function HelperQuickSort(a, b, e ,  fn)

	local compare=a:get(b);
	local left =b;
	local right = e;
	
	if(left >right) then
		return;
	end

	 while (left <right) 	do
	
		while ((left <right) and fn(a:get(right),compare)==true)  do
			right = right-1;
		end

		local l = a:get(left);
		a:set(left,  a:get(right));		
		a:set(right, l);

		while ((left <right)  and   fn(a:get(left),compare)==false) do
			left = left+1;
		end

		local l = a:get(right);
		a:set(right,  a:get(left));		
		a:set(left, l);
		
	end

	a:set(right,  a:get(left));	
	
	quick_sort(a, b, right-1, fn);
	quick_sort(a, right+1, e, fn);
end

function HelperGetChild(wnd, name)
	local w = wnd:GetLXZWindow(name);
	if w == nil then
		LXZMessageBox("HelperGetChild :"..name);
		return w;
	end
	return w;
end

function HelperGetRender(wnd, clsname, realname)
	if(wnd==nil) then
		LXZMessageBox("wnd null render:"..clsname);
		return;
	end
	
	local render = nil;
	if(realname==nil) then
		render = wnd:GetRender(clsname);
	else
		render = wnd:GetRender(realname);
	end
	return render;
end

function HelperGetWindowTextColor(wnd, realname)
	local render = HelperGetRender(wnd,"EditBox", realname);
	if(render ~= nil) then
		RenderRefEditBoxLogic.textcolor = render:GetAttributeNameRef("EditBox:normalTextColour", RenderRefEditBoxLogic.textcolor);
		local address = render:GetAddress(RenderRefEditBoxLogic.textcolor);
		--local ptlist = tousertype(address, "LXZPointList");
		return address;
	end	
end

function HelperGetWindowPictureColor(wnd, realname)
	local render = HelperGetRender(wnd,"Picture", realname);
	if(render ~= nil) then
		RenderRefPictureLogic.spritecolor = render:GetAttributeNameRef("Picture:Sprite:color", RenderRefPictureLogic.spritecolor);
		local addr = render:GetAddress(RenderRefPictureLogic.spritecolor);
		local rgba = tousertype(addr, "RGBA");
	--	LXZMessageBox("HelperSetWindowPictureMixPictureColor:"..RenderRefPicture.spritecolor.." r:"..r.." g:"..g.." b:"..b.." a:"..a);
		return rgba.red,rgba.green,rgba.blue,rgba.alpha;
	end
end


function HelperSetWindowTextColor(wnd, r, g, b, a,realname)	
	local render = HelperGetRender(wnd,"EditBox", realname);
	if(render ~= nil) then
		RenderRefEditBoxLogic.textcolor = render:GetAttributeNameRef("EditBox:normalTextColour", RenderRefEditBoxLogic.textcolor);
		local addr = render:GetAddress(RenderRefEditBoxLogic.textcolor);
		local rgba = tousertype(addr, "RGBA");
		rgba.red = r;
		rgba.alpha = a;
		rgba.blue = b;
		rgba.green = g;
	end
end

function HelperSetWindowDragPageDistance(wnd, dist, realname)
	local render = HelperGetRender(wnd,"DraggingLogic", realname);	
	if(render~=nil) then
		RenderRefDraggingLogic.page_distance =  render:GetAttributeNameRef("Dragging:PageScrollLen", RenderRefDraggingLogic.page_distance);
		render:SetAttribute(RenderRefDraggingLogic.page_distance, dist);
	end
end

function HelperSetRectangleColor(wnd, r,g,b,a,realname)
	local render = HelperGetRender(wnd,"Rectangle", realname);	
	if(render ~= nil) then
		RenderRefRectangleLogic.FillColor = render:GetAttributeNameRef("Rect:FillColor", RenderRefRectangleLogic.FillColor);
		local addr = render:GetAddress(RenderRefRectangleLogic.FillColor);
		local rgba = tousertype(addr, "RGBA");
		rgba.red = r;
		rgba.alpha = a;
		rgba.blue = b;
		rgba.green = g;
		--LXZMessageBox("g:"..g);
	end
end

function HelperGetRectangleColor(wnd,realname)
	local render = HelperGetRender(wnd,"Rectangle", realname);
	if(render ~= nil) then
		RenderRefRectangleLogic.FillColor = render:GetAttributeNameRef("Rect:FillColor", RenderRefRectangleLogic.FillColor);
		local addr = render:GetAddress(RenderRefRectangleLogic.FillColor);
		local rgba = tousertype(addr, "RGBA");
		return rgba.red,rgba.green,rgba.blue,rgba.alpha
	end
end

function HelperGetChildWidthSum(wnd)
	local rect = LXZRect:new_local();
	wnd:GetVisualFrame(rect);
	if(wnd:GetWidth()>rect:Width()) then
		return wnd:GetWidth();
	end
	return rect:Width();	
end

function HelperGetChildHeightSum(wnd)
	local rect = LXZRect:new_local();
	wnd:GetVisualFrame(rect);
	if(wnd:GetHeight()>rect:Height()) then
		return wnd:GetHeight();
	end
	return rect:Height();	
end

function HelperGetPrevWidthSum(wnd)
	local sum = 0;
	wnd = wnd:GetPrevSibling();
	while wnd ~= nil do
		sum = sum+wnd:GetWidth();
		wnd = wnd:GetPrevSibling();
	end
	return sum;
end

function HelperGetPrevHeightSum(wnd)
	local sum = 0;
	wnd = wnd:GetPrevSibling();
	while wnd ~= nil do
		sum = sum+wnd:GetHeight();
		wnd = wnd:GetPrevSibling();
	end
	return sum;
end

function HelperGetArrayWindowOffset(wnd)
	local render = wnd:GetRender("ArrayLXZWindowLogic");
	if(render ~= nil) then
		RenderRefArrayLXZWindow.offsetx = render:GetAttributeNameRef("ArrayLXZWindow:Offset:x", RenderRefArrayLXZWindow.offsetx);
		RenderRefArrayLXZWindow.offsety = render:GetAttributeNameRef("ArrayLXZWindow:Offset:y", RenderRefArrayLXZWindow.offsety);
		return tonumber(render:GetAttribute(RenderRefArrayLXZWindow.offsetx)),tonumber(render:GetAttribute(RenderRefArrayLXZWindow.offsety));
	end
end

function HelperSetArrayWindowOffset(wnd, x, y)
	local render = wnd:GetRender("ArrayLXZWindowLogic");
	if(render ~= nil) then
		RenderRefArrayLXZWindow.offsetx = render:GetAttributeNameRef("ArrayLXZWindow:Offset:x", RenderRefArrayLXZWindow.offsetx);
		RenderRefArrayLXZWindow.offsety = render:GetAttributeNameRef("ArrayLXZWindow:Offset:y", RenderRefArrayLXZWindow.offsety);
		render:SetAttribute(RenderRefArrayLXZWindow.offsetx,x);
		render:SetAttribute(RenderRefArrayLXZWindow.offsety,y);
	end
end

function HelperSetWindowText(wnd, text,realname)
	local render = HelperGetRender(wnd,"EditBox", realname);	
	if(render ~= nil) then
		RenderRefEditBoxLogic.text = render:GetAttributeNameRef("EditBox:Text", RenderRefEditBoxLogic.text);
		if text == nil then
			text = "";
		end
		render:SetAttribute(RenderRefEditBoxLogic.text, text);
	else
		LXZMessageBox("HelperSetWindowText:"..text);
	end
end

function HelperSetWindowSymText(wnd, text,realname)
	local render = HelperGetRender(wnd,"EditBox", realname);	
	if(render ~= nil) then
		RenderRefEditBoxLogic.symtext = render:GetAttributeNameRef("EditBox:symContent", RenderRefEditBoxLogic.symtext);
		render:SetAttribute(RenderRefEditBoxLogic.symtext, text);
	end
end

function HelperTrimBreak(text)
	if(string.len(text)>0) then
			if(string.byte(text, -1) ==10) then
				--LXZMessageBox("text has return char:"..text);
				text = string.sub(text, 1, -2);
			end
	end
	return text;
end

function HelperSetEmbededWindow(wnd,name,realname)
	local render = HelperGetRender(wnd,"Window", realname);
	if(render ~= nil) then
		RenderRefWindow.name = render:GetAttributeNameRef("Window:WindowName", RenderRefWindow.name);
		 render:SetAttribute(RenderRefWindow.name, name);		
	end
end

function HelperGetWindowText(wnd,realname)
	--LXZMessageBox("HelperGetWindowText");
	local render = HelperGetRender(wnd,"EditBox", realname);
	if(render ~= nil) then
		RenderRefEditBoxLogic.text = render:GetAttributeNameRef("EditBox:Text", RenderRefEditBoxLogic.text);
		local text =  render:GetAttribute(RenderRefEditBoxLogic.text, text);
		return HelperTrimBreak(text);	
	end
	
	return "0";
end

function HelperSetParticleEmission(wnd, cnt)
	local render = wnd:GetRender("Particle");
	if(render ~= nil) then
		RenderRefParticleLogic.nEmission = render:GetAttributeNameRef("Particle:Info:nEmission", RenderRefParticleLogic.nEmission);				
		render:SetAttribute(RenderRefParticleLogic.nEmission, tostring(cnt));	
	end
end

function HelperSetParticlePsiFile(wnd, file)
	local render = wnd:GetRender("Particle");
	if(render ~= nil) then
		RenderRefParticleLogic.psiFile = render:GetAttributeNameRef("Particle:psiFile", RenderRefParticleLogic.psiFile);	
		render:SetAttribute(RenderRefParticleLogic.psiFile, file);	
	end
	
end

function HelperSetParticleColor(wnd,  rf,gf,bf,af,  rd,gd,bd,ad)
	local render = wnd:GetRender("Particle");
	if(render ~= nil) then
		RenderRefParticleLogic.colorStart = render:GetAttributeNameRef("Particle:Info:colorStart", RenderRefParticleLogic.colorStart);				
		local addr = render:GetAddress(RenderRefParticleLogic.colorStart);
		local rgba = tousertype(addr, "LXZColor");
		rgba.a = af/255;
		rgba.b = bf/255;
		rgba.g = gf/255;
		rgba.r = rf/255;
		
		
		RenderRefParticleLogic.colorEnd = render:GetAttributeNameRef("Particle:Info:colorEnd", RenderRefParticleLogic.colorEnd);				
		local addr = render:GetAddress(RenderRefParticleLogic.colorEnd);
		local rgba = tousertype(addr, "LXZColor");
		rgba.a = ad/255;
		rgba.b = bd/255;
		rgba.g = gd/255;
		rgba.r= rd/255;		
	end
end

FileToColor = {__index=FileToColor};
FileToColor["mushroom_blue"] = 1;
FileToColor["mushroom_red"] = 2;
FileToColor["mushroom_yellow"] = 3;
FileToColor["mushroom_green"] = 4;

function HelperGetWindowColor(wnd)
	local render = wnd:GetRender("color");
	if(render ~= nil) then
		RenderRefPictureLogic.file = render:GetAttributeNameRef("Picture:Sprite:ImageName", RenderRefPictureLogic.file);
		return FileToColor[render:GetAttribute(RenderRefPictureLogic.file)];
	end
	
	return 0;
end

function HelperPauseWindowMove(wnd)
	local render = wnd:GetRender("MoveLogic");
	if(render ~= nil) then
		RenderRefMoveLogic.IsMoving = render:GetAttributeNameRef("MoveLogic:IsMoving", RenderRefMoveLogic.IsMoving);
		render:SetAttribute(RenderRefMoveLogic.IsMoving, "2");		
	end
	
end

function HelperResumeWindowMove(wnd)
	local render = wnd:GetRender("MoveLogic");
	if(render ~= nil) then
		RenderRefMoveLogic.IsMoving = render:GetAttributeNameRef("MoveLogic:IsMoving", RenderRefMoveLogic.IsMoving);
		render:SetAttribute(RenderRefMoveLogic.IsMoving, "1");		
	end
end

function HelperStopWindowMove(wnd)
	local render = wnd:GetRender("MoveLogic");
	if(render ~= nil) then
		RenderRefMoveLogic.IsMoving = render:GetAttributeNameRef("MoveLogic:IsMoving", RenderRefMoveLogic.IsMoving);
		render:SetAttribute(RenderRefMoveLogic.IsMoving, "0");		
	end
end

function HelperSetWindowSpeed(wnd, speed)
	local render = wnd:GetRender("MoveLogic");
	if(render ~= nil) then
		RenderRefMoveLogic.Speed = render:GetAttributeNameRef("MoveLogic:Speed", RenderRefMoveLogic.Speed);				
		render:SetAttribute(RenderRefMoveLogic.Speed, tostring(speed));	
	end
end

function HelperGetWindowSpeed(wnd)
	local render = wnd:GetRender("MoveLogic");
	if(render ~= nil) then
		RenderRefMoveLogic.Speed = render:GetAttributeNameRef("MoveLogic:Speed", RenderRefMoveLogic.Speed);				
		return tonumber(render:GetAttribute(RenderRefMoveLogic.Speed));	
	end
	
	return 0;
end

--加速度
function HelperSetWindowAccelerate(wnd, acc)
	local render = wnd:GetRender("MoveLogic");
	if(render ~= nil) then
		RenderRefMoveLogic.AccSpeed = render:GetAttributeNameRef("MoveLogic:AccSpeed", RenderRefMoveLogic.AccSpeed);				
		render:SetAttribute(RenderRefMoveLogic.AccSpeed, tostring(acc));	
	end
end

function HelperGetWindowAccelerate(wnd)
	local render = wnd:GetRender("MoveLogic");
	if(render ~= nil) then
		RenderRefMoveLogic.AccSpeed = render:GetAttributeNameRef("MoveLogic:AccSpeed", RenderRefMoveLogic.AccSpeed);				
		return tonumber(render:GetAttribute(RenderRefMoveLogic.Speed));	
	end
	
	return 0;
end

function HelperSetWindowMoveTarget(wnd, tox, toy)
	local render = wnd:GetRender("MoveLogic");
	if(render ~= nil) then
		RenderRefMoveLogic.MovePtList = render:GetAttributeNameRef("MoveLogic:Move:PtList", RenderRefMoveLogic.MovePtList);
				
		local address = render:GetAddress(RenderRefMoveLogic.MovePtList);
		local ptlist = tousertype(address, "LXZPointList");

		local pt = LXZPoint:new_local();
		wnd:GetHotPos(pt);
		ptlist:clear();
		ptlist:push_back(pt);
		
		pt.x = tox;
		pt.y = toy;
		ptlist:push_back(pt);
	end
	
end

function HelperWindowMoveTo(wnd, tox, toy, speed, acc)
			
		HelperSetWindowMoveTarget(wnd, tox, toy);
		HelperSetWindowSpeed(wnd, tostring(speed));
		HelperSetWindowAccelerate(wnd, tostring(acc));
		
		local msg  = CLXZMessage:new_local();
		wnd:ProcMessage("OnStartMove",  msg, wnd);
			

end

function HelperCheckChildCollider(wnd, rect)
	local child_rect = LXZRect:new_local();	
	local colliderchild = nil;
	local max = 0;
	local window = wnd:GetFirstChild();
	while (window ~= nil) do 
		window:GetRect(child_rect);
		local rc = rect:Interset(child_rect);
		if(rc:Height()*rc:Width()>max) then
			max = rc:Height()*rc:Width();
			colliderchild=window;
		end	
		window = window:GetNextSibling();
	end
	return colliderchild;
end

function HelperSetRoot(wnd)
	local winmgr = CLXZWindowMgr:Instance();
	winmgr:SetRoot(wnd);
end

function HelperGetRoot()
	local winmgr = CLXZWindowMgr:Instance();
	local wnd =  winmgr:GetRoot();
	return wnd;
end

local CursorLogic = {};
function HelperGetCursorState(name)
	local winmgr = CLXZWindowMgr:Instance();
	local wnd = winmgr:GetCursor();
	if name == nil then
		return wnd:GetState();
	end
	
	local render=HelperGetRender(wnd, "Picture",name);
	if render== nil then
		return wnd:GetState();
	end
		
	CursorLogic.state = render:GetAttributeNameRef("Picture:Base:State", CursorLogic.state);
	LXZAPI_OutputDebugStr("cursor state "..name.." state ref:"..CursorLogic.state.."   value:"..render:GetAttribute(CursorLogic.state))		
	return tonumber(render:GetAttribute(CursorLogic.state));		
end

function HelperSetCursorState(state)
	local winmgr = CLXZWindowMgr:Instance();
	local wnd = winmgr:GetCursor();
	wnd:SetState(state-1);
	wnd:Show();
end

function IntergalTimes(a, b)
	if(math.floor(a/b)==(a/b)) then
		return true;
	end
	
	return false;
end


function HelperShowRender(wnd, name, bShow)
	local render = wnd:GetRender(name);
	if(render~=nil) then
		render.IsVisible = bShow;
	end
end

function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end  -- if
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end  -- for
        return setmetatable(new_table, getmetatable(object))
    end  -- function _copy
    return _copy(object)
end  -- function deepcopy


function EffectTimer(wnd, tblParam)

	if(tblParam.timeFunc == nil) then
		tblParam.timeFunc = LXZAPI_timeGetTime;
	end
	
	if(tblParam.start== nil) then
		tblParam.start = 1;
		
		if(tblParam.relativetime ~= nil) then
			tblParam.time = tblParam.timeFunc()+tblParam.relativetime;
		else
			tblParam.relativetime = tblParam.timeFunc()-tblParam.time;
		end
	end
		
	if(tblParam.playcnt == nil) then
		tblParam.playcnt=1;
	end		

	if(tblParam.timeFunc()>tblParam.time) then
		tblParam.playcnt = tblParam.playcnt-1;		
		if(tblParam.func ~= nil) then
			tblParam.func(wnd, tblParam);
		end
		
		if(tblParam.playcnt<=0) then
			return true;
		else
			tblParam.time = tblParam.timeFunc()+tblParam.relativetime;
		end
	end
	
	return false;
end

function HelperSetWindowPictureLayoutOffset(wnd,  sidename, offset, realname)	
	local render = HelperGetRender(wnd, "Picture", realname);
	if(render ~= nil) then
		--LXZMessageBox("HelperSetWindowTextureFile");
		if(RenderRefPictureLogic.Layout == nil) then
			RenderRefPictureLogic.Layout = {};
		end
		
		RenderRefPictureLogic.Layout[sidename] = render:GetAttributeNameRef("Picture:LayoutRect:"..sidename, RenderRefPictureLogic.Layout[sidename]);
		render:SetAttribute(RenderRefPictureLogic.Layout[sidename], tostring(offset));	
	end
end

function HelperSetWindowPictureColor(wnd, r, g, b, a, realname)
	local render = HelperGetRender(wnd, "Picture", realname);
	if(render ~= nil) then
		RenderRefPictureLogic.spritecolor = render:GetAttributeNameRef("Picture:Sprite:color", RenderRefPictureLogic.spritecolor);
		local addr = render:GetAddress(RenderRefPictureLogic.spritecolor);
		local rgba = tousertype(addr, "RGBA");
	--	LXZMessageBox("HelperSetWindowPictureMixPictureColor:"..RenderRefPicture.spritecolor.." r:"..r.." g:"..g.." b:"..b.." a:"..a);
		rgba.red = r;
		rgba.alpha = a;
		rgba.blue = b;
		rgba.green = g;
		--LXZMessageBox("a:"..a);
	end
end

function HelperSetWindowPicture(wnd,  name, realname)
	local render = HelperGetRender(wnd, "Picture", realname);
	if(render ~= nil) then
		--LXZMessageBox("HelperSetWindowTextureFile");
		RenderRefPictureLogic.imagename = render:GetAttributeNameRef("Picture:Sprite:ImageName", RenderRefPictureLogic.imagename);
		render:SetAttribute(RenderRefPictureLogic.imagename, name);	
	end
end

function HelperSetWindowPictureScale(wnd,  scalex, scaley, realname)
	local render = HelperGetRender(wnd, "Picture", realname);	
	if(render ~= nil) then
		--LXZMessageBox("HelperSetWindowTextureFile");
		RenderRefPictureLogic.ScaleX = render:GetAttributeNameRef("Picture:Sprite:fScaleX", RenderRefPictureLogic.ScaleX);
		RenderRefPictureLogic.ScaleY = render:GetAttributeNameRef("Picture:Sprite:fScaleY", RenderRefPictureLogic.ScaleY);		
		render:SetAttribute(RenderRefPictureLogic.ScaleX, scalex);	
		render:SetAttribute(RenderRefPictureLogic.ScaleY, scaley);	
		--LXZMessageBox("HelperSetWindowPictureScale:"..scalex.." y:"..scaley.." RenderRefPictureLogic.ScaleX:"..RenderRefPictureLogic.ScaleX);
	end
end

function HelperSetWindowPictureScaleByWnd(wnd,  bScaleByWnd, realname)
	local render = HelperGetRender(wnd, "Picture", realname);	
	if(render ~= nil) then
		--LXZMessageBox("HelperSetWindowTextureFile");
		RenderRefPictureLogic.ScaleByWnd = render:GetAttributeNameRef("Picture:Sprite:IsScaleByWnd", RenderRefPictureLogic.ScaleByWnd);
		if(bScaleByWnd==true) then
			render:SetAttribute(RenderRefPictureLogic.ScaleByWnd, "1");	
		else
			render:SetAttribute(RenderRefPictureLogic.ScaleByWnd, "0");	
		end
	end
end

function HelperGetWindowPictureFile(wnd,  realname)
	local render = HelperGetRender(wnd, "Picture", realname);	
	if(render ~= nil) then
		--LXZMessageBox("HelperSetWindowTextureFile");
		RenderRefPictureLogic.file = render:GetAttributeNameRef("Picture:Sprite:file", RenderRefPictureLogic.file);
		return render:GetAttribute(RenderRefPictureLogic.file);	
		--LXZAPI_OutputDebugStr("file:"..name);
	end
end

function HelperSetWindowPictureFile(wnd,  name, realname)
	local render = HelperGetRender(wnd, "Picture", realname);	
	if(render ~= nil) then
		--LXZMessageBox("HelperSetWindowTextureFile");
		RenderRefPictureLogic.file = render:GetAttributeNameRef("Picture:Sprite:file", RenderRefPictureLogic.file);
		render:SetAttribute(RenderRefPictureLogic.file, name);	
		LXZAPI_OutputDebugStr("file:"..name);
	end
end

function HelperSetWindowParticlePic(wnd,  name, realname)
	local render = HelperGetRender(wnd, "Particle", realname);
	if(render ~= nil) then
		--LXZMessageBox("HelperSetWindowTextureFile");
		RenderRefParticleLogic.imagename = render:GetAttributeNameRef("Particle:Sprite:ImageName", RenderRefParticleLogic.imagename);
		render:SetAttribute(RenderRefParticleLogic.imagename, name);	
	end
end

function PlayEffect(name)
	local audio = SimpleAudioEngine:sharedEngine();
	audio:playEffect(name, false);	
end

function DeleteElement(sender, nodeleted)
	
	local wnd = sender:GetFirstChild()
	while wnd ~= nil do
		DeleteElement(wnd, true);
		wnd = wnd:GetNextSibling();
	end
		
	--删除
	tblUpdateWnd[sender:GetID()] = nil;	
	if(nodeleted==nil) then
		sender:Delete();		
	end
	sender.update = nil;
	
end

function EffectFaceIn(wnd, tblParam)
	WindowRefLogic.alpha = wnd:GetAttributeNameRef("CLXZWindow:Mask:alpha", WindowRefLogic.alpha);		
	
	if(tblParam.step==nil) then
		tblParam.step = 2;
	end
	
	if(tblParam.from==nil) then
		tblParam.from=100;
	end
	
	if(tblParam.start==nil) then
		tblParam.start = 1;
		tblParam.old = tonumber(wnd:GetAttribute(WindowRefLogic.alpha));
		wnd:SetAttribute(WindowRefLogic.alpha, tostring(tblParam.from));
		return false;
	end
	
	local alpha = tonumber(wnd:GetAttribute(WindowRefLogic.alpha));
	alpha = alpha+tblParam.step;	
	if(alpha>255) then
		alpha = 255;
	end
	
	wnd:SetAttribute(WindowRefLogic.alpha, tostring(alpha));
	
	if(LXZAPI_timeGetTime()>tblParam.time) then
		wnd:SetAttribute(WindowRefLogic.alpha, tostring(tblParam.old));
		return true;
	end
	
	return false;
end

function HelperGetWindowMask(wnd)
	WindowRefLogic.alpha = wnd:GetAttributeNameRef("CLXZWindow:Mask:alpha", WindowRefLogic.alpha);	
	WindowRefLogic.red = wnd:GetAttributeNameRef("CLXZWindow:Mask:red", WindowRefLogic.red);	
	WindowRefLogic.green = wnd:GetAttributeNameRef("CLXZWindow:Mask:green", WindowRefLogic.green);	
	WindowRefLogic.blue = wnd:GetAttributeNameRef("CLXZWindow:Mask:blue", WindowRefLogic.blue);	
	return tonumber(wnd:GetAttribute(WindowRefLogic.red)),tonumber(wnd:GetAttribute(WindowRefLogic.green)),tonumber(wnd:GetAttribute(WindowRefLogic.blue)),tonumber(wnd:GetAttribute(WindowRefLogic.alpha))
end

function HelperSetWindowMask(wnd,r,g,b,a)
	WindowRefLogic.alpha = wnd:GetAttributeNameRef("CLXZWindow:Mask:alpha", WindowRefLogic.alpha);	
	WindowRefLogic.red = wnd:GetAttributeNameRef("CLXZWindow:Mask:red", WindowRefLogic.red);	
	WindowRefLogic.green = wnd:GetAttributeNameRef("CLXZWindow:Mask:green", WindowRefLogic.green);	
	WindowRefLogic.blue = wnd:GetAttributeNameRef("CLXZWindow:Mask:blue", WindowRefLogic.blue);	
	 wnd:SetAttribute(WindowRefLogic.red, r);
	 wnd:SetAttribute(WindowRefLogic.green,g);
	 wnd:SetAttribute(WindowRefLogic.blue, b);
	 wnd:SetAttribute(WindowRefLogic.alpha, a);	 
end

function EffectFaceInOut(wnd, tblParam, bStop)
	WindowRefLogic.alpha = wnd:GetAttributeNameRef("CLXZWindow:Mask:alpha", WindowRefLogic.alpha);		
	
	if(tblParam.framecount==nil) then
		tblParam.framecount = 1;
	end
	
	if(tblParam.from==nil) then
		tblParam.from=100;
	end
	
	if(tblParam.to==nil) then
		tblParam.to=0;
	end
		
	if(tblParam.playcnt == nil) then
		tblParam.playcnt=1;
	end
	
	if(tblParam.start==nil) then
		tblParam.start = 1;
		if(tblParam.old==nil) then
			tblParam.old = tonumber(wnd:GetAttribute(WindowRefLogic.alpha));
		end
		
		tblParam.saveframe = tblParam.framecount;
		tblParam.step = (tblParam.to-tblParam.from)/tblParam.framecount;		
		wnd:SetAttribute(WindowRefLogic.alpha, tostring(tblParam.from));
		return false;
	end
		
	local alpha = tonumber(wnd:GetAttribute(WindowRefLogic.alpha));
	alpha = alpha+tblParam.step;	
	if(alpha<0 or alpha>255) then
		alpha = tblParam.to;
	end
		
	tblParam.framecount = tblParam.framecount-1;
	wnd:SetAttribute(WindowRefLogic.alpha, tostring(alpha));
	
	if(tblParam.framecount<0) then
		tblParam.playcnt = tblParam.playcnt-1;
		if(tblParam.playcnt<=0) then			
			wnd:SetAttribute(WindowRefLogic.alpha, tostring(tblParam.old));
			if(tblParam.hide ~= nil) then
				wnd:Hide();
				wnd.update = nil;
			end
			
			if(tblParam.del~=nil) then
				DeleteElement(wnd);
				wnd.update = nil;
			end				
			return true;
		else
			tblParam.framecount = tblParam.saveframe;
			wnd:SetAttribute(WindowRefLogic.alpha, tostring(tblParam.from));
		end
	end	

	return false;
end


function EffectFaceOut(wnd, tblParam, bStop)
	WindowRefLogic.alpha = wnd:GetAttributeNameRef("CLXZWindow:Mask:alpha", WindowRefLogic.alpha);		
	
	if(tblParam.step==nil) then
		tblParam.step = 2;
	end
	
	if(tblParam.from==nil) then
		tblParam.from=100;
	end
	
	if(tblParam.End==nil) then
		tblParam.End=0;
	end
	
	if(tblParam.playcnt == nil) then
		tblParam.playcnt=1;
	end
	
	if(tblParam.start==nil) then
		tblParam.start = 1;
		if(tblParam.old==nil) then
			tblParam.old = tonumber(wnd:GetAttribute(WindowRefLogic.alpha));
		end
		
		wnd:SetAttribute(WindowRefLogic.alpha, tostring(tblParam.from));
		return false;
	end
		
	local alpha = tonumber(wnd:GetAttribute(WindowRefLogic.alpha));
	alpha = alpha-tblParam.step;	
	if(alpha<=tblParam.End) then
		tblParam.playcnt = tblParam.playcnt-1;
		if(tblParam.playcnt<=0) then
			alpha = tblParam.End;
			wnd:SetAttribute(WindowRefLogic.alpha, tostring(tblParam.old));
			if(tblParam.hide ~= nil) then
				wnd:Hide();
				wnd.update = nil;
			end
			
			if(tblParam.del~=nil) then
				DeleteElement(wnd);
				wnd.update = nil;
			end				
			return true;
		else
			alpha = tblParam.from;
		end
	end
	wnd:SetAttribute(WindowRefLogic.alpha, tostring(alpha));

	return false;
end

function HelperSetWindowArrayChildPicture(wnd, tbl, imageName, renderName)
	if(tbl == nil) then
		return;
	end
	
	for i = 1, table.getn(tbl), 1 do
		local w = wnd:GetChild(tbl[i]);	
		HelperSetWindowPicture(w, imageName, renderName);
	end

end

function HelperSetWindowArrayChildPictureFile(wnd, tbl, fileName, renderName)
	if(tbl == nil) then
		return;
	end
	
	for i = 1, table.getn(tbl), 1 do
		local w = wnd:GetChild(tbl[i]);	
		HelperSetWindowPictureFile(w, fileName, renderName);
	end

end

 function HelperRandomTable(max, tblRand)
	local val = math.random(1, max);
	local count = 0;
	for i = 1,  table.getn(tblRand), 1 do
		count = count+tblRand[i];			
		if(val<=count) then
			return i;
		end
	end		
	
	return table.getn(tblRand);		
end
	
function EffectRandomSchedule(wnd, tblParam)
	if(tblParam.effect == nil or table.getn(tblParam.effect)<=0) then
		return true;
	end
	
	if(tblParam.rand == nil or table.getn(tblParam.rand)<=0 or table.getn(tblParam.effect)< table.getn(tblParam.rand)) then
		return true;
	end
	
	if(wnd:IsVisible()==false) then
		return false;
	end
	
	if(tblParam.index == nil) then		
		local count = 0;
		for i = 1,  table.getn(tblParam.rand), 1 do
			count = count+tblParam.rand[i];			
		end
		
		tblParam.randsum = count;		
		tblParam.index = HelperRandomTable(tblParam.randsum, tblParam.rand);
	end
	
	if(tblParam.playcnt== nil) then
		tblParam.playcnt = 1;
	end
	
	if(tblParam.backup == nil) then
		tblParam.backup = deepcopy(tblParam.effect);
	end
	
	if(tblParam.effect[tblParam.index].f(wnd, tblParam.effect[tblParam.index].p)==true) then			
		tblParam.playcnt = tblParam.playcnt -1;
		if(tblParam.playcnt <=0) then
			return true;	
		else
			tblParam.effect = deepcopy(tblParam.backup);
			tblParam.index = HelperRandomTable(tblParam.randsum, tblParam.rand);
		end
	end
	
	return false;
end

-- coroutine reuse
local coroutine_pool = {}
local coroutine_yield = coroutine.yield
local coroutine_count = 0
local function co_create(f)
	local co = table.remove(coroutine_pool)
	if co == nil then
		local print = print
		co = coroutine.create(function(...)
			f(...)
			while true do
				f = nil
				coroutine_pool[#coroutine_pool+1] = co
				f = coroutine_yield "EXIT"
				f(coroutine_yield())
			end
		end)
		coroutine_count = coroutine_count + 1
		if coroutine_count > 1024 then
			--skynet.error("May overload, create 1024 task")
			coroutine_count = 0
		end
	else
		coroutine.resume(co, f)
	end
	return co
end

function HelperCoroutine(func)
	local co = coroutine.create(func);	
	local res,err = coroutine.resume(co,co);
	if(res==false) then
		LXZMessageBox("HelperCoroutine:"..err);
	end
	return co;
end

function EffectContainer(wnd, tblParam)
	
	if(tblParam.effect == nil or table.getn(tblParam.effect)<=0) then
		return true;
	end
	
	if(wnd:IsVisible()==false) then
		return false;
	end
	
	if(tblParam.index == nil) then
		tblParam.index = 1;
	end
	
	if(tblParam.playcnt== nil) then
		tblParam.playcnt = 1;
	end
	
	if(tblParam.backup == nil) then
		tblParam.backup = deepcopy(tblParam.effect);
	end
	
	if(tblParam.effect[tblParam.index].f(wnd, tblParam.effect[tblParam.index].p)==true) then
		tblParam.index = tblParam.index+1;
	end
	
	if(tblParam.index>table.getn(tblParam.effect)) then
		tblParam.playcnt = tblParam.playcnt -1;
		if(tblParam.playcnt <=0) then
			return true;	
		else			
			tblParam.effect = deepcopy(tblParam.backup);
			tblParam.index = 1;
		end
	end
	
	return false;
end

function HelperSetWindowPictureAngle(wnd, angle, realname)
	local render = nil;
	if(realname==nil) then
		render = wnd:GetRender("Picture");
	else
		render = wnd:GetRender(realname);
	end
	
	if(angle<0) then
		angle = angle+math.atan(1)*8;
	end
	
	if(render~=nil) then		
		RenderRefPictureLogic.SpriteRadia = render:GetAttributeNameRef("Picture:Sprite:fRadia", RenderRefPictureLogic.SpriteRadia);		
		local fRadia = tonumber(render:GetAttribute(RenderRefPictureLogic.SpriteRadia));		
		render:SetAttribute(RenderRefPictureLogic.SpriteRadia, tostring(angle));				
	end
	
end


function EffectRotateFunc(wnd, tblParam)
	if(tblParam.speed == nil) then
		tblParam.speed = 0.1571;
	end
	
	if(tblParam.playcnt==nil) then
		tblParam.playcnt=1;
	end
	
	if(tblParam.startangle==nil) then
		tblParam.startangle = 0;
	end
	
	if(tblParam.endangle==nil) then
		if(tblParam.speed>0) then
			tblParam.endangle = math.atan(1)*8;
		else
			tblParam.endangle = -math.atan(1)*8;
		end
	end
	
	if(tblParam.curangle == nil) then
		if(tblParam.speed>0) then
			tblParam.curangle = tblParam.startangle;
		else
			tblParam.curangle = tblParam.endangle;
		end
		HelperSetWindowPictureAngle(wnd, tblParam.curangle, tblParam.render);
		if(tblParam.fn ~= nil) then
			tblParam.fn(wnd, tblParam.curangle)
		end
		return false;
	end
	
	if(tblParam.acce==nil) then
		tblParam.acce = 0;
	end
	
	tblParam.speed = tblParam.speed+tblParam.acce;
	
	tblParam.curangle = tblParam.curangle+tblParam.speed;
	if(tblParam.speed>0 and tblParam.curangle>=tblParam.endangle) then
		tblParam.playcnt = tblParam.playcnt-1;
		if(tblParam.playcnt<=0) then
			if(tblParam.noreset == nil) then
				HelperSetWindowPictureAngle(wnd, tblParam.startangle, tblParam.render);
				if(tblParam.fn ~= nil) then
					tblParam.fn(wnd, tblParam.startangle)
				end
			end
			return true;
		else
			tblParam.curangle = tblParam.startangle;
		end		
	elseif(tblParam.speed<0 and tblParam.curangle<=tblParam.startangle) then
		--LXZMessageBox("ddd:"..tblParam.curangle.." :"..tblParam.endangle);
		tblParam.playcnt = tblParam.playcnt-1;
		if(tblParam.playcnt<=0) then
			if(tblParam.noreset == nil) then
				HelperSetWindowPictureAngle(wnd, tblParam.endangle, tblParam.render);
				if(tblParam.fn ~= nil) then
					tblParam.fn(wnd, tblParam.endangle)
				end
			end
			return true;
		else
			tblParam.curangle = tblParam.endangle;
		end		
	end
		
	HelperSetWindowPictureAngle(wnd, tblParam.curangle, tblParam.render);
	if(tblParam.fn ~= nil) then
		tblParam.fn(wnd, tblParam.curangle)
	end
	
	return false;
end


function EffectAnimateNum(wnd, text, thread1,interval)
	
	local nnstr = "";
	local newtext = "";	
	local co = coroutine.create(function (thread)
		HelperSetWindowText(wnd, "");
		if(interval==nil) then
			interval = 35;
		end
				
		for i = 1, string.len(text),1 do
			local time = 0;
			while(1) do			
				AddWndUpdateFunc(wnd, EffectTimer, {time=LXZAPI_timeGetTime()+interval}, thread);
				coroutine.yield();
				PlayEffect("click.wav");
				
				local num = tonumber(string.char(string.byte(text, i)));
				local nn  = math.random(0,9);
				time = time+interval;
				if(time>=200) then
					nn=num;
				end
				
				if(num==nn) then
					nnstr = nnstr..nn;	
					newtext = nnstr;
					for k=i+1,string.len(text),1 do
						local kn = tonumber(string.char(string.byte(text, i)));
						newtext = newtext..math.random(0,kn);
					end
					HelperSetWindowText(wnd, newtext);
					break;
				else
					newtext = nnstr..nn;
					for k=i+1,string.len(text),1 do
						local kn = tonumber(string.char(string.byte(text, i)));
						newtext = newtext..math.random(0,kn);
					end
					HelperSetWindowText(wnd, newtext);
				end				
			end			
			--LXZAPI_OutputDebugStr("newtext:"..newtext);
		end
		
		if(thread1 ~= nil) then
			coroutine.resume(thread1);	
		end
		
	end);	
	coroutine.resume(co, co);	

end


function EffectAnimateNum1(wnd, text, thread1,interval)
	
	local oldtext = HelperGetWindowText(wnd);
	local nnstr = "";
	local newtext = "";	
	local co = coroutine.create(function (thread)
		HelperSetWindowText(wnd, "");
		if(interval==nil) then
			interval = 35;
		end
		
		local len = string.len(text);				
		local oldlen = string.len(oldtext);				
		for i = 1, len,1 do
			
			local kk = 1;
			local index = i-len+oldlen;
			if(index>0) then
				kk = tonumber(string.char(string.byte(oldtext, index)));				
			end			
			--LXZMessageBox("EffectAnimateNum1:"..kk);
			
			while(1) do			
			
				--PlayEffect("click.wav");				
				local num = tonumber(string.char(string.byte(text, i)));
				local nn  = math.mod(kk,10);				
				if(num==nn) then
					nnstr = nnstr..nn;	
					newtext = nnstr;
					for k=i+1,string.len(text),1 do
						local kn = tonumber(string.char(string.byte(text, i)));
						newtext = newtext..kn;
					end
					HelperSetWindowText(wnd, newtext);
					break;
				else
					newtext = nnstr..nn;
					for k=i+1,string.len(text),1 do
						local kn = tonumber(string.char(string.byte(text, i)));
						newtext = newtext..kn;
					end
					HelperSetWindowText(wnd, newtext);
				end		

				kk = kk+1;	
			end		
			
			AddWndUpdateFunc(wnd, EffectTimer, {time=LXZAPI_timeGetTime()+interval}, thread, 1);
			coroutine.yield();
		end
		
		if(thread1 ~= nil) then
			coroutine.resume(thread1);	
		end
		
	end);	
	coroutine.resume(co, co);	

end

function EffectTrace(wnd, tblParam)
	if(tblParam.target == nil or tblParam.target:IsDeleted()==true) then
		return true;
	end
	
	if(tblParam.start == nil) then
		tblParam.start = 1;
		tblParam.id = tblParam.target:GetID();
		return false;
	end
	
	if(tblParam.target:GetID()~= tblParam.id) then
		return true;		
	end
	
	if(tblParam.func ~= nil) then
		if(tblParam.func(tblParam.target)==false) then
			return true;
		end
	end
	
	local pt = LXZPoint:new_local();	
	tblParam.target:GetHotPos(pt);
	pt.x = pt.x+tblParam.offsetx;
	pt.y = pt.y+tblParam.offsety;
	wnd:SetHotPos(pt);
		
	return false;	
end

function EffectShake(wnd, tblParam)
	if(tblParam.pos == nil or table.getn(tblParam.pos)==0) then
		return true;
	end
	
	if(tblParam.scale==nil) then
		tblParam.scale = 1;
	end
	
	if(tblParam.playcnt == nil) then
		tblParam.playcnt = 1;
	end
	
	local pt = LXZPoint:new_local();
	if(tblParam.index == nil) then
		tblParam.index = 1;
		wnd:GetHotPos(pt);
		tblParam.oldx = pt.x;
		tblParam.oldy = pt.y;
	end
		
	wnd:GetHotPos(pt);
	pt.x = pt.x+tblParam.pos[tblParam.index].x*tblParam.scale;
	pt.y = pt.y+tblParam.pos[tblParam.index].y*tblParam.scale;	
	tblParam.index = tblParam.index+1;
	if(tblParam.index>table.getn(tblParam.pos)) then
		tblParam.playcnt = tblParam.playcnt-1;
		if(tblParam.playcnt<=0) then
			pt.x = tblParam.oldx;
			pt.y = tblParam.oldy;
			wnd:SetHotPos(pt);
			return true;
		end
		
		tblParam.index = 1;
	end
	
	wnd:SetHotPos(pt);
	return false;
	
end

function EffectAnimate(wnd, tblParam, stop)
	if(tblParam.time==nil) then
		tblParam.time=0;
	end

	if(tblParam.interval== nil) then
		tblParam.interval = 100;
	end
	
	if(tblParam.frame == nil or table.getn(tblParam.frame)==0) then
		return true;
	end
	
	if(wnd:IsBitSet(STATUS_IsVisible)==false) then
		return false;
	end
	
	if(tblParam.playcnt==nil) then
		tblParam.playcnt = 1;
	end
	
	if(tblParam.index == nil) then
		tblParam.index = 1;
	end
	
	if(tblParam.start==nil) then
		tblParam.start=1;
		HelperSetWindowPicture(wnd, tblParam.frame[tblParam.index], tblParam.render);
		HelperSetWindowArrayChildPicture(wnd:GetParent(), tblParam.child, tblParam.frame[tblParam.index], tblParam.render);
		
		if(tblParam.file ~= nil) then
			HelperSetWindowPictureFile(wnd, tblParam.file[tblParam.index], tblParam.render);
			HelperSetWindowArrayChildPictureFile(wnd:GetParent(), tblParam.child, tblParam.file[tblParam.index], tblParam.render);
		end
		
		tblParam.index=tblParam.index+1;	
		tblParam.time = tblParam.interval+LXZAPI_timeGetTime();
		return false;
	end
			
	if(LXZAPI_timeGetTime()>=tblParam.time) then
	
		if(tblParam.index>table.getn(tblParam.frame)) then
			if(tblParam.playcnt<=1) then			
				if(tblParam.noreset==nil) then
					HelperSetWindowPicture(wnd, tblParam.frame[1], tblParam.render);
					HelperSetWindowArrayChildPicture(wnd:GetParent(), tblParam.child, tblParam.frame[1], tblParam.render);
					if(tblParam.file ~= nil) then
						HelperSetWindowPictureFile(wnd, tblParam.file[1], tblParam.render);
						HelperSetWindowArrayChildPictureFile(wnd:GetParent(), tblParam.child, tblParam.file[1], tblParam.render);
					end
				end
				
				if(tblParam.func ~= nil) then
					tblParam.func(wnd, tblParam);
				end
				
				return true;
			else
				tblParam.playcnt = tblParam.playcnt-1;
				tblParam.index = math.mod(tblParam.index,table.getn(tblParam.frame));
			end
		end		
		
		HelperSetWindowPicture(wnd, tblParam.frame[tblParam.index], tblParam.render);
		HelperSetWindowArrayChildPicture(wnd:GetParent(), tblParam.child, tblParam.frame[tblParam.index], tblParam.render);
		if(tblParam.file ~= nil) then
			HelperSetWindowPictureFile(wnd, tblParam.file[tblParam.index], tblParam.render);
			HelperSetWindowArrayChildPictureFile(wnd:GetParent(), tblParam.child, tblParam.file[tblParam.index], tblParam.render);
		end
		
		--LXZAPI_OutputDebugStr("EffectAnimate:"..tblParam.frame[tblParam.index]);
		tblParam.index=tblParam.index+1;	
		tblParam.time = tblParam.interval+LXZAPI_timeGetTime();
	end	
	
	return false;	

end


function EffectParticleAnimate(wnd, tblParam)
	if(tblParam.time==nil) then
		tblParam.time=0;
	end

	if(tblParam.interval== nil) then
		tblParam.interval = 100;
	end
	
	if(tblParam.frame == nil or table.getn(tblParam.frame)==0) then
		return true;
	end
	
	if(tblParam.playcnt==nil) then
		tblParam.playcnt = 1;
	end
	
	if(tblParam.index==nil) then
		tblParam.index=1;
		HelperSetWindowParticlePic(wnd, tblParam.frame[tblParam.index]);
		
		if(tblParam.file ~= nil) then
			HelperSetWindowPictureFile(wnd, tblParam.file[tblParam.index]);
		end
		
		tblParam.index=tblParam.index+1;	
		tblParam.time = tblParam.interval+LXZAPI_timeGetTime();
		return false;
	end
			
	if(LXZAPI_timeGetTime()>=tblParam.time) then
	
		if(tblParam.index>table.getn(tblParam.frame)) then
			if(tblParam.playcnt<=1) then			
				if(tblParam.noreset==nil) then
					HelperSetWindowParticlePic(wnd, tblParam.frame[1]);
					if(tblParam.file ~= nil) then
						HelperSetWindowPictureFile(wnd, tblParam.file[1]);
					end
				end
				return true;
			else
				tblParam.playcnt = tblParam.playcnt-1;
				tblParam.index = math.mod(tblParam.index,table.getn(tblParam.frame));
			end
		end		
		
		HelperSetWindowParticlePic(wnd, tblParam.frame[tblParam.index]);
		if(tblParam.file ~= nil) then
			HelperSetWindowPictureFile(wnd, tblParam.file[tblParam.index]);
		end
		
		--LXZAPI_OutputDebugStr("EffectAnimate:"..tblParam.frame[tblParam.index]);
		tblParam.index=tblParam.index+1;	
		tblParam.time = tblParam.interval+LXZAPI_timeGetTime();
	end	
	
	return false;	

end



function HelperSetWindowExtXY(wnd, x,y)
	WindowRefLogic.ExtX = wnd:GetAttributeNameRef("CLXZWindow:SIZE:nExtX", WindowRefLogic.ExtX);
	WindowRefLogic.ExtY  = wnd:GetAttributeNameRef("CLXZWindow:SIZE:nExtY", WindowRefLogic.ExtY);
	wnd:SetAttribute(WindowRefLogic.ExtX, x);
	wnd:SetAttribute(WindowRefLogic.ExtY, y);
end

function HelperGetWindowExtXY(wnd)
	WindowRefLogic.ExtX = wnd:GetAttributeNameRef("CLXZWindow:SIZE:nExtX", WindowRefLogic.ExtX);
	WindowRefLogic.ExtY = wnd:GetAttributeNameRef("CLXZWindow:SIZE:nExtY", WindowRefLogic.ExtY);
	return tonumber(wnd:GetAttribute(WindowRefLogic.ExtX)), tonumber(wnd:GetAttribute(WindowRefLogic.ExtY));
end

function HelperSetWindowExtX(wnd, x)
	WindowRefLogic.ExtX = wnd:GetAttributeNameRef("CLXZWindow:SIZE:nExtX", WindowRefLogic.ExtX);
	wnd:SetAttribute(WindowRefLogic.ExtX, x);
end

function HelperSetWindowHotAligned(wnd, aligned)
	WindowRefLogic.HotAligned = wnd:GetAttributeNameRef("CLXZWindow:Hot:nHotAlign", WindowRefLogic.HotAligned);
	wnd:SetAttribute(WindowRefLogic.HotAligned, aligned);
end

function HelperGetWindowHotAligned(wnd)
	WindowRefLogic.HotAligned = wnd:GetAttributeNameRef("CLXZWindow:Hot:nHotAlign", WindowRefLogic.HotAligned);
	return tonumber(wnd:GetAttribute(WindowRefLogic.HotAligned));
end

function HelperGetWindowExtX(wnd)
	WindowRefLogic.ExtX = wnd:GetAttributeNameRef("CLXZWindow:SIZE:nExtX", WindowRefLogic.ExtX);
	return tonumber(wnd:GetAttribute(WindowRefLogic.ExtX));
end

function HelperSetWindowExtY(wnd, y)
	WindowRefLogic.ExtY = wnd:GetAttributeNameRef("CLXZWindow:SIZE:nExtY", WindowRefLogic.ExtY);
	wnd:SetAttribute(WindowRefLogic.ExtY, y);
end

function HelperGetWindowExtY(wnd)
	WindowRefLogic.ExtY = wnd:GetAttributeNameRef("CLXZWindow:SIZE:nExtY", WindowRefLogic.ExtY);
	return tonumber(wnd:GetAttribute(WindowRefLogic.ExtY));
end

function HelperGetWindowScaleX(wnd)
	WindowRefLogic.ScaleX = wnd:GetAttributeNameRef("CLXZWindow:Scale:fScaleX", WindowRefLogic.ScaleX);	
	return tonumber(wnd:GetAttribute(WindowRefLogic.ScaleX));
end

function HelperGetWindowScaleY(wnd)
	WindowRefLogic.ScaleY = wnd:GetAttributeNameRef("CLXZWindow:Scale:fScaleY", WindowRefLogic.ScaleY);	
	return tonumber(wnd:GetAttribute(WindowRefLogic.ScaleY));
end

function EffectZoomInRectFunc(wnd, tblParam)
	if(tblParam.dst == nil) then
		return;
	end
	
	local scalex = HelperGetWindowScaleX(wnd);
	local scaley = HelperGetWindowScaleY(wnd);
	
	if(tblParam.src == nil) then
		local rect = LXZRect:new_local();
		wnd:GetRect(rect,false);
		tblParam.src = {l=rect.left, r=rect.right, t=rect.top, b=rect.bottom};
	end
	
	if(tblParam.framecount == nil) then
		tblParam.framecount = 1;
	end
	
	local pt = LXZPoint:new_local();
	if(tblParam.start == nil) then		
		local topt = LXZPoint:new_local();	
		local vec = LXZVector2D:new_local();
		local rect = LXZRect:new_local();
		rect.left = tblParam.src.l; rect.top = tblParam.src.t;rect.right=tblParam.src.r;rect.bottom=tblParam.src.b;
		wnd:GetHotPosByRect(rect,pt);
		rect.left = tblParam.dst.l; rect.top = tblParam.dst.t;rect.right=tblParam.dst.r;rect.bottom=tblParam.dst.b;
		wnd:GetHotPosByRect(rect,topt);
		tblParam.fromx = pt.x;
		tblParam.fromy = pt.y;
		tblParam.tox = topt.x;
		tblParam.toy = topt.y; 
		vec.x = topt.x-pt.x;
		vec.y = topt.y-pt.y;
		tblParam.dist = math.sqrt(vec.x*vec.x+vec.y*vec.y);
		tblParam.start = 1;
		tblParam.toscalex = (tblParam.dst.r-tblParam.dst.l)/(tblParam.src.r-tblParam.src.l);
		tblParam.toscaley = (tblParam.dst.b-tblParam.dst.t)/(tblParam.src.b-tblParam.src.t);
		tblParam.stepscalex = (tblParam.toscalex-scalex)/tblParam.framecount;
		tblParam.stepscaley = (tblParam.toscaley-scaley)/tblParam.framecount;
		vec:normalize();
		tblParam.stepdist = tblParam.dist/tblParam.framecount;
		tblParam.dirx = vec.x;
		tblParam.diry = vec.y;
		tblParam.curx = tblParam.fromx;
		tblParam.cury = tblParam.fromy;
		tblParam.oldscalex = scalex;
		tblParam.oldscaley = scaley;
	end
	
	local dist = tblParam.stepdist;
	if(tblParam.dist<dist) then
		dist = tblParam.dist;
	end
	
	tblParam.curx = tblParam.curx+tblParam.dirx*dist;
	tblParam.cury = tblParam.cury+tblParam.diry*dist;
	pt.x = tblParam.curx;
	pt.y = tblParam.cury;
	wnd:SetHotPos(pt);
	
	scalex = scalex+tblParam.stepscalex;
	scaley = scaley+tblParam.stepscaley;
	wnd:SetScale(scalex, scaley);
	
	tblParam.framecount = tblParam.framecount-1;
	if(tblParam.framecount<=0) then
		if(tblParam.reset) then
			pt.x = tblParam.fromx;
			pt.y = tblParam.fromy;
			wnd:SetHotPos(pt);
			wnd:SetScale(tblParam.oldscalex, tblParam.oldscaley);
			wnd:SetWidth(tblParam.src.r-tblParam.src.l);
			wnd:SetHeight(tblParam.src.b-tblParam.src.t);
		end	
		return true;
	end
		
	return false;
end

function EffectZoomInFunc(wnd, tblParam)
	--
		
	--
	WindowRefLogic.ScaleX = wnd:GetAttributeNameRef("CLXZWindow:Scale:fScaleX", WindowRefLogic.ScaleX);		
	WindowRefLogic.ScaleY = wnd:GetAttributeNameRef("CLXZWindow:Scale:fScaleY", WindowRefLogic.ScaleY);
	
	if(tblParam.min==nil) then
		tblParam.min= 0.1;
	end
	
	if(tblParam.step==nil) then
		tblParam.step = 0.001;
	end
	
	if(tblParam.max==nil) then
		tblParam.max = 2;
	end
	
	if(tblParam.playcnt == nil) then
		tblParam.playcnt = 1;
	end
	
	if(tblParam.acc== nil) then
		tblParam.acc=0;
	else
		if(tblParam.acc>0 and tblParam.stepmax==nil) then
			tblParam.stepmax = tblParam.step*10;
		elseif(tblParam.acc<0 and tblParam.stepmin==nil) then
			tblParam.stepmin = tblParam.step/100;
		end
	end
			
	local scale = tonumber(wnd:GetAttribute(WindowRefLogic.ScaleX));
	if(tblParam.oldscale==nil) then
		tblParam.oldscale=scale;
		
		if(tblParam.step>0) then
			scale = tblParam.min;
		else
			scale = tblParam.max;
		end
		
		wnd:SetAttribute(WindowRefLogic.ScaleX, tostring(scale));
		wnd:SetAttribute(WindowRefLogic.ScaleY, tostring(scale));			
	else
		scale = scale+tblParam.step;
	end
	
	tblParam.currentscale = scale;
		
	if(tblParam.step>0 and scale>tblParam.max) then
		tblParam.playcnt = tblParam.playcnt-1;
		if(tblParam.playcnt<=0) then			
			scale = tblParam.max;
			if(tblParam.oldscale~=nil) then
				if(tblParam.noreset==nil) then
					wnd:SetAttribute(WindowRefLogic.ScaleX, tostring(tblParam.oldscale));
					wnd:SetAttribute(WindowRefLogic.ScaleY, tostring(tblParam.oldscale));					
				end
			end
			--LXZMessageBox("EffectZoomInFunc");
			if(tblParam.func~=nil) then
				tblParam.func(wnd, tblParam);
			end
			
			return true;		
		else
			scale = tblParam.min;
		end
	elseif(tblParam.step<0 and scale<tblParam.min) then	
		tblParam.playcnt = tblParam.playcnt-1;
		if(tblParam.playcnt<=0) then			
			if(tblParam.oldscale~=nil) then
				if(tblParam.noreset==nil) then
					wnd:SetAttribute(WindowRefLogic.ScaleX, tostring(tblParam.oldscale));
					wnd:SetAttribute(WindowRefLogic.ScaleY, tostring(tblParam.oldscale));					
				end
			end
			--LXZMessageBox("EffectZoomInFunc 222");
		
			if(tblParam.func~=nil) then
				tblParam.func(wnd, tblParam);
			end
			
			return true;		
		else
			scale = tblParam.max;
		end
	end
		
	tblParam.step = tblParam.step + tblParam.acc;
	if(tblParam.acc>0 and tblParam.step>tblParam.stepmax) then
		tblParam.step = tblParam.stepmax;
	elseif(tblParam.acc<0 and tblParam.step<tblParam.stepmin) then
		tblParam.step = tblParam.stepmin;
	end
	
	wnd:SetAttribute(WindowRefLogic.ScaleX, tostring(scale));
	wnd:SetAttribute(WindowRefLogic.ScaleY, tostring(scale));		
	
	return false;
end

function EffectAttribute(wnd, tblParam)
	--attribute reference.
	if(WindowRefLogic[tblParam.attribute]==nil) then
		WindowRefLogic[tblParam.attribute] = wnd:GetAttributeNameRef(tblParam.attribute, WindowRefLogic[tblParam.attribute]);		
	end
	
	if(tblParam.step == nil) then
		tblParam.step = (tblParam.to-tblParam.from)/tblParam.frames;
	end
	
	--start
	if(tblParam._frame == nil) then
		tblParam._frame = 0;
	end
	
	local bRet  =  false;
	if(tblParam._frame>=tblParam.frames) then
		bRet = true;
	end
	
	local v = tblParam.from+tblParam.step*tblParam._frame;
	if(bRet==true) then
		v = tblParam.to;
	end
	
	if(tblParam.diction ~= nil) then
		v = tblParam.diction[v];
	end	
	
	wnd:SetAttribute(WindowRefLogic[tblParam.attribute], v);
	tblParam._frame = tblParam._frame+1;	
	tblParam._v = v;
	
	--LXZAPI_OutputDebugStr("v:"..v.." step:"..tblParam.step.." from:"..tblParam.from..);
		
	return bRet;
end


function EffectFunction(wnd, tblParam)

	if(tblParam.step == nil) then
		tblParam.step = (tblParam.to-tblParam.from)/tblParam.frames;
	end
	
	--start
	if(tblParam._frame == nil) then
		tblParam._frame = 0;
	end
	
	local bRet  =  false;
	if(tblParam._frame>=tblParam.frames) then
		bRet = true;
	end
	
	local v = tblParam.from+tblParam.step*tblParam._frame;
	if(bRet==true) then
		v = tblParam.to;
	end
	
	if(tblParam.diction ~= nil) then
		v = tblParam.diction[v];
	end	
	
	if(tblParam.func~=nil) then
		tblParam.func(wnd,v);
	end
	
	tblParam._frame = tblParam._frame+1;	
	tblParam._v = v;
	
	--LXZAPI_OutputDebugStr("v:"..v.." step:"..tblParam.step.." from:"..tblParam.from..);
		
	return bRet;
end

function EffectZoomOutFunc(wnd, tblParam)
	
	--
	WindowRefLogic.ScaleX = wnd:GetAttributeNameRef("CLXZWindow:Scale:fScaleX", WindowRefLogic.ScaleX);		
	WindowRefLogic.ScaleY = wnd:GetAttributeNameRef("CLXZWindow:Scale:fScaleY", WindowRefLogic.ScaleY);
	
	if(tblParam.from==nil) then
		tblParam.from= 1;
	end
	
	if(tblParam.step==nil) then
		tblParam.step = 0.001;
	end
	
	if(tblParam.min==nil) then
		tblParam.min = 0.1;
	end
	
	if(tblParam.playcnt == nil) then
		tblParam.playcnt = 1;
	end
	
	if(tblParam.acc== nil) then
		tblParam.acc=0;
	end
			
	local scale = tonumber(wnd:GetAttribute(WindowRefLogic.ScaleX));
	if(tblParam.oldscale==nil) then
		tblParam.oldscale=1;
		scale = tblParam.from;
		--wnd:SetAttribute(WindowRefLogic.ScaleX, tostring(scale));
		--wnd:SetAttribute(WindowRefLogic.ScaleY, tostring(scale));	
		wnd:SetScale(scale, scale);		
	else
		scale = scale-tblParam.step;
	end
		
	if(scale<tblParam.min) then
		tblParam.playcnt = tblParam.playcnt-1;
		if(tblParam.playcnt<=0) then			
			if(tblParam.oldscale~=nil) then
				if(tblParam.noreset==nil) then
					--wnd:SetAttribute(WindowRefLogic.ScaleX, tostring(tblParam.oldscale));
					--wnd:SetAttribute(WindowRefLogic.ScaleY, tostring(tblParam.oldscale));					
					wnd:SetScale(tblParam.oldscale, tblParam.oldscale);
				end
			end
			
			if(tblParam.func~=nil) then
				tblParam.func(wnd, tblParam);
			end
			
			if(tblParam.debug) then
				LXZAPI_OutputDebugStr("End Name:"..wnd:GetName().." scale:"..scale.." ".. helpdb_formatkv(tblParam));
			end
			return true;		
		else
			scale = tblParam.from;
		end
	end
	
	tblParam.step = tblParam.step + tblParam.acc;
	
	wnd:SetScale(scale, scale);
	--wnd:SetAttribute(WindowRefLogic.ScaleX, tostring(scale));
	--wnd:SetAttribute(WindowRefLogic.ScaleY, tostring(scale));		
	
	if(tblParam.debug) then
		LXZAPI_OutputDebugStr("Name:"..wnd:GetName().." scale:"..scale.." ".. helpdb_formatkv(tblParam));
	end
	
	return false;
end

function EffectBlink(wnd, tblParam)

	if(tblParam.times==nil) then
		tblParam.times = 10;
	end
	
	if(tblParam.duration==nil) then
		tblParam.duration = 1.0;
	end
	
	if(tblParam.start == nil) then
		tblParam.start = 1;
		tblParam.time = 0;
		tblParam.slice = 1.0/tblParam.times;
		tblParam.prevtime = LXZAPI_timeGetTime();
		tblParam.oldstate = wnd:IsVisible();
		return;
	end
	
	local dt = (LXZAPI_timeGetTime()-tblParam.prevtime)/1000.0;
	tblParam.time = tblParam.time+dt;
	local fm = math.mod(tblParam.time,tblParam.slice);
	tblParam.prevtime = LXZAPI_timeGetTime();

	if(tblParam.time>=tblParam.duration) then
		if(tblParam.oldstate==true) then
			wnd:SetBit(STATUS_IsVisible);
		else
			wnd:DelBit(STATUS_IsVisible);
		end
		return true;
	end
	
	if((fm*2)>tblParam.slice) then
		wnd:SetBit(STATUS_IsVisible);
	else
		wnd:DelBit(STATUS_IsVisible);
	end
	
	return false;
end

function EffectJump(wnd, tblParam)
	if(tblParam.jumps == nil) then
		tblParam.jumps = 1;
	end
	
	if(tblParam.duration == nil) then
		tblParam.duration = 1.0;
	end
	
	if(tblParam.height == nil) then
		tblParam.height = 10;
	end
	
	if(tblParam.playcnt == nil) then
		tblParam.playcnt = 1;
	end
	
	if(tblParam.deltax==nil) then
		tblParam.deltax=0;
	end
	
	if(tblParam.deltay==nil) then
		tblParam.deltay=1;
	end
		
	--start
	local pt = LXZPoint:new_local();
	if(tblParam.start == nil) then
		tblParam.start = 1;
		wnd:GetHotPos(pt);
		tblParam.x = pt.x;
		tblParam.y = pt.y;
		if(tblParam.reverse==nil) then
			tblParam.dt = 0;
		else
			tblParam.dt = tblParam.duration;
		end
		
		if(tblParam.oldx==nil) then
			tblParam.oldx = pt.x;
			tblParam.oldy = pt.y;
		end
		
		tblParam.time = tblParam.duration;
		tblParam.prevtime = LXZAPI_timeGetTime();
		--LXZAPI_OutputDebugStr("x:"..pt.x.." y:"..pt.y.."  ");
		return false;
	end
	
	local dt = (LXZAPI_timeGetTime()-tblParam.prevtime)/1000.0;
	if(tblParam.reverse==nil) then
		tblParam.dt = tblParam.dt+dt;
	else
		tblParam.dt = tblParam.dt-dt;
	end
	tblParam.prevtime = LXZAPI_timeGetTime();
	
	local frac = math.mod(tblParam.dt*tblParam.jumps, 1);
	local y = tblParam.height*4*frac*(1-frac);
	local dy = y+tblParam.deltay*tblParam.dt;
	local dx = tblParam.deltax*tblParam.dt;
	tblParam.y = tblParam.oldy-dy;
	tblParam.x = tblParam.oldx+dx;
--	LXZAPI_OutputDebugStr("dx:"..dx.." dy:"..dy.."  ");
		
	pt.x = tblParam.x;
	pt.y = tblParam.y;	
	wnd:SetHotPos(pt);
		
	if(tblParam.dt>=tblParam.duration or tblParam.dt<=0) then
		tblParam.playcnt = tblParam.playcnt-1;
		if(tblParam.playcnt<=0) then
			if(tblParam.func ~=nil) then
				tblParam.func(wnd,tblParam);				
			end
			
			if(tblParam.reset  ~= nil and tblParam.reset==true) then
				pt.x = tblParam.oldx;
				pt.y = tblParam.oldy;
				wnd:SetHotPos(pt);				
			end
			
			--LXZMessageBox("deltay:"..(tblParam.y-tblParam.oldy));			
			return true;
		else			
			tblParam.start = nil;
		end	
	end
	
	return false;
end


function EffectRotateMove(wnd, tblParam)
	if(tblParam.from == nil) then
		tblParam.from = 0;
	end
	
	if(tblParam.to == nil) then
		tblParam.to = math.atan(1)*8;
	end
	
	if(tblParam.speed == nil) then
		tblParam.speed = 0.1;
	end
	
	if(tblParam.radiu == nil) then
		tblParam.radiu = 100;
	end
	
	if(tblParam.orgx==nil) then
		tblParam.orgx=0;
		tblParam.orgy=0;
	end
	
	if(tblParam.playcnt == nil) then
		tblParam.playcnt = 1;
	end
	
	local pt = LXZPoint:new_local();
	
	if(tblParam.init == nil) then
		tblParam.init = 1;
		tblParam.cur = tblParam.from;
		tblParam.x = tblParam.radiu*math.cos(tblParam.cur);
		tblParam.y = tblParam.radiu*math.sin(tblParam.cur);
		pt.x = tblParam.x+tblParam.orgx;
		pt.y = tblParam.y+tblParam.orgy;
		wnd:SetHotPos(pt);
		return 0;
	end
	
	tblParam.cur = tblParam.cur+tblParam.speed;
	if((tblParam.cur>=tblParam.to and tblParam.speed>0) or (tblParam.cur<tblParam.to and tblParam.speed<0)) then
		tblParam.cur = tblParam.to;
		tblParam.x = tblParam.radiu*math.cos(tblParam.cur);
		tblParam.y = tblParam.radiu*math.sin(tblParam.cur);
		pt.x = tblParam.x+tblParam.orgx;
		pt.y = tblParam.y+tblParam.orgy;
		wnd:SetHotPos(pt);
		tblParam.playcnt = tblParam.playcnt-1;
		if(tblParam.playcnt<=0) then
			if(tblParam.func~= nil) then
				tblParam.func(wnd,tblParam);
			end
			return true;
		end
		
		tblParam.cur = tblParam.start;				
	end
	
	tblParam.x = tblParam.radiu*math.cos(tblParam.cur);
	tblParam.y = tblParam.radiu*math.sin(tblParam.cur);
	pt.x = tblParam.x+tblParam.orgx;
	pt.y = tblParam.y+tblParam.orgy;
	wnd:SetHotPos(pt);
	
	return false;
end

function EffectMove(wnd, tblParam)
	if(tblParam.speed== nil) then
		tblParam.speed = 1;
	end
	
	if(tblParam.get==nil) then
		tblParam.get = function(w) local pt = LXZPoint:new_local(); w:GetHotPos(pt,tblParam.screen); return pt.x, pt.y; end;
	end
	
	if(tblParam.set==nil) then
		tblParam.set = function(w,x,y) 
			local pt = LXZPoint:new_local();
			pt.x=x; pt.y=y; 
			w:SetHotPos(pt,tblParam.screen);
			end;
	end
	
	if(tblParam.time == nil) then
		tblParam.time = LXZAPI_timeGetTime();
	end
		
	if(tblParam.acce == nil) then
		tblParam.acce = 0;
	end
	
	if(tblParam.fromx == nil) then
		local pt = LXZPoint:new_local();
		--wnd:GetHotPos(pt);
		if(tblParam.link~= nil) then
			pt.x,pt.y = tblParam.get(wnd:GetParent():GetChild(tblParam.link));
			--LXZMessageBox(tblParam.link);
		else
			pt.x,pt.y=tblParam.get(wnd);
		end
		
		tblParam.fromx = pt.x;
		tblParam.fromy = pt.y;
	end
	
	if(tblParam.dir==nil) then
		tblParam.dir =1;
		local vec = LXZVector2D:new_local();
		vec.x = tblParam.x-tblParam.fromx;
		vec.y = tblParam.y-tblParam.fromy;
		vec:normalize();
		tblParam.dirx = vec.x;
		tblParam.diry = vec.y;
	end
	
	if(tblParam.stop~= nil and tblParam.stop==true) then
		return true;
	end
	
	local pt = LXZPoint:new_local();
	local dir = {{x=0,y=1}, {x=0, y=-1},{x=1,y=0}, {x=-1,y=0}};	
	if(tblParam.dirx == nil or tblParam.diry==nil) then
		tblParam.dirx = dir[tblParam.dir].x;
		tblParam.diry = dir[tblParam.dir].y;
	end
	
	if(tblParam.range == nil) then
		tblParam.range = 10;
	end
		
	if(tblParam.x == nil) then
		local pt = LXZPoint:new_local();
		if(tblParam.link~= nil) then
			pt.x,pt.y=tblParam.get(wnd:GetParent():GetChild(tblParam.link));
		else
			pt.x,pt.y=tblParam.get(wnd);			
		end
		
		pt.x = pt.x+tblParam.range*tblParam.dirx;
		pt.y = pt.y+tblParam.range*tblParam.diry;
		
		tblParam.x = pt.x;
		tblParam.y = pt.y;		
	end
	
	if(tblParam.fromx==tblParam.x and tblParam.fromy==tblParam.y) then
		return true;
	end
		
	if(tblParam.start == nil) then
		if(tblParam.link~= nil) then
			pt.x,pt.y=tblParam.get(wnd:GetParent():GetChild(tblParam.link));			
		else			
			pt.x,pt.y=tblParam.get(wnd);
		end
		
		tblParam.oldx = pt.x;
		tblParam.oldy = pt.y;		
		tblParam.start = 1;			
		pt.x = tblParam.fromx;
		pt.y = tblParam.fromy;
		--wnd:SetHotPos(pt);		
		tblParam.set(wnd, pt.x, pt.y);
		wnd:Show();
		tblParam.curx = pt.x;
		tblParam.cury = pt.y;
		
		local offsetx = pt.x-tblParam.x;
		local offsety = pt.y-tblParam.y;
		local dist = math.sqrt(offsetx*offsetx+offsety*offsety);
		tblParam.olddist = dist;
		--LXZMessageBox("Name:"..wnd:GetName().." dist:"..dist.." olddist:"..tblParam.olddist);
		return false;
	end
	
	local dtime = LXZAPI_timeGetTime()- tblParam.time;
	 tblParam.time = LXZAPI_timeGetTime();
	
	local gspeed = 0;
	if(tblParam.addspeed~= nil) then
		--LXZMessageBox("addspeed:"..gspeed);
		gspeed = tblParam.addspeed();
		--LXZMessageBox("addspeed:"..gspeed);
	end
	
	local add = (tblParam.acce*dtime/33);
	tblParam.speed = tblParam.speed+add;
	tblParam.dtime = dtime;
	tblParam.add = add;
	
	if(tblParam.speed<0.001) then
		tblParam.speed = 0.001;
	end
		
	local r = (tblParam.speed+gspeed)*dtime/33;
	if(tblParam.mulspeed ~= nil) then
		r = r*tblParam.mulspeed();
	end
	
	--
	tblParam.curx = tblParam.curx+r*tblParam.dirx;
	tblParam.cury = tblParam.cury+r*tblParam.diry;	
	pt.x = tblParam.curx;
	pt.y = tblParam.cury;
	
	local offsetx = pt.x-tblParam.x;
	local offsety = pt.y-tblParam.y;
	
	local dist = math.sqrt(offsetx*offsetx+offsety*offsety);
	if(tblParam.olddist < dist or dist<=1) then		
		pt.x = tblParam.x;
		pt.y = tblParam.y;
		--wnd:SetHotPos(pt);
		tblParam.set(wnd, pt.x, pt.y);
		if(tblParam.hide ~= nil) then
			wnd:Hide();
		end
		
		if(tblParam.func~= nil) then
			tblParam.func(wnd, tblParam);
		end		
				
		if(tblParam.reset ~= nil and tblParam.reset==true) then
			pt.x = tblParam.oldx;
			pt.y = tblParam.oldy;
			--wnd:SetHotPos(pt);
			tblParam.set(wnd, pt.x, pt.y);
			--LXZMessageBox("Name:"..wnd:GetName().." dist:"..dist.." olddist:"..tblParam.olddist);
		end
		
		if(tblParam.del ~= nil) then
			DeleteElement(wnd);
			wnd.update = nil;
		end
		
		--LXZAPI_OutputDebugStr("Name:"..wnd:GetName().." dist:"..dist..helpdb_formatkv(tblParam));
		return true;		
	end	
	
	tblParam.olddist = dist;	
	--wnd:SetHotPos(pt);	
	tblParam.set(wnd, pt.x, pt.y);
	
	--move check
	if(tblParam.movefunc ~= nil) then
		return tblParam.movefunc(wnd, tblParam);
	end
			
	return false;
end

function UpdateWindow()

	local tbl = {};
	local count = 0;
	local ref = 0;
	local cnt = 0;
	for k,wnd in pairs(tblUpdateWnd) do
		if(wnd.updateself == nil) then
			cnt = UpdateWnd(wnd,k);
			ref = ref+cnt;
		end
		
		count = count+1;
	end
		
	for k,wnd in pairs(tblUpdateWnd) do
		if(wnd ~= nil and wnd:IsDeleted() == false) then
			tbl[wnd:GetID()] = wnd;
		end
	end
	
	tblUpdateWnd = tbl;	
end

function UpdateWnd(wnd,k)
	--
	if(wnd == nil or wnd.update == nil or wnd:IsDeleted() == true) then
		return 0;
	end

	local ref = 0;
	for i = 1, table.getn(wnd.update),1 do		
		local v = wnd.update[i];						
		if(v ~= nil and v.p~=nil and v.id==k and v.f(wnd, v.p)==true) then					
			if(v.p and v.p.debug) then LXZAPI_OutputDebugStr("Name:"..wnd:GetName().." "..helpdb_formatkv(v.p)); end;
			v.p = nil;			
			v.f = nil;
			if(v.thread ~= nil) then
				coroutine.resume(v.thread);
			end
		else
			if(v.p and v.p.debug) then LXZAPI_OutputDebugStr("Name:"..wnd:GetName().." "..helpdb_formatkv(v.p)); end;
			ref = ref+1;
		end		
		
		if(wnd.update == nil or wnd:IsDeleted()==true) then
			wnd.update = nil;
			tblUpdateWnd[k] = nil;
			return 0;
		end						
	end		
	
	return ref;
end

function DelWndUpdateFunc(wnd, func, id)
	if(wnd.update==nil) then
		wnd.update = {};
	end
				
	for i = 1, table.getn(wnd.update),1 do
		local v = wnd.update[i];
		if(v ~= nil and v.f==func and id == v.fid) then
			--stop it
			v.f(wnd, v.p, true);
			v.f = nil;
			v.p = nil;
		end		
	end
	
end

function AddWndUpdateFunc(wnd, func, param, thread, id, updateself)
	if(wnd.update==nil) then
		wnd.update = {};
	end
	
	--start it
	func(wnd, param);

	--
	tblUpdateWnd[wnd:GetID()] = wnd;
	wnd.updateself = updateself;
	
	--	
	local del = 0;
	for i = 1, table.getn(wnd.update),1 do
		local v = wnd.update[i];
		if(v ~= nil and v.f ~= nil) then
			if(v.f==func and id==v.fid) then		
				v.f = func;
				v.p = param;
				v.thread = thread;
				v.id = wnd:GetID();
				v.fid = id;
				return;
			end
		else
			del = i;
		end		
	end
	
	if(del>0) then
		wnd.update[del] = {f=func,p=param,thread=thread,id=wnd:GetID(),fid=id};
	else
		table.insert(wnd.update, {f=func,p=param,thread=thread,id=wnd:GetID(),fid=id});
	end
	
end

local WindowPool = {};
function HelperPushWindow(show, hide)	
	if #WindowPool >= 1 then
		local t = WindowPool[#WindowPool];
		if t.hide~= nil then
			t.hide();
		end
	end
	
	local t = {show=show,hide=hide};		
	table.insert(WindowPool,  lst);
	
	if show~= nil then
		show();
	end	
end

function HelperPopWindow()
	if #WindowPool<=1 then
		return false;
	end
	
	local t = WindowPool[#WindowPool];
	if t.hide then
		t.hide();
	end
	
	table.remove(WindowPool, #WindowPool);
		
	local t = WindowPool[#WindowPool];
	if t.show then
		t.show();
	end
	
	return true
end

function TrimRightChar(str, a)
	local c = string.sub(str, string.len(str),string.len(str));
	if(c == a) then
		--LXZMessageBox("c:"..c.." len:"..string.len(pass));
		str = string.sub(str, 1, string.len(str)-1);
	end	
	
	return str;
end

function HelperPostJSON(url, data, fn)

	local co = coroutine.create(function (thread)	
		local urlrequest = _urlRequest:new();
		urlrequest.nRequestType = eRequestPost;
		urlrequest.func = "xxxxURLResponeFunc";
		urlrequest.url = url.."?";
		for k,v in pairs(data) do
			urlrequest.url = urlrequest.url ..k.."="..v.."&";
		end	
			
		urlrequest.url = TrimRightChar(urlrequest.url, '&');
		urlrequest.url = TrimRightChar(urlrequest.url, '?');
		urlrequest.thread = thread;
		--LXZMessageBox(urlrequest.url);
		
		local curl = CLXZCurl:Instance();
		curl:send(urlrequest);	
		local urlresponse = coroutine.yield();
		if(fn~=nil) then
			fn(urlresponse);
		end		
	end);
	
	coroutine.resume(co, co);	
	
end

function HelperTraversalChilds(wnd, fn)
	local child = wnd:GetFirstChild();
	while(child ~= nil) do
		if(fn(child)) then
			return child;
		end		
		child = child:GetNextSibling();
	end
end

function SendSMS(phonenum, data)
	if(phonenum==nil or string.len(phonenum)<9 or string.find(phonenum, "[^0-9]")~=nil) then		
		return false;
	end
	
	if(LXZAPIGetOS()=="ANDROID") then
		local msg = CLXZMessage:new_local();
		msg:lstring(phonenum,1);
		msg:lstring(data,1);
		CallAndroidStaticAPI("com/lxzengine/androidapp/LXZEngineActivity", "smsSend","(Ljava/lang/String;Ljava/lang/String;)V",  msg, "nBnBvR");	
	elseif(LXZAPIGetOS()=="IOS") then
		LXZAPI_CallSystemAPI("smsSend",  phonenum..":"..data);
	end
	

	return true;
end

function HelperGetDayCount(year, month)
	--日
	--闰年共有366天(31，29，31，30，31，30，31，31，30，31，30，31)。
	--平年365天（31，28，31，30，31，30，31，31，30，31，30，31）
	local leap = {31,29,31,30,31,30,31,31,30,31,30,31};
	local nor   = {31,28,31,30,31,30,31,31,30,31,30,31};
		
	local year = year;
	local mon = month;	
	local cnt = nor[mon];
	if(math.mod(year,400)==0 or (math.mod(year,4)==0 and math.mod(year,100)~=0)) then	
		cnt = leap[mon];
	end
		
	return cnt;
end

function HelperWindowCaller(wnd, cmd, ...)

	local msg = CLXZMessage:new_local();
	for i,v in ipairs{...} do
			msg:PushAddress();
			msg:cstring(tostring(v));		
	end	
	wnd:ProcMessage(cmd, msg, wnd);	
	
	local ret = {};
	local retMsg = msg:getResult();
	if(retMsg ~= nil and retMsg:getIndex()>0) then
		local index = retMsg:getIndex();
		retMsg:setMode(SM_READ);
		retMsg:setIndexPos(0);
		for i=0,index,1 do
			local r = HelperTrimBreak(retMsg:cstring());
			table.insert(ret, r);
		end		
	end	
	
	return unpack(ret);
	
end
