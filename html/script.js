const navButtons = document.querySelectorAll(".nav-button");
const settingButtons = document.querySelectorAll(".settingButton");

const containerMain = document.getElementById("container-main");
const containerStatus = document.getElementById("container-status");
const containerSickness = document.getElementById("container-sickness");
const containerHelper = document.getElementById("container-helper");
const containerSettings = document.getElementById("container-hive-settings");

const buttonAddQueen = document.getElementById("addQueen");
const buttonAddBees = document.getElementById("addBees");
const buttonAddHealth = document.getElementById("addHealth");
const buttonTakeHoney = document.getElementById("takeHoney");
const buttonAddWater = document.getElementById("addWater");
const buttonAddFood = document.getElementById("addFood");
const buttonAddClean = document.getElementById("addClean");
const buttonCureIllness = document.getElementById("addIllness");
const buttonResetPosition = document.getElementById("resetPosition");

const getCloseWorkers = document.getElementById("getCloseWorkers");
const buttonFireWorker = document.getElementById("fireWorker");

let currentBeehive = {};
let config = {};
let hiveID = 0;
let oldHivePosition = {};

function setOldCoords(){
    oldHivePosition = { 
        coordsX: Number(currentBeehive.Coords.x), 
        coordsY: Number(currentBeehive.Coords.y), 
        coordsZ: Number(currentBeehive.Coords.z), 
        coordsH: Number(currentBeehive.Coords.heading)
    }
}

// Fill Function

function setVerticalProgress(id, value) {

    const progress = document.getElementById(id);

    const percent = Math.max(0, Math.min(100, value));

    progress.style.height = `${percent}%`;
}


// Load Translations

let Translation = {};

// Coords

let coordsX = 0
let coordsY = 0
let coordsZ = 0
let coordsH = 0
let intensity = 0

// Set Status Function

function setStatus() {
    setVerticalProgress("progressFillWater", currentBeehive.Water);
    document.getElementById("water").innerText = `${Translation.water_status_page} ${Math.floor(currentBeehive.Water)}`;
    setVerticalProgress("progressFillFood", currentBeehive.Food);
    document.getElementById("food").innerText = `${Translation.food_status_page} ${Math.floor(currentBeehive.Food)}`;
    setVerticalProgress("progressFillClean", currentBeehive.Clean);
    document.getElementById("clean").innerText = `${Translation.clean_status_page} ${Math.floor(currentBeehive.Clean)}`;
    setVerticalProgress("progressFillHealth", currentBeehive.Health);
    document.getElementById("health").innerText = `${Translation.health_status_page} ${Math.floor(currentBeehive.Health)}`;
    setVerticalProgress("progressFillHoney", currentBeehive.Product / config.ProduktPerHoney);
    document.getElementById("honey").innerText = `${Translation.honey_main_page} ${Math.floor(currentBeehive.Product / config.ProduktPerHoney)}`;
    document.getElementById("queenText").innerText = `${Translation.queen_main_page} ${currentBeehive.BeeSettings.QueenLabel}`;
    document.getElementById("beesText").innerText = `${Translation.bees_main_page} ${currentBeehive.BeeSettings.BeeLabel} ${currentBeehive.Bees}`;
    setVerticalProgress("progressFillIllness", currentBeehive.Sickness.Intensity);
    document.getElementById("illness").innerText = `${Translation.illness_status_page} ${Math.floor(currentBeehive.Sickness.Intensity)}`;

    if (currentBeehive.Sickness.Type !== "") {
        document.getElementById("sicknessType").innerText = `${Translation.sickness_type_text} ${currentBeehive.Sickness.Type}`;
        document.getElementById("sicknessMedizin").innerText = `${Translation.sickness_medizin_text} ${currentBeehive.Sickness.MedicineLabel}`;
    }

    if (currentBeehive.Helper.CharIdent && currentBeehive.Helper.CharIdent !== 0) {
        document.getElementById("currentWorkerText").innerText = `${Translation.current_worker_text} ${currentBeehive.Helper.Name}`;
    }
    coordsX = currentBeehive.Coords.x
    coordsY = currentBeehive.Coords.y
    coordsZ = currentBeehive.Coords.z
    coordsH = currentBeehive.Coords.heading

}

