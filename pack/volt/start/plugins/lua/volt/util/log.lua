local M = {}

local LEVEL_INFO = 0
local LEVEL_WARN = 1
local LEVEL_ERR  = 2

local level_name = {
    [LEVEL_INFO] = "INFO",
    [LEVEL_WARN] = "WARNING",
    [LEVEL_ERR]  = "ERROR",
}

-- Returns the function name and line at which the logging function was called
--
-- @return
--      - (string) debug.getinfo's name property
--      - (number) debug.getinfo's currentline property
local function get_info()
    local info = debug.getinfo(4, "nl")
    return info.name, info.currentline
end

-- Logs the message according to a standard format.
--
-- @param level_name (number): the logging level's numeric index
-- @param message (string): the message to log at that level
local function log(level, message, ...)
    local caller_name, calling_line = get_info()

    print(string.format(
        "[%s at %s::%d] %s",
        level_name[level],
        caller_name,
        calling_line,
        string.format(message, ...)
    ))
end

-- Logs the given message as debug information (INFO)
--
-- @param message (string): the message to be logged at INFO level
function M.info(message, ...)
    log(LEVEL_INFO, message, ...)
end

-- Logs the given message as a warning (WARNING)
--
-- @param message (string): the message to be logged at WARNING level
function M.warn(message, ...)
    log(LEVEL_WARN, message, ...)
end

-- Logs the given message as an error (ERROR)
--
-- @param message (string): the message to be logged at ERROR level
function M.err(message, ...)
    log(LEVEL_ERR, message, ...)
end

return M
