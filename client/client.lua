local VORPcore = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()
local Menu = exports.vorp_menu:GetMenuData()
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

-----------------------------------------------
--------------- GetBeehivesData ---------------
-----------------------------------------------

-- Debug

if Config.Debug then
    Citizen.Wait(3000)
    TriggerServerEvent('mms-beekeeper:server:GetBeehivesData')
end

RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function()
    Citizen.Wait(10000)
    TriggerServerEvent('mms-beekeeper:server:GetBeehivesData')
end)

RegisterNetEvent('mms-beekeeper:client:ReciveData')
AddEventHandler('mms-beekeeper:client:ReciveData',function(Beehives,CharIdent)
    BeehiveData = Beehives
    CharID = CharIdent
    TriggerEvent('mms-beekeeper:client:CreateBeehivesOnStart')
    Citizen.Wait(1000)
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
    Citizen.Wait(500)
    BeehiveData = nil
    TriggerServerEvent('mms-beekeeper:server:GetBeehivesData')
end)
-----------------------------------------------
--------------- Create Beehive ----------------
-----------------------------------------------

RegisterNetEvent('mms-beekeeper:client:CreateBeehive')
AddEventHandler('mms-beekeeper:client:CreateBeehive',function()
    local BeehiveClose = false
    local MyCoords = GetEntityCoords(PlayerPedId())
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
            x = MyCoords.x + 1,0,
            y = MyCoords.y + 1.0,
            z = MyCoords.z -1,
        },
        Sickness = {
            CurrentlySick = false,
            Type = '',
            Medicine = '',
            MedicineLabel = '',
            Intensity = 0.0,
        },
        Model = Config.BeehiveBox,
    }
    if not BeehiveClose then
        TriggerServerEvent('mms-beekeeper:server:SaveBeehiveToDatabase',Data)
        TriggerEvent('mms-beekeeper:client:ReloadData')
    else
        VORPcore.NotifyRightTip(_U('ToCloseToAnotherHive'),5000)
    end
end)

-----------------------------------------------
------------ Create Beehives OnStart ----------
-----------------------------------------------

RegisterNetEvent('mms-beekeeper:client:CreateBeehivesOnStart')
AddEventHandler('mms-beekeeper:client:CreateBeehivesOnStart',function()
    for h,v in ipairs(BeehiveData) do
        local Data = json.decode(v.data)
        local Beehive = CreateObject(Config.BeehiveBox, Data.Coords.x, Data.Coords.y, Data.Coords.z,true,true,false)
        SetEntityInvincible(Beehive,true)
        FreezeEntityPosition(Beehive,true)
        CreatedBeehives[#CreatedBeehives + 1] = Beehive

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
    local BeehivePromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local ManageBeehive = BeehivePromptGroup:RegisterPrompt(_U('ManageBeehive'), 0x760A9C6F, 1, 1, true, 'click')--, {timedeventhash = 'SHORT_TIMED_EVENT'}) -- KEY G
    local DeleteBeehive = BeehivePromptGroup:RegisterPrompt(_U('DeleteBeehive'), 0x27D1C284, 1, 1, true, 'hold', {timedeventhash = 'SHORT_TIMED_EVENT'}) -- KEY R
    if BeehiveData ~= nil then
        while ThreadRunning do
            Citizen.Wait(3)
            local MyCoords = GetEntityCoords(PlayerPedId())
            for h,v in ipairs(BeehiveData) do
                if v.charident == CharID then
                    local Data = json.decode(v.data)
                    local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, Data.Coords.x, Data.Coords.y, Data.Coords.z, true)
                    if Distance <= 2 then
                        BeehivePromptGroup:ShowGroup(_U('BeehivePromptGroup'))

                        if ManageBeehive:HasCompleted() then
                            TriggerServerEvent('mms-beekeeper:server:GetDataForMenu',v.id)
                        end

                        if DeleteBeehive:HasCompleted() then
                            TriggerServerEvent('mms-beekeeper:server:DeleteBeehive',v.id)
                            Citizen.Wait(500)
                            TriggerEvent('mms-beekeeper:client:ReloadData')
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
------------------- Menu Data -----------------
-----------------------------------------------

