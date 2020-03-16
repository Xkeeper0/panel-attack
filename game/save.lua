local sep = package.config:sub(1, 1) --determines os directory separator (i.e. "/" or "\")

function write_key_file() pcall(function()
	local file = love.filesystem.newFile("keys.txt")
	file:open("w")
	file:write(json.encode(K))
	file:close()
end) end

function read_key_file() pcall(function()
	local K=K
	local file = love.filesystem.newFile("keys.txt")
	file:open("r")
	local teh_json = file:read(file:getSize())
	local user_conf = json.decode(teh_json)
	file:close()
	-- TODO: remove this later, it just converts the old format.
	if #user_conf == 0 then
		local new_conf = {}
		for k,v in pairs(user_conf) do
			new_conf[k:sub(3)] = v
		end
		user_conf = {new_conf, {}, {}, {}}
	end
	for k,v in ipairs(user_conf) do
		K[k]=v
	end
end) end
function read_txt_file(path_and_filename)
	local s
	pcall(function()
		local file = love.filesystem.newFile(path_and_filename)
		file:open("r")
		s = file:read(file:getSize())
		file:close()
	end)
	if not s then
		s = "Failed to read file"..path_and_filename
	else
	s = s:gsub('\r\n?', '\n')
	end
	return s or "Failed to read file"
 end

function write_conf_file() pcall(function()
	local file = love.filesystem.newFile("conf.json")
	file:open("w")
	file:write(json.encode(config))
	file:close()
end) end

function read_conf_file() pcall(function()
	local file = love.filesystem.newFile("conf.json")
	file:open("r")
	local teh_json = file:read(file:getSize())
	for k,v in pairs(json.decode(teh_json)) do
		config[k] = v
	end
	file:close()
end) end

function read_replay_file() pcall(function()
	local file = love.filesystem.newFile("replay.txt")
	file:open("r")
	local teh_json = file:read(file:getSize())
	local temp = json.decode(teh_json)
	if temp then
		replay = temp
	else
		error("replay is bad")
	end
	if type(replay.in_buf) == "table" then
		replay.in_buf=table.concat(replay.in_buf)
		write_replay_file()
	end

	if replay == nil then
		replay = {}
	end
end) end

function write_replay_file(path, filename) pcall(function()
	local file
	if path and filename then
		love.filesystem.createDirectory(path)
		file = love.filesystem.newFile(path .. filename)
	else
		file = love.filesystem.newFile("replay.txt")
	end
	file:open("w")
	file:write(json.encode(replay))
	file:close()
end) end

function write_user_id_file() pcall(function()
	love.filesystem.createDirectory("servers/"..connected_server_ip)
	local file = love.filesystem.newFile("servers/"..connected_server_ip.."/user_id.txt")
	file:open("w")
	file:write(tostring(my_user_id))
	file:close()
end) end

function read_user_id_file() pcall(function()
	local file = love.filesystem.newFile("servers/"..connected_server_ip.."/user_id.txt")
	file:open("r")
	my_user_id = file:read()
	file:close()
end) end

function write_puzzles() pcall(function()
	love.filesystem.createDirectory("puzzles")
	local file = love.filesystem.newFile("puzzles/stock (example).txt")
	file:open("w")
	file:write(json.encode(puzzle_sets))
	file:close()
end) end

function read_puzzles() pcall(function()
	-- if type(replay.in_buf) == "table" then
		-- replay.in_buf=table.concat(replay.in_buf)
	-- end

	puzzle_packs = love.filesystem.getDirectoryItems("puzzles") or {}
	print("loading custom puzzles...")
	for _,filename in pairs(puzzle_packs) do
		print(filename)
		if love.filesystem.getInfo("puzzles/"..filename)
		and filename ~= "stock (example).txt"
		and filename ~= "README.txt" then
			print("loading custom puzzle set: "..(filename or "nil"))
			local current_set = {}
			local file = love.filesystem.newFile("puzzles/"..filename)
			file:open("r")
			local teh_json = file:read(file:getSize())
			current_set = json.decode(teh_json) or {}
			for set_name, puzzle_set in pairs(current_set) do
				puzzle_sets[set_name] = puzzle_set
			end
			print("loaded above set")
		end
	end
end) end

function print_list(t)
	for i, v in ipairs(t) do
		print(v)
	end
end

function copy_file(source, destination)
	local lfs = love.filesystem
	local source_file = lfs.newFile(source)
	source_file:open("r")
	local source_size = source_file:getSize()
	temp = source_file:read(source_size)
	source_file:close()

	local new_file = lfs.newFile(destination)
	new_file:open("w")
	local success, message =  new_file:write(temp, source_size)
	new_file:close()
end

function recursive_copy(source, destination)
	local lfs = love.filesystem
	local names = lfs.getDirectoryItems(source)
	local temp
	for i, name in ipairs(names) do
		if lfs.isDirectory(source.."/"..name) then
			print("calling recursive_copy(source".."/"..name..", ".. destination.."/"..name..")")
			recursive_copy(source.."/"..name, destination.."/"..name)

		elseif lfs.isFile(source.."/"..name) then
			if not lfs.isDirectory(destination) then
			 love.filesystem.createDirectory(destination)
			end
			print("copying file:  "..source.."/"..name.." to "..destination.."/"..name)

			local source_file = lfs.newFile(source.."/"..name)
			source_file:open("r")
			local source_size = source_file:getSize()
			temp = source_file:read(source_size)
			source_file:close()

			local new_file = lfs.newFile(destination.."/"..name)
			new_file:open("w")
			local success, message =  new_file:write(temp, source_size)
			new_file:close()

			print(message)
		else
			print("name:  "..name.." isn't a directory or file?")
		end
	end
end
