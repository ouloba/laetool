
tblUpdateWnd = {};

--render attr ref 
RenderRefDraggingLogic = {};
RenderRefMoveLogic = {};
RenderRefEditBoxLogic = {};
RenderRefPictureLogic = {};
RenderRefRectangleLogic = {};
RenderRefParticleLogic = {};
RenderRefArrayLXZWindow = {};
WindowRefLogic = {};
local mime = require("mime");


function EffectEase(wnd, t)
	if t.attribute== nil then
		return true;
	end
	
	if t.fn == nil then
		return true;
	end
	
	local obj=wnd;
	if t.render ~= nil then
		obj=wnd:GetRender(t.render);
	end
	
	if t.attribute_ref == nil then
		t.attribute_ref=obj:GetAttributeNameRef(t.attribute);
	end
	
	if t.offset == nil then
		t.offset = 0;
	end
	
	if t.origin == nil then
		t.origin = obj:GetAttribute(t.attribute_ref);
	end
	
	if t.time == nil then
		t.time = 0;
	end
	
	if t.begin == nil then
		t.begin = 0;
	end
	
	if t.count==nil then
		t.count=1;
	end
		
	local v=t.fn(t.type,t.time,t.begin, t.change, t.duration)+t.origin+t.offset;
	t.time=t.time+LXZAPI_GetFrameTime();
	obj:SetAttribute (t.attribute_ref, v);
	
	if t.time>=t.duration then
		t.count=t.count-1;
		if t.count<=0 then
			if t.reset ~= nil then
				obj:SetAttribute (t.attribute_ref, t.origin);
			end
			
			if t.hide~= nil then
				wnd:Hide();
			end
			
			if t.del ~= nil then
				wnd:Delete();
			end
			
			--kkk=kkk+1;
			
			return true;
		else
			t.time=0;
		end	
	end
	
	return false;
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
	return gdb;
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

--查询是否存在表名
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

function HelperGetWindowTextColor(wnd, realname)
	local render = HelperGetRender(wnd,"EditBox", realname);
	if(render ~= nil) then
		RenderRefEditBoxLogic.textcolor = render:GetAttributeNameRef("EditBox:normalTextColour", RenderRefEditBoxLogic.textcolor);
		local address = render:GetAddress(RenderRefEditBoxLogic.textcolor);
		--local ptlist = tousertype(address, "LXZPointList");
		local rgba = tousertype(addr, "RGBA");
		return rgba.red,rgba.green,rgba.blue,rgba.alpha
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

function HelperGetWindowText(wnd,realname)
	--LXZMessageBox("HelperGetWindowText");
	local render = HelperGetRender(wnd,"EditBox", realname);
	if(render ~= nil) then
		RenderRefEditBoxLogic.text = render:GetAttributeNameRef("EditBox:Text", RenderRefEditBoxLogic.text);
		local text =  render:GetAttribute(RenderRefEditBoxLogic.text, text);
		return HelperTrimBreak(text);	
	end	
	return "";
end

function HelperGetRoot()
	local winmgr = CLXZWindowMgr:Instance();
	local wnd =  winmgr:GetRoot();
	return wnd;
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
	
function HelperCoroutine(func)
	local co = coroutine.create(func);	
	local res,err = coroutine.resume(co,co);
	if(res==false) then
		LXZMessageBox("HelperCoroutine:"..err);
	end
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

function HelperGetWindowScaleX(wnd)
	WindowRefLogic.ScaleX = wnd:GetAttributeNameRef("CLXZWindow:Scale:fScaleX", WindowRefLogic.ScaleX);	
	return tonumber(wnd:GetAttribute(WindowRefLogic.ScaleX));
end

function HelperGetWindowScaleY(wnd)
	WindowRefLogic.ScaleY = wnd:GetAttributeNameRef("CLXZWindow:Scale:fScaleY", WindowRefLogic.ScaleY);	
	return tonumber(wnd:GetAttribute(WindowRefLogic.ScaleY));
end

function UpdateWindow()

	local tbl = {};
	local count = 0;
	local ref = 0;
	local cnt = 0;
	for k,wnd in pairs(tblUpdateWnd) do
		if(wnd.updateself == nil and wnd:GetID()==k) then
			cnt = UpdateWnd(wnd,k);
			ref = ref+cnt;
		end
		
		count = count+1;
	end
		
	for k,wnd in pairs(tblUpdateWnd) do
		if(wnd ~= nil and wnd:IsDeleted() == false and k==wnd:GetID()) then
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

function TrimRightChar(str, a)
	local c = string.sub(str, string.len(str),string.len(str));
	if(c == a) then
		--LXZMessageBox("c:"..c.." len:"..string.len(pass));
		str = string.sub(str, 1, string.len(str)-1);
	end	
	
	return str;
end

function xxxxURLResponeFunc(urlresponse)	
	local urlrequest = urlresponse:getRequest();
	if(urlrequest.thread ~= nil) then
		--LXZMessageBox("urlrequest.thread:"..type(urlrequest.thread));
		coroutine.resume(urlrequest.thread, urlresponse);		
	end	
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
