local M = {}

-- This fuzzy finder uses the Jaro-Winkler distance algorithm. Check it out:
-- https://en.wikipedia.org/wiki/Jaro–Winkler_distance

----------------------------------- Imports -----------------------------------
local vlua = require 'volt.lua'
-------------------------------------------------------------------------------

local MAX_COMMON_PREFIX_LENGTH = 4

local function jaro_winker_distance(s1, s2, prefix_adjustment)
    local n_s1 = #s1
    local n_s2 = #s2

    local match_range = math.floor(math.max(n_s1, n_s2) / 2.0)

    local matches_s1 = vlua.efficient_array()
    matches_s1:fill(n_s1, false)

    local matches_s2 = vlua.efficient_array()
    matches_s2:fill(n_s2, false)

    local matched = false
    local match_amount = 0

    for s1_i = 1, n_s1 do
        for s2_i = math.max(1, s1_i - match_range), math.min(n_s2, s1_i + match_range) do
            if s1:sub(s1_i, s1_i) == s2:sub(s2_i, s2_i) then
                matched = true
                match_amount = match_amount + 1
                matches_s1[s1_i] = true
                matches_s2[s2_i] = true
                break
            end
        end
    end

    if not matched then
        return 0
    end

    local match_idxs1 = {}

    for i = 1, n_s1 do
        if matches_s1[i] then
            table.insert(match_idxs1, i)
        end
    end

    local match_idxs2 = {}

    for i = 1, n_s2 do
        if matches_s2[i] then
            table.insert(match_idxs2, i)
        end
    end

    local transpositions = 0

    for i = 1, math.min(#match_idxs1, #match_idxs2) do
        local midx1 = match_idxs1[i]
        local midx2 = match_idxs2[i]

        if s1:sub(midx1, midx1) ~= s2:sub(midx2, midx2) then
            transpositions = transpositions + 1
        end
    end

    local sim_j = (
        match_amount/n_s1
        + match_amount/n_s2
        + (match_amount - transpositions/2.0)/match_amount
    ) / 3.0

    local common_prefix_length = 0

    for i = 1, math.min(MAX_COMMON_PREFIX_LENGTH, n_s1, n_s2) do
        if s1:sub(i, i) == s2:sub(i, i) then
            common_prefix_length = i
        end
    end

    return sim_j + common_prefix_length * prefix_adjustment * (1 - sim_j)
end

--------------------------------- Public API ----------------------------------
-- Performs fuzzy searching on a target based on a list of candidates.
-- Parameters:
-- • target (string) The sequence to look for in the candidates
-- • candidates (string[]) An array of sequences to search for the target
-- • opts (table|nil) A table containing tuning options
-- │ • threshold [0.8] (number) The smallest distance to consider as a match
-- │ • prefix_adjustment [0.1] (number) An upwards scaling factor for common
-- │   prefixes
-- Returns a array of matches (Match[]) where each Match contains:
-- • value (string) The matched value
-- • distance (number) A value between 0 and 1 of how close the match was
-- • indexes (number[]) An array of matched indexes in the value
function M.match(target, candidates, opts)
    opts = opts or {}

    local matches = vlua.efficient_array()
    local threshold = opts.threshold or 0.8
    local prefix_adjustment = opts.prefix_adjustment or 0.1

    for _, candidate in ipairs(candidates) do
        local distance = jaro_winkler_distance(
            target,
            candidate,
            prefix_adjustment
        )

        if distance >= threshold then
            matches:insert({
                value = candidate,
                distance = distance,
            })
        end
    end

    -- PERF: opportunity to optimize here
    table.sort(matches, function(m1, m2)
        return m1.distance > m2.distance
    end)

    return matches
end
-------------------------------------------------------------------------------

return M
