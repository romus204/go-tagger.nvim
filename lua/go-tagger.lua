local M = {}

local config = {
    skip_private = true,     -- Skip unexported fields (starting with lowercase)
    casing = "snake_case",   -- Global casing setting
    tags = {}                -- Per tag setting override
}

function M.setup(user_config)
    config = vim.tbl_deep_extend("force", config, user_config or {})
end

----------------------------------------------------------------
-- CASE CONVERTERS
----------------------------------------------------------------

local function split_words(str)
    str = str:gsub("(%l)(%u)", "%1 %2")
    str = str:gsub("(%u)(%u%l)", "%1 %2")
    str = str:gsub("[_%-%s]+", " ")

    local words = {}
    for w in str:gmatch("%S+") do
        table.insert(words, w:lower())
    end
    return words
end

local function to_snake_case(str)
    return table.concat(split_words(str), "_")
end

local function to_kebab_case(str)
    return table.concat(split_words(str), "-")
end

local function to_camel_case(str)
    local words = split_words(str)
    if #words == 0 then return str end

    local result = words[1]
    for i = 2, #words do
        result = result .. words[i]:sub(1, 1):upper() .. words[i]:sub(2)
    end
    return result
end

local function to_pascal_case(str)
    local words = split_words(str)
    for i, w in ipairs(words) do
        words[i] = w:sub(1, 1):upper() .. w:sub(2)
    end
    return table.concat(words)
end

local casing_map = {
    snake_case = to_snake_case,
    camelCase = to_camel_case,
    PascalCase = to_pascal_case,
    ["kebab-case"] = to_kebab_case,
}

----------------------------------------------------------------
-- CASING RESOLVER
----------------------------------------------------------------

local function get_casing_fn(tag)
    -- per-tag override
    if config.tags
        and config.tags[tag]
        and config.tags[tag].casing
        and casing_map[config.tags[tag].casing]
    then
        return casing_map[config.tags[tag].casing]
    end

    -- global
    if config.casing and casing_map[config.casing] then
        return casing_map[config.casing]
    end

    -- fallback
    return to_snake_case
end

----------------------------------------------------------------
-- TAG PARSING
----------------------------------------------------------------

local function parse_existing_tags(tag_string)
    local tags = {}
    for tag in tag_string:gmatch("[^%s]+") do
        local key = tag:match("^(.-):")
        if key then
            tags[#tags + 1] = { key = key, raw = tag }
        end
    end
    return tags
end

----------------------------------------------------------------
-- ADD TAGS
----------------------------------------------------------------

local function add_tags_to_line(line, tag_input)
    local field = line:match("^%s*([%w_]+)%s+[%w_%*%[%]]+")
    if not field then return line end

    if config.skip_private and field:sub(1, 1):lower() == field:sub(1, 1) then
        return line
    end

    local before, existing_tag_str, after = line:match("^(.-)`(.-)`(.*)$")
    local tags = {}

    if existing_tag_str then
        tags = parse_existing_tags(existing_tag_str)
    else
        local beforeComment, afterComment = line:match("^(.-)//(.*)$")
        if beforeComment and afterComment then
            before = beforeComment
            after = "//" .. afterComment
        else
            before = line
            after = ""
        end
    end

    local existing_keys = {}
    for _, tag in ipairs(tags) do
        existing_keys[tag.key] = true
    end

    for new_tag in tag_input:gmatch("[^,%s]+") do
        if not existing_keys[new_tag] then
            local casing_fn = get_casing_fn(new_tag)

            tags[#tags + 1] = {
                key = new_tag,
                raw = string.format('%s:"%s"', new_tag, casing_fn(field))
            }
        end
    end

    local combined_tags = {}
    for _, tag in ipairs(tags) do
        table.insert(combined_tags, tag.raw)
    end

    return before .. "`" .. table.concat(combined_tags, " ") .. "`" .. after
end

----------------------------------------------------------------
-- REMOVE TAGS
----------------------------------------------------------------

local function remove_tags_from_line(line, tag_to_remove)
    local before, tag_str, after = line:match("^(.-)`(.-)`(.*)$")
    if not tag_str then return line end

    local new_tags = {}
    for tag in tag_str:gmatch("[^%s]+") do
        local key = tag:match("^(.-):")
        if tag_to_remove == "" or (key and key == tag_to_remove) then
        else
            table.insert(new_tags, tag)
        end
    end

    if #new_tags == 0 then
        return before .. after
    else
        return before .. "`" .. table.concat(new_tags, " ") .. "`" .. after
    end
end

----------------------------------------------------------------
-- INPUT
----------------------------------------------------------------

local function input_tags()
    return vim.fn.input("tag(s): "):gsub("%s+", "")
end

local function input_tag_to_remove()
    return vim.fn.input("tag: "):gsub("%s+", "")
end

----------------------------------------------------------------
-- BUFFER UPDATE
----------------------------------------------------------------

local function update_lines(bufnr, start_idx, end_idx, transformer)
    local lines = vim.api.nvim_buf_get_lines(bufnr, start_idx, end_idx, false)
    for i, line in ipairs(lines) do
        lines[i] = transformer(line)
    end
    vim.api.nvim_buf_set_lines(bufnr, start_idx, end_idx, false, lines)
end

----------------------------------------------------------------
-- PUBLIC API
----------------------------------------------------------------

function M.add_tags(start_line, end_line)
    local bufnr = vim.api.nvim_get_current_buf()

    if start_line and end_line then
        local tag_input = input_tags()
        if tag_input == "" then return end

        update_lines(bufnr, start_line, end_line, function(line)
            return add_tags_to_line(line, tag_input)
        end)
    end
end

function M.remove_tags(start_line, end_line)
    local bufnr = vim.api.nvim_get_current_buf()
    local tag_input = input_tag_to_remove()

    if start_line and end_line then
        update_lines(bufnr, start_line, end_line, function(line)
            return remove_tags_from_line(line, tag_input)
        end)
    end
end

return M
