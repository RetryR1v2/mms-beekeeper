-- Server Side
local VORPcore = exports.vorp_core:GetCore()

-----------------------------------------------
----------------- Register Item ---------------
-----------------------------------------------

exports.vorp_inventory:registerUsableItem(Config.BeehiveItem, function(data)
    local src = data.source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local CharIdent = Character.charIdentifier
    local MyHives = 0
    local Job = Character.job
    if Config.JobLock then
        for h,v in ipairs(Config.BeekeeperJobs) do
            if Job == v.Job then
                local Beehives = MySQL.query.await("SELECT * FROM mms_beekeeper", { })
                if #Beehives > 0 then
                    for h,v in ipairs(Beehives) do
                        if v.charident == CharIdent then
                            MyHives = MyHives + 1
                        end
                    end
                    if MyHives < Config.MaxBeehivesPerPlayer then
                        TriggerClientEvent('mms-beekeeper:client:CreateBeehive',src)
                    else
                        VORPcore.NotifyRightTip(src,_U('MaxHivesReached'),5000)
                    end
                else
                    TriggerClientEvent('mms-beekeeper:client:CreateBeehive',src)
                end
            else
                VORPcore.NotifyRightTip(src,_U('NotTheRightJob'),5000)
            end
        end
    else
        local Beehives = MySQL.query.await("SELECT * FROM mms_beekeeper", { })
        if #Beehives > 0 then
            for h,v in ipairs(Beehives) do
                if v.charident == CharIdent then
                    MyHives = MyHives + 1
                end
            end
            if MyHives < Config.MaxBeehivesPerPlayer then
                TriggerClientEvent('mms-beekeeper:client:CreateBeehive',src)
            else
                VORPcore.NotifyRightTip(src,_U('MaxHivesReached'),5000)
            end
        else
            TriggerClientEvent('mms-beekeeper:client:CreateBeehive',src)
        end
    end
end)

-----------------------------------------------
--------------- Get Beehive Data --------------
-----------------------------------------------

RegisterServerEvent('mms-beekeeper:server:GetBeehivesData',function()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local CharIdent = Character.charIdentifier
    local Beehives = MySQL.query.await("SELECT * FROM mms_beekeeper", { })
    if #Beehives > 0 then
        TriggerClientEvent('mms-beekeeper:client:ReciveData',src,Beehives,CharIdent)
    end
end)


-----------------------------------------------
----------- Save Beehive to Database ----------
-----------------------------------------------

RegisterServerEvent('mms-beekeeper:server:SaveBeehiveToDatabase',function (Data)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local ident = Character.identifier
    local charident = Character.charIdentifier
    exports.vorp_inventory:subItem(src, Config.BeehiveItem, 1)
    MySQL.insert('INSERT INTO `mms_beekeeper` (ident,charident,data) VALUES (?, ?, ?)',
    {ident,charident,json.encode(Data)}, function()end)
    for h,v in ipairs(GetPlayers()) do
        TriggerClientEvent('mms-beekeeper:client:ReloadData',v)
    end
end)

-----------------------------------------------
-------------- Main Update Thread -------------
-----------------------------------------------

Citizen.CreateThread(function()
    local UpdateTimer = Config.UpdateTimer * 60000
    while true do
        Citizen.Wait(30000)
        UpdateTimer = UpdateTimer - 30000
        if UpdateTimer <= 0 then
            TriggerEvent('mms-beekeeper:server:DoTheUpdateProcess')
            UpdateTimer = Config.UpdateTimer * 60000
        end
    end
end)

