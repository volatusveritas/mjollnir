local opts = require("volt.util.opts")

local optpackage = opts.create_option_package()

opts.push_window_option(optpackage, "number", false)
opts.push_window_option(optpackage, "relativenumber", false)

opts.apply(optpackage)

opts.set_undo_ftplugin(optpackage)
