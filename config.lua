Config = {}

Config.defaultlang = "de_lang"
Config.Debug = true

------------------------------------------------------------------
--------------------- JobLock Settings ---------------------------
------------------------------------------------------------------

Config.JobLock = false
Config.BeekeeperJobs = {
    { Job = 'Beekeeper' },
}

------------------------------------------------------------------
--------------------- Beehive Settings ---------------------------
------------------------------------------------------------------

-- Item
Config.BeehiveItem = 'beehive_box'
Config.BeehiveBox = 'p_crate03x'

-- Blips
Config.UseBlips = true  -- Blips will Only Set on Owned Hives
Config.BlipName = 'Bienenstock'
Config.BlipSprite = 'blip_animal'
Config.BlipScale = 2.0

-- Delete Beehive 

Config.GetBackBoxItem = true

------------------------------------------------------------------
--------------------- Update Settings ----------------------------
------------------------------------------------------------------

Config.UpdateTimer = 5 -- time in Minute

------------------------------------------------------------------
---------------------- Health Settings ---------------------------
------------------------------------------------------------------

Config.ReduceHealthOnDirty = 1.0 -- Max Health = 100
Config.ReduceHealthIfCleanUnder = 30

Config.HealItem = 'potato'
Config.HealItemLabel = 'Kartoffel'
Config.HealGain = 50

------------------------------------------------------------------
----------------------- Food Settings ----------------------------
------------------------------------------------------------------

Config.ReduceFoodPerTick = 0.4 -- MaxFood = 100
Config.FoodItem = 'sugar'
Config.FoodItemLabel = 'Zucker'
Config.FoodGain = 50

------------------------------------------------------------------
---------------------- Water Settings ----------------------------
------------------------------------------------------------------

Config.ReduceWaterPerTick = 0.5 -- MaxWater = 100
Config.WaterItem = 'water'
Config.WaterItemLabel = 'Wasser'
Config.WaterGain = 50

------------------------------------------------------------------
---------------------- Clean Settings ----------------------------
------------------------------------------------------------------

Config.ReduceCleanPerTick = 0.3 -- Max Cleaness = 100
Config.CleanItem = 'wheat'
Config.CleanItemLabel = 'Weizen'
Config.CleanGain = 50

------------------------------------------------------------------
--------------------------- BeeItems -----------------------------
------------------------------------------------------------------

Config.BeeTypes = {
    {
        QueenItem = 'basic_queen',
        QueenLabel = 'Bienenkönigin',
        BeeItem = 'basic_bees',
        BeeLabel = 'Biene',
        AddBees = 15,
        Product = 'honey',
        ProductLabel = 'Honig',
        ProductHappy = 0.015,
        ProductNormal = 0.010,
        MaxBeesPerHive = 200,
    },
    {
        QueenItem = 'basic_hornet_queen',
        QueenLabel = 'Hornissenkönigin',
        BeeItem = 'basic_hornets',
        BeeLabel = 'Hornisse',
        AddBees = 10,
        Product = 'honey2',
        ProductLabel = 'Manuka Honig',
        ProductHappy = 0.015,
        ProductNormal = 0.010,
        MaxBeesPerHive = 200,
    },
}

------------------------------------------------------------------
--------------------------- Happy Function -----------------------
------------------------------------------------------------------

Config.BeesCanBeHappy = true
Config.HappyAt = {
    Food = 60,
    Water = 60,
    Clean = 60,
}

Config.GetBeesOnHappy = true

Config.BeesMin = 1
Config.BeesMax = 3

------------------------------------------------------------------
------------------------- Bees Die Function ----------------------
------------------------------------------------------------------

Config.BeesCanDie = true
Config.DieAt = {
    Food = 10,
    Water = 10,
    Clean = 10,
}

Config.LooseBeesMin = 3
Config.LooseBeesMax = 5


------------------------------------------------------------------
--------------------------- Honey Settings -----------------------
------------------------------------------------------------------

Config.ProduktPerHoney = 60 -- 60 Product are 1 Jar Honey
Config.JarItem = 'empty_bee_jar'