local VORPcore = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()
local progressbar = exports.vorp_progressbar:initiate()

---- LOCALS ---

local CreatedBeehives = {}
local CreatedBlips = {}
local BeehiveData = nil
local CharID = nil
local ThreadRunning = false
local CreatedWildBeehives = {}
local SmokedBeehives = {}
local TakenBeeBeehives = {}
local TakenQueenBeehives = {}
local TakenHoneyBeehives = {}
local bees_cloud_group = "core"
local bees_cloud_name = "ent_amb_insect_bee_swarm"
local CreatedFXSwarms = {}
local WildHivesSpawned = false
local Translation = {}
local NuiOpen = false

local oldHat = nil
local newBeekeeperHat = nil
local wearingHat = false

local file = LoadResourceFile(
    GetCurrentResourceName(),
    'html/locales/de.json'
)

if file then
    Translation = json.decode(file)
end

RegisterNetEvent('openBeehive',function(CurrentBeehive)
    local data = json.decode(CurrentBeehive[1].data)
    local hiveID = CurrentBeehive[1].id
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'open',
        currentHive = data,
        config = Config,
        hiveID = hiveID,
    })
    NuiOpen = true
end)

RegisterNuiCallback('close',function(data,cb)
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = 'close'
    })

    cb({success = true})
    NuiOpen = false
end)

RegisterNetEvent('updateNUI',function(Data)
    if NuiOpen then
        SendNUIMessage({
            action = 'updateNUI',
            currentHive = Data
        })
    end
end)

-- Get Lang

RegisterNuiCallback('getLang',function(data,cb)
    local lang = Config.lang
    cb({success = true, lang = lang})
end)


-----------------------------------------------
--------------- GetBeehivesData ---------------
-----------------------------------------------

-- Debug
Citizen.CreateThread(function()
    if Config.Debug then
        Citizen.Wait(3000)
        TriggerServerEvent('mms-beekeeper:server:GetBeehivesData')
        Citizen.Wait(300)
        TriggerEvent('mms-beekeeper:client:SpawnWildBeehives')
    end
end)

RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function()
    Citizen.Wait(10000)
    TriggerServerEvent('mms-beekeeper:server:GetBeehivesData')
    TriggerEvent('mms-beekeeper:client:SpawnWildBeehives')
end)

RegisterNetEvent('mms-beekeeper:client:ReciveData')
AddEventHandler('mms-beekeeper:client:ReciveData',function(Beehives,CharIdent)
    BeehiveData = Beehives
    CharID = CharIdent
    TriggerEvent('mms-beekeeper:client:CreateBeehivesOnStart')
    Citizen.Wait(500)
    TriggerEvent('mms-beekeeper:client:StartMainThred')
end)

RegisterNetEvent('mms-beekeeper:client:ReloadData')
AddEventHandler('mms-beekeeper:client:ReloadData',function()
    ThreadRunning = false
    for _, beehive in ipairs(CreatedBeehives) do
        DeleteObject(beehive)
    end
    for _, blips in ipairs(CreatedBlips) do
        blips:Remove()
    end
    for _,BeesFX in ipairs(CreatedFXSwarms) do
        StopParticleFxLooped(BeesFX,true)
    end
    TriggerServerEvent('mms-beekeeper:server:GetBeehivesData')
end)
-----------------------------------------------
--------------- Create Beehive ----------------
-----------------------------------------------