RegisterServerEvent('mms-beekeeper:server:DoTheUpdateProcess',function()
    local Beehives = MySQL.query.await("SELECT * FROM mms_beekeeper", { })
    if #Beehives > 0 then
        
        for h,v in ipairs(Beehives) do
            local Data = json.decode(v.data)
            
            -----------------------------------------------
            ------------------ FOOD UPDATE ----------------
            -----------------------------------------------

            if Data.Food > 0 then
                local NewFood = Data.Food - Config.ReduceFoodPerTick
                if NewFood < 0 then
                    Data.Food = 0
                else
                    Data.Food = NewFood
                end
            end

            -----------------------------------------------
            ------------------ Water UPDATE ----------------
            -----------------------------------------------

            if Data.Water > 0 then
                local NewWater = Data.Water - Config.ReduceWaterPerTick
                if NewWater < 0 then
                    Data.Water = 0
                else
                    Data.Water = NewWater
                end
            end

            -----------------------------------------------
            ----------------- Clean UPDATE ----------------
            -----------------------------------------------

            if Data.Clean > 0 then
                local NewClean = Data.Clean - Config.ReduceCleanPerTick
                if NewClean < 0 then
                    Data.Clean = 0
                else
                    Data.Clean = NewClean
                end
            end

            -----------------------------------------------
            ----------------- Honey UPDATE ----------------
            -----------------------------------------------

            if Data.Bees > 0 and Data.Queen > 0 and Config.BeesCanBeHappy  then
                local Happy = false
                if Data.Food >= Config.HappyAt.Food and Data.Water >= Config.HappyAt.Water and Data.Clean >= Config.HappyAt.Clean then
                    Happy = true
                end
                if Happy then
                    local CalculateProduct = Data.Bees * Data.BeeSettings.ProductHappy
                    local NewProduct = Data.Product + CalculateProduct
                    Data.Product = NewProduct
                else
                    local CalculateProduct = Data.Bees * Data.BeeSettings.ProductNormal
                    local NewProduct = Data.Product + CalculateProduct
                    Data.Product = NewProduct
                end
            elseif Data.Bees > 0 and Data.Queen > 0 then
                local CalculateProduct = Data.Bees * Data.BeeSettings.ProductNormal
                local NewProduct = Data.Product + CalculateProduct
                Data.Product = NewProduct
            end

            -----------------------------------------------
            ----------------- Bees UPDATE ----------------
            -----------------------------------------------

            if Data.Bees > 0 and Data.Queen > 0 and Config.BeesCanBeHappy and Config.GetBeesOnHappy then
                local Happy = false
                if Data.Food >= Config.HappyAt.Food and Data.Water >= Config.HappyAt.Water and Data.Clean >= Config.HappyAt.Clean then
                    Happy = true
                end
                if Happy then
                    local AddBeeValue = math.random(Config.BeesMin,Config.BeesMax)
                    local NewBees = Data.Bees + AddBeeValue
                    if NewBees > Config.MaxBeesPerHive then
                        NewBees = Config.MaxBeesPerHive
                    end
                    Data.Bees = NewBees
                end
            end

            if Data.Bees > 0 and Data.Queen > 0 and Config.BeesCanDie then
                local BeesDie = false
                if Data.Food <= Config.DieAt.Food and Data.Water <= Config.DieAt.Water and Data.Clean <= Config.DieAt.Clean then
                    BeesDie = true
                end
                if BeesDie then
                    local RemoveBeeValue = math.random(Config.LooseBeesMin,Config.LooseBeesMax)
                    local NewBees = Data.Bees + RemoveBeeValue
                    Data.Bees = NewBees
                end
            end

            -----------------------------------------------
            -------------- Sickness UPDATE ----------------
            -----------------------------------------------
            local BeesNewSick = false
            local BeesCurrentlySick = false
            if Data.Sickness.CurrentlySick then
                BeesCurrentlySick = true
            end

            if Config.BeesCanBeSick and not BeesCurrentlySick then
                local ChanceToBeSick = math.random(1,100)
                if ChanceToBeSick <= Config.SicknessChance then
                    BeesNewSick = true
                end
            end

            if BeesNewSick then
                local MaxIndex = #Config.SickNess
                local RandomIndex = math.random(1,MaxIndex)
                local PickedSickness = Config.SickNess[RandomIndex]
                Data.Sickness.CurrentlySick = true
                Data.Sickness.Type = PickedSickness.Type
                Data.Sickness.Medicine = PickedSickness.Medicin
                Data.Sickness.Intensity = Config.IncreaseIntensityPerUpdate
                Data.Sickness.MedicineLabel = PickedSickness.MedicinLabel
            end

            if BeesCurrentlySick then
                local NewIntensity = Data.Sickness.Intensity + Config.IncreaseIntensityPerUpdate
                if NewIntensity > 100 then
                    NewIntensity = 100
                end
                Data.Sickness.Intensity = NewIntensity
            end

            if Config.BeesDieOn100 and Data.Sickness.Intensity >= 100 then
                Data.Bees = 0
                Data.Queen = 0
                Data.BeeSettings = {
                    QueenItem = '',
                    QueenLabel = '',
                    BeeItem = '',
                    BeeLabel = '',
                    Product = '',
                    ProductLabel = '',
                    ProductHappy = 0.0,
                    ProductNormal = 0.0,
                }
            end

            -----------------------------------------------
            --------------- Database UPDATE ---------------
            -----------------------------------------------
            MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),v.id})
        end

    end
