local M = {}

--[[
    The project_list file contains a single project per line.
    Each line is in the format <projectName>:<projectPath>, where:
    * projectName is the displayed name of the project
    * projectPath is the path to the folder containing the project's files
]]

-- Imports
local msg = require('volt.util.msg')
local ui = require('volt.util.ui')

local projects_folder = vim.fn.stdpath('data')
local projects_path = string.format('%s/projects', projects_folder)
local projects = {}

local function get_project_titles()
    local project_titles = {}
    local next_idx = 1

    for name, path in pairs(projects) do
        project_titles[next_idx] = name
        next_idx = next_idx + 1
    end

    return project_titles
end

local function get_project_paths()
    local project_paths = {}
    local next_idx = 1

    for name, path in pairs(projects) do
        project_paths[next_idx] = path
        next_idx = next_idx + 1
    end

    return project_paths
end

local function get_project_members()
    local project_names = {}
    local project_paths = {}
    local next_idx = 1

    for name, path in pairs(projects) do
        project_names[next_idx] = names
        project_paths[next_idx] = path
        next_idx = next_idx + 1
    end

    return project_paths
end

local function get_project_amount()
    local project_amount = 0

    for _, _ in pairs(projects) do
        project_amount = project_amount + 1
    end

    return project_amount
end

local function project_to_field(title)
    return string.format('%s:%s', title, projects[title])
end

local function field_to_project(field)
    return string.match(field, '(.-):(.*)')
end

local function save_projects()
    local projects_file, err_msg = io.open(projects_path, 'w')

    if projects_file == nil then
        msg.err(string.format(
            'Failed to open the project list file for writing: %s',
            err_msg
        ))
        return
    end

    for title, _ in pairs(projects) do
        projects_file:write(project_to_field(title), '\n')
    end

    projects_file:close()
end

local function load_projects()
    local projects_file, err_msg = io.open(projects_path, 'r')

    if projects_file == nil then
        msg.err(string.format(
            'Failed to load the project list file: %s',
            err_msg
        ))
        return
    end

    local idx = 1
    for line in projects_file:lines() do
        local title, path = field_to_project(line)

        if title == nil then
            msg.err(string.format(
                'Wrong project field format in line %d: "%s"',
                idx, line
            ))
        else
            projects[title] = path
        end

        idx = idx + 1
    end

    projects_file:close()
end

local function save_project(title)
    projects[title] = vim.fn.getcwd()
    save_projects()
end

local function load_project(title)
    if get_project_amount() == 0 then
        msg.info('Project list is empty. Skipping project selection prompt.')
        return
    end

    vim.cmd(string.format('cd %s', projects[title]))

    msg.info(string.format('Project "%s" loaded.', title))
end

local function init_projects()
    if vim.fn.filereadable(projects_path) == 1 then
        return true
    end

    vim.fn.mkdir(projects_folder, 'p')
    local projects_file = io.open(projects_path, 'w')

    if file == nil then
        msg.err('Failed to load the project list file. Aborting project list setup.')
        return
    end

    projects_file:close()

    return false
end

function M.show_projects()
    vim.print(projects)
end

function M.prompt_save_project()
    local project_name = vim.fn.input('[Save Project] Project name: ')

    if project_name == '' then
        return
    end

    save_project(project_name)
end

function M.prompt_load_project()
    if get_project_amount() == 0 then
        msg.info('No projects to load. Skipping project selection prompt.')
        return
    end

    ui.selection(
        'Load Project',
        get_project_titles(),
        nil,
        function(idx, item)
            if idx == nil then
                return
            end

            load_project(item)
            msg.info(string.format('Project "%s" succesfully loaded.', item))
        end
    )
end

function M.prompt_delete_project()
    if get_project_amount() == 0 then
        msg.info('No projects to delete. Skipping project selection prompt.')
        return
    end

    ui.selection(
        'Delete Project',
        get_project_titles(),
        nil,
        function(idx, item)
            if idx == nil then
                return
            end

            -- table index is nil
            projects[item] = nil
            save_projects()
            msg.info(string.format('Project "%s" succesfully deleted.', item))
        end
    )
end

function M.setup()
    if init_projects() then load_projects() end
end

return M