RegisterNetEvent('mms-beekeeper:client:OpenMenu')
AddEventHandler('mms-beekeeper:client:OpenMenu',function(CurrentBeehive)
    Data = json.decode(CurrentBeehive[1].data)
    BeehiveMenu = {
        {
            label = _U('QueenLabel') .. Data.BeeSettings.QueenLabel .. ' ' .. Data.Queen,
            value = "AddQueen",
            desc = _U('QueenLabelDesc'),
            itemHeight = "3vh"
        },
        {
            label = _U('BeeLabel') .. Data.BeeSettings.BeeLabel .. ' ' .. Data.Bees,
            value = "AddBees",
            desc = _U('BeeLabelDesc'),
            itemHeight = "3vh"
        },
        {
            label = _U('ProductLabel') .. Data.BeeSettings.ProductLabel .. ' ' .. math.floor(Data.Product / Config.ProduktPerHoney),
            value = "TakeProduct",
            desc = Data.BeeSettings.ProductLabel .. _U('ProductLabelDesc'),
            itemHeight = "3vh"
        },
        {
            label = _U('FoodLabel') .. Data.Food,
            value = "AddFood",
            desc = _U('FoodLabelDesc'),
            itemHeight = "3vh"
        },
        {
            label = _U('WaterLabel') .. Data.Water,
            value = "AddWater",
            desc = _U('WaterLabelDesc'),
            itemHeight = "3vh"
        },
        {
            label = _U('CleanLabel') .. Data.Clean,
            value = "AddClean",
            desc = _U('CleanLabelDesc'),
            itemHeight = "3vh"
        },
        {
            label = _U('HealthLabel') .. Data.Health,
            value = "AddHealth",
            desc = _U('HealthLabelDesc'),
            itemHeight = "3vh"
        },
        {
            label = _U('SicknessLabel') .. Data.Sickness.Type .. ' ' .. Data.Sickness.Intensity,
            value = "HealSickness",
            desc = _U('SicknessLabelDesc') .. Data.Sickness.MedicineLabel,
            itemHeight = "3vh"
        },
    }

    Menu.Open("default",GetCurrentResourceName(),"BeehiveMenu", -- unique namespace will allow the menu to open where you left off

    {
        title = _U('HiveMenuHeader'),
        subtext = _U('HiveMenuSubHeader'),
        align = "top-center", -- top-right , top-center , top-left
        elements = BeehiveMenu, -- elements needed
        itemHeight = "4vh", -- set all elements to this height if they are not definded in the element (optional)
    },
        
        
    function(data, Menu)

        if data.current.value == "AddFood" then
            CrouchAnim()
            Progressbar(Config.FeedTime*1000,_U('FeedingHive'))
            TriggerServerEvent('mms-beekeeper:server:AddFood',CurrentBeehive[1].id)
            Menu.close()
        end

        if data.current.value == "TakeProduct" then
            CrouchAnim()
            Progressbar(Config.TakeHoneyTime*1000,_U('TakingHoney'))
            TriggerServerEvent('mms-beekeeper:server:TakeProduct',CurrentBeehive[1].id)
            Menu.close()
        end
        
        if data.current.value == "AddWater" then
            CrouchAnim()
            Progressbar(Config.WaterTime*1000,_U('WaterHive'))
            TriggerServerEvent('mms-beekeeper:server:AddWater',CurrentBeehive[1].id)
            Menu.close()
        end

        if data.current.value == "AddClean" then
            CrouchAnim()
            Progressbar(Config.CleanTime*1000,_U('CleaningHive'))
            TriggerServerEvent('mms-beekeeper:server:AddClean',CurrentBeehive[1].id)
            Menu.close()
        end

        if data.current.value == "AddHealth" then
            CrouchAnim()
            Progressbar(Config.HealTime*1000,_U('HealingHive'))
            TriggerServerEvent('mms-beekeeper:server:AddHealth',CurrentBeehive[1].id)
            Menu.close()
        end

        if data.current.value == "AddQueen" then
            if Data.Queen > 0 then
                VORPcore.NotifyRightTip(_U('AlreadyHasAQueen'),5000)
            else
                CrouchAnim()
                Progressbar(Config.QueenTime*1000,_U('AddingQueen'))
                TriggerServerEvent('mms-beekeeper:server:AddQueen',CurrentBeehive[1].id)
                Menu.close()
            end
        end

        if data.current.value == "AddBees" then
            if Data.Queen < 1 then
                VORPcore.NotifyRightTip(_U('InsertQueenFirst'),5000)
            else
                CrouchAnim()
                Progressbar(Config.BeeTime*1000,_U('AddingBee'))
                TriggerServerEvent('mms-beekeeper:server:AddBees',CurrentBeehive[1].id,Data.BeeSettings.QueenItem)
                Menu.close()
            end
        end
        
        if data.current.value == "HealSickness" then
            if Data.Sickness.Intensity > 0 then
                CrouchAnim()
                Progressbar(Config.SickTime*1000,_U('CuringSickness'))
                TriggerServerEvent('mms-beekeeper:server:HealSickness',CurrentBeehive[1].id)
                Menu.close()
            else
                VORPcore.NotifyRightTip(_U('BeesNotSick'),5000)
            end
        end

        end,

        function(data,Menu)
            Menu.close()
        end)

end)

