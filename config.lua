Config = {}

Config.defaultlang = "de_lang"
Config.Debug = true

------------------------------------------------------------------
---------------- Auto Destroy Hive Settings ----------------------
------------------------------------------------------------------

-- This Option Destroy Inactive hives.
-- You Need to Calculate this IncreaseDamageBy with your Update Time
-- In Case you got update timer on 10 Min
-- Every 10 min will increase by 0.10 so 0.60 per hour
-- 14,4 per Day its 6,94 Days to Delete the Hive
-- Damage GEts Increased if no Bees and Queens in Hive 
-- then the Damage will increase.

Config.DetroyHives = true
Config.IncreaseDamageBy = 0.10
Config.DeleteHiveOnDamage = 100

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

-- FX

Config.UseBeeFX = true  -- Disables BeeFx

-- Item
Config.BeehiveItem = 'beehive_box'

-- Beehive Props

Config.UseRandomHive = true

Config.FixProp = 1

Config.Props = {
    { BeehiveBox = 'bee_house_gk_1' }, -- 1
    { BeehiveBox = 'bee_house_gk_2' }, -- 2
    { BeehiveBox = 'bee_house_gk_3' }, -- 3
    { BeehiveBox = 'bee_house_gk_4' }, -- 4
    { BeehiveBox = 'bee_house_gk_5' }, -- 5
    { BeehiveBox = 'bee_house_gk_6' }, -- 6
}

-- Blips
Config.UseBlips = true  -- Blips will Only Set on Owned Hives
Config.BlipName = 'Bienenstock'
Config.BlipSprite = 'blip_animal'
Config.BlipScale = 2.0

-- Delete Beehive 

Config.GetBackBoxItem = true

-- Max Bees Per Hive.

Config.MaxBeesPerHive = 200

-- Max Hives Per Player

Config.MaxBeehivesPerPlayer = 1 -- To Disable just Make 1000 in Here so Everyone can have 1000 Hives

------------------------------------------------------------------
--------------------- Update Settings ----------------------------
------------------------------------------------------------------

Config.UpdateTimer = 1 -- time in Minute

------------------------------------------------------------------
---------------------- Health Settings ---------------------------
------------------------------------------------------------------

Config.ReduceHealthOnDirty = 1.0 -- Max Health = 100
Config.ReduceHealthIfCleanUnder = 30

Config.HealItem = 'potato'
Config.HealItemLabel = 'Kartoffel'
Config.HealGain = 50

Config.HealTime = 5 -- Time in Secs

------------------------------------------------------------------
----------------------- Food Settings ----------------------------
------------------------------------------------------------------

Config.ReduceFoodPerTick = 0.4 -- MaxFood = 100
Config.FoodItem = 'sugar'
Config.FoodItemLabel = 'Zucker'
Config.FoodGain = 50

Config.FeedTime = 5 -- Time in Secs

------------------------------------------------------------------
---------------------- Water Settings ----------------------------
------------------------------------------------------------------

Config.ReduceWaterPerTick = 0.5 -- MaxWater = 100
Config.WaterItem = 'water'
Config.WaterItemLabel = 'Wasser'
Config.WaterGain = 50

Config.GiveBackEmpty = true
Config.GiveBackEmptyItem = 'wateringcan_empty'

Config.WaterTime = 5 -- Time in Secs

------------------------------------------------------------------
---------------------- Clean Settings ----------------------------
------------------------------------------------------------------

Config.ReduceCleanPerTick = 0.3 -- Max Cleaness = 100
Config.CleanItem = 'wheat'
Config.CleanItemLabel = 'Weizen'
Config.CleanGain = 50

Config.CleanTime = 5 -- Time in Secs

------------------------------------------------------------------
--------------------------- BeeItems -----------------------------
------------------------------------------------------------------

Config.QueenTime = 10
Config.BeeTime = 5

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
------------------------- Bees Can be Sick -----------------------
------------------------------------------------------------------

Config.SickTime = 25

Config.BeesCanBeSick = true
Config.SicknessChance = 1 -- 10 = 10% 
Config.BeesDieOn100 = true  -- Sickness Intensity Max = 100
Config.IncreaseIntensityPerUpdate = 1.5