RegisterNetEvent('mms-beekeeper:client:CreateBeehive')
AddEventHandler('mms-beekeeper:client:CreateBeehive',function()
    local BeehiveClose = false
    local BeehiveProp = Config.Props[Config.FixProp].BeehiveBox

    if Config.UseRandomHive then
        local MaxIndex = #Config.Props
        local RandomIndex = math.random(1,MaxIndex)
        BeehiveProp = Config.Props[RandomIndex].BeehiveBox
    end


    local MyCoords = GetEntityCoords(PlayerPedId())
    local MyHeading = GetEntityHeading(PlayerPedId())
    if BeehiveData ~= nil then
        for h,v in ipairs(BeehiveData) do
            local Data = json.decode(v.data)
            local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, Data.Coords.x, Data.Coords.y, Data.Coords.z, true)
            if Distance <= 5 then
                BeehiveClose = true
            end
        end
    end
    local Data = {
        Food = 0.0,
        Water = 0.0,
        Health = 100.0,
        Clean = 0.0,
        Product = 0.0,
        BeeSettings = {
            QueenItem = '',
            QueenLabel = '',
            BeeItem = '',
            BeeLabel = '',
            Product = '',
            ProductLabel = '',
            ProductHappy = 0.0,
            ProductNormal = 0.0,
        },
        Bees = 0,
        Queen = 0,
        Coords = { 
            x = MyCoords.x + 1.0,
            y = MyCoords.y + 1.0,
            z = MyCoords.z -1,
            heading = MyHeading,
        },
        Sickness = {
            CurrentlySick = false,
            Type = '',
            Medicine = '',
            MedicineLabel = '',
            Intensity = 0.0,
        },
        Model = BeehiveProp,
        Helper = {
            Name = '',
            CharIdent = 0,
        },
        Damage = 0.0,
    }
    if not BeehiveClose then
        TriggerServerEvent('mms-beekeeper:server:SaveBeehiveToDatabase',Data)
    else
        VORPcore.NotifyRightTip(Translation.to_close_to_another_hive,5000)
    end
end)

-----------------------------------------------
------------ Create Beehives OnStart ----------
-----------------------------------------------

RegisterNetEvent('mms-beekeeper:client:CreateBeehivesOnStart')
AddEventHandler('mms-beekeeper:client:CreateBeehivesOnStart',function()
    for h,v in ipairs(BeehiveData) do
        local Data = json.decode(v.data)
        local Beehive = CreateObject(Data.Model, Data.Coords.x, Data.Coords.y, Data.Coords.z,false,true,false)
        local heading = tonumber(Data.Coords.heading)
        if Data.Coords.heading == nil then
            Data.Coords.heading = 100
        end
        SetEntityHeading(Beehive,Data.Coords.heading)
        SetEntityInvincible(Beehive,true)
        FreezeEntityPosition(Beehive,true)
        SetEntityAlwaysPrerender(Beehive,false)
        CreatedBeehives[#CreatedBeehives + 1] = Beehive
        if Config.UseBeeFX then
            Citizen.InvokeNative(0xA10DB07FC234DD12, bees_cloud_group)
            local BeeFXSwarm = Citizen.InvokeNative(0xBA32867E86125D3A , bees_cloud_name, Data.Coords.x, Data.Coords.y, Data.Coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
            CreatedFXSwarms[#CreatedFXSwarms + 1] = BeeFXSwarm
        end
        if Config.UseBlips then
            if v.charident == CharID then
                local BeehiveBlip = BccUtils.Blips:SetBlip(Config.BlipName, Config.BlipSprite, Config.BlipScale, Data.Coords.x, Data.Coords.y, Data.Coords.z)
                CreatedBlips[#CreatedBlips + 1] = BeehiveBlip
            end
        end

    end
end)

-----------------------------------------------
------------------ MainThread -----------------
-----------------------------------------------

RegisterNetEvent('mms-beekeeper:client:StartMainThred')
AddEventHandler('mms-beekeeper:client:StartMainThred',function()
    ThreadRunning = true
    -- Owner Prompts
    local BeehivePromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local ManageBeehive = BeehivePromptGroup:RegisterPrompt(Translation.manage_beehive, 0x760A9C6F, 1, 1, true, 'click')--, {timedeventhash = 'SHORT_TIMED_EVENT'}) -- KEY G
    local DeleteBeehive = BeehivePromptGroup:RegisterPrompt(Translation.delete_beehive, 0x27D1C284, 1, 1, true, 'hold', {timedeventhash = 'SHORT_TIMED_EVENT'}) -- KEY R

    -- Helper Only Manage
    local BeehiveHelperPromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local ManageHelperBeehive = BeehiveHelperPromptGroup:RegisterPrompt(Translation.manage_beehive, 0x760A9C6F, 1, 1, true, 'click')--, {timedeventhash = 'SHORT_TIMED_EVENT'}) -- KEY G

    if BeehiveData ~= nil then
        while ThreadRunning do
            Citizen.Wait(5)
            local MyCoords = GetEntityCoords(PlayerPedId())
            for h,v in ipairs(BeehiveData) do
                local Data = json.decode(v.data)
                if v.charident == CharID then
                    local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, Data.Coords.x, Data.Coords.y, Data.Coords.z, true)
                    if Distance <= 2 then
                        BeehivePromptGroup:ShowGroup(Translation.beehive_prompt_group)

                        if ManageBeehive:HasCompleted() then
                            TriggerServerEvent('mms-beekeeper:server:GetDataForMenu',v.id)
                        end

                        if DeleteBeehive:HasCompleted() then
                            TriggerServerEvent('mms-beekeeper:server:DeleteBeehive',v.id)
                            Citizen.Wait(500)
                        end

                    end
                end
                if Data.Helper.CharIdent == CharID then
                    local Distance2 = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, Data.Coords.x, Data.Coords.y, Data.Coords.z, true)
                    if Distance2 <= 2 then
                        BeehiveHelperPromptGroup:ShowGroup(Translation.beehive_prompt_group)

                        if ManageHelperBeehive:HasCompleted() then
                            TriggerServerEvent('mms-beekeeper:server:GetDataForMenu',v.id)
                        end

                    end
                end
            end
        end
    else
        TriggerEvent('mms-beekeeper:client:ReloadData')
        if Config.Debug then print('DEBUG: Reloading Data') end
    end
end)

