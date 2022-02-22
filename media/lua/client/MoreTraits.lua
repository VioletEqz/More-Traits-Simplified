require('NPCs/MainCreationMethods');
require("Items/Distributions");
require("Items/ProceduralDistributions");
--[[
TODO Figure out what is causing stat synchronization issues
When playing in Singleplayer, traits like Blissful work just fine. But in Multiplayer, subtracting stats doesn't
seem to work properly. This also effects Hardy, Alcoholic (removing stress when drinking alcohol doesn't work in MP)
TODO Code optimization
This is constantly ongoing. Whenever I see something that can be written more efficiently, I try to rewrite where i can.
TODO Reimplement Fast and Slow traits
Ever since the animations update, the previous calculations stopped working, and despite hours wracking my brain,
I have been unable to find a workaround.
--]]
--Global Variables
luckimpact = 1.0;

local function tableContains(t, e)
    for _, value in pairs(t) do
        if value == e then
            return true
        end
    end
    return false
end

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function initToadTraitsPerks(_player)
    local player = _player;
    local playerdata = player:getModData();
    local damage = 20;
    local bandagestrength = 5;
    local splintstrength = 0.9;
    local fracturetime = 50;
    local scratchtimemod = 20;
    local bleedtimemod = 10;

    if player:HasTrait("injured") then
        local bodydamage = player:getBodyDamage();
        local itterations = ZombRand(1, 4) + 1;
        local doburns = true;
        if SandboxVars.MoreTraits.InjuredBurns == false then
            doburns = false;
        end
        for i = 0, itterations do
            local randompart = ZombRand(0, 16);
            local b = bodydamage:getBodyPart(BodyPartType.FromIndex(randompart));
            local injury = ZombRand(0, 5);
            local skip = false;
            if b:HasInjury() then
                itterations = itterations - 1;
                skip = true;
            end
            if skip == false then
                if injury <= 1 then
                    b:AddDamage(damage);
                    b:setScratched(true, true);
                    b:setBandaged(true, bandagestrength, true, "Base.AlcoholBandage");
                elseif injury == 2 then
                    if doburns == true then
                        b:AddDamage(damage);
                        b:setBurned();
                        b:setBurnTime(ZombRand(50) + damage);
                        b:setNeedBurnWash(false);
                        b:setBandaged(true, bandagestrength, true, "Base.AlcoholBandage");
                    else
                        itterations = itterations - 1;
                    end
                elseif injury == 3 then
                    b:AddDamage(damage);
                    b:setCut(true, true);
                    b:setBandaged(true, bandagestrength, true, "Base.AlcoholBandage");
                elseif injury >= 4 then
                    b:AddDamage(damage);
                    b:setDeepWounded(true);
                    b:setStitched(true);
                    b:setBandaged(true, bandagestrength, true, "Base.AlcoholBandage");
                end
            end
        end
        bodydamage:setInfected(false);
        bodydamage:setInfectionLevel(0);
    end
    if player:HasTrait("broke") then
        local bodydamage = player:getBodyDamage();
        bodydamage:getBodyPart(BodyPartType.LowerLeg_R):AddDamage(damage);
        bodydamage:getBodyPart(BodyPartType.LowerLeg_R):setFractureTime(fracturetime);
        bodydamage:getBodyPart(BodyPartType.LowerLeg_R):setSplint(true, splintstrength);
        bodydamage:getBodyPart(BodyPartType.LowerLeg_R):setSplintItem("Base.Splint");
        bodydamage:getBodyPart(BodyPartType.LowerLeg_R):setBandaged(true, bandagestrength, true, "Base.AlcoholBandage");
        bodydamage:setInfected(false);
        bodydamage:setInfectionLevel(0);
    end
    if player:HasTrait("burned") then
        local bodydamage = player:getBodyDamage();
        for i = 0, bodydamage:getBodyParts():size() - 1 do
            local b = bodydamage:getBodyParts():get(i);
            b:setBurned();
            b:setBurnTime(ZombRand(10, 100) + damage);
            b:setNeedBurnWash(false);
            b:setBandaged(true, ZombRand(1, 10) + bandagestrength, true, "Base.AlcoholBandage");
        end
    end
    playerdata.ToadTraitBodyDamage = nil;
    player:getBodyDamage():Update();
    playerdata.fLastHP = nil;
    checkWeight();
end


function checkWeight()
    local player = getPlayer();
    local strength = player:getPerkLevel(Perks.Strength);
    local mule = 10;
    local mouse = 6;
    local default = 8;
    local globalmod = 0;
    if SandboxVars.MoreTraits.WeightPackMule then
        mule = SandboxVars.MoreTraits.WeightPackMule;
    end
    if SandboxVars.MoreTraits.WeightPackMouse then
        mouse = SandboxVars.MoreTraits.WeightPackMouse;
    end
    if SandboxVars.MoreTraits.WeightDefault then
        default = SandboxVars.MoreTraits.WeightDefault;
    end
    if SandboxVars.MoreTraits.WeightGlobalMod then
        globalmod = SandboxVars.MoreTraits.WeightGlobalMod;
    end
    local muleMaxWeightbonus = math.floor(mule + strength / 5 + globalmod);
    local mouseMaxWeightbonus = math.floor(mouse + globalmod);
    local defaultMaxWeightbonus = math.floor(default + globalmod);
    if player:HasTrait("packmule") then
        player:setMaxWeightBase(muleMaxWeightbonus);
    elseif player:HasTrait("packmouse") then
        player:setMaxWeightBase(mouseMaxWeightbonus);
    else
        player:setMaxWeightBase(defaultMaxWeightbonus)
        ;
    end
end

local function QuickWorker(_player)
    local player = _player;
    if player:HasTrait("quickworker") then
        if player:hasTimedActions() == true then
            local actions = player:getCharacterActions();
            local blacklist = { "ISWalkToTimedAction", "ISPathFindAction", "" }
            local action = actions:get(0);
            local type = action:getMetaType();
            local delta = action:getJobDelta();
            --Don't modify the action if it is in the Blacklist or if it has not yet started (is valid)
            if tableContains(blacklist, type) == false and delta > 0 then
                local modifier = 0.5;
                if SandboxVars.MoreTraits.QuickWorkerScaler then
                    modifier = modifier * (SandboxVars.MoreTraits.QuickWorkerScaler * 0.01);
                end
                if player:HasTrait("Lucky") and ZombRand(100) <= 10 then
                    modifier = modifier + 0.25 * luckimpact;
                elseif player:HasTrait("Unlucky") and ZombRand(100) <= 10 then
                    modifier = modifier - 0.25 * luckimpact;
                end
                if player:HasTrait("Dextrous") and ZombRand(100) <= 10 then
                    modifier = modifier + 0.25;
                elseif player:HasTrait("AllThumbs") and ZombRand(100) <= 10 then
                    modifier = modifier - 0.25;
                end
                if type == "ISReadABook" then
                    if player:HasTrait("FastReader") then
                        modifier = modifier * 5;
                    elseif player:HasTrait("SlowReader") then
                        modifier = modifier * 1.5;
                    else
                        modifier = modifier * 3;
                    end
                end
                if modifier < 0 then
                    modifier = 0;
                end
                if delta < 0.99 - (modifier * 0.01) then
                    --Don't overshoot it.
                    action:setCurrentTime(action:getCurrentTime() + modifier);
                end
            end
        end
    end
end

local function SlowWorker(_player)
    local player = _player;
    if player:HasTrait("slowworker") then
        if player:hasTimedActions() == true then
            local actions = player:getCharacterActions();
            local blacklist = { "ISWalkToTimedAction", "ISPathFindAction", "" }
            local action = actions:get(0);
            local type = action:getMetaType();
            local delta = action:getJobDelta();
            --Don't modify the action if it is in the Blacklist or if it has not yet started (is valid)
            if tableContains(blacklist, type) == false and delta > 0 then
                local modifier = 0.5;
                local chance = 15;
                if SandboxVars.MoreTraits.SlowWorkerScaler then
                    chance = SandboxVars.MoreTraits.SlowWorkerScaler;
                end
                if player:HasTrait("Lucky") and ZombRand(100) <= 10 then
                    modifier = modifier - 0.5 * luckimpact;
                elseif player:HasTrait("Unlucky") and ZombRand(100) <= 10 then
                    modifier = modifier + 0.5 * luckimpact;
                end
                if player:HasTrait("Dextrous") and ZombRand(100) <= 10 then
                    modifier = modifier - 0.5;
                elseif player:HasTrait("AllThumbs") and ZombRand(100) <= 10 then
                    modifier = modifier + 0.5;
                end
                if type == "ISReadABook" then
                    if player:HasTrait("FastReader") then
                        modifier = modifier * 0.1;
                    elseif player:HasTrait("SlowReader") then
                        modifier = modifier * 0.5;
                    else
                        modifier = modifier * 0.25;
                    end
                end
                if modifier < 0 then
                    modifier = 0;
                end
                if delta < 0.99 - (modifier * 0.01) and ZombRand(100) <= chance then
                    --Don't overshoot it.
                    action:setCurrentTime(action:getCurrentTime() - modifier);
                end
            end
        end
    end
end

local function MainPlayerUpdate(_player)
    local player = _player;
    QuickWorker(player);
    SlowWorker(player);
end
local function OnLoad()
    --reset any worn clothing to default state.
    local player = getPlayer();
    local playerdata = player:getModData();
    local wornItems = player:getWornItems();
    for i = wornItems:size() - 1, 0, -1 do
        local item = wornItems:getItemByIndex(i);
        if item:IsClothing() then
            local itemdata = item:getModData();
            itemdata.sState = nil;
        end
    end
    playerdata.ToadTraitBodyDamage = nil;
    player:getBodyDamage():Update();
end

Events.OnPlayerUpdate.Add(MainPlayerUpdate);
Events.EveryTenMinutes.Add(checkWeight);
Events.OnNewGame.Add(initToadTraitsPerks);
Events.OnLoad.Add(OnLoad);