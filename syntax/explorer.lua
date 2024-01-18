vim.cmd([=[syntax match ExplorerFolder ;^[^[:space:]]\+/$;]=])
vim.cmd([=[syntax match ExplorerLink ;^[^[:space:]]\+ >>$;]=])
vim.cmd([=[syntax match ExplorerFile ;^[^[:space:]]*[^/>[:space:]]\+$;]=])
