local M = {}

-- A mapdesc-grid is a table mapping strings (rhs) to mapdesc cells.
--
-- A mapdesc cell contains:
-- * desc (string): a description of the mapping or title of the mapping group.
-- * map [table]: the subcommand mappings, treated as a mappingdesc grid.

local last_mode = "n"
local accumulated_input = ""
local timeout_timer = nil
local help_buffer = nil
local valid_modes = {
    n = true,
    v = true, [""] = true,
    s = true, [""] = true,
    i = true,
    t = true,
}

M.mapdesc_grid = {
    n = {},
    v = {},
    s = {},
    i = {},
    t = {},
}

function M.apply_grid(mode, mgrid, parent)
    local root = parent or M.mapdesc_grid[mode]

    for key, mcell in pairs(mgrid) do
        root[key] = { desc = mcell.desc }

        if type(mcell.map) == "table" then
            root[key].map = {}
            M.apply_grid(mode, mcell.map, root[key].map)
        end
    end
end

local function in_valid_mode()
    local mode_indicator = string.lower(vim.fn.mode())

    if mode_indicator ~= last_mode then
        accumulated_input = ""
    end

    last_mode = mode_indicator

    return valid_modes[mode_indicator] ~= nil
end

function M.get_input_mapping(grid, target, prefix)
    prefix = prefix or ""

    for key, mcell in pairs(grid) do
        if vim.api.nvim_replace_termcodes(prefix..key, true, true, true) == target then
            return mcell
        elseif grid[key].map then
            local sub_result = M.get_input_mapping(
                grid[key].map,
                target,
                prefix..key
            )

            if sub_result then
                return sub_result
            end
        end
    end
end

function M.open_help_window()
    local window = require("volt.util.window")

    help_buffer = vim.api.nvim_create_buf(false, true)

    local input_mapping = M.get_input_mapping(
        M.mapdesc_grid[last_mode],
        vim.api.nvim_replace_termcodes(accumulated_input, true, true, true)
    )

    if not input_mapping then
        return
    end

    local window_text = { input_mapping.desc, "\n" }

    -- figure out text

    -- figure out dimensions from text

    window.open_window_br(help_buffer, false, { height = 16 })

    vim.api.nvim_buf_set_lines(
        help_buffer,
        1, 1,
        false,
        window_text
    )
end

function M.close_help_window()
    vim.api.nvim_buf_delete(help_buffer, { force = true })
    help_buffer = nil
end

function M.update_help_window()
    if help_buffer then
        vim.schedule(M.close_help_window)
    end

    vim.schedule(M.open_help_window)
end

function M.set_accumulated_input(new_value)
    accumulated_input = new_value
    M.update_help_window()
end

function M.get_accumulated_input()
    return accumulated_input
end

local function on_timeout()
    timeout_timer:stop()

    M.set_accumulated_input("")
end

local function on_key(key)
    if not in_valid_mode() or key == "" then
	accumulated_input = ""

        if timeout_timer then
            timeout_timer:stop()
        end

	if help_buffer then
            vim.schedule(M.close_help_window)
	end

        return
    end

    if not timeout_timer then
        timeout_timer = vim.loop.new_timer()
        timeout_timer:start(vim.o.timeoutlen, vim.o.timeoutlen, on_timeout)
    else
        timeout_timer:again()
    end

    M.set_accumulated_input(accumulated_input..key)
end

function M.setup()
    vim.on_key(on_key)
end

return M
