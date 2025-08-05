--[[ Version Checker ]] --
local version = "353"

local DISCORD_WEBHOOK = ""
local DISCORD_NAME = "AN - ENGINESWAP"
local DISCORD_IMAGE = "https://cdn.discordapp.com/attachments/1026175982509506650/1026176123928842270/Lanzaned.png"

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        checkResourceVersion()
    end
end)

function checkUpdateEmbed(color, name, message, footer)
    local content = {
        {
            ["color"] = color,
            ["title"] = " " .. name .. " ",
            ["description"] = message,
            ["footer"] = {
                ["text"] = " " .. footer .. " ",
            },
        }
    }
    PerformHttpRequest(DISCORD_WEBHOOK, function(err, text, headers) end, 
    'POST', json.encode({
        username = DISCORD_NAME, 
        embeds = content, 
        avatar_url = DISCORD_IMAGE
    }), { ['Content-Type'] = 'application/json '})
end

function checkResourceVersion()
    PerformHttpRequest("https://raw.githubusercontent.com/Annalouu/an-engineswap/main/version.txt", function(err, text, headers)
        if (version > text) then -- Using Dev Branch
            print(" ")
            print("---------- ANNALOU | ENGINE SWAP ----------")
            print("Engineswap is using a development branch! Please update to stable ASAP!")
            print("Your Version: " .. version .. " Current Stable Version: " .. text)
            print("https://github.com/Annalouu/an-engineswap")
            print("-----------------------------------------------")
            print(" ")
            checkUpdateEmbed(5242880, "Engineswap Update Checker", "Engineswap is using a development branch! Please update to stable ASAP!\nYour Version: " .. version .. " Current Stable Version: " .. text .. "\nhttps://github.com/Annalouu/an-engineswap", "Script created by: https://discord.gg/94fqva84vb")
        elseif (text < version) then -- Not updated
            print(" ")
            print("---------- ANNALOU | ENGINE SWAP ----------")
            print("Engineswap is not up to date! Please update!")
            print("Curent Version: " .. version .. " Latest Version: " .. text)
            print("https://github.com/Annalouu/an-engineswap")
            print("-----------------------------------------------")
            print(" ")
            checkUpdateEmbed(5242880, "Engineswap Update Checker", "Engineswap is not up to date! Please update!\nCurent Version: " .. version .. " Latest Version: " .. text .. "\nhttps://github.com/Annalouu/an-engineswap", "Script created by: https://discord.gg/94fqva84vb")
        else -- resource is fine
            print(" ")
            print("---------- ANNALOU | ENGINE SWAP ----------")
            print("Engineswap is up to date and ready to go!")
            print("Running on Version: " .. version)
            print("https://github.com/Annalouu/an-engineswap")
            print("-----------------------------------------------")
            print(" ")
            checkUpdateEmbed(20480, "Engineswap Update Checker", "Engineswap is up to date and ready to go!\nRunning on Version: " .. version .. "\nhttps://github.com/Annalouu/an-engineswap", "Script created by: https://discord.gg/94fqva84vb")
        end 
    end, "GET", "", {})
end
