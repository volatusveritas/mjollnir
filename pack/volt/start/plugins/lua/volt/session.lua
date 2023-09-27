local M = {}

function M.setup()
    local augroup = vim.api.nvim_create_augroup("volt_session", {})

    -- Autosave session when leaving if opened with a session
    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = augroup,
        callback = function()
            if vim.v.this_session == "" then
                return
            end

            vim.cmd(("mksession! %s"):format(vim.v.this_session))
        end,
    })
end

return M