Config.SickNess = {
    {
        Type = 'Bienen Pocken',
        Medicin = 'bandage',
        MedicinLabel = 'Bandage'
    },
    {
        Type = 'Beulen Pest',
        Medicin = 'bandage',
        MedicinLabel = 'Bandage'
    },
}

------------------------------------------------------------------
--------------------------- Honey Settings -----------------------
------------------------------------------------------------------

Config.ProduktPerHoney = 60 -- 60 Product are 1 Jar Honey
Config.JarItem = 'empty_bee_jar'

Config.TakeHoneyTime = 3 -- Time in Sec

-- Clear Product if no Bees in Hive

Config.ClearProductOnNoBees = true

------------------------------------------------------------------
------------------------- JarSettings ----------------------------
------------------------------------------------------------------

Config.GiveBackEmptyJarQueen = true
Config.GiveBackEmptyJarQueenItem = 'empty_bee_jar'

Config.GiveBackEmptyJarBees = true
Config.GiveBackEmptyJarBeesItem = 'empty_bee_jar'

------------------------------------------------------------------
------------------------- WildBeehives ---------------------------
------------------------------------------------------------------

Config.WildBeehiveSpawn = true
Config.WildBeehiveModel = 's_hornetnest_01x'

Config.SmokerItem = 'torch_smoker'
Config.SmokerLabel = 'Bienenrauch'
Config.BugNetItem = 'bug_net'
Config.BugNetLabel = 'Käfernetz'
Config.SmokeHiveTime = 5

Config.EmptyBeeJar = 'empty_bee_jar'
Config.EmptyBeeJarLabel = 'Glas'

Config.GetBeeTime = 5 -- Time in secs
Config.GetQueenTime = 5 -- Time in secs

Config.ResetWildHives = true -- Reset Hives After x Minu
Config.ResetWildHivesTimer = 60 -- Time in Minutes

Config.OnlySmokeToTakeProduct = true 
-- if True the insects can stay inside to get Product you just need to smoke the Hive.

Config.GetDmgFromWildBees = true -- You will get Stung from Wild Bees
Config.ChanceToGetStung = 50 -- Chance in %
Config.StungDamage = -50 -- Need to be a negative number else you get healed.

