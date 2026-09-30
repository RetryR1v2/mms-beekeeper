-- Server Side
local VORPcore = exports.vorp_core:GetCore()

local file = LoadResourceFile(
    GetCurrentResourceName(),
    'html/locales/de.json'
)

if file then
    Translation = json.decode(file)
end
-----------------------------------------------
------------- Register Callback ---------------
-----------------------------------------------

VORPcore.Callback.Register('mms-beekeeper:callback:GetJarAmount', function(source,cb,HoneyAmount,HoneyItem)
    local src = source
    local JarAmount = exports.vorp_inventory:getItemCount(src, nil, Config.JarItem)
    local CanCarry = exports.vorp_inventory:canCarryItem(src, HoneyItem, HoneyAmount)
    cb ({JarAmount,CanCarry})
end)

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
                        VORPcore.NotifyRightTip(src,Translation.max_hive_Reached,5000)
                    end
                else
                    TriggerClientEvent('mms-beekeeper:client:CreateBeehive',src)
                end
            else
                VORPcore.NotifyRightTip(src,Translation.not_the_right_job,5000)
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
                VORPcore.NotifyRightTip(src,Translation.max_hive_Reached,5000)
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
            local charIDOwner = v.charident
            
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
            local MaxProduct = Config.ProduktPerHoney * Config.MaxHoneyInHive
            if Data.Bees > 0 and Data.Queen > 0 and Config.BeesCanBeHappy  then
                local Happy = false
                if Data.Food >= Config.HappyAt.Food and Data.Water >= Config.HappyAt.Water and Data.Clean >= Config.HappyAt.Clean then
                    Happy = true
                end
                if Happy then
                    local CalculateProduct = Data.Bees * Data.BeeSettings.ProductHappy
                    local NewProduct = Data.Product + CalculateProduct
                    Data.Product = NewProduct
                    if NewProduct < MaxProduct then
                        Data.Product = NewProduct
                    elseif NewProduct >= MaxProduct then
                        Data.Product = MaxProduct
                    end
                else
                    local CalculateProduct = Data.Bees * Data.BeeSettings.ProductNormal
                    local NewProduct = Data.Product + CalculateProduct
                    Data.Product = NewProduct
                    if NewProduct < MaxProduct then
                        Data.Product = NewProduct
                    elseif NewProduct >= MaxProduct then
                        Data.Product = MaxProduct
                    end
                end
            elseif Data.Bees > 0 and Data.Queen > 0 then
                local CalculateProduct = Data.Bees * Data.BeeSettings.ProductNormal
                local NewProduct = Data.Product + CalculateProduct
                if NewProduct < MaxProduct then
                    Data.Product = NewProduct
                elseif NewProduct >= MaxProduct then
                    Data.Product = MaxProduct
                end
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
                    local NewBees = Data.Bees - RemoveBeeValue
                    if NewBees < 0 then
                        NewBees = 0
                    end
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
                if Config.ClearProductOnNoBees then
                    Data.Product = 0
                end
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
            ---------------- Damage UPDATE ----------------
            -----------------------------------------------
            local HiveDeleted = false
            if Data.Damage == nil then
                Data.Damage = 0
            end
            if Config.DetroyHives then
                if Data.Bees <= 0 and Data.Queen <= 0 then
                    local NewDamage = Data.Damage + Config.IncreaseDamageBy
                    Data.Damage = NewDamage
                    if Data.Damage >= Config.DeleteHiveOnDamage then
                        MySQL.execute('DELETE FROM mms_beekeeper WHERE id = ?', {v.id}, function() end)
                        for h,v in ipairs(GetPlayers()) do
                            TriggerClientEvent('mms-beekeeper:client:ReloadData',v)
                        end
                        HiveDeleted = true
                    end
                elseif Data.Bees > 0 or Data.Queen > 0 and Data.Damage > 0 then
                    Data.Damage = 0
                end
            end

            -----------------------------------------------
            --------------- Database UPDATE ---------------
            -----------------------------------------------
            if not HiveDeleted then
                MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),v.id})
                for h,v in ipairs(GetPlayers()) do
                    TriggerClientEvent('updateNUI',v,Data)
                end
            end

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
        TriggerClientEvent('openBeehive',src,CurrentBeehive)
    end
end)

-----------------------------------------------
-------------- AddFood To Hive ----------------
-----------------------------------------------