async function loadTranslation() {
    const getLang = await fetch(`https://${GetParentResourceName()}/getLang`, {
           method: "POST",

        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({})
    });
        
    const lang = await getLang.json();
        
    if (lang.success) {
        const response = await fetch(`locales/${lang.lang}.json`);
        Translation = await response.json();
        
        document.querySelectorAll("[data-i18n]").forEach(function(element) {
            const key = element.getAttribute("data-i18n");
            element.innerText = Translation[key];
        });

        document.querySelectorAll("[data-i18n-placeholder]").forEach(function(element) {
            const key = element.getAttribute("data-i18n-placeholder");
            element.placeholder = Translation[key];
        });
    } else {
        const response = await fetch(`locales/de.json`);
        Translation = await response.json();

        document.querySelectorAll("[data-i18n]").forEach(function(element) {
            const key = element.getAttribute("data-i18n");
            element.innerText = Translation[key];
        });

        document.querySelectorAll("[data-i18n-placeholder]").forEach(function(element) {
            const key = element.getAttribute("data-i18n-placeholder");
            element.placeholder = Translation[key];
        });
    }

}

loadTranslation();

// --------------------------------------------------
// --------------------------------------------------
// --------------------------------------------------

// --------------------------------------------------
// -----    Funktion Königin einsetzen          -----
// --------------------------------------------------

buttonAddQueen.addEventListener("click",function(){
    addQueen()
});

async function addQueen() {
    try {
        const response = await fetch(`https://${GetParentResourceName()}/addQueen`, {
            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({
                hiveID: hiveID,
            })
        });
        
        const data = await response.json();

        if (data.success) {
            currentBeehive = data.Data
            setStatus()
            document.getElementById("statusTextMain").textContent = Translation.queen_added_successfully;
            await wait(5000);
            document.getElementById("statusTextMain").textContent = "";
        } else {
            document.getElementById("statusTextMain").textContent = Translation.cant_add_queen;
            await wait(5000);
            document.getElementById("statusTextMain").textContent = "";
        }

    } catch (error) {
        console.error("Error sending message:", error);
    }
}

// --------------------------------------------------
// --------------------------------------------------
// --------------------------------------------------

// --------------------------------------------------
// -----    Funktion Bienen einsetzen           -----
// --------------------------------------------------

buttonAddBees.addEventListener("click",function(){
    addBees()
});

async function addBees() {
    try {
        const response = await fetch(`https://${GetParentResourceName()}/addBees`, {
            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({
                hiveID: hiveID,
            })
        });
        
        const data = await response.json();

        if (data.success) {
            currentBeehive = data.Data
            setStatus()
            document.getElementById("statusTextMain").textContent = Translation.bee_added_successfully;
            await wait(5000);
            document.getElementById("statusTextMain").textContent = "";
        } else {
            document.getElementById("statusTextMain").textContent = `${Translation.cant_add_bee} ${currentBeehive.BeeSettings.BeeLabel}`;
            await wait(5000);
            document.getElementById("statusTextMain").textContent = "";
        }

    } catch (error) {
        console.error("Error sending message:", error);
    }
};

// --------------------------------------------------
// --------------------------------------------------
// --------------------------------------------------

// --------------------------------------------------
// -----        Funktion Honig Nehmen           -----
// --------------------------------------------------

buttonTakeHoney.addEventListener("click",function(){
    takeHoney()
});

async function takeHoney() {
    try {
        let honeyAmount = Math.floor(currentBeehive.Product / config.ProduktPerHoney)
        let amount = document.getElementById("takeHoneyNumber").value
        if (amount > 0 && honeyAmount >= amount ) {
            const response = await fetch(`https://${GetParentResourceName()}/takeHoney`, {
                method: "POST",

                headers: {
                    "Content-Type": "application/json"
                },

                body: JSON.stringify({
                    hiveID: hiveID,
                    amount: amount,
                })
            });
            
            const data = await response.json();

            if (data.success) {
                currentBeehive = data.Data
                setStatus()
                document.getElementById("takeHoneyNumber").value = 0;
                document.getElementById("statusTextMain").textContent = Translation.honey_taken_successfully;
                await wait(5000);
                document.getElementById("statusTextMain").textContent = "";
            } else {
                document.getElementById("statusTextMain").textContent = Translation.not_enogh_jars;
                await wait(5000);
                document.getElementById("statusTextMain").textContent = "";
            }
        } else if (amount < 0 ) {
            document.getElementById("statusTextMain").textContent = Translation.minus_not_allowed;
            await wait(5000);
            document.getElementById("statusTextMain").textContent = "";
        } else if (honeyAmount < amount) {
            document.getElementById("statusTextMain").textContent = Translation.not_enogh_honey;
            await wait(5000);
            document.getElementById("statusTextMain").textContent = "";
        } else {
            document.getElementById("statusTextMain").textContent = Translation.need_an_input;
            await wait(5000);
            document.getElementById("statusTextMain").textContent = "";
        }
    } catch (error) {
        console.error("Error sending message:", error);
    }
};