-----------------------------------------------
----------- Create Wild Beehives --------------
-----------------------------------------------

Citizen.CreateThread(function ()
    if Config.WildBeehiveSpawn then

        local WildBeehivePromptGroup = BccUtils.Prompts:SetupPromptGroup()
        local SmokeBeehive = WildBeehivePromptGroup:RegisterPrompt(_U('SmokeBeehive'), 0x760A9C6F, 1, 1, true, 'click')--, {timedeventhash = 'SHORT_TIMED_EVENT'}) -- KEY G
        local TakeBees = WildBeehivePromptGroup:RegisterPrompt(_U('TakeBees'), 0x27D1C284, 1, 1, true, 'click')--, {timedeventhash = 'SHORT_TIMED_EVENT'}) -- KEY R
        local TakeQueen = WildBeehivePromptGroup:RegisterPrompt(_U('TakeQueen'), 0x5181713D, 1, 1, true, 'click')--, {timedeventhash = 'SHORT_TIMED_EVENT'}) -- KEY Spacebar

        -- CreateBeehives 
        for h,v in ipairs(Config.WildBeehives) do
            local WildBeehive = CreateObject(Config.WildBeehiveModel, v.x, v.y, v.z,true,true,false)
            SetEntityInvincible(WildBeehive,true)
            FreezeEntityPosition(WildBeehive,true)
            Citizen.InvokeNative(0x203BEFFDBE12E96A, WildBeehive, v.x, v.y, v.z, v.heading, v.rotx, v.roty, v.rotz)
            CreatedWildBeehives[#CreatedWildBeehives + 1] = WildBeehive
        end

        -- Prompt for Wild Beehives
        while true do
            Citizen.Wait(5)
            for h,v in ipairs(Config.WildBeehives) do
                MyCoords = GetEntityCoords(PlayerPedId())
                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)

                if Distance <= 2 then
                    WildBeehivePromptGroup:ShowGroup(_U('WildBeehivePromptGroup'))

                    if SmokeBeehive:HasCompleted() then
                        local CurrentHive = v
                        TriggerServerEvent('mms-beekeeper:server:SmokeBeehive', CurrentHive,SmokedBeehives)
                    end

                    if TakeBees:HasCompleted() then
                        local TakenBees = false
                        if TakenBeeBeehives[1] ~= nil then
                            for h,v in ipairs(TakenBeeBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    TakenBees = true
                                end
                            end
                        end
                        if SmokedBeehives[1] == nil then
                            VORPcore.NotifyRightTip(_U('BeehiveNotSmoked'), 5000)
                        end
                        for h,v in ipairs(SmokedBeehives) do
                            local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                            if Distance < 2 and not TakenBees then
                                TriggerServerEvent('mms-beekeeper:server:TakeBeesFromWildHive', CurrentHive)
                            else
                                VORPcore.NotifyRightTip(_U('BeehiveNotSmoked'), 5000)
                            end
                        end
                    end

                    if TakeQueen:HasCompleted() then
                        local TakenQueen = false
                        if TakenQueenBeehives[1] ~= nil then
                            for h,v in ipairs(TakenQueenBeehives) do
                                local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                                if Distance < 2 then
                                    TakenQueen = true
                                end
                            end
                        end
                        if TakenBeeBeehives[1] == nil then
                            VORPcore.NotifyRightTip(_U('StillBeesInHive'), 5000)
                        end
                        for h,v in ipairs(TakenBeeBeehives) do
                            local Distance = GetDistanceBetweenCoords(MyCoords.x, MyCoords.y, MyCoords.z, v.x, v.y, v.z, true)
                            if Distance < 2 and not TakenQueen then
                                TriggerServerEvent('mms-beekeeper:server:TakeQueenFromWildHive', CurrentHive)
                            else
                                VORPcore.NotifyRightTip(_U('StillBeesInHive'), 5000)
                            end
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
    TaskPlayAnim(ped, dict, "inspectfloor_player", 0.5, 8.0, -1, 1, 0, false, false, false)
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
    end
end)