VORPcore.Callback.Register('addFood', function(source,cb,hiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = hiveID})
    local Data = json.decode(CurrentBeehive[1].data)
    if #CurrentBeehive > 0 then
        local HasItem = exports.vorp_inventory:getItemCount(src, nil, Config.FoodItem)
        if HasItem > 0 and Data.Food < 100 then
            exports.vorp_inventory:subItem(src,Config.FoodItem,1)
            local NewFood = Data.Food + Config.FoodGain
            if NewFood > 100 then
                NewFood = 100
            end
            Data.Food = NewFood
            MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),hiveID})
            cb({success = true, Data = Data})
        elseif HasItem > 0 and Data.Food >= 100 then
            cb({success = false, type = 1})
        elseif HasItem <= 0 then
            cb({success = false, type = 2})
        end
    end
end)

-----------------------------------------------
-------------- AddWater To Hive ---------------
-----------------------------------------------

VORPcore.Callback.Register('addWater', function(source,cb,hiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = hiveID})
    local Data = json.decode(CurrentBeehive[1].data)
    if #CurrentBeehive > 0 then
        local HasItem = exports.vorp_inventory:getItemCount(src, nil, Config.WaterItem)
        if HasItem > 0 and Data.Water < 100 then
            exports.vorp_inventory:subItem(src,Config.WaterItem,1)
            local NewWater = Data.Water + Config.WaterGain
            if NewWater > 100 then
                NewWater = 100
            end
            Data.Water = NewWater
            MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),hiveID})
            if Config.GiveBackEmpty then
                CanCarry = exports.vorp_inventory:canCarryItem(src, Config.GiveBackEmptyItem, 1)
                if CanCarry then
                    exports.vorp_inventory:addItem(src,Config.GiveBackEmptyItem,1)
                end
            end
            cb({success = true, Data = Data})
        elseif HasItem > 0 and Data.Water >= 100 then
            cb({success = false, type = 1})
        elseif HasItem <= 0 then
            cb({success = false, type = 2})
        end
    end
end)

-----------------------------------------------
-------------- AddClean To Hive ---------------
-----------------------------------------------

VORPcore.Callback.Register('addClean', function(source,cb,hiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = hiveID})
    local Data = json.decode(CurrentBeehive[1].data)
    if #CurrentBeehive > 0 then
        local HasItem = exports.vorp_inventory:getItemCount(src, nil, Config.CleanItem)
        if HasItem > 0 and Data.Clean < 100 then
            exports.vorp_inventory:subItem(src,Config.CleanItem,1)
            local NewClean = Data.Clean + Config.CleanGain
            if NewClean > 100 then
                NewClean = 100
            end
            Data.Clean = NewClean
            MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),hiveID})
            cb({success = true, Data = Data})
        elseif HasItem > 0 and Data.Clean >= 100 then
            cb({success = false, type = 1})
        elseif HasItem <= 0 then
            cb({success = false, type = 2})
        end
    end
end)

-----------------------------------------------
------------- AddHealth To Hive ---------------
-----------------------------------------------

VORPcore.Callback.Register('addHealth', function(source,cb,hiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = hiveID})
    local Data = json.decode(CurrentBeehive[1].data)
    if #CurrentBeehive > 0 then
        local HasItem = exports.vorp_inventory:getItemCount(src, nil, Config.HealItem)
        if HasItem > 0 and Data.Health < 100 then
            exports.vorp_inventory:subItem(src,Config.HealItem,1)
            local NewHeal = Data.Health + Config.HealGain
            if NewHeal > 100 then
                NewHeal = 100
            end
            Data.Health = NewHeal
            MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),hiveID})
            cb({success = true, Data = Data})
        elseif HasItem > 0 and Data.Health >= 100 then
            cb({success = false, type = 1})
        elseif HasItem <= 0 then
            cb({success = false, type = 2})
        end
    end
end)

-----------------------------------------------
-------------- AddQueen To Hive ---------------
-----------------------------------------------

VORPcore.Callback.Register('AddQueen', function(source,cb,hiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = hiveID})
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
            if Data.Queen < 1 then
                exports.vorp_inventory:subItem(src,QueensTable[1].QueenItem,1)
                local NewQueen = Data.Queen + 1
                if NewQueen > 1 then
                    NewQueen = 1
                end
                Data.Queen = NewQueen
                Data.BeeSettings.QueenItem = QueensTable[1].QueenItem
                Data.BeeSettings.QueenLabel = QueensTable[1].QueenLabel
                MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),hiveID})
                if Config.GiveBackEmptyJarQueen then
                    CanCarry = exports.vorp_inventory:canCarryItem(src, Config.GiveBackEmptyJarQueenItem, 1)
                    if CanCarry then
                        exports.vorp_inventory:addItem(src,Config.GiveBackEmptyJarQueenItem,1)
                    end
                end
                cb({success = true, Data = Data})
            else
                cb({success = false})
            end
        end
    end
end)

-----------------------------------------------
--------------- AddBees To Hive ---------------
-----------------------------------------------

