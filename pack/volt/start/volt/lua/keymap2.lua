local keymap = {}

keymap.operatorfunc = nil

function volt_operatorfunc()
    keymap.operatorfunc()
end

-- Much simpler implementation of the stupidly complex original keymap plugin

local mapper_metatable = {}

mapper_metatable.__index = mapper_metatable

-- group has:
-- • key?: key to be propagated down
-- • opts?: opts like in vim.keymap.set()
function mapper_metatable:group(group)
    group.key = group.key or ''
    group.opts = group.opts or {}

    self.groups.len = self.groups.len + 1
    self.groups[self.groups.len] = group

    return self
end

function mapper_metatable:endgroup()
    self.groups[self.groups.len] = nil
    self.groups.len = self.groups.len - 1

    return self
end

function mapper_metatable:get_grouped_key(leaf_key)
    local key_sequence = {}

    local last_idx = 0

    for i, group in ipairs(self.groups) do
        key_sequence[i] = group.key
        last_idx = i
    end

    key_sequence[last_idx + 1] = leaf_key

    return table.concat(key_sequence)
end

function mapper_metatable:get_grouped_opts(leaf_opts)
    local opts = {}

    for _, group in ipairs(self.groups) do
        opts = vim.tbl_extend('force', opts, group.opts)
    end

    return vim.tbl_extend('force', opts, leaf_opts)
end

-- TODO(volatus): merge get_grouped_key() and get_grouped_opts() into a single-loop function?

-- mapping has:
-- • key: leaf key for this mapping
-- • map: the rhs in vim.keymap.set()
-- • opts?: the opts in vim.keymap.set()
-- TODO(volatus): add a check for the required properties above?
function mapper_metatable:set(mapping)
    mapping.opts = mapping.opts or {}

    local key = self:get_grouped_key(mapping.key)
    local opts = self:get_grouped_opts(mapping.opts)

    local rhs = mapping.map

    if opts.operator then
        opts.operator = nil
        opts.expr = true
        rhs = function()
            vim.o.operatorfunc = 'v:lua.volt_operatorfunc'
            keymap.operatorfunc = mapping.map
            return 'g@'
        end
    end

    vim.keymap.set(self.mode, key, rhs, opts)

    return self
end

-- mapping has:
-- • map: the rhs in vim.keymap.set()
-- • opts?: the opts in vim.keymap.set()
-- TODO(volatus): add a check for the required properties above?
function mapper_metatable:self(mapping)
    mapping.key = ''
    return self:set(mapping)
end

-- mode: mode as in vim.keymap.set()
function keymap.new_mapper(mode)
    local mapper = {
        mode = mode,
        tree = {},
        groups = { len = 0 },
    }

    setmetatable(mapper, mapper_metatable)

    return mapper
end

keymap.normal   = function() return keymap.new_mapper('n') end
keymap.visual   = function() return keymap.new_mapper('v') end
keymap.terminal = function() return keymap.new_mapper('t') end
keymap.insert   = function() return keymap.new_mapper('i') end

return keymap
