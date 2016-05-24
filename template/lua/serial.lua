local tinsert = table.insert
local tconcat = table.concat
local tremove = table.remove
local smatch = string.match
local sgmatch = string.gmatch
local sgsub = string.gsub
local ipairs = ipairs
local pairs = pairs
local type = type
local tostring = tostring
local tonumber = tonumber
local loadstring = loadstring
local print = print

local function h2n(s)
	return tonumber(s,16); 
end

--- The default tango serialization module.
-- Uses table serialization from http://lua/users.org/wiki/TableUtils and loadstring for unserialize.
serialize = nil

function helpdb_getfield(tbl)
	if(type(tbl)~='table') then
		LXZMessageBox("helpdb_getfield:"..type(tbl));
		return;
	end
	
	local field = nil;
	for k,v in pairs(tbl) do
		if(field) then
			field = field..","..k;		
		else
			field = tostring(k);		
		end
	end
	return field;
end

function helpdb_getvalue(tbl)
	if(type(tbl)~='table') then
		LXZMessageBox("helpdb_getvalue:"..type(tbl));
		return;
	end
	
	local value = nil;
	for k,v in pairs(tbl) do
		if(value) then
			if(type(v)=="string") then
				value = value..",".."'"..v.."'";		
			else
				value = value..","..v;		
			end
		else
			if(type(v)=="string") then
				value ="'"..v.."'";		
			else
				value = tostring(v);		
			end
		end
	end
	return value;
end

function HelperBin2Str(data)
	if(data==nil or type(data)~='string') then
		return "";
	end

	local len = string.len(data);
	local str = "";
	for i = 1, len,1 do
		str = str..string.format("%02x", string.byte(data, i));
	end
	return str;
end

function HelperStr2Bin(hexstr)	
--    local s = string.gsub(hexstr, "(%x%x)%c", function (n )  return h2n(n);  end)
 --   return s
 	if(hexstr==nil or type(hexstr)~='string') then
		return "";
	end
	
	local msg = CLXZMessage:new_local();
	for i=1,string.len(hexstr)-1,2 do
		local bb = string.sub(hexstr, i, i+1);
		msg:uint8(h2n(bb));
	end
	return msg:getMsgPtr();
end

local converters = {
  string = function(v)
             v = sgsub(v,"\n","\\n")
             if smatch(sgsub(v,"[^'\"]",""),'^"+$') then
               return "'"..v.."'"
             end
             return '"'..sgsub(v,'"','\\"')..'"'             
           end,
  table = function(v)
            return serialize(v)
          end,
  number = function(v)
             return tostring(v)
           end,
  boolean = function(v)
           return tostring(v)
         end  
}

local valtostr = 
  function(v)
    local conv = converters[type(v)]
    if conv then
      return conv(v)
    else
      return 'nil'
    end
  end

local keytostr = 
  function(k)
    if 'string' == type(k) and smatch(k,"^[_%a][_%a%d]*$") then
      return k
    else
      return '['..valtostr(k)..']'
    end
  end

serialize = 
  function(tbl)
    local result,done = {},{}
    for k,v in ipairs(tbl) do
      tinsert(result,valtostr(v))
      done[k] = true
    end
    for k,v in pairs(tbl) do
      if not done[k] then
        tinsert(result,keytostr(k)..'='..valtostr(v))
      end
    end
    return '{'..tconcat(result,',')..'}'
  end

unserialize = 
  function(strtab)
    return loadstring('return '..strtab)()
  end