-----------------------------------------------
-------- Get Damage From Own Hives ------------
-----------------------------------------------

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(10000)
        while ThreadRunning and BeehiveData ~= nil and Config.useBeekeeperHats do
            local MyCoords = GetEntityCoords(PlayerPedId())
            Citizen.Wait(5000)
            for h,v in ipairs(BeehiveData) do
                local Data = json.decode(v.data)
                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, Data.Coords.x, Data.Coords.y, Data.Coords.z, true)
                if Distance <= 5 then
                    if not wearingHat then
                        local Chance = math.random(1,100)
                        if Chance <= Config.ChanceToGetStung then
                            local MyPed = PlayerPedId()
                            ChangeEntityHealth(MyPed,Config.StungDamage)
                            VORPcore.NotifyRightTip(Translation.you_got_stung_by_bees, 5000)
                        end
                    end
                end
            end
        end
    end
end)

RegisterNuiCallback('addQueen',function(data,cb)
    local hiveID = data.hiveID
    local status = VORPcore.Callback.TriggerAwait('AddQueen',hiveID)
    if status.success then
        CrouchAnim()
        Progressbar(Config.QueenTime*1000,Translation.adding_queen)
        cb(status)
    else
        cb(status)
    end
end)

RegisterNuiCallback('addBees',function(data,cb)
    local hiveID = data.hiveID
    local status = VORPcore.Callback.TriggerAwait('addBees',hiveID)
    if status.success then
        CrouchAnim()
        Progressbar(Config.BeeTime*1000,Translation.adding_bee)
        cb(status)
    else
        cb(status)
    end
end)

RegisterNuiCallback('takeHoney',function(data,cb)
    local hiveID = data.hiveID
    local honeyAmount = data.amount
    local status = VORPcore.Callback.TriggerAwait('takeHoney',hiveID,honeyAmount)
    if status.success then
        CrouchAnim()
        Progressbar(Config.TakeHoneyTime*1000*honeyAmount,Translation.taking_honey)
        cb(status)
    else
        cb(status)
    end
end)

RegisterNuiCallback('addHealth',function(data,cb)
    local hiveID = data.hiveID
    local status = VORPcore.Callback.TriggerAwait('addHealth',hiveID)
    if status.success then
        CrouchAnim()
        Progressbar(Config.HealTime*1000,Translation.healing_hive)
        cb(status)
    else
        cb(status)
    end
end)

RegisterNuiCallback('addWater',function(data,cb)
    local hiveID = data.hiveID
    local status = VORPcore.Callback.TriggerAwait('addWater',hiveID)
    if status.success then
        CrouchAnim()
        Progressbar(Config.WaterTime*1000,Translation.adding_water)
        cb(status)
    else
        cb(status)
    end
end)

RegisterNuiCallback('addFood',function(data,cb)
    local hiveID = data.hiveID
    local status = VORPcore.Callback.TriggerAwait('addFood',hiveID)
    if status.success then
        CrouchAnim()
        Progressbar(Config.FeedTime*1000,Translation.adding_food)
        cb(status)
    else
        cb(status)
    end
end)