end)

-----------------------------------------------
----------- Get New Data For Menu -------------
-----------------------------------------------

RegisterServerEvent('mms-beekeeper:server:GetDataForMenu',function(HiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = HiveID})
    if #CurrentBeehive > 0 then
        TriggerClientEvent('mms-beekeeper:client:OpenMenu',src,CurrentBeehive)
    end
end)

-----------------------------------------------
-------------- AddFood To Hive ----------------
-----------------------------------------------

RegisterServerEvent('mms-beekeeper:server:AddFood',function(HiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = HiveID})
    if #CurrentBeehive > 0 then
        local HasItem = exports.vorp_inventory:getItemCount(src, nil, Config.FoodItem)
        if HasItem > 0 then
            local Data = json.decode(CurrentBeehive[1].data)
            exports.vorp_inventory:subItem(src,Config.FoodItem,1)
            local NewFood = Data.Food + Config.FoodGain
            if NewFood > 100 then
                NewFood = 100
            end
            Data.Food = NewFood
            MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),HiveID})
            VORPcore.NotifyRightTip(src,_U('FoodAdded'),5000)
        else
            VORPcore.NotifyRightTip(src,_U('NoFoodItem') .. Config.FoodItemLabel,5000)
        end
    end
end)

-----------------------------------------------
-------------- AddWater To Hive ---------------
-----------------------------------------------

RegisterServerEvent('mms-beekeeper:server:AddWater',function(HiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = HiveID})
    if #CurrentBeehive > 0 then
        local HasItem = exports.vorp_inventory:getItemCount(src, nil, Config.WaterItem)
        if HasItem > 0 then
            local Data = json.decode(CurrentBeehive[1].data)
            exports.vorp_inventory:subItem(src,Config.WaterItem,1)
            local NewWater = Data.Water + Config.WaterGain
            if NewWater > 100 then
                NewWater = 100
            end
            Data.Water = NewWater
            MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),HiveID})
            VORPcore.NotifyRightTip(src,_U('WaterAdded'),5000)
            if Config.GiveBackEmpty then
                CanCarry = exports.vorp_inventory:canCarryItem(src, Config.GiveBackEmptyItem, 1)
                if CanCarry then
                    exports.vorp_inventory:addItem(src,Config.GiveBackEmptyItem,1)
                else
                    VORPcore.NotifyRightTip(src,_U('CantGetEmptyItem') .. Config.WaterItemLabel,5000)
                end
            end
        else
            VORPcore.NotifyRightTip(src,_U('NoWaterItem') .. Config.WaterItemLabel,5000)
        end
    end
end)

-----------------------------------------------
-------------- AddClean To Hive ---------------
-----------------------------------------------

RegisterServerEvent('mms-beekeeper:server:AddClean',function(HiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = HiveID})
    if #CurrentBeehive > 0 then
        local HasItem = exports.vorp_inventory:getItemCount(src, nil, Config.CleanItem)
        if HasItem > 0 then
            local Data = json.decode(CurrentBeehive[1].data)
            exports.vorp_inventory:subItem(src,Config.CleanItem,1)
            local NewClean = Data.Clean + Config.CleanGain
            if NewClean > 100 then
                NewClean = 100
            end
            Data.Clean = NewClean
            MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),HiveID})
            VORPcore.NotifyRightTip(src,_U('HiveCleaned'),5000)
        else
            VORPcore.NotifyRightTip(src,_U('NoCleanItem') .. Config.CleanItemLabel,5000)
        end
    end
