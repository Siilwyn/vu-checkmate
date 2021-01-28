ServerUtils:SetCustomGameModeName('Checkmate')
RCON:SendCommand('vars.roundStartPlayercount', {'4'})
RCON:SendCommand('vars.autoBalance', {'false'})

local players = {}
local kingId = nil
local firstAssassinId = nil

local guardianWeapons = {
    m9 = { name = 'Weapons/M9/U_M9', attachments = {} },
    mp443 = { name = 'Weapons/MP443/U_MP443', attachments = {} },
    glock18 = { name = 'Weapons/Glock18/U_Glock18', attachments = {} },
    mp412rex = { name = 'Weapons/MP412Rex/U_MP412Rex', attachments = {} },
    remington870 = { name = 'Weapons/Remington870/U_870', attachments = {} },
    p90 = { name = 'Weapons/P90/U_P90', attachments = {} },
    aks74u = { name = 'Weapons/AKS74u/U_AKS74u', attachments = {} },
    scarh = { name = 'Weapons/SCAR-H/U_SCAR-H', attachments = {} },
    m240 = { name = 'Weapons/M240/U_M240', attachments = {} },
}

local guardianWeaponOrder = {
    guardianWeapons.m9,
    guardianWeapons.mp443,
    guardianWeapons.glock18,
    guardianWeapons.mp412rex,
    guardianWeapons.remington870,
    guardianWeapons.p90,
    guardianWeapons.aks74u,
    guardianWeapons.scarh,
    guardianWeapons.m240,
}

Events:Subscribe('Server:RoundReset', function()
    if #PlayerManager:GetPlayers() >= 4 then
        kingId = randomKey(players)
        local king = getPlayerOrBot(kingId)
        players[kingId].role = 'king'

        firstAssassinId = randomKey(players)
        while kingId == firstAssassinId do
            firstAssassinId = randomKey(players)
        end

        local firstAssassin = getPlayerOrBot(firstAssassinId)
        players[firstAssassinId].role = 'firstAssassin'
    end
end)

Events:Subscribe('Player:Joining', function(name, playerGuid, ipAddress, accountGuid)
    if kingId ~= nil then
        players[tostring(playerGuid)] = { weaponIndex = 1, role = 'assassin' }
    else
        players[tostring(playerGuid)] = { weaponIndex = 1, role = 'guardian' }
    end
end)

Events:Subscribe('Player:Left', function(player)
    if player.guid == kingId then
        RCON:SendCommand('mapList.runNextRound')
    end

    players[tostring(player.guid)] = nil
end)

