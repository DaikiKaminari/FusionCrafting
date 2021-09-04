-- [V0.3-BETA]
--- CONFIG & GLOBAL VARIABLES ---
local inventory -- inventory API

-- the item that is in the first slot of the input container to indicate it's an upgrade kit
local upgradeFakeItem = "item.tconstruct.materials.necrotic_bone"

-- where the items are provided by ME interfaces (blocking mode)
local inputContainer
local inputContainerName = "bottom"
local inputContainerCoreContainer = "west"
local inputContainerInjectorContainer = "east"

-- where the desired upgrade is placed (can actually be any type of container)
local pedestalUpgrade
local pedestalUpgradeName = "thaumcraft:tilepedestal_4"
local pedestalUpgradeInjectorContainer = "down"

-- where core item will be before being sent in the core (an enderchest is good for this purpose)
local coreContainer
local coreContainerName = "minecraft:ender chest_2"
local coreContainerCore = "up"
local coreContainerAE = "south"
local coreContainerPedestalStuff = "north"

-- where renamed items are stored to validate the AE craft
local kitContainer
local kitContainerName = "thermalexpansion:storage_strongbox_1"
local kitContainerAE = "up"

--- INIT ---
local function init()
    inventory = require("inventory")
    inputContainer = assert(peripheral.wrap(inputContainerName), "Input container cannot be found.")
    coreContainer = assert(peripheral.wrap(coreContainerName), "Core container cannot be found.")
    pedestalUpgrade = assert(peripheral.wrap(pedestalUpgradeName), "Pedestal upgrade cannot be found.")
    kitContainer = assert(peripheral.wrap(kitContainerName), "Kit container cannot be found.")
    local monitor = peripheral.find("monitor")
    term.clear()
    if monitor then
        term.redirect(monitor)
        term.clear()
        term.setCursorPos(1, 1)
    else
        print("Warning : no monitor found.")
    end
end

--- METHODS ---
-- Returns true if both pedestals contains items (a stuff and an upgrade)
local function isUpgrade()
    return inputContainer.getItemMeta(1)["rawName"] == upgradeFakeItem
end

local function coreItems(isUpgrade)
    inputContainer.pushItems(inputContainerCoreContainer, 1) -- input container -> core container
    if isUpgrade then
        coreContainer.pushItems(coreContainerAE, 1) -- core container -> AE
        local timeout = 0
        while coreContainer.pullItems(coreContainerPedestalStuff, 1) == 0 do -- pedestal stuff -> core container
            print("Missing stuff on the pedestal.")
            timeout = timeout + 1
            if timeout > 20 then
                return false
            end
            sleep(1)
        end
        inventory.pushItemsFromAllSlots(kitContainer, kitContainerAE) -- kit container -> AE
    end
    coreContainer.pushItems(coreContainerCore, 1) -- core container -> core
    return true
end

local function injectorItems(isUpgrade)
    if isUpgrade then
        pedestalUpgrade.pushItems(pedestalUpgradeInjectorContainer, 1) -- pedestal upgrade -> injector container
    end
    inventory.pushItemsFromAllSlots(inputContainer, inputContainerInjectorContainer) -- input container -> injector container
    sleep(2) -- injector container to injectors by ducts
    return true
end

local function endProcess(isUpgrade)
    local timeout = 0
    while coreContainer.pullItems(coreContainerCore, 2) == 0 do -- core -> core container
        timeout = timeout + 1
        if timeout > 10 then
            return false
        end
        sleep(1)
    end
    if isUpgrade then
        coreContainer.pushItems(coreContainerPedestalStuff, 1) -- core container -> pedestal stuff
        local timeout = 0
        while pedestalUpgrade.pullItems(pedestalUpgradeInjectorContainer, 1) == 0 do -- injector container -> pedestal upgrade
            timeout = timeout + 1
            if timeout > 5 then
                return false
            end
        end
    else
        coreContainer.pushItems(coreContainerAE, 1) -- core container -> AE
    end
    return true
end

local function process(isUpgrade)
    local timeout = 0
    while isUpgrade and not next(pedestalUpgrade.list()) do -- waits an upgrade is provided
        print("Missing upgrade on the pedestal.")
        timeout = timeout + 1
        if timeout > 20 then
            return false
        end
        sleep(1)
    end
    if not coreItems(isUpgrade) then return false end
    if not injectorItems(isUpgrade) then return false end
    return endProcess(isUpgrade) 
end


--- MAIN ---
local function main()
    init()
    while true do
        if next(inputContainer.list()) then
            print("Start craft...")
            if process(isUpgrade()) then
                print("Craft finished.")
            else
                print("Craft canceled : timeout.")
            end
            print()
        end
        sleep(1)
    end
end

main()