// --------------------------------------------------
// --------------------------------------------------
// --------------------------------------------------

// --------------------------------------------------
// -----    Funktion Bienenstock Reparieren     -----
// --------------------------------------------------

buttonAddHealth.addEventListener("click",function(){
    addHealth()
});

async function addHealth() {
    try {
        const response = await fetch(`https://${GetParentResourceName()}/addHealth`, {
            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({
                hiveID: hiveID,
            })
        });
        
        const data = await response.json();

        if (data.success) {
            currentBeehive = data.Data
            setStatus()
            document.getElementById("statusTextMain").textContent = Translation.health_added_successfully;
            await wait(5000);
            document.getElementById("statusTextMain").textContent = "";
        } else if (!data.success && data.type === 1) {
            document.getElementById("statusTextMain").textContent = `${Translation.health_not_low}`;
            await wait(5000);
            document.getElementById("statusTextMain").textContent = "";
        } else if (!data.success && data.type === 1) {
            document.getElementById("statusTextMain").textContent = `${Translation.no_health_item} ${config.HealItemLabel}`;
            await wait(5000);
            document.getElementById("statusTextMain").textContent = "";
        }

    } catch (error) {
        console.error("Error sending message:", error);
    }
};

// --------------------------------------------------
// --------------------------------------------------
// --------------------------------------------------

// --------------------------------------------------
// -----       Funktion Wasser geben            -----
// --------------------------------------------------

buttonAddWater.addEventListener("click",function(){
    addWater()
});

async function addWater() {
    try {
        const response = await fetch(`https://${GetParentResourceName()}/addWater`, {
            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({
                hiveID: hiveID,
            })
        });
        
        const data = await response.json();

        if (data.success) {
            currentBeehive = data.Data
            setStatus()
            document.getElementById("statusTextStatusPage").textContent = Translation.water_added_sucessfully;
            await wait(5000);
            document.getElementById("statusTextStatusPage").textContent = "";
        } else if (!data.success && data.type === 1) {
            document.getElementById("statusTextStatusPage").textContent = Translation.water_already_full;
            await wait(5000);
            document.getElementById("statusTextStatusPage").textContent = "";
        } else if (!data.success && data.type === 2) {
            document.getElementById("statusTextStatusPage").textContent = `${Translation.no_water_item} ${config.WaterItemLabel}`;
            await wait(5000);
            document.getElementById("statusTextStatusPage").textContent = "";
        }

    } catch (error) {
        console.error("Error sending message:", error);
    }
};

// --------------------------------------------------
// --------------------------------------------------
// --------------------------------------------------

// --------------------------------------------------
// -----       Funktion Essen geben             -----
// --------------------------------------------------

buttonAddFood.addEventListener("click",function(){
    addFood()
});

async function addFood() {
    try {
        const response = await fetch(`https://${GetParentResourceName()}/addFood`, {
            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({
                hiveID: hiveID,
            })
        });
        
        const data = await response.json();

        if (data.success) {
            currentBeehive = data.Data
            setStatus()
            document.getElementById("statusTextStatusPage").textContent = Translation.food_added_sucessfully;
            await wait(5000);
            document.getElementById("statusTextStatusPage").textContent = "";
        } else if (!data.success && data.type === 1) {
            document.getElementById("statusTextStatusPage").textContent = Translation.food_already_full;
            await wait(5000);
            document.getElementById("statusTextStatusPage").textContent = "";
        } else if (!data.success && data.type === 2) {
            document.getElementById("statusTextStatusPage").textContent = `${Translation.no_food_item} ${config.FoodItemLabel}`;
            await wait(5000);
            document.getElementById("statusTextStatusPage").textContent = "";
        }

    } catch (error) {
        console.error("Error sending message:", error);
    }
};

