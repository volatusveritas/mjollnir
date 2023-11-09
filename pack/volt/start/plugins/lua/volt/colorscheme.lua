local M = {}

function M.setup()
    vim.api.nvim_create_user_command("VoltColorschemeReload", function(ctx)
        require("volt.theme").activate()
    end, {})
end

return M