RegisterNuiCallback('addClean',function(data,cb)
    local hiveID = data.hiveID
    local status = VORPcore.Callback.TriggerAwait('addClean',hiveID)
    if status.success then
        CrouchAnim()
        Progressbar(Config.CleanTime*1000,Translation.adding_clean)
        cb(status)
    else
        cb(status)
    end
end)

RegisterNuiCallback('cureIllness',function(data,cb)
    local hiveID = data.hiveID
    local status = VORPcore.Callback.TriggerAwait('cureIllness',hiveID)
    if status.success then
        CrouchAnim()
        Progressbar(Config.HealTime*1000,Translation.curing_illness)
        cb(status)
    else
        cb(status)
    end
end)

RegisterNuiCallback('getCloseHelpers',function(data,cb)
    local hiveID = data.hiveID
    local status = VORPcore.Callback.TriggerAwait('getCloseHelpers',hiveID)
    if status.success then
        cb(status)
    else
        cb(status)
    end
end)

RegisterNuiCallback('hireHelper',function(data,cb)
    local hiveID = data.hiveID
    local helperSrc = data.helperSrc
    local helperCharident = data.helperCharident
    local helperName = data.helperName
    local status = VORPcore.Callback.TriggerAwait('hireHelper',hiveID,helperSrc,helperCharident,helperName)
    cb(status)
end)

RegisterNuiCallback('fireHelper',function(data,cb)
    local hiveID = data.hiveID
    local status = VORPcore.Callback.TriggerAwait('fireHelper',hiveID)
    cb(status)
end)

RegisterNuiCallback('changePosition',function(data,cb)
    local hiveID = data.hiveID
    local coordsX = data.coordsX
    local coordsY = data.coordsY
    local coordsZ = data.coordsZ
    local coordsH = data.coordsH
    local status = VORPcore.Callback.TriggerAwait('changePosition',hiveID,coordsX,coordsY,coordsZ,coordsH)
    cb(status)
end)

-----------------------------------------------
-------- Get Damage From Wild Hives -----------
-----------------------------------------------

Citizen.CreateThread(function ()
    Citizen.Wait(10000)
    while WildHivesSpawned and Config.GetDmgFromWildBees do
        Citizen.Wait(5000)
        for h,v in ipairs(Config.WildBeehives) do
            MyCoords = GetEntityCoords(PlayerPedId())
            local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
            if Distance <= 10 then
                local IsSmoked = false
                if SmokedBeehives[1] ~= nil then
                    for h,v in ipairs(SmokedBeehives) do
                        local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                        if Distance < 10 then
                            IsSmoked = true
                        end
                    end
                end
                if Config.useBeekeeperHats then
                    if not wearingHat then
                        local Chance = math.random(1,100)
                        if Chance <= Config.ChanceToGetStung then
                            local MyPed = PlayerPedId()
                            ChangeEntityHealth(MyPed,Config.StungDamage)
                            VORPcore.NotifyRightTip(Translation.you_got_stung_by_bees, 5000)
                        end
                    end
                else
                    if not IsSmoked then
                        local Chance = math.random(1,100)
                        if Chance <= Config.ChanceToGetStung then
                            local MyPed = PlayerPedId()
                            ChangeEntityHealth(MyPed,Config.StungDamage)
                            VORPcore.NotifyRightTip(Translation.you_got_stung_by_bees, 5000)
                        end
                    end
                end
            end
        end
    end
end)

-----------------------------------------------
----------- Create Wild Beehives --------------
-----------------------------------------------