// --------------------------------------------------
// --------------------------------------------------
// --------------------------------------------------

// --------------------------------------------------
// -----    Funktion Bienenstock Reinigen       -----
// --------------------------------------------------

buttonAddClean.addEventListener("click",function(){
    addClean()
});

async function addClean() {
    try {
        const response = await fetch(`https://${GetParentResourceName()}/addClean`, {
            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({
                hiveID: hiveID,
            })
        });
        
        const data = await response.json();

        if (data.success) {
            currentBeehive = data.Data
            setStatus()
            document.getElementById("statusTextStatusPage").textContent = Translation.clean_added_sucessfully;
            await wait(5000);
            document.getElementById("statusTextStatusPage").textContent = "";
        } else if (!data.success && data.type === 1) {
            document.getElementById("statusTextStatusPage").textContent = Translation.clean_already_full;
            await wait(5000);
            document.getElementById("statusTextStatusPage").textContent = "";
        } else if (!data.success && data.type === 2) {
            document.getElementById("statusTextStatusPage").textContent = `${Translation.no_clean_item} ${config.CleanItemLabel}`;
            await wait(5000);
            document.getElementById("statusTextStatusPage").textContent = "";
        }

    } catch (error) {
        console.error("Error sending message:", error);
    }
};

// --------------------------------------------------
// --------------------------------------------------
// --------------------------------------------------

// --------------------------------------------------
// -----     Funktion Krankheit Heilen          -----
// --------------------------------------------------

buttonCureIllness.addEventListener("click",function(){
    cureIllness()
});

async function cureIllness() {
    try {
        const response = await fetch(`https://${GetParentResourceName()}/cureIllness`, {
            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({
                hiveID: hiveID,
            })
        });
        
        const data = await response.json();

        if (data.success) {
            currentBeehive = data.Data
            setStatus()
            document.getElementById("sicknessType").innerText = "";
            document.getElementById("sicknessMedizin").innerText = "";
            document.getElementById("statusTextSicknessPage").textContent = Translation.sickness_cured_successfully;
            await wait(5000);
            document.getElementById("statusTextSicknessPage").textContent = "";
        } else if (!data.success && data.type === 1) {
            document.getElementById("statusTextSicknessPage").textContent = Translation.hive_not_sick;
            await wait(5000);
            document.getElementById("statusTextSicknessPage").textContent = "";
        } else if (!data.success && data.type === 2) {
            document.getElementById("statusTextSicknessPage").textContent = `${Translation.no_cure_item} ${currentBeehive.Sickness.MedicineLabel}`;
            await wait(5000);
            document.getElementById("statusTextSicknessPage").textContent = "";
        }

    } catch (error) {
        console.error("Error sending message:", error);
    }
};

// --------------------------------------------------
// --------------------------------------------------
// --------------------------------------------------

// --------------------------------------------------
// -----     Funktion Nahe Spieler Finden       -----
// --------------------------------------------------

getCloseWorkers.addEventListener("click",function(){
    getCloseHelpers()
});

async function getCloseHelpers() {
    try {
        const response = await fetch(`https://${GetParentResourceName()}/getCloseHelpers`, {
            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({})
        });
        
        const data = await response.json();

        if (data.success) {
            document.getElementById("container-closeWorkers").innerHTML = "";
            const text = document.createElement("h3")
            text.innerText = Translation.avaible_workers

            document.getElementById("container-closeWorkers").appendChild(text);

            data.closeHelper.forEach((closeHelper, index) => {

                const button = document.createElement("button");
                button.innerText = closeHelper.helperName;

                button.addEventListener("click", function () {
                    hireHelper(closeHelper.helperSrc, closeHelper.helperCharident, closeHelper.helperName);
                });

                document.getElementById("container-closeWorkers").appendChild(button);
            })
        } else{
            document.getElementById("statusTextHelperPage").textContent = Translation.no_close_players;
            await wait(5000);
            document.getElementById("statusTextHelperPage").textContent = "";
        }

    } catch (error) {
        console.error("Error sending message:", error);
    }
};

