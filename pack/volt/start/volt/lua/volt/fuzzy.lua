local M = {}

----------------------------------- Imports -----------------------------------
local vlua = require 'volt.lua'
-------------------------------------------------------------------------------

local function volt_distance(target, candidate)
    local n_target = #target
    local n_candidate = #candidate

    if n_candidate < n_target then
        return -1
    end

    local sequences = vlua.efficient_array()
    local next_starter = 0

    while true do
        next_starter = candidate:find(target:sub(1, 1), next_starter + 1)

        if next_starter == nil then
            break
        end

        local sequence = vlua.efficient_array()
        sequence:insert(next_starter)
        local next_idx = next_starter

        for i = 2, n_target do
            next_idx = candidate:find(target:sub(i, i), next_idx + 1)

            if next_idx == nil then
                break
            end

            sequence:insert(next_idx)
        end

        if sequence.length == n_target then
            sequences:insert(sequence)
        end
    end

    if sequences.length == 0 then
        return -1
    end

    local indexes = nil
    local smallest_scattering = math.huge

    for _, sequence in ipairs(sequences) do
        local scattering = 0

        for i = 1, sequence.length - 1 do
            scattering = scattering + (sequence[i+1] - sequence[i] - 1)
        end

        if scattering < smallest_scattering then
            indexes = sequence
            smallest_scattering = scattering
        end
    end

    return smallest_scattering + math.abs(n_target - n_candidate), indexes
end

--------------------------------- Public API ----------------------------------
-- Performs fuzzy searching on a list of candidates based on a target.
--
-- @param target (string) The sequence to look for in the candidates
-- @param candidates (string[]) An array of sequences to search for the target
--
-- @return value (string) The matched value
-- @return distance (number) A value between 0 and 1 of how close the match was
-- @return indexes (number[]) An array of matched indexes in the value
function M.match(target, candidates)
    local matches = vlua.efficient_array()

    for _, candidate in ipairs(candidates) do
        local distance, indexes = volt_distance(target, candidate)

        if distance ~= -1 then
            matches:insert({
                value = candidate,
                distance = distance,
                indexes = indexes,
            })
        end
    end

    table.sort(matches, function(m1, m2)
        return m1.distance < m2.distance
    end)

    return matches
end
-------------------------------------------------------------------------------

return M
