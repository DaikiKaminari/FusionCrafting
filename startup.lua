--- CONFIG & GLOBAL VARIABLES ---
local inventory -- inventory API

--local redstoneInputSide = "right"

local inputContainer
local inputContainerName = "bottom"
local inputContainerCoreContainer = "west"
local inputContainerInjectorContainer = "east"

local pedestalUpgrade
local pedestalUpgradeName = "thaumcraft:tilepedestal_4"
local pedestalUpgradeInjectorContainer = "down"

local coreContainer
local coreContainerName = "minecraft:ender chest_2"
local coreContainerCore = "up"
local coreContainerAE = "south"
local coreContainerPedestalStuff = "north"

--- INIT ---
local function init()
    inventory = require("inventory")
    inputContainer = assert(peripheral.wrap(inputContainerName), "Input container cannot be found.")
    coreContainer = assert(peripheral.wrap(coreContainerName), "Core container cannot be found.")
    pedestalUpgrade = assert(peripheral.wrap(pedestalUpgradeName), "Pedestal upgrade cannot be found.")
end

--- METHODS ---
-- Returns true if both pedestals contains items (a stuff and an upgrade)
local function isUpgrade()
    if pedestalUpgrade.getItem(1) then
        return true
    end
    return false
end

local function coreItems(isUpgrade)
    inputContainer.pushItems(inputContainerCoreContainer, 1) -- input container -> core container
    if isUpgrade then
        coreContainer.pushItems(coreContainerAE, 1) -- core container -> AE
        coreContainer.pullItems(coreContainerPedestalStuff, 1) -- pedestal -> core container
    end
    coreContainer.pushItems(coreContainerCore, 1) -- core container -> core
end

local function injectorItems(isUpgrade)
    if isUpgrade then
        coreContainer.pullItems(coreContainerPedestalStuff, 1) -- pedestal stuff -> core container
        pedestalUpgrade.pushItems(pedestalUpgradeInjectorContainer, 1) -- pedestal upgrade -> injector container
    end
    inventory.pushItemsFromAllSlots(inputContainer, inputContainerInjectorContainer) -- input container -> injector container
    sleep(2) -- injector container to injectors by ducts
end

local function endProcess(isUpgrade)
    local timetout = 0
    while coreContainer.pullItems(coreContainerCore, 2) == 0 do -- core -> core container
        timeout = timeout + 1
        if timeout > 10 then
            return false
        end
        sleep(1)
    end
    if isUpgrade then
        coreContainer.pushItems(coreContainerPedestalStuff, 1) -- core container -> pedestal stuff
        sleep(1)
        pedestalUpgrade.pullItems(pedestalUpgradeInjectorContainer, 1) -- injector container -> pedestal upgrade
    else
        coreContainer.pushItems(coreContainerAE, 1) -- core container -> AE
    end
    return true
end

local function process(isUpgrade)
    coreItems(isUpgrade)
    injectorItems(isUpgrade)
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