// --------------------------------------------------
// --------------------------------------------------
// --------------------------------------------------

// --------------------------------------------------
// -----     Funktion Helfer Einstellen         -----
// --------------------------------------------------

async function hireHelper(helperSrc, helperCharident, helperName) {
    try {
        const response = await fetch(`https://${GetParentResourceName()}/hireHelper`, {
            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({
                hiveID: hiveID,
                helperSrc: helperSrc,
                helperCharident: helperCharident,
                helperName: helperName
            })
        });
        
        const data = await response.json();

        if (data.success) {
            document.getElementById("container-closeWorkers").innerHTML = "";
            document.getElementById("statusTextHelperPage").textContent = `${Translation.helper_hired} ${helperName}`;
            currentBeehive = data.Data
            setStatus()
            await wait(5000);
            document.getElementById("statusTextHelperPage").textContent = "";
        }

    } catch (error) {
        console.error("Error sending message:", error);
    }
};

// --------------------------------------------------
// --------------------------------------------------
// --------------------------------------------------

// --------------------------------------------------
// -----      Funktion Helfer Kündigen          -----
// --------------------------------------------------

buttonFireWorker.addEventListener("click",function(){
    fireHelper()
});

async function fireHelper() {
    try {
        if (currentBeehive.Helper.CharIdent > 0) {
            const response = await fetch(`https://${GetParentResourceName()}/fireHelper`, {
                method: "POST",

                headers: {
                    "Content-Type": "application/json"
                },

                body: JSON.stringify({
                    hiveID: hiveID,
                })
            });
            
            const data = await response.json();

            if (data.success) {
                currentBeehive = data.Data
                setStatus()
                document.getElementById("statusTextHelperPage").textContent = Translation.worker_fired_successfully;
                document.getElementById("currentWorkerText").innerText = Translation.current_worker_text;
                await wait(5000);
                document.getElementById("statusTextHelperPage").textContent = "";
            }
        }else{
            document.getElementById("statusTextHelperPage").textContent = Translation.no_worker_to_fire;
            await wait(5000);
            document.getElementById("statusTextHelperPage").textContent = "";
        }

    } catch (error) {
        console.error("Error sending message:", error);
    }
};

// --------------------------------------------------
// --------------------------------------------------
// --------------------------------------------------

// --------------------------------------------------
// -----      Funktion Navigationsleiste        -----
// --------------------------------------------------

navButtons.forEach(function(button) {

    button.addEventListener("click", function() {

        const page = button.dataset.page;

        if (page === "main") {
            containerMain.style.display = "flex";
            containerStatus.style.display = "none";
            containerSickness.style.display = "none";
            containerHelper.style.display = "none";
            containerSettings.style.display = "none";
            document.getElementById("container-closeWorkers").innerHTML = "";
        } else if  (page === "status"){
            containerMain.style.display = "none";
            containerStatus.style.display = "flex";
            containerSickness.style.display = "none";
            containerHelper.style.display = "none";
            containerSettings.style.display = "none";
            document.getElementById("container-closeWorkers").innerHTML = "";
        } else if  (page === "sickness"){
            containerMain.style.display = "none";
            containerStatus.style.display = "none";
            containerSickness.style.display = "flex";
            containerHelper.style.display = "none";
            containerSettings.style.display = "none";
            document.getElementById("container-closeWorkers").innerHTML = "";
        } else if  (page === "helper"){
            containerMain.style.display = "none";
            containerStatus.style.display = "none";
            containerSickness.style.display = "none";
            containerHelper.style.display = "flex";
            containerSettings.style.display = "none";
            document.getElementById("container-closeWorkers").innerHTML = "";
        } else if  (page === "settings"){
            containerMain.style.display = "none";
            containerStatus.style.display = "none";
            containerSickness.style.display = "none";
            containerHelper.style.display = "none";
            containerSettings.style.display = "flex";
            document.getElementById("container-closeWorkers").innerHTML = "";
        }

    });

});

// --------------------------------------------------
// --------------------------------------------------
// --------------------------------------------------

// --------------------------------------------------
// -----      Funktion Ausrichtung Ändern       -----
// --------------------------------------------------