RegisterNetEvent('mms-beekeeper:client:SpawnWildBeehives')
AddEventHandler('mms-beekeeper:client:SpawnWildBeehives',function()
    Citizen.Wait(5000)
    if Config.WildBeehiveSpawn then

        local WildBeehivePromptGroup = BccUtils.Prompts:SetupPromptGroup()
        local SmokeBeehive = WildBeehivePromptGroup:RegisterPrompt(Translation.smoke_wild_hive, 0x760A9C6F, 1, 1, true, 'click')--, {timedeventhash = 'SHORT_TIMED_EVENT'}) -- KEY G
        local TakeBees = WildBeehivePromptGroup:RegisterPrompt(Translation.take_wild_bee, 0x27D1C284, 1, 1, true, 'click')--, {timedeventhash = 'SHORT_TIMED_EVENT'}) -- KEY R
        local TakeQueen = WildBeehivePromptGroup:RegisterPrompt(Translation.take_wild_queen, 0x5181713D, 1, 1, true, 'click')--, {timedeventhash = 'SHORT_TIMED_EVENT'}) -- KEY Spacebar
        local TakeHoney = WildBeehivePromptGroup:RegisterPrompt(Translation.take_wild_honey, 0x2CD5343E, 1, 1, true, 'click')--, {timedeventhash = 'SHORT_TIMED_EVENT'}) -- KEY Enter

        -- CreateBeehives 
        for h,v in ipairs(Config.WildBeehives) do
            local WildBeehive = CreateObject(Config.WildBeehiveModel, v.x, v.y, v.z,true,true,false)
            SetEntityInvincible(WildBeehive,true)
            FreezeEntityPosition(WildBeehive,true)
            SetEntityAlwaysPrerender(WildBeehive,false)
            Citizen.InvokeNative(0x203BEFFDBE12E96A, WildBeehive, v.x, v.y, v.z, v.heading, v.rotx, v.roty, v.rotz)
            CreatedWildBeehives[#CreatedWildBeehives + 1] = WildBeehive
            if Config.UseBeeFX then
                Citizen.InvokeNative(0xA10DB07FC234DD12, bees_cloud_group)
                local BeeFXSwarm = Citizen.InvokeNative(0xBA32867E86125D3A , bees_cloud_name, v.x, v.y, v.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
                CreatedFXSwarms[#CreatedFXSwarms + 1] = BeeFXSwarm
            end
        end
        WildHivesSpawned = true
        -- Prompt for Wild Beehives
        while true do
            Citizen.Wait(5)
            for h,v in ipairs(Config.WildBeehives) do
                MyCoords = GetEntityCoords(PlayerPedId())
                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                local CurrentHive = v
                if Distance <= 2 then
                    WildBeehivePromptGroup:ShowGroup(Translation.wild_hive_promp_group)

                    if SmokeBeehive:HasCompleted() then
                        local IsSmoked = false
                        local TakenHoney = false
                        local TakenQueen = false
                        local TakenBees = false
                        if TakenQueenBeehives[1] ~= nil then
                            for h,v in ipairs(TakenQueenBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    TakenQueen = true
                                end
                            end
                        end
                        if TakenBeeBeehives[1] ~= nil then
                            for h,v in ipairs(TakenBeeBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    TakenBees = true
                                end
                            end
                        end
                        if TakenHoneyBeehives[1] ~= nil then
                            for h,v in ipairs(TakenHoneyBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    TakenHoney = true
                                end
                            end
                        end
                        if SmokedBeehives[1] ~= nil then
                            for h,v in ipairs(SmokedBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    IsSmoked = true
                                end
                            end
                        end

                        if not IsSmoked then
                            local MyPed = PlayerPedId()
                            local prop_name = "p_bugkiller01x"
                            local PlayAnimStatus = true
                             -- Create the prop
                            local SmokerItem = CreateObject(GetHashKey(prop_name), MyCoords.x, MyCoords.y, MyCoords.z, true, true, true)
                            SetEntityAsMissionEntity(SmokerItem, true, true)
                            AttachEntityToEntity(SmokerItem, MyPed, GetEntityBoneIndexByName(MyPed, "SKEL_R_FINGER00"), 
                            0.2, -0.2, -0.0, -40.0, 50.0, 30.0, true, true, false, true, 1, true)

                            -- Request and play animation
                            RequestAnimDict("script_rc@gun5@ig@stage_01@ig3_bellposes")
                            while not HasAnimDictLoaded("script_rc@gun5@ig@stage_01@ig3_bellposes") do
                                Citizen.Wait(100)
                            end

                            TaskPlayAnim(MyPed, "script_rc@gun5@ig@stage_01@ig3_bellposes", "pose_01_idle_famousgunslinger_05", 
                                        1.0, 8.0, -1, 1, 0, false, false, false)
                            Citizen.Wait(Config.SmokeHiveTime*1000)
                            ClearPedTasks(MyPed)
                                while PlayAnimStatus do
                                        Citizen.Wait(100)
                                        if not IsEntityPlayingAnim(MyPed, "script_rc@gun5@ig@stage_01@ig3_bellposes", "pose_01_idle_famousgunslinger_05", 3) then
                                        DeleteEntity(SmokerItem) -- Clean up the prop
                                        PlayAnimStatus = false
                                    end
                                end
                            TriggerServerEvent('mms-beekeeper:server:SmokeBeehive', CurrentHive,SmokedBeehives)
                        else
                            VORPcore.NotifyRightTip(Translation.wild_hive_already_smoked, 5000)
                        end
                    end

                    if TakeBees:HasCompleted() then
                        local IsSmoked = false
                        local TakenHoney = false
                        local TakenQueen = false
                        local TakenBees = false
                        if TakenQueenBeehives[1] ~= nil then
                            for h,v in ipairs(TakenQueenBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    TakenQueen = true
                                end
                            end
                        end
                        if TakenBeeBeehives[1] ~= nil then
                            for h,v in ipairs(TakenBeeBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    TakenBees = true
                                end
                            end
                        end
                        if TakenHoneyBeehives[1] ~= nil then
                            for h,v in ipairs(TakenHoneyBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    TakenHoney = true
                                end
                            end
                        end
                        if SmokedBeehives[1] ~= nil then
                            for h,v in ipairs(SmokedBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    IsSmoked = true
                                end
                            end
                        end
                        
                        if IsSmoked and not TakenBees then
                            local PlayAnimStatus = true
                                local prop_name = "mp005_s_posse_col_net01x"
                                local MyPed = PlayerPedId()
                                -- Create the prop
                                local BugNet = CreateObject(GetHashKey(prop_name), MyCoords.x, MyCoords.y, MyCoords.z, true, true, true)
                                SetEntityAsMissionEntity(BugNet, true, true)
                                AttachEntityToEntity(BugNet, MyPed, GetEntityBoneIndexByName(MyPed, "PH_L_Hand"),0.0, 0.0, -0.45, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

                                -- Request and play animation
                                RequestAnimDict("mini_games@fishing@shore")
                                while not HasAnimDictLoaded("mini_games@fishing@shore") do
                                    Citizen.Wait(100)
                                end
                                TaskPlayAnim(MyPed, "mini_games@fishing@shore", "cast",1.0, 8.0, -1, 31, 0, false, false, false)
                                -- Wait the Catch Time
                                Citizen.Wait(Config.GetBeeTime*1000)
                                ClearPedTasks(MyPed)
                                -- Cleanup BugNet when animation stops
                                    while PlayAnimStatus do
                                        Citizen.Wait(100)
                                        if not IsEntityPlayingAnim(MyPed, "mini_games@fishing@shore", "cast", 3) then
                                            DeleteEntity(BugNet) -- Clean up the prop
                                            PlayAnimStatus = false
                                        end
                                    end
                                TriggerServerEvent('mms-beekeeper:server:TakeBeesFromWildHive', CurrentHive)
                            elseif IsSmoked and TakenBees then
                                VORPcore.NotifyRightTip(Translation.no_more_bees, 5000)
                            elseif not IsSmoked then
                                VORPcore.NotifyRightTip(Translation.wild_hive_not_smoked, 5000)
                            end
                    end

                    if TakeQueen:HasCompleted() then
                        local IsSmoked = false
                        local TakenHoney = false
                        local TakenQueen = false
                        local TakenBees = false
                        if TakenQueenBeehives[1] ~= nil then
                            for h,v in ipairs(TakenQueenBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    TakenQueen = true
                                end
                            end
                        end
                        if TakenBeeBeehives[1] ~= nil then
                            for h,v in ipairs(TakenBeeBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    TakenBees = true
                                end
                            end
                        end
                        if TakenHoneyBeehives[1] ~= nil then
                            for h,v in ipairs(TakenHoneyBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    TakenHoney = true
                                end
                            end
                        end
                        if SmokedBeehives[1] ~= nil then
                            for h,v in ipairs(SmokedBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    IsSmoked = true
                                end
                            end
                        end

                        if IsSmoked and TakenBees and not TakenQueen then
                            local PlayAnimStatus = true
                            local prop_name = "mp005_s_posse_col_net01x"
                            local MyPed = PlayerPedId()
                            -- Create the prop
                            local BugNet = CreateObject(GetHashKey(prop_name), MyCoords.x, MyCoords.y, MyCoords.z, true, true, true)
                            SetEntityAsMissionEntity(BugNet, true, true)
                            AttachEntityToEntity(BugNet, MyPed, GetEntityBoneIndexByName(MyPed, "PH_L_Hand"),0.0, 0.0, -0.45, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

                            -- Request and play animation
                            RequestAnimDict("mini_games@fishing@shore")
                            while not HasAnimDictLoaded("mini_games@fishing@shore") do
                                Citizen.Wait(100)
                            end
                            TaskPlayAnim(MyPed, "mini_games@fishing@shore", "cast",1.0, 8.0, -1, 31, 0, false, false, false)
                            -- Wait the Catch Time
                            Citizen.Wait(Config.GetQueenTime*1000)
                            ClearPedTasks(MyPed)
                            -- Cleanup BugNet when animation stops
                                while PlayAnimStatus do
                                    Citizen.Wait(100)
                                    if not IsEntityPlayingAnim(MyPed, "mini_games@fishing@shore", "cast", 3) then
                                        DeleteEntity(BugNet) -- Clean up the prop
                                        PlayAnimStatus = false
                                    end
                                end
                            TriggerServerEvent('mms-beekeeper:server:TakeQueenFromWildHive', CurrentHive)                
                        elseif IsSmoked and not TakenBees then
                            VORPcore.NotifyRightTip(Translation.still_bees_in_hive, 5000)
                        elseif IsSmoked and TakenBees and TakenQueen then
                            VORPcore.NotifyRightTip(Translation.queen_already_taken, 5000)
                        elseif not IsSmoked then
                            VORPcore.NotifyRightTip(Translation.wild_hive_not_smoked, 5000)
                        end
                    end

                    if TakeHoney:HasCompleted() then
                        local IsSmoked = false
                        local TakenHoney = false
                        local TakenQueen = false
                        local TakenBees = false
                        if TakenQueenBeehives[1] ~= nil then
                            for h,v in ipairs(TakenQueenBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    TakenQueen = true
                                end
                            end
                        end
                        if TakenBeeBeehives[1] ~= nil then
                            for h,v in ipairs(TakenBeeBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    TakenBees = true
                                end
                            end
                        end
                        if TakenHoneyBeehives[1] ~= nil then
                            for h,v in ipairs(TakenHoneyBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    TakenHoney = true
                                end
                            end
                        end
                        if SmokedBeehives[1] ~= nil then
                            for h,v in ipairs(SmokedBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    IsSmoked = true
                                end
                            end
                        end

                        if not Config.OnlySmokeToTakeProduct and TakenBees and TakenQueen and not TakenHoney then
                            TriggerServerEvent('mms-beekeeper:server:TakeHoneyFromWildHive', CurrentHive)
                        elseif Config.OnlySmokeToTakeProduct and IsSmoked and not TakenHoney then
                            TriggerServerEvent('mms-beekeeper:server:TakeHoneyFromWildHive', CurrentHive)
                        elseif TakenBees and TakenQueen and TakenHoney then
                            VORPcore.NotifyRightTip(Translation.no_more_honey_in_hive, 5000)
                        elseif Config.OnlySmokeToTakeProduct and not TakenHoney and not IsSmoked then
                            VORPcore.NotifyRightTip(Translation.wild_hive_not_smoked, 5000)
                        elseif Config.OnlySmokeToTakeProduct and TakenHoney then
                            VORPcore.NotifyRightTip(Translation.no_more_honey_in_hive, 5000)
                        elseif not Config.OnlySmokeToTakeProduct and not TakenBees then
                            VORPcore.NotifyRightTip(Translation.still_insects_in_hive, 5000)
                        end
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('mms-beekeeper:client:BeehiveSmoked',function(CurrentHive)
    table.insert(SmokedBeehives,CurrentHive)
end)

RegisterNetEvent('mms-beekeeper:client:BeesTakenFromHive',function(CurrentHive)
    table.insert(TakenBeeBeehives,CurrentHive)
end)

RegisterNetEvent('mms-beekeeper:client:QueenTakenFromHive',function(CurrentHive)
    table.insert(TakenQueenBeehives,CurrentHive)
end)

RegisterNetEvent('mms-beekeeper:client:HoneyTakenFromHive',function(CurrentHive)
    table.insert(TakenHoneyBeehives,CurrentHive)
end)

-----------------------------------------------
------------ Reset Wild Beehives --------------
-----------------------------------------------

Citizen.CreateThread(function ()
    if Config.ResetWildHives then
        while true do
            Citizen.Wait(10000)
            if SmokedBeehives[1] ~= nil and not CountdownStartet then
                CountdownStartet = true
                if Config.Debug then print('WildHivesResetTimerStartet') end
                local Counter = Config.ResetWildHivesTimer * 6000
                while Counter > 0 do
                    Citizen.Wait(30000)
                    Counter = Counter - 30000
                    if Counter <= 0 then
                        CountdownStartet = false
                        TakenHoneyBeehives = {}
                        TakenQueenBeehives = {}
                        TakenBeeBeehives = {}
                        SmokedBeehives = {}
                        if Config.Debug then print('WildHivesCleared') end
                    end
                end
            end
        end
    end
end)

---------------------------------------------
----------------- Wear HAT ------------------
---------------------------------------------

if Config.useBeekeeperHats then

    local function getOldHat()
        local myPed = PlayerPedId()
        -- _GET_META_PED_TYPE
        local metaPedTyp = Citizen.InvokeNative(0xEC9A1261BF0CE510, myPed,Citizen.ResultAsInteger())
        -- _GET_SHOP_ITEM_HAT_COMPONENT
        local hutHash = Citizen.InvokeNative(0x7E02E4218D916B94,myPed,metaPedTyp,true,Citizen.ResultAsInteger())

        return hutHash
    end

    local function wearHood()
        wearingHat = true
        local getHat = exports.vorp_character:GetPlayerComponent("Hat") --getOldHat()
        oldHat = getHat.comp
        local myPed = PlayerPedId()
        if IsPedMale(myPed) then
            newBeekeeperHat = Config.hoodsMale[1].hash
            TriggerEvent('hawk_beekeeper_hood:useitems',newBeekeeperHat)
        else
            newBeekeeperHat = Config.hoodsFemale[1].hash
            TriggerEvent('hawk_beekeeper_hood:useitems',newBeekeeperHat)
        end
    end

    local function wearOldHat()
        wearingHat = false
        local ped = PlayerPedId()
        if oldHat == 0 or oldHat == nil then
            -- REMOVE_SHOP_ITEM_FROM_PED_BY_CATEGORY
            Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x9925C067, 0, true)
            -- _UPDATE_PED_VARIATION
            Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
            return
        end

        if oldHat ~= 0 then
            TriggerEvent('hawk_beekeeper_hood:useitems',oldHat)
            oldHat = nil
        end
    end

    RegisterNetEvent('toggleBeekeeperHood',function()
        if not wearingHat then
            wearHood()
        else
            wearOldHat()
        end
    end)

end

----------------- Utilities -----------------


------ Progressbar

function Progressbar(Time,Text)
    progressbar.start(Text, Time, function ()
    end, 'linear')
    Wait(Time)
    ClearPedTasks(PlayerPedId())
end

------ Animation

function CrouchAnim()
    local dict = "script_rc@cldn@ig@rsc2_ig1_questionshopkeeper"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    TaskPlayAnim(ped, dict, "inspectfloor_MyPed", 0.5, 8.0, -1, 1, 0, false, false, false)
end

---- CleanUp on Resource Restart 

RegisterNetEvent('onResourceStop',function(resource)
    if resource == GetCurrentResourceName() then
        for _, beehive in ipairs(CreatedBeehives) do
            DeleteObject(beehive)
        end
        for _, blips in ipairs(CreatedBlips) do
            blips:Remove()
        end
        for _, wildbeehives in ipairs(CreatedWildBeehives) do
            DeleteObject(wildbeehives)
        end
        for _,BeesFX in ipairs(CreatedFXSwarms) do
            StopParticleFxLooped(BeesFX,true)
        end
    end
end)