Events:Subscribe('Player:Respawn', function(player)
    local playerMeta = players[tostring(player.guid)]
    local knife = ResourceManager:SearchForDataContainer('Weapons/Knife/U_Knife')

    if playerMeta.role == 'assassin' then
        local l96 = ResourceManager:SearchForDataContainer('Weapons/XP1_L96/U_L96')
        local l96Attachments = { 'Weapons/XP1_L96/U_L96_PKS-07' }

        local assassinCustomization = CustomizeSoldierData()
        assassinCustomization.removeAllExistingWeapons = true

        local primaryWeapon = UnlockWeaponAndSlot()
        primaryWeapon.weapon = SoldierWeaponUnlockAsset(l96)
        primaryWeapon.slot = WeaponSlot.WeaponSlot_0
        setAttachments(primaryWeapon, l96Attachments)

        local meleeWeapon = UnlockWeaponAndSlot()
        meleeWeapon.weapon = SoldierWeaponUnlockAsset(knife)
        meleeWeapon.slot = WeaponSlot.WeaponSlot_5

        assassinCustomization.weapons:add(primaryWeapon)
        assassinCustomization.weapons:add(meleeWeapon)

        player.soldier:ApplyCustomization(assassinCustomization)

        player.teamId = TeamId.Team1
        if kingId ~= nil then
            ChatManager:SendMessage('You are an assassin, kill the king ' .. getPlayerOrBot(kingId).name, player)
        end
    elseif playerMeta.role == 'guardian' then
        local achievedWeapon = ResourceManager:SearchForDataContainer(guardianWeaponOrder[playerMeta.weaponIndex].name)

        local guardianCustomization = CustomizeSoldierData()
        guardianCustomization.removeAllExistingWeapons = true

        local primaryWeapon = UnlockWeaponAndSlot()
        primaryWeapon.weapon = SoldierWeaponUnlockAsset(achievedWeapon)
        primaryWeapon.slot = WeaponSlot.WeaponSlot_0

        local meleeWeapon = UnlockWeaponAndSlot()
        meleeWeapon.weapon = SoldierWeaponUnlockAsset(knife)
        meleeWeapon.slot = WeaponSlot.WeaponSlot_5

        guardianCustomization.weapons:add(primaryWeapon)
        guardianCustomization.weapons:add(meleeWeapon)

        player.soldier:ApplyCustomization(guardianCustomization)

        player.teamId = TeamId.Team2
        if kingId ~= nil then
            ChatManager:SendMessage('You are a guardian, protect the king ' .. getPlayerOrBot(kingId).name, player)
        end
    elseif playerMeta.role == 'firstAssassin' then
        local l96 = ResourceManager:SearchForDataContainer('Weapons/XP1_L96/U_L96')
        local l96Attachments = { 'Weapons/XP1_L96/U_L96_PKS-07' }

        local firstAssassinCustomization = CustomizeSoldierData()
        firstAssassinCustomization.removeAllExistingWeapons = true

        local primaryWeapon = UnlockWeaponAndSlot()
        primaryWeapon.weapon = SoldierWeaponUnlockAsset(l96)
        primaryWeapon.slot = WeaponSlot.WeaponSlot_0
        setAttachments(primaryWeapon, l96Attachments)

        local meleeWeapon = UnlockWeaponAndSlot()
        meleeWeapon.weapon = SoldierWeaponUnlockAsset(knife)
        meleeWeapon.slot = WeaponSlot.WeaponSlot_5

        firstAssassinCustomization.weapons:add(primaryWeapon)
        firstAssassinCustomization.weapons:add(meleeWeapon)

        player.soldier:ApplyCustomization(firstAssassinCustomization)

        player.teamId = TeamId.Team1
        if kingId ~= nil then
            ChatManager:SendMessage('You are an assassin, kill the king ' .. getPlayerOrBot(kingId).name, player)
        end
    else
        local spas12 = ResourceManager:SearchForDataContainer('Weapons/XP2_SPAS12/U_SPAS12')

        local kingCustomization = CustomizeSoldierData()
        kingCustomization.removeAllExistingWeapons = true

        local primaryWeapon = UnlockWeaponAndSlot()
        primaryWeapon.weapon = SoldierWeaponUnlockAsset(spas12)
        primaryWeapon.slot = WeaponSlot.WeaponSlot_0

        local meleeWeapon = UnlockWeaponAndSlot()
        meleeWeapon.weapon = SoldierWeaponUnlockAsset(knife)
        meleeWeapon.slot = WeaponSlot.WeaponSlot_5

        kingCustomization.weapons:add(primaryWeapon)
        kingCustomization.weapons:add(meleeWeapon)

        player.soldier:ApplyCustomization(kingCustomization)

        player.teamId = TeamId.Team2
        if kingId ~= nil then
            ChatManager:SendMessage('You are the king, kill assassins and stay alive!', player)
        end
    end
end)

Events:Subscribe('Player:Killed', function(player, inflictor, position, weapon, isRoadKill, isHeadShot, wasVictimInReviveState, info)
    local playerMeta = getPlayerOrBotMeta(player)

    if playerMeta.role == 'king' then
		ChatManager:SendMessage('The king has been killed!')
        RCON:SendCommand('mapList.endRound', {'2'})
    end

    if inflictor == nil then
        if playerMeta.role ~= 'firstAssassin' then
            playerMeta.role = 'assassin'
            player.teamId = TeamId.Team1
        return;
        end
    end

    local inflictorMeta = getPlayerOrBotMeta(inflictor)

    if inflictorMeta.role == 'guardian' and inflictorMeta.weaponIndex < #guardianWeaponOrder then
        inflictorMeta.weaponIndex = inflictorMeta.weaponIndex + 1
        local weapon = ResourceManager:SearchForDataContainer(guardianWeaponOrder[inflictorMeta.weaponIndex].name)
        inflictor:SelectWeapon(WeaponSlot.WeaponSlot_0, weapon, {})
        return;
    end

    if inflictorMeta.role == 'king' and playerMeta.role ~= 'firstAssassin' then
        playerMeta.role = 'guardian'
        player.teamId = TeamId.Team2
    else
        playerMeta.role = 'assassin'
        player.teamId = TeamId.Team1
    end
end)

function randomKey(items)
    local keys = {}
    for key in pairs(items) do table.insert(keys, key) end
    return keys[math.random(#keys)]
end

function setAttachments(unlockWeapon, attachments)
    for _, attachment in pairs(attachments) do
        local unlockAsset = UnlockAsset(ResourceManager:SearchForDataContainer(attachment))
        unlockWeapon.unlockAssets:add(unlockAsset)
    end
end

function getPlayerOrBot(id)
    return
        PlayerManager:GetPlayerByGuid(Guid(id))
        or PlayerManager:GetPlayerByName(id)
end

function getPlayerOrBotMeta(player)
    return
        players[tostring(player.guid)]
        or players[player.name]
end
