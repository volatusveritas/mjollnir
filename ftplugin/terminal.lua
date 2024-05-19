if vim.fn.exists('b:did_ftplugin') == 1 then
    return
end

vim.api.nvim_buf_set_var(0, 'did_ftplugin', 1)

vim.wo.number = false
vim.wo.relativenumber = false

vim.api.nvim_buf_set_var(0, 'undo_ftplugin', 'setlocal number< relativenumber<')