end)

-----------------------------------------------
------------- AddHealth To Hive ---------------
-----------------------------------------------

RegisterServerEvent('mms-beekeeper:server:AddHealth',function(HiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = HiveID})
    if #CurrentBeehive > 0 then
        local HasItem = exports.vorp_inventory:getItemCount(src, nil, Config.HealItem)
        if HasItem > 0 then
            local Data = json.decode(CurrentBeehive[1].data)
            exports.vorp_inventory:subItem(src,Config.HealItem,1)
            local NewHeal = Data.Health + Config.HealGain
            if NewHeal > 100 then
                NewHeal = 100
            end
            Data.Health = NewHeal
            MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),HiveID})
            VORPcore.NotifyRightTip(src,_U('HealthAdded'),5000)
        else
            VORPcore.NotifyRightTip(src,_U('NoHealItem') .. Config.HealItemLabel,5000)
        end
    end
end)

-----------------------------------------------
-------------- AddQueen To Hive ---------------
-----------------------------------------------

RegisterServerEvent('mms-beekeeper:server:AddQueen',function(HiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = HiveID})
    if #CurrentBeehive > 0 then
        local QueensTable = {}
        for h,v in ipairs(Config.BeeTypes) do
            local HasItem = exports.vorp_inventory:getItemCount(src, nil, v.QueenItem)
            if HasItem > 0 then
                table.insert(QueensTable,v)
            end
        end
        if #QueensTable > 0 then
            local Data = json.decode(CurrentBeehive[1].data)
            exports.vorp_inventory:subItem(src,QueensTable[1].QueenItem,1)
            local NewQueen = Data.Queen + 1
            if NewQueen > 1 then
                NewQueen = 1
            end
            Data.Queen = NewQueen
            Data.BeeSettings.QueenItem = QueensTable[1].QueenItem
            Data.BeeSettings.QueenLabel = QueensTable[1].QueenLabel
            MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),HiveID})
            VORPcore.NotifyRightTip(src,_U('QueenAdded'),5000)
            if Config.GiveBackEmptyJarQueen then
                CanCarry = exports.vorp_inventory:canCarryItem(src, Config.GiveBackEmptyJarQueenItem, 1)
                if CanCarry then
                    exports.vorp_inventory:addItem(src,Config.GiveBackEmptyJarQueenItem,1)
                else
                    VORPcore.NotifyRightTip(src,_U('CantGetEmptyJar'),5000)
                end
            end
        else
            VORPcore.NotifyRightTip(src,_U('NoQueenItem'),5000)
        end
    end
end)

-----------------------------------------------
--------------- AddBees To Hive ---------------
-----------------------------------------------

RegisterServerEvent('mms-beekeeper:server:AddBees',function(HiveID,Queen)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = HiveID})
    if #CurrentBeehive > 0 then
        local BeeTable = nil
        for h,v in ipairs(Config.BeeTypes) do
            local HasItem = exports.vorp_inventory:getItemCount(src, nil, v.BeeItem)
            if HasItem > 0 and v.QueenItem == Queen then
                BeeTable = v
            end
        end
        if BeeTable ~= nil then
            local Data = json.decode(CurrentBeehive[1].data)
            exports.vorp_inventory:subItem(src,BeeTable.BeeItem,1)
            local NewBees = Data.Bees + BeeTable.AddBees
            if NewBees > Config.MaxBeesPerHive then
                NewBees = Config.MaxBeesPerHive
            end
            Data.Bees = NewBees
            Data.BeeSettings.BeeItem = BeeTable.BeeItem
            Data.BeeSettings.BeeLabel = BeeTable.BeeLabel
            Data.BeeSettings.Product = BeeTable.Product
            Data.BeeSettings.ProductLabel = BeeTable.ProductLabel
            Data.BeeSettings.ProductHappy = BeeTable.ProductHappy
            Data.BeeSettings.ProductNormal = BeeTable.ProductNormal
            MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),HiveID})
            VORPcore.NotifyRightTip(src,_U('BeesAdded'),5000)
            if Config.GiveBackEmptyJarBees then
                CanCarry = exports.vorp_inventory:canCarryItem(src, Config.GiveBackEmptyJarBeesItem, 1)
                if CanCarry then
                    exports.vorp_inventory:addItem(src,Config.GiveBackEmptyJarBeesItem,1)
                else
                    VORPcore.NotifyRightTip(src,_U('CantGetEmptyJar'),5000)
                end
            end
        else
            VORPcore.NotifyRightTip(src,_U('NoBeeItem'),5000)
        end
    end
