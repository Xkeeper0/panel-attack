
local Log = {}

Log.LEVELS	= {
	OFF			= 0,
	ERROR		= 1,
	WARNING		= 2,
	INFO		= 3,
	DEBUG		= 4,
	}

Log.LEVEL_NAMES	= {
	[0]	=
	"OFF",
	"ERROR",
	"WARNING",
	"INFO",
	"DEBUG",
	}

Log.currentLevel	= Log.LEVELS.INFO

function Log:message(level, message, ...)
	if level > self.currentLevel then
		return
	end

	print(string.format("[%s] %s", Log.LEVEL_NAMES[level], message))
	if (...) then
		if (#{...}) > 1 or type(...) == "table" then
			tprint({...})
		else
			print(...)
		end
	end

end

function Log:error(m, ...) self:message(self.LEVELS.ERROR, m, ...) end
function Log:warning(m, ...) self:message(self.LEVELS.WARNING, m, ...) end
function Log:info(m, ...) self:message(self.LEVELS.INFO, m, ...) end
function Log:debug(m, ...) self:message(self.LEVELS.DEBUG, m, ...) end

function Log:setLevel(l)
	self.currentLevel = l
end

return Log
