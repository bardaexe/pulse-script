local cards <const> = {
    handshake = {
        active = json.encode({
            ["type"] = "AdaptiveCard",
            ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
            ["version"] = "1.5",
            ["body"] = {
                {
                    ["type"] = "Image",
                    ["url"] =
                    "https://cdn.discordapp.com/attachments/769280060623421483/1296280374565015575/Logo_neon.png?ex=6711b6ad&is=6710652d&hm=69b2ecf57439bcb84204c3a6b57b7d3f65969a04ed8303d6e5a67f506eff958f&",
                    ["size"] = "Medium",
                    ["horizontalAlignment"] = "Center"
                },
                {
                    ["type"] = "TextBlock",
                    ["wrap"] = true,
                    ["weight"] = "Bolder",
                    ["text"] = "Pulse Security",
                    ["horizontalAlignment"] = "Center",
                    ["style"] = "heading"
                },
                {
                    ["spacing"] = "Large",
                    ["type"] = "TextBlock",
                    ["wrap"] = true,
                    ["text"] = "Handshaking with Pulse Security's API..",
                    ["horizontalAlignment"] = "Center",
                    ["spacing"] = "Medium"
                }
            },
        }),
        failed = json.encode({
            ["type"] = "AdaptiveCard",
            ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
            ["version"] = "1.5",
            ["body"] = {
                {
                    ["type"] = "Image",
                    ["url"] =
                    "https://cdn.discordapp.com/attachments/769280060623421483/1296280374565015575/Logo_neon.png?ex=6711b6ad&is=6710652d&hm=69b2ecf57439bcb84204c3a6b57b7d3f65969a04ed8303d6e5a67f506eff958f&",
                    ["size"] = "Medium",
                    ["horizontalAlignment"] = "Center"
                },
                {
                    ["type"] = "TextBlock",
                    ["wrap"] = true,
                    ["weight"] = "Bolder",
                    ["text"] = "Pulse Security",
                    ["horizontalAlignment"] = "Center",
                    ["style"] = "heading"
                },
                {
                    ["spacing"] = "Medium",
                    ["type"] = "TextBlock",
                    ["wrap"] = true,
                    ["text"] = "Failed to handshake with Pulse Security's API",
                    ["verticalContentAlignment"] = "Center",
                    ["horizontalAlignment"] = "Center"
                },
                {
                    ["type"] = "TextBlock",
                    ["spacing"] = "None",
                    ["text"] = "Please try again later or contact the server owner regarding this message.",
                    ["horizontalAlignment"] = "Center",
                    ["wrap"] = true,
                    ["isSubtle"] = true
                }
            },
        })
    },
    banned = json.encode({
        ["type"] = "AdaptiveCard",
        ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
        ["version"] = "1.5",
        ["body"] = {
            {
                ["type"] = "TextBlock",
                ["wrap"] = true,
                ["text"] = "You have been globally banned by Pulse Security.",
                ["style"] = "heading"
            },
            {
                ["type"] = "ColumnSet",
                ["columns"] = {
                    {
                        ["type"] = "Column",
                        ["items"] = {
                            {
                                ["type"] = "Image",
                                ["style"] = "Person",
                                ["url"] =
                                "https://cdn.discordapp.com/attachments/769280060623421483/1296280374565015575/Logo_neon.png?ex=6711b6ad&is=6710652d&hm=69b2ecf57439bcb84204c3a6b57b7d3f65969a04ed8303d6e5a67f506eff958f&",
                                ["size"] = "Small"
                            }
                        },
                        ["width"] = "auto"
                    },
                    {
                        ["type"] = "Column",
                        ["items"] = {
                            {
                                ["type"] = "TextBlock",
                                ["weight"] = "Bolder",
                                ["text"] = "Ban ID: %s, Issued by: %s, Reason: %s, Banned at: %s",
                                ["wrap"] = true
                            },
                            {
                                ["type"] = "TextBlock",
                                ["spacing"] = "None",
                                ["text"] =
                                "This ban can be disabled specifically for this server by the server owner.\nIf pulsec.net will get enough requests by our users, we will consider to remove the ban globally.",
                                ["wrap"] = true,
                                ["isSubtle"] = true,
                            }
                        },
                        ["width"] = "stretch"
                    }
                }
            }
        },
        ["actions"] = {
            {
                ["type"] = "Action.OpenUrl",
                ["url"] = "https://pulsec.net",
                ["title"] = "Website"
            },
            {
                ["type"] = "Action.OpenUrl",
                ["url"] = "https://discord.gg/FNK4Z6EMWV",
                ["title"] = "Discord"
            }
        }
    })
}

