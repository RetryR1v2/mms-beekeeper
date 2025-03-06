-- Server Side
local VORPcore = exports.vorp_core:GetCore()

-----------------------------------------------
----------------- Register Item ---------------
-----------------------------------------------

exports.vorp_inventory:registerUsableItem(Config.BeehiveItem, function(data)
    local src = data.source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local Job = Character.job
    if Config.JobLock then
        for h,v in ipairs(Config.BeekeeperJobs) do
            if Job == v.Job then
                TriggerClientEvent('mms-beekeeper:client:CreateBeehive',src)
            else
                VORPcore.NotifyRightTip(src,_U('NotTheRightJob'),5000)
            end
        end
    else
        TriggerClientEvent('mms-beekeeper:client:CreateBeehive',src)
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
                    local CalculateProduct = Data.Bees * Data.BeeSettings.Product
                    local NewProduct = Data.Product + CalculateProduct
                    Data.Product = NewProduct
                end
            elseif Data.Bees > 0 and Data.Queen > 0 then
                local CalculateProduct = Data.Bees * Data.BeeSettings.Product
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
            if NewBees > BeeTable.MaxBeesPerHive then
                NewBees = BeeTable.MaxBeesPerHive
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
end)