settingButtons.forEach(function(button) {

    button.addEventListener("click", function() {
        const valueButton = button.dataset.valuebutton;
        if (valueButton === "setXPlus"){
            coordsX = currentBeehive.Coords.x
            coordsY = currentBeehive.Coords.y
            coordsZ = currentBeehive.Coords.z
            coordsH = currentBeehive.Coords.heading
            intensity = Number(document.getElementById("changePositionIntensity").value)
            if (intensity >= 0.1 && intensity <= Number(config.maxMovementIntensity)) {
                coordsX = Number(coordsX) + intensity
                changePosition(coordsX,coordsY,coordsZ,coordsH)
            }else if (intensity <= 0){
                setText(Translation.no_intesity_set)
            }else if (intensity > Number(config.maxMovementIntensity)){
                setText(`${Translation.max_intesity_reached} ${config.maxMovementIntensity}`)
            }
        }else if  (valueButton === "setXMinus"){
            coordsX = currentBeehive.Coords.x
            coordsY = currentBeehive.Coords.y
            coordsZ = currentBeehive.Coords.z
            coordsH = currentBeehive.Coords.heading
            intensity = Number(document.getElementById("changePositionIntensity").value)
            if (intensity >= 0.1 && intensity <= Number(config.maxMovementIntensity)) {
                coordsX = Number(coordsX) - intensity
                changePosition(coordsX,coordsY,coordsZ,coordsH)
            }else if (intensity <= 0){
                setText(Translation.no_intesity_set)
            }else if (intensity > Number(config.maxMovementIntensity)){
                setText(`${Translation.max_intesity_reached} ${config.maxMovementIntensity}`)
            }
        } else if  (valueButton === "setYPlus"){
            coordsX = currentBeehive.Coords.x
            coordsY = currentBeehive.Coords.y
            coordsZ = currentBeehive.Coords.z
            coordsH = currentBeehive.Coords.heading
            intensity = Number(document.getElementById("changePositionIntensity").value)
            if (intensity >= 0.1 && intensity <= Number(config.maxMovementIntensity)) {
                coordsY = Number(coordsY) + intensity
                changePosition(coordsX,coordsY,coordsZ,coordsH)
            }else if (intensity <= 0){
                setText(Translation.no_intesity_set)
            }else if (intensity > Number(config.maxMovementIntensity)){
                setText(`${Translation.max_intesity_reached} ${config.maxMovementIntensity}`)
            }
        } else if  (valueButton === "setYMinus"){
            coordsX = currentBeehive.Coords.x
            coordsY = currentBeehive.Coords.y
            coordsZ = currentBeehive.Coords.z
            coordsH = currentBeehive.Coords.heading
            intensity = Number(document.getElementById("changePositionIntensity").value)
            if (intensity >= 0.1 && intensity <= Number(config.maxMovementIntensity)) {
                coordsY = Number(coordsY) - intensity
                changePosition(coordsX,coordsY,coordsZ,coordsH)
            }else if (intensity <= 0){
                setText(Translation.no_intesity_set)
            }else if (intensity > Number(config.maxMovementIntensity)){
                setText(`${Translation.max_intesity_reached} ${config.maxMovementIntensity}`)
            }
        } else if  (valueButton === "setZPlus"){
            coordsX = currentBeehive.Coords.x
            coordsY = currentBeehive.Coords.y
            coordsZ = currentBeehive.Coords.z
            coordsH = currentBeehive.Coords.heading
            intensity = Number(document.getElementById("changePositionIntensity").value)
            if (intensity >= 0.1 && intensity <= Number(config.maxMovementIntensity)) {
                coordsZ = Number(coordsZ) + intensity
                changePosition(coordsX,coordsY,coordsZ,coordsH)
            }else if (intensity <= 0){
                setText(Translation.no_intesity_set)
            }else if (intensity > Number(config.maxMovementIntensity)){
                setText(`${Translation.max_intesity_reached} ${config.maxMovementIntensity}`)
            }
        } else if  (valueButton === "setZMinus"){
            coordsX = currentBeehive.Coords.x
            coordsY = currentBeehive.Coords.y
            coordsZ = currentBeehive.Coords.z
            coordsH = currentBeehive.Coords.heading
            intensity = Number(document.getElementById("changePositionIntensity").value)
            if (intensity >= 0.1 && intensity <= Number(config.maxMovementIntensity)) {
                coordsZ = Number(coordsZ) - intensity
                changePosition(coordsX,coordsY,coordsZ,coordsH)
            }else if (intensity <= 0){
                setText(Translation.no_intesity_set)
            }else if (intensity > Number(config.maxMovementIntensity)){
                setText(`${Translation.max_intesity_reached} ${config.maxMovementIntensity}`)
            }
        } else if  (valueButton === "setHPlus"){
            coordsX = currentBeehive.Coords.x
            coordsY = currentBeehive.Coords.y
            coordsZ = currentBeehive.Coords.z
            coordsH = currentBeehive.Coords.heading
            intensity = Number(document.getElementById("changePositionIntensity").value)
            if (intensity >= 0.1 && intensity <= Number(config.maxMovementIntensity)) {
                coordsH = Number(coordsH) + intensity
                changePosition(coordsX,coordsY,coordsZ,coordsH)
            }else if (intensity <= 0){
                setText(Translation.no_intesity_set)
            }else if (intensity > Number(config.maxMovementIntensity)){
                setText(`${Translation.max_intesity_reached} ${config.maxMovementIntensity}`)
            }
        } else if  (valueButton === "setHMinus"){
            coordsX = currentBeehive.Coords.x
            coordsY = currentBeehive.Coords.y
            coordsZ = currentBeehive.Coords.z
            coordsH = currentBeehive.Coords.heading
            intensity = Number(document.getElementById("changePositionIntensity").value)
            if (intensity >= 0.1 && intensity <= Number(config.maxMovementIntensity)) {
                coordsH = Number(coordsH) - intensity
                changePosition(coordsX,coordsY,coordsZ,coordsH)
            }else if (intensity <= 0){
                setText(Translation.no_intesity_set)
            }else if (intensity > Number(config.maxMovementIntensity)){
                setText(`${Translation.max_intesity_reached} ${config.maxMovementIntensity}`)
            }
        }

    });

});

