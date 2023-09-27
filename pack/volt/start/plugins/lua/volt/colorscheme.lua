local M = {}

function M.setup()
    vim.api.nvim_create_user_command("VoltColorschemeReload", function(ctx)
        vim.cmd(("colorscheme %s"):format(vim.g.colors_name))
    end, {})
end

return M
