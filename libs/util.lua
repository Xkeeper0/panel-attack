local sort, pairs, select, unpack, error =
	table.sort, pairs, select, unpack, error
local type, setmetatable, getmetatable =
			type, setmetatable, getmetatable
local random = math.random

-- bounds b so a<=b<=c
function bound(a, b, c)
	if b<a then return a
	elseif b>c then return c
	else return b end
end

-- mods b so a<=b<=c
function wrap(a, b, c)
	return (b-a)%(c-a+1)+a
end

-- map for numeric tables
function map(func, tab)
	local ret = {}
	for i=1, #tab do
		ret[i]=func(tab[i])
	end
	return ret
end

-- map for dicts
function map_dict(func, tab)
	local ret = {}
	for key,val in pairs(tab) do
		ret[key]=func(val)
	end
	return ret
end

function map_inplace(func, tab)
	for i=1, #tab do
		tab[i]=func(tab[i])
	end
	return tab
end

function map_dict_inplace(func, tab)
	for key,val in pairs(tab) do
		tab[key]=func(val)
	end
	return tab
end

-- reduce for numeric tables
function reduce(func, tab, ...)
	local idx, value = 2, nil
	if select("#", ...) ~= 0 then
		value = select(1, ...)
		idx = 1
	elseif #tab == 0 then
		error("Tried to reduce empty table with no initial value")
	else
		value = tab[1]
	end
	for i=idx,#tab do
		value = func(value, tab[i])
	end
	return value
end

function car(tab)
	return tab[1]
end
-- This sucks lol
function cdr(tab)
	return {select(2, unpack(tab))}
end

-- a useful right inverse of table.concat
function procat(str)
	local ret = {}
	for i=1,#str do
		ret[i]=str:sub(i,i)
	end
	return ret
end

-- iterate over frozen pairs in sorted order
function spairs(tab)
	local keys,vals,idx = {},{},0
	for k in pairs(tab) do
		keys[#keys+1] = k
	end
	sort(keys)
	for i=1,#keys do
		vals[i]=tab[keys[i]]
	end
	return function()
		idx = idx + 1
		return keys[idx], vals[idx]
	end
end

function uniformly(t)
	return t[random(#t)]
end

function content_equal(a,b)
	if type(a) ~= "table" or type(b) ~= "table" then
		return a == b
	end
	for i=1,2 do
		for k,v in pairs(a) do
			if b[k] ~= v then
				return false
			end
		end
		a,b=b,a
	end
	return true
end

-- does not perform deep comparisons of keys which are tables.
function deep_content_equal(a,b)
	if type(a) ~= "table" or type(b) ~= "table" then
		return a == b
	end
	for i=1,2 do
		for k,v in pairs(a) do
			if not deep_content_equal(v,b[k]) then
				return false
			end
		end
		a,b=b,a
	end
	return true
end

function shallowcpy(tab)
	local ret = {}
	for k,v in pairs(tab) do
		ret[k]=v
	end
	return ret
end

local deepcpy_mapping = {}
local real_deepcpy
function real_deepcpy(tab)
	if deepcpy_mapping[tab] ~= nil then
		return deepcpy_mapping[tab]
	end
	local ret = {}
	deepcpy_mapping[tab] = ret
	deepcpy_mapping[ret] = ret
	for k,v in pairs(tab) do
		if type(k) == "table" then
			k=real_deepcpy(k)
		end
		if type(v) == "table" then
			v=real_deepcpy(v)
		end
		ret[k]=v
	end
	return setmetatable(ret, getmetatable(tab))
end

function deepcpy(tab)
	if type(tab) ~= "table" then return tab end
	local ret = real_deepcpy(tab)
	deepcpy_mapping = {}
	return ret
end

--Note: this round() doesn't work with negative numbers
function round(positive_decimal_number, number_of_decimal_places)
	if not number_of_decimal_places then
		number_of_decimal_places = 0
	end
	return math.floor(positive_decimal_number*10^number_of_decimal_places+0.5)/10^number_of_decimal_places
end

function frames_to_time_string(frame_count, include_60ths_of_secs)
	local hour_min_sep = ":"
	local min_sec_sep = ":"
	local sec_60th_sep = "'"
	local ret = ""
	if frame_count >= 216000 then
		--enough to include hours
		ret = ret..math.floor(frame_count / 216000)
		--minutes with 2 digits (like 05 instead of 5)
		ret = ret..hour_min_sep..string.format("%02d", math.floor(frame_count / 3600 % 3600))
	else
		--minutes with only one digit if only one digit if needed
		ret = ret..math.floor(frame_count / 3600 % 3600)
	end
	--seconds
	ret = ret..min_sec_sep..string.format("%02d", math.floor(frame_count / 60 % 60))
	if include_60ths_of_secs then
		--also include 60ths of a second
		ret = ret..sec_60th_sep..string.format("%02d", frame_count % 60)
	end
	return ret
end

-- Not actually for encoding/decoding byte streams as base64.
-- Rather, it's for encoding streams of 6-bit symbols in printable characters.
base64encode = procat("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890+/")
base64decode = {}
for i=1,64 do
	local val = i-1
	base64decode[base64encode[i]]={}
	local bit = 32
	for j=1,6 do
		base64decode[base64encode[i]][j]=(val>=bit)
		val=val%bit
		bit=bit/2
	end
end

-- split the input string on some separator, returns table
function split(inputstr, sep)
	sep = sep or '%s'
	local t = {}
	for field, s in string.gmatch(inputstr, "([^" .. sep .. "]*)(" .. sep .. "?)") do
		table.insert(t, field)
		if s == "" then
			return t
		end
	end
end

function file_exists(name)
	local f = io.open(name,"r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

do
	local function show(val)
		if type(val) == "string" then
			return '"' .. val .. '"'
		else
			return tostring(val)
		end
	end
	function tprint(t, indent, done)
		if type(t) ~= "table" then
			print("tprint got " .. type(t))
			return
		end

		done = done or {}
		indent = indent or 0
		for key, value in pairs(t) do
			local indents = string.rep(" ", indent) -- indent it
			if type(value) == "table" and not done[value] then
				done[value] = true
				print(indents .. show(key) .. ":");
				tprint(value, indent + 2, done)
			elseif done[value] then
				print(indents .. show(key) .. " = " .. show(value) .. " ??? recursion?")
			else
				print(indents .. show(key) .. " = " .. show(value))
			end
		end
	end
end
