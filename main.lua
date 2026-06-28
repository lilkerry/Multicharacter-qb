local QBCore = exports['qb-core']:GetCoreObject()

local function GetPlayerLicense(src)
    for _, id in pairs(GetPlayerIdentifiers(src)) do
        if string.find(id, "license:") then
            return id
        end
    end
    return nil
end

QBCore.Functions.CreateCallback('qb-multicharacter:server:GetCharacters', function(source, cb)
    local license = GetPlayerLicense(source)
    if not license then
        cb({})
        return
    end

    MySQL.query('SELECT * FROM players WHERE license = ?', { license }, function(result)
        local characters = {}

        for i = 1, Config.CharacterSlots do
            characters[i] = nil
        end

        for _, v in pairs(result) do
            local cid = tonumber(v.cid) or 1
            characters[cid] = {
                citizenid = v.citizenid,
                cid = cid,
                name = (v.charinfo and json.decode(v.charinfo) and (json.decode(v.charinfo).firstname .. " " .. json.decode(v.charinfo).lastname)) or "Unknown",
                money = v.money and json.decode(v.money) or {},
                job = v.job and json.decode(v.job) or {},
                charinfo = v.charinfo and json.decode(v.charinfo) or {}
            }
        end

        cb(characters)
    end)
end)

QBCore.Functions.CreateCallback('qb-multicharacter:server:CreateCharacter', function(source, cb, data)
    local license = GetPlayerLicense(source)
    if not license then
        cb(false)
        return
    end

    local cid = tonumber(data.cid)
    if not cid or cid < 1 or cid > Config.CharacterSlots then
        cb(false)
        return
    end

    local citizenid = QBCore.Player.CreateCitizenId()
    local name = {
        firstname = data.firstname or "New",
        lastname = data.lastname or "Citizen",
        birthdate = data.birthdate or "2000-01-01",
        gender = tonumber(data.gender) or 0,
        nationality = data.nationality or "USA"
    }

    local money = {
        cash = 500,
        bank = 5000,
        crypto = 0
    }

    local job = {
        name = "unemployed",
        label = "Civilian",
        payment = 10,
        onduty = false,
        isboss = false,
        grade = {
            name = "Freelancer",
            level = 0
        }
    }

    MySQL.insert([[
        INSERT INTO players
        (citizenid, license, name, money, charinfo, job, gang, position, metadata, inventory, cid)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        citizenid,
        license,
        citizenid,
        json.encode(money),
        json.encode(name),
        json.encode(job),
        json.encode({}),
        json.encode({
            x = Config.DefaultSpawn.x,
            y = Config.DefaultSpawn.y,
            z = Config.DefaultSpawn.z,
            a = Config.DefaultSpawn.w
        }),
        json.encode({}),
        json.encode({}),
        cid
    }, function(insertId)
        cb(insertId ~= nil)
    end)
end)

QBCore.Functions.CreateCallback('qb-multicharacter:server:DeleteCharacter', function(source, cb, citizenid)
    local license = GetPlayerLicense(source)
    if not license or not citizenid then
        cb(false)
        return
    end

    MySQL.query('DELETE FROM players WHERE citizenid = ? AND license = ?', { citizenid, license }, function()
        cb(true)
    end)
end)

RegisterNetEvent('qb-multicharacter:server:SelectCharacter', function(citizenid)
    local src = source
    if not citizenid then return end

    QBCore.Player.Login(src, citizenid, function()
        QBCore.Commands.Refresh(src)
        TriggerClientEvent('qb-multicharacter:client:CharacterLoaded', src)
    end)
end)

RegisterNetEvent('qb-multicharacter:server:CreateStarterItems', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    for _, item in pairs(Config.StarterItems) do
        Player.Functions.AddItem(item.name, item.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "add")
    end
end)
