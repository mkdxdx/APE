-- As a more advanced solution, we can write an iterator that traverses a table following the order of its keys.
-- An optional parameter f allows the specification of an alternative order. It first sorts the keys into an array,
-- and then iterates on the array. At each step, it returns the key and value from the original table:
function pairsByKeys (t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end
	return iter
end

-- Compatibility: Lua-5.1
function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

-- serialize table
local DUMP_IGNORE = {os = 1, io = 1, table = 1, _VERSION = 1, math = 1, love = 1, string = 1, package = 1, _G = 1, DUMP_IGNORE = 1, ndump = 1, xpcall = 1, unpack = 1, type = 1, require = 1, setmetatable = 1, next = 1, pairs = 1, ipairs = 1, dofile = 1, collectgarbage = 1, load = 1, loadfile = 1, loadstring = 1, module = 1, pcall = 1, gcinfo = 1, getmetatable = 1, error = 1, debug = 1, coroutine = 1, assert = 1, tonumber = 1, tostring = 1, setfenv = 1, arg = 1, argv = 1, dumpAll = 1, dumpUserData = 1, getfenv = 1, newproxy = 1, select = 1}
function ndump(object, map, visited, prefix, ignoredMap)
    map = map or {}
    ignoredMap = ignoredMap or {}
    visited = visited or {}
    if object ~= nil and visited[object] == nil then
        visited[object] = true
        for k, v in pairs(object) do
            local useMap = not prefix and DUMP_IGNORE[tostring(k)] ~= nil and ignoredMap or map
            local child = nil
            local vtype = type(v)
            k = tostring(k)
            if vtype == "table" then
                child = v
                v = "{}"
            elseif vtype == "string" then
                v = "\"" .. string.gsub(string.gsub(v, "\\", "\\\\"),"\n", "\\n") .. "\""
            elseif vtype == "function" then
                v = (prefix and (prefix .. "[\"" .. k .. "\"]") or k) .. " or function() end"
            elseif vtype == "userdata" then
                v = "{} --[[ " .. tostring(v) .. "]]--"
            end
            table.insert(useMap, (prefix and (prefix .. "[\"" .. k .. "\"]") or k) .. " = " .. tostring(v))
            if child then
                ndump(child, useMap, visited, (prefix and (prefix .. "[\"" .. k .. "\"]") or k))
            end
        end
    end
    if not prefix then
        local sf = function(a, b)
            return string.lower(a) < string.lower(b)
        end
        table.sort(map, sf)
        table.sort(ignoredMap, sf)
        return table.concat(map, "\n"), "-- " .. table.concat(ignoredMap, "\n-- ")
    end
end