--[[
    Retrieves the value of a convar as a boolean.

    @param name string: The name of the convar to retrieve.
    @param default boolean: The default value to return if the convar is not set.

    @return boolean: The value of the convar if it is set, otherwise the default value.
]]
local function getPlayerIdentifiers(name, src)
    local nameSearch <const> = tonumber(GetConvar("pulsec_name_search", 0)) ~= 0
    local identifiers <const> = {
        name = nameSearch and name or nil,
        ip = GetPlayerIdentifierByType(src, "ip"),
        steam = GetPlayerIdentifierByType(src, "steam"),
        discord = GetPlayerIdentifierByType(src, "discord"),
        license = GetPlayerIdentifierByType(src, "license"),
        license2 = GetPlayerIdentifierByType(src, "license2"),
        xbl = GetPlayerIdentifierByType(src, "xbl"),
        live = GetPlayerIdentifierByType(src, "live"),
        hwid1 = GetPlayerIdentifierByType(src, "hwid"),
        hwid2 = GetPlayerIdentifierByType(src, "hwid2"),
        hwid3 = GetPlayerIdentifierByType(src, "hwid3"),
        hwid4 = GetPlayerIdentifierByType(src, "hwid4"),
        hwid5 = GetPlayerIdentifierByType(src, "hwid5")
    }

    return identifiers
end

--[[
    Retrieves a list of excluded bans from the server configuration.

    This function reads the "pulsec_exclude" convar, which is expected to be a comma-separated
    string of ban IDs. It then processes this string to create a table where each key is a ban ID
    (converted to a number) and the value is `true`, indicating that the ban is excluded.

    @return table A table of excluded bans with ban IDs as keys and `true` as values.
]]
local function getExcludedBans()
    local _excludedBans <const> = GetConvar("pulsec_exclude", "")
    local excludedBans = {}
    for ban in string.gmatch(string.gsub(_excludedBans, " ", ""), '([^,]+)') do
        excludedBans[tonumber(ban)] = true
    end

    return excludedBans
end

--[[
    Retrieves ban information for a player based on their identifiers.

    @param name string: The name of the player.
    @param src number: The source ID of the player.

    @return table: A table containing the HTTP response code and response text.

    The function performs an HTTP POST request to the PulseC API endpoint to get ban details.
    It uses player identifiers and an API key for authorization.
    The request is asynchronous, and the function waits for the response before returning it.
]]
local function getBanByFields(name, src)
    local apiKey <const> = GetConvar("pulsec_api_key", "none")
    if apiKey == "none" then
        print("^1pulsec_api_key not found, please set it in the server.cfg! skipped ban check for " .. name .. "...^0")
        return
    end

    local identifiers <const> = getPlayerIdentifiers(name, src)
    local pResponse = promise.new()

    PerformHttpRequest("https://pulsec.net/api/getBanByFields", function(code, text, headers)
        -- PerformHttpRequest("http://localhost:3000/api/getBanByFields", function(code, text, headers)
        pResponse:resolve({ code = code, text = text })
    end, "POST", json.encode(identifiers), {
        ["Authorization"] = "Bearer " .. apiKey,
        ["Content-Type"] = "application/json"
    })

    return Citizen.Await(pResponse)
end

--[[
    This function handles the player connection process.
    It performs a series of checks to determine if the player is banned.
    If the player is banned, it presents a ban card with the ban details.
    If the player is not banned, it allows the player to connect.

    @param name The name of the player attempting to connect.
    @param setKickReason A function to set the reason for kicking the player.
    @param deferrals An object to manage the deferral process.
]]
local function onPlayerConnecting(name, setKickReason, deferrals)
    local src <const> = source
    local currentCard = cards.handshake.active

    deferrals.defer()

    -- mandatory wait!
    Wait(0)

    Citizen.CreateThread(function()
        while true do
            deferrals.presentCard(currentCard)
            Citizen.Wait(0)
        end
    end)

    -- mandatory wait!
    Wait(0)

    local response <const> = getBanByFields(name, src)
    if response?.code ~= 200 then
        currentCard = cards.handshake.failed
        return
    end

    local isBanned <const> = #response.text > 2
    if isBanned then
        local data <const> = json.decode(response.text)

        local excludedBans <const> = getExcludedBans()
        if excludedBans[data.id] then
            deferrals.done()
            return
        end

        local date <const> = data.date:sub(1, 10) .. " " .. data.date:sub(12, 19)

        currentCard = string.format(cards.banned, data.id, data.server, data.reason, date)
        return
    end

    deferrals.done()
end

AddEventHandler("playerConnecting", onPlayerConnecting)
