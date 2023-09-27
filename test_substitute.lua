local jonathan = 5
local sustenance = "Someone's creek is another's salvation."

local function potato(creek)
    return string.format("Shadowed %s", creek)
end

local undying = potato(sustenance)

local sb = require("volt.substitute")
sb.enter_mode(0, vim.fn.line("$"), "bane", "bane")