VORPcore.Callback.Register('addBees', function(source,cb,hiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = hiveID})
    local Data = json.decode(CurrentBeehive[1].data)
    if #CurrentBeehive > 0 then
        local BeeTable = nil
        for h,v in ipairs(Config.BeeTypes) do
            local HasItem = exports.vorp_inventory:getItemCount(src, nil, v.BeeItem)
            if HasItem > 0 and v.QueenItem == Data.BeeSettings.QueenItem then
                BeeTable = v
            end
        end
        if BeeTable ~= nil then
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
            MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),hiveID})
            if Config.GiveBackEmptyJarBees then
                CanCarry = exports.vorp_inventory:canCarryItem(src, Config.GiveBackEmptyJarBeesItem, 1)
                if CanCarry then
                    exports.vorp_inventory:addItem(src,Config.GiveBackEmptyJarBeesItem,1)
                end
            end
            cb({success = true, Data = Data})
        else
            cb({success = false})
        end
    end
end)

-----------------------------------------------
------------- TakeHoney from Hive -------------
-----------------------------------------------

VORPcore.Callback.Register('takeHoney', function(source,cb,hiveID,honeyAmount)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = hiveID})
    if #CurrentBeehive > 0 then
        local HasItem = exports.vorp_inventory:getItemCount(src, nil, Config.JarItem)
        if HasItem >= tonumber(honeyAmount) then
            local Data = json.decode(CurrentBeehive[1].data)
            exports.vorp_inventory:subItem(src,Config.JarItem,tonumber(honeyAmount))
            exports.vorp_inventory:addItem(src,Data.BeeSettings.Product,tonumber(honeyAmount))
            local NewProduct = Data.Product - Config.ProduktPerHoney * tonumber(honeyAmount)
            Data.Product = NewProduct
            MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),hiveID})
            cb({success = true, Data = Data})
        else
            cb({success = false})
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

-----------------------------------------------
--------------- Heal Sickness -----------------
-----------------------------------------------

VORPcore.Callback.Register('cureIllness', function(source,cb,hiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = hiveID})
    local Data = json.decode(CurrentBeehive[1].data)
    if #CurrentBeehive > 0 and Data.Sickness.CurrentlySick then
        local HasItem = exports.vorp_inventory:getItemCount(src, nil, Data.Sickness.Medicine)
        if HasItem > 0 and Data.Sickness.CurrentlySick then
            exports.vorp_inventory:subItem(src,Data.Sickness.Medicine,1)
            Data.Sickness = {
                CurrentlySick = false,
                Type = '',
                Medicine = '',
                MedicineLabel = '',
                Intensity = 0.0,
            }
            MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),hiveID})
            cb({success = true, Data = Data})
        elseif HasItem < 0 then
            cb({success = false, type = 2})
        end
    elseif not Data.Sickness.CurrentlySick then
        cb({success = false, type = 1})
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
        VORPcore.NotifyRightTip(src,Translation.beehive_smoked,5000)
    else
        VORPcore.NotifyRightTip(src,Translation.no_smoke_item .. Config.SmokerLabel,5000)
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
        local Amout = math.random(CurrentHive.GetBeeItemMin,CurrentHive.GetBeeItemMax)
        local CanCarry = exports.vorp_inventory:canCarryItem(src, CurrentHive.GetBeeItem, Amout)
        if CanCarry then
            TriggerClientEvent('mms-beekeeper:client:BeesTakenFromHive',src,CurrentHive)
            exports.vorp_inventory:addItem(src,CurrentHive.GetBeeItem,Amout)
            exports.vorp_inventory:subItem(src,Config.EmptyBeeJar,1)
            VORPcore.NotifyRightTip(src,Translation.bees_taken,5000)
        else
            VORPcore.NotifyRightTip(src,Translation.no_invetory_space,5000)
        end
    else
        VORPcore.NotifyRightTip(src,Translation.no_tool .. Config.EmptyBeeJarLabel .. Translation.or_tool .. Config.BugNetLabel,5000)
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
        local Amout = math.random(CurrentHive.GetQueenItemMin,CurrentHive.GetQueenItemMax)
        local CanCarry = exports.vorp_inventory:canCarryItem(src, CurrentHive.GetQueenItem, Amout)
        if CanCarry then
            TriggerClientEvent('mms-beekeeper:client:QueenTakenFromHive',src,CurrentHive)
            exports.vorp_inventory:addItem(src,CurrentHive.GetQueenItem,Amout)
            exports.vorp_inventory:subItem(src,Config.EmptyBeeJar,1)
            VORPcore.NotifyRightTip(src,Translation.queen_taken,5000)
        else
            VORPcore.NotifyRightTip(src,Translation.no_invetory_space,5000)
        end
    else
        VORPcore.NotifyRightTip(src,Translation.no_tool .. Config.EmptyBeeJarLabel .. Translation.or_tool .. Config.BugNetLabel,5000)
    end