async function setText(text) {
    document.getElementById("statusTextSettingsPage").textContent = text;
    await wait(5000);
    document.getElementById("statusTextSettingsPage").textContent = "";
}

buttonResetPosition.addEventListener("click",function(){
    changePosition(oldHivePosition.coordsX,oldHivePosition.coordsY,oldHivePosition.coordsZ,oldHivePosition.coordsH)
});

// --------------------------------------------------
// --------------------------------------------------
// --------------------------------------------------

async function changePosition(coordsX,coordsY,coordsZ,coordsH) {
    try {
        const response = await fetch(`https://${GetParentResourceName()}/changePosition`, {
            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({
                hiveID: hiveID,
                coordsX: coordsX,
                coordsY: coordsY,
                coordsZ: coordsZ,
                coordsH: coordsH,
            })
        });
            
        const data = await response.json();

        if (data.success) {
            currentBeehive = data.Data
            setStatus()
            document.getElementById("statusTextSettingsPage").textContent = Translation.new_value_set;
            await wait(1000);
            document.getElementById("statusTextSettingsPage").textContent = "";
        }
        
    } catch (error) {
        console.error("Error sending message:", error);
    }
};

// --------------------------------------------------
// --------------------------------------------------
// --------------------------------------------------

document.addEventListener("keydown", (event) => {

    if (event.key === "Escape") {
        closeMenu();
    }
});

async function closeMenu() {
    try {
        const response = await fetch(`https://${GetParentResourceName()}/close`, {
            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({})
        });
        
        const data = await response.json()

        containerMain.style.display = "none";
        containerStatus.style.display = "none";
        containerSickness.style.display = "none";
        containerHelper.style.display = "none";
        containerSettings.style.display = "none";

    } catch (error) {
        console.error("Error sending message:", error);
    }
};

// Wait Function
function wait(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
};

window.addEventListener("message", function (event) {

    const data = event.data;

    if (data.action === "open") {
        currentBeehive = data.currentHive;
        config = data.config;
        hiveID = data.hiveID;
        setStatus()
        document.body.style.display = "flex";
        containerMain.style.display = "flex";
        setOldCoords()
    }

    if (data.action === "updateNUI") {
        currentBeehive = data.currentHive;
        setStatus()
    }

    if (data.action === "close") {
        document.body.style.display = "none";
    }
});