Config.WildBeehives = { -- Currently not Used
    --Valentine Area
    { 
        x = -216.408,
        y = 826.143,
        z = 125.752,
        rotx = -2.958,
        roty = 6.732,
        rotz = -145.55,
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -193.722,
        y = 743.794,
        z = 123.141,
        rotx = 9.698,
        roty = -5.618,
        rotz = -79.592,
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5
    },
    {   
        x = -453.896,
        y = 834.049,
        z = 121.246,
        rotx = -1.0,
        roty = 5.041,
        rotz = 170.42,
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -377.553, 
        y = 982.536, 
        z = 120.848, 
        rotx = -4.384, 
        roty = -0.888, 
        rotz = 130.965, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -154.658, 
        y = 891.411, 
        z = 151.904, 
        rotx = 1.172, 
        roty = 3.543, 
        rotz = 97.143, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -133.371, 
        y = 752.107, 
        z = 131.926, 
        rotx = 10.236, 
        roty = 13.214, 
        rotz = -71.214, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -58.255, 
        y = 876.738, 
        z = 206.057, 
        rotx = -8.453, 
        roty = -5.837, 
        rotz = 96.247, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -255.331, 
        y = 174.082, 
        z = 64.637, 
        rotx = 1.301, 
        roty = -10.387, 
        rotz = 34.752, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -775.097, 
        y = 463.872, 
        z = 83.063, 
        rotx = 0.0, 
        roty = 1.0, 
        rotz = 78.761, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 122.636, 
        y = 1001.221, 
        z = 211.823, 
        rotx = -1.0, 
        roty = 2.0, 
        rotz = 2.246, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -330.201, 
        y = 271.946, 
        z = 96.68, 
        rotx = 7.956, 
        roty = 1.806, 
        rotz = 60.257, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -86.149, 
        y = 326.456, 
        z = 106.402, 
        rotx = -1.036, 
        roty = 1.431, 
        rotz = 99.169, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    --Ambarino
    { 
        x = 185.459, 
        y = 1365.287, 
        z = 172.666, 
        rotx = -10.664, 
        roty = 27.0, 
        rotz = 39.002, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 337.993, 
        y = 1512.106, 
        z = 182.987, 
        rotx = -42.0, 
        roty = 8.0, 
        rotz = -135.78, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 454.742, 
        y = 1612.141, 
        z = 205.198, 
        rotx = -22.0, 
        roty = 5.739, 
        rotz = -2.234, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 642.597, 
        y = 1265.632, 
        z = 210.373, 
        rotx = -30.0, 
        roty = 3.647, 
        rotz = 95.294, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 821.806, 
        y = 1468.998, 
        z = 204.831, 
        rotx = -41.085, 
        roty = -11.619, 
        rotz = 116.201, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 720.604, 
        y = 1675.157, 
        z = 217.055, 
        rotx = -24.086, 
        roty = -9.687, 
        rotz = -30.025, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 607.537, 
        y = 2004.162, 
        z = 218.05, 
        rotx = -7.76, 
        roty = 16.942, 
        rotz = 72.112, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5  
    },
    { 
        x = 696.983, 
        y = 2206.197,
        z = 230.566, 
        rotx = 0.281, 
        roty = 18.121, 
        rotz = 74.134, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 328.714, 
        y = 1752.252, 
        z = 193.609, 
        rotx = -27.321, 
        roty = 0.025, 
        rotz = -70.783, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 1422.023, 
        y = 1449.823, 
        z = 187.042, 
        rotx = 3.075, 
        roty = 44.426, 
        rotz = 168.331, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 1753.457, 
        y = 1349.792, 
        z = 78.869, 
        rotx = -1.094, 
        roty = 2.33, 
        rotz = -45.445, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 1953.252, 
        y = 1665.154, 
        z = 175.816, 
        rotx = -17.345, 
        roty = -1.206, 
        rotz = -64.113, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 2118.802, 
        y = 1759.698, 
        z = 138.776, 
        rotx = 44.934, 
        roty = -10.479, 
        rotz = -54.619, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 2374.447, 
        y = 1967.643, 
        z = 162.636, 
        rotx = -39.906,
        roty = 1.276,
        rotz = 176.374, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 2459.903, 
        y = 2263.569, 
        z = 181.559, 
        rotx = 19.701, 
        roty = -11.727, 
        rotz = -23.628, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 2696.615, 
        y = 2338.641, 
        z = 162.465, 
        rotx = -18.121, 
        roty = -0.827, 
        rotz = 76.06, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 3087.923, 
        y = 1729.067, 
        z = 87.041, 
        rotx = 3.824, 
        roty = -11.696, 
        rotz = 39.041, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 3060.493, 
        y = 1695.868, 
        z = 70.664, 
        rotx = -23.925, 
        roty = 2.798, 
        rotz = 117.251, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 2546.732, 
        y = 1663.22, 
        z = 93.541, 
        rotx = -28.573, 
        roty = -3.301, 
        rotz = 49.913, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    --Grizzlies East
    { 
        x = 748.320, 
        y = 1870.760, 
        z = 243.940, 
        rotx = -8.005, 
        roty = -7.216, 
        rotz = 87.216, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5  
    },
    { 
        x = 729.060, 
        y = 1790.030, 
        z = 232.140, 
        rotx = 5.230, 
        roty = 20.092, 
        rotz = -159.672, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5  
    },
    { 
        x = 766.840, 
        y = 1626.890, 
        z = 214.060, 
        rotx = -13.797, 
        roty = 14.597, 
        rotz = -136.597, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 981.520,
        y = 1208.780, 
        z = 181.010, 
        rotx = 2.221, 
        roty = 33.000, 
        rotz = -114.000, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 946.480, 
        y = 1087.990, 
        z = 154.040, 
        rotx = 10.710, 
        roty = 47.000, 
        rotz = 66.000, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 1082.050, 
        y = 1033.910, 
        z = 142.680, 
        rotx = -7.188, 
        roty = -39.000,
        rotz = -109.000, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 1194.957, 
        y = 977.070, 
        z = 120.690, 
        rotx = -4.990, 
        roty = -5.393, 
        rotz = -144.543, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 1149.300, 
        y = 901.370, 
        z = 119.072, 
        rotx = -3.214, 
        roty = 30.000, 
        rotz = 175.000, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 1440.520, 
        y = 840.310, 
        z = 101.900, 
        rotx = 7.666, 
        roty = -6.000, 
        rotz = -145.000, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 1250.040, 
        y = 1153.710, 
        z = 152.430, 
        rotx = 0.000, 
        roty = 0.000, 
        rotz = -75.252, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 1612.845, 
        y = 1312.940, 
        z = 149.200, 
        rotx = -15.372, 
        roty = -30.000, 
        rotz = -74.000, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },--42
    --Lemoyne
    { 
        x = 1468.310, 
        y = -85.040, 
        z = 99.510, 
        rotx = -5.382, 
        roty = 31.000, 
        rotz = -89.000, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 1281.750, 
        y = -145.980, 
        z = 94.960, 
        rotx = 4.294, 
        roty = 23.000, 
        rotz = 175.000, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 1083.900, 
        y = -227.720,
        z = 96.370, 
        rotx = -1.777, 
        roty = -3.428, 
        rotz = -2.126, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 894.270, 
        y = -406.610,
        z = 89.140, 
        rotx = 6.586,
        roty = 11.716, 
        rotz = -33.000, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 740.400, 
        y = -457.180, 
        z = 80.190, 
        rotx = 15.280, 
        roty = 30.000, 
        rotz = 53.000, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 933.950, 
        y = -527.330, 
        z = 88.350, 
        rotx = 0.000,
        roty = 12.000, 
        rotz = -167.934, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 1054.100, 
        y = -593.090, 
        z = 93.720, 
        rotx = -7.692, 
        roty = -13.716, 
        rotz = -33.729, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 1122.860, 
        y = -819.170, 
        z = 86.290, 
        rotx = -8.000, 
        roty = -5.000, 
        rotz = -8.000, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 1377.500, 
        y = -947.740, 
        z = 53.840, 
        rotx = 3.000, 
        roty = -34.000, 
        rotz = -105.000, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = 1421.872, 
        y = -1573.480, 
        z = 71.310, 
        rotx = -7.734, 
        roty = 29.000, 
        rotz = -179.000, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    --West Elizabeth
    { 
        x = -1210.260, 
        y = 523.640, 
        z = 80.270, 
        rotx = -29.000, 
        roty = -13.683, 
        rotz = 92.253, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -1347.434, 
        y = 595.400, 
        z = 102.680, 
        rotx = -32.000, 
        roty = -4.195, 
        rotz = 165.864, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -1508.460, 
        y = 655.530, 
        z = 117.420, 
        rotx = -28.000, 
        roty = 3.130, 
        rotz = 135.332, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -2074.910, 
        y = 789.120, 
        z = 144.650, 
        rotx = -27.000, 
        roty = -3.406, 
        rotz = 131.922, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -2533.940, 
        y = 837.870, 
        z = 151.180, 
        rotx = -4.000, 
        roty = -39.000,
        rotz = 29.000, 
        heading = 50, 
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -2474.260, 
        y = 463.014, 
        z = 146.510, 
        rotx = -27.000, 
        roty = -4.294, 
        rotz = -80.577, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -2811.930, 
        y = -144.260, 
        z = 160.250, 
        rotx = -28.000, 
        roty = -6.233, 
        rotz = -51.551, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -2716.070, 
        y = -426.740, 
        z = 155.430, 
        rotx = -32.000, 
        roty = -14.377,
        rotz = -171.840,
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
    { 
        x = -1697.726, 
        y = 222.810, 
        z = 119.980, 
        rotx = -40.000, 
        roty = 7.504, 
        rotz = 15.933, 
        heading = 50,
        GetBeeItem = 'basic_bees',
        GetBeeItemMin = 1,
        GetBeeItemMax = 3,
        GetQueenItem = 'basic_queen',
        GetQueenItemMin = 1,
        GetQueenItemMax = 3,
        ProductWildHive = 'honey',
        ProductGet = 1,
        ItemNeeded = 'empty_bee_jar',
        TakeProductTime = 5 
    },
}