end)

-----------------------------------------------
------------ TakeHoney Wild Hive --------------
-----------------------------------------------

RegisterServerEvent('mms-beekeeper:server:TakeHoneyFromWildHive',function(CurrentHive)
    local src = source
    local HasItem = exports.vorp_inventory:getItemCount(src, nil, Config.EmptyBeeJar)
    if HasItem > 0 then
        local CanCarry = exports.vorp_inventory:canCarryItem(src, CurrentHive.ProductWildHive, CurrentHive.ProductGet)
        if CanCarry then
            exports.vorp_inventory:subItem(src,CurrentHive.ItemNeeded,1)
            exports.vorp_inventory:addItem(src,CurrentHive.ProductWildHive,CurrentHive.ProductGet)
            TriggerClientEvent('mms-beekeeper:client:HoneyTakenFromHive',src,CurrentHive)
            VORPcore.NotifyRightTip(src,Translation.honey_successfully_taken_from_hive,5000)
        else
            VORPcore.NotifyRightTip(src,Translation.no_invetory_space,5000)
        end
    else
        VORPcore.NotifyRightTip(src,Translation.missing_jar,5000)
    end
end)

-----------------------------------------------
----------------- Helper System ---------------
-----------------------------------------------

VORPcore.Callback.Register('getCloseHelpers', function(source,cb)
    local src = source
    local closeHelper = {}
    for h,player in ipairs(GetPlayers()) do  -- Finding ClosestPlayer
        local MyPed = GetPlayerPed(src)
        local MyCoords = GetEntityCoords(MyPed)
        local ClosePed = GetPlayerPed(player)
        local CloseCoords = GetEntityCoords(ClosePed)
        local Distance = #(MyCoords - CloseCoords)
        if Distance < 3 then
            local HelperChar = VORPcore.getUser(player).getUsedCharacter
            HelperName = HelperChar.firstname .. ' ' .. HelperChar.lastname
            HelperCharIdent = HelperChar.charIdentifier
            HelperSrc = player
            local helperData = {helperSrc = player, helperCharident = HelperCharIdent, helperName = HelperName}
            table.insert(closeHelper, helperData)
        end
    end
    if #closeHelper > 0 then
        cb({success = true, closeHelper = closeHelper})
    else
        cb({success = false})
    end
end)

VORPcore.Callback.Register('hireHelper', function(source,cb,hiveID,helperSrc,helperCharident,helperName)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = hiveID})
    local Data = json.decode(CurrentBeehive[1].data)
    if #CurrentBeehive > 0 then
        Data.Helper.Name = helperName
        Data.Helper.CharIdent = helperCharident
        MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),hiveID})
        for h,player in ipairs(GetPlayers()) do
            TriggerClientEvent('mms-beekeeper:client:ReloadData',player)
        end
    end
    cb({success = true, Data = Data})
end)

VORPcore.Callback.Register('fireHelper', function(source,cb,hiveID)
    local src = source
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = hiveID})
    local Data = json.decode(CurrentBeehive[1].data)
    if #CurrentBeehive > 0 then
        Data.Helper.Name = ''
        Data.Helper.CharIdent = 0
        MySQL.update('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),hiveID})
        for h,v in ipairs(GetPlayers()) do
            TriggerClientEvent('mms-beekeeper:client:ReloadData',v)
        end
    end
    cb({success = true, Data = Data})
end)

-----------------------------------------------
---------------- Change Heading ---------------
-----------------------------------------------

VORPcore.Callback.Register('changePosition', function(source,cb,hiveID,coordsX,coordsY,coordsZ,coordsH)
    local src = source
    print(coordsX,coordsY,coordsZ,coordsH)
    local CurrentBeehive = MySQL.query.await("SELECT * FROM mms_beekeeper WHERE id=@id", { ["id"] = hiveID})
    if #CurrentBeehive > 0 then
        local Data = json.decode(CurrentBeehive[1].data)
        Data.Coords.x = tonumber(coordsX)
        Data.Coords.y = tonumber(coordsY)
        Data.Coords.z = tonumber(coordsZ)
        Data.Coords.heading = tonumber(coordsH)
        MySQL.update.await('UPDATE `mms_beekeeper` SET data = ? WHERE id = ?',{json.encode(Data),hiveID})
        for h,v in ipairs(GetPlayers()) do
            TriggerClientEvent('mms-beekeeper:client:ReloadData',src)
        end
        cb({success = true, Data = Data})
    end
end)