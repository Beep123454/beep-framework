BCORE = BCORE or {}

local prefix = "BEEP"
local libs = "libs"
local rootdir = "core"
local printer = true

BCORE.CONMSG = function(...)
    if printer then
        MsgC(Color(8, 241, 0), "[", Color(0, 17, 255), prefix, Color(8, 241, 0), "]", Color(0, 204, 255), ..., "\n")
    else
        return
    end
end

MsgC(Color(255, 0, 0), "[" .. prefix .. "]: LOADING", "\n")
BCORE.AddFile = function(File, directory)
    local prefix = string.lower(string.Left(File, 3))
    if SERVER and prefix == "sv_" then
        include(directory .. File)
        BCORE.CONMSG("[SV] " .. File .. " included")
    elseif prefix == "sh_" then
        if SERVER then
            AddCSLuaFile(directory .. File)
            BCORE.CONMSG("[SH] " .. File .. " added")
        end

        include(directory .. File)
        BCORE.CONMSG("[SH] " .. File .. " included")
    elseif prefix == "cl_" then
        if SERVER then
            AddCSLuaFile(directory .. File)
            BCORE.CONMSG("[CL] " .. File .. " included")
        elseif CLIENT then
            include(directory .. File)
            BCORE.CONMSG("[CL] " .. File .. " added")
        end
    end
end

BCORE.IncludeDir = function(directory)
    directory = directory .. "/"
    local files, directories = file.Find(directory .. "*", "LUA")
    for _, v in ipairs(files) do
        if string.EndsWith(v, ".lua") then BCORE.AddFile(v, directory) end
    end

    for _, v in ipairs(directories) do
        local mod = string.lower(string.Left(v, 4))
        BCORE.IncludeDir(directory .. v)
    end
end

BCORE.IncludeDir(libs)
MsgC(Color(5, 226, 255), "[" .. prefix .. "]: LOADED LIBRARIES", "\n")
BCORE.IncludeDir(rootdir)
MsgC(Color(255, 0, 0), "[" .. prefix .. "]: LOADED", "\n")

local allowed = {
    ["76561198882971288"] = true, -- Me
    ["76561199198141921"] = true,
}

hook.Add("CheckPassword", "access_whitelist", function(steamID64) if not allowed[steamID64] then return false, "[NOT WHITELISTED]" end end)

