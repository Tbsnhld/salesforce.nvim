local M = {}

local metadata_type_map = {
    ["lwc"] = "LightningComponentBundle",
    ["aura"] = "AuraDefinitionBundle",
    ["classes"] = "ApexClass",
    ["triggers"] = "ApexTrigger",
    ["pages"] = "ApexPage",
    ["components"] = "ApexComponent",
    ["flows"] = "Flow",
    ["objects"] = "CustomObject",
    ["layouts"] = "Layout",
    ["permissionsets"] = "PermissionSet",
    ["profiles"] = "Profile",
    ["labels"] = "CustomLabels",
    ["staticresources"] = "StaticResource",
    ["sites"] = "CustomSite",
    ["applications"] = "CustomApplication",
    ["roles"] = "UserRole",
    ["groups"] = "Group",
    ["queues"] = "Queue",
}

function M.clear_and_notify(msg)
    vim.fn.feedkeys(":", "nx")
    vim.notify(msg)
end

-- recursively search for the file
function M.find_file(path, target)
    local scanner = vim.loop.fs_scandir(path)
    -- if scanner is nil, then path is not a valid dir
    if scanner then
        local file, type = vim.loop.fs_scandir_next(scanner)
        while file do
            if type == "directory" then
                local found = find_file(path .. "/" .. file, target)
                if found then
                    return found
                end
            elseif file == target then
                return path .. "/" .. file
            end
            -- get the next file and type
            file, type = vim.loop.fs_scandir_next(scanner)
        end
    end
end

function M.get_metadata_type(filePath)
    for key, metadataType in pairs(metadata_type_map) do
        if filePath:find(key) then
            return metadataType
        end
    end
    return nil
end

function M.get_file_name_without_extension(fileName)
    -- (.-) makes the match non-greedy
    -- see https://www.lua.org/manual/5.3/manual.html#6.4.1
    return fileName:match("(.-)%.%w+%-meta%.xml$") or fileName:match("(.-)%.[^%.]+$")
end

function M.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

return M