end)

-----------------------------------------------
------------- TakeHoney from Hive -------------
-----------------------------------------------

RegisterServerEvent('mms-beekeeper:server:TakeProduct',function(HiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = HiveID})
    if #CurrentBeehive > 0 then
        local HasItem = exports.vorp_inventory:getItemCount(src, nil, Config.JarItem)
        if HasItem > 0 then
            local Data = json.decode(CurrentBeehive[1].data)
            if Data.Product >= Config.ProduktPerHoney then
                exports.vorp_inventory:subItem(src,Config.JarItem,1)
                exports.vorp_inventory:addItem(src,Data.BeeSettings.Product,1)
                local NewProduct = Data.Product - Config.ProduktPerHoney
                Data.Product = NewProduct
                MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),HiveID})
                VORPcore.NotifyRightTip(src,_U('ProductTaken'),5000)
            else
                VORPcore.NotifyRightTip(src,_U('NotEnoghProduct'),5000)
            end
        else
            VORPcore.NotifyRightTip(src,_U('NoJarItem'),5000)
        end
    end
end)

-----------------------------------------------
----------------- Delete Hive -----------------
-----------------------------------------------

RegisterServerEvent('mms-beekeeper:server:DeleteBeehive',function(HiveID)
    local src = source
    MySQL.execute('DELETE FROM mms_beekeeper WHERE id = ?', {HiveID}, function() end)
    if Config.GetBackBoxItem then
        exports.vorp_inventory:addItem(src,Config.BeehiveItem,1)
    end
    for h,v in ipairs(GetPlayers()) do
        TriggerClientEvent('mms-beekeeper:client:ReloadData',v)
    end
end)

RegisterServerEvent('mms-beekeeper:server:HealSickness',function(HiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = HiveID})
    if #CurrentBeehive > 0 then
        local Data = json.decode(CurrentBeehive[1].data)
        local HasItem = exports.vorp_inventory:getItemCount(src, nil, Data.Sickness.Medicine)
        if HasItem > 0 then
            exports.vorp_inventory:subItem(src,Data.Sickness.Medicine,1)
            Data.Sickness = {
                CurrentlySick = false,
                Type = '',
                Medicine = '',
                MedicineLabel = '',
                Intensity = 0.0,
            }
            MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),HiveID})
            VORPcore.NotifyRightTip(src,_U('SicknessHealed'),5000)
        else
            VORPcore.NotifyRightTip(src,_U('NoMedicineItem') .. Data.Sickness.MedicineLabel,5000)
        end
    end
end)

-----------------------------------------------
-------------- Smoke Wild Hive ----------------
-----------------------------------------------

RegisterServerEvent('mms-beekeeper:server:SmokeBeehive',function(CurrentHive)
    local src = source
    local HasItem = exports.vorp_inventory:getItemCount(src, nil, Config.SmokerItem)
    if HasItem > 0 then
        TriggerClientEvent('mms-beekeeper:client:BeehiveSmoked',src,CurrentHive)
        VORPcore.NotifyRightTip(src,_U('BeehiveSmoked'),5000)
    else
        VORPcore.NotifyRightTip(src,_U('NoSmokerItem') .. Config.SmokerLabel,5000)
    end
end)

-----------------------------------------------
------------- TakeBees Wild Hive --------------
-----------------------------------------------

