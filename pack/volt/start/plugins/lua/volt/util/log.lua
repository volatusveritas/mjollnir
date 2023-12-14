local M = {}

local LEVEL_INFO = "INFO"
local LEVEL_WARN = "WARNING"
local LEVEL_ERR  = "ERROR"

--- Get the position where this function was called.
-- Returns the function name and line at which the logging function was called.
-- @return (string) debug.getinfo's name property.
-- @return (number) debug.getinfo's currentline property.
local function get_info()
    local info = debug.getinfo(4, "nl")
    return info.name, info.currentline
end

--- Logs the message according to a standard format.
-- @param level_name (number) The logging level's numeric index.
-- @param message (string) The message to log at that level.
-- @param args (string*) Extra arguments for formatting the message.
local function log(level, message, ...)
    local caller_name, calling_line = get_info()

    print(string.format(
        "[%s at %s::%d] %s",
        level,
        caller_name,
        calling_line,
        string.format(message, ...)
    ))
end

--- Logs the given message as debug information (INFO).
-- @param message (string) The message to be logged at INFO level.
-- @param args (string*) Extra arguments for formatting the message.
function M.info(message, ...)
    log(LEVEL_INFO, message, ...)
end

--- Logs the given message as a warning (WARNING).
-- @param message (string): the message to be logged at WARNING level.
-- @param args (string*) Extra arguments for formatting the message.
function M.warn(message, ...)
    log(LEVEL_WARN, message, ...)
end

--- Logs the given message as an error (ERROR).
-- @param message (string): the message to be logged at ERROR level.
-- @param args (string*) Extra arguments for formatting the message.
function M.err(message, ...)
    log(LEVEL_ERR, message, ...)
end

return M