RegisterServerEvent('mms-beekeeper:server:TakeBeesFromWildHive',function(CurrentHive)
    local src = source
    local HasItem = exports.vorp_inventory:getItemCount(src, nil, Config.EmptyBeeJar)
    local HasItem2 = exports.vorp_inventory:getItemCount(src, nil, Config.BugNetItem)
    if HasItem > 0 and HasItem2 > 0 then
        TriggerClientEvent('mms-beekeeper:client:BeesTakenFromHive',src,CurrentHive)
        local Amout = math.random(Config.GetBeeItemMin,Config.GetBeeItemMax)
        exports.vorp_inventory:addItem(src,Config.GetBeeItem,Amout)
        exports.vorp_inventory:subItem(src,Config.EmptyBeeJar,1)
        VORPcore.NotifyRightTip(src,_U('BeesTaken'),5000)
    else
        VORPcore.NotifyRightTip(src,_U('NoTool') .. Config.EmptyBeeJarLabel .. _U('OrTool') .. Config.BugNetLabel,5000)
    end
end)

-----------------------------------------------
------------ TakeQueen Wild Hive --------------
-----------------------------------------------

RegisterServerEvent('mms-beekeeper:server:TakeQueenFromWildHive',function(CurrentHive)
    local src = source
    local HasItem = exports.vorp_inventory:getItemCount(src, nil, Config.EmptyBeeJar)
    local HasItem2 = exports.vorp_inventory:getItemCount(src, nil, Config.BugNetItem)
    if HasItem > 0 and HasItem2 > 0 then
        TriggerClientEvent('mms-beekeeper:client:QueenTakenFromHive',src,CurrentHive)
        local Amout = math.random(Config.GetQueenItemMin,Config.GetQueenItemMax)
        exports.vorp_inventory:addItem(src,Config.GetQueenItem,Amout)
        exports.vorp_inventory:subItem(src,Config.EmptyBeeJar,1)
        VORPcore.NotifyRightTip(src,_U('QueenTaken'),5000)
    else
        VORPcore.NotifyRightTip(src,_U('NoTool') .. Config.EmptyBeeJarLabel .. _U('OrTool') .. Config.BugNetLabel,5000)
    end
end)

-----------------------------------------------
----------------- Helper System ---------------
-----------------------------------------------

RegisterServerEvent('mms-beekeeper:server:AddHelper',function(HiveID)
    local src = source
    local HelperName = ''
    local HelperCharIdent = 0
    local HelperSrc = nil
    local PedFound = 0
    for h,player in ipairs(GetPlayers()) do  -- Finding ClosestPlayer
        local MyPed = GetPlayerPed(src)
        local MyCoords = GetEntityCoords(MyPed)
        local ClosePed = GetPlayerPed(player)
        local CloseCoords = GetEntityCoords(ClosePed)
        local Distance = #(MyCoords - CloseCoords)
        if Distance > 0.2 and Distance < 3 and PedFound == 0 then
            local HelperChar = VORPcore.getUser(player).getUsedCharacter
            HelperName = HelperChar.firstname .. ' ' .. HelperChar.lastname
            HelperCharIdent = HelperChar.charIdentifier
            PedFound = PedFound + 1
            HelperSrc = player
        end
    end
    if PedFound > 0 then
        local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = HiveID})
        if #CurrentBeehive > 0 then
            local Data = json.decode(CurrentBeehive[1].data)
            Data.Helper.Name = HelperName
            Data.Helper.CharIdent = HelperCharIdent
            VORPcore.NotifyRightTip(src,_U('HelperHired') .. HelperName,5000)
            VORPcore.NotifyRightTip(HelperSrc,_U('YouGotHired'),5000)
            TriggerClientEvent('mms-beekeeper:client:ReloadData',src)
            TriggerClientEvent('mms-beekeeper:client:ReloadData',HelperSrc)
            MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),HiveID})
        end
    end
end)

RegisterServerEvent('mms-beekeeper:server:RemoveHelper',function(HiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = HiveID})
    if #CurrentBeehive > 0 then
        local Data = json.decode(CurrentBeehive[1].data)
        Data.Helper.Name = ''
        Data.Helper.CharIdent = 0
        VORPcore.NotifyRightTip(src,_U('HelperFired'),5000)
        MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),HiveID})
    end
end)