-- [V1.2]
local inventory = {}

-- returns true if fields from item1 are contained in item2
local function compareItems(item1, item2, ignoreQty)
    for k,v in pairs(item1) do
        if type(v) ~= type(item2[k]) then
            return false
        end
        if type(v) == "table" then
          if not compareItems(v, item2[k], ignoreQty) then
            return false
          end
        else
          if (not ignoreQty and v ~= item2[k]) or (k ~= "qty" and v ~= item2[k]) then
            return false
          end
        end
    end
    return true
end
inventory.compareItems = compareItems

-- returns true if two items are identical
local function isItemIdentical(item1, item2, ignoreQty)
    if not item1 then
        error("First item cannot be nil.")
    end
    if not item2 then
        error("Second item cannot be nil")
    end
    return inventory.compareItems(item1, item2, ignoreQty) and inventory.compareItems(item2, item1, ignoreQty)
end
inventory.isItemIdentical = isItemIdentical

-- returns true if the item is contained in a list
local function isItemInList(item1, itemList, ignoreQty)
    for k,item2 in pairs(itemList) do
        if inventory.isItemIdentical(item1, item2, ignoreQty) then
            return k
        end
    end
    return false
end
inventory.isItemInList = isItemInList

-- returns true if the two lists contains the same items
local function isItemListIdentical(items1, items2, ignoreQty)
    for _,item1 in pairs(items1) do
        if not inventory.isItemInList(item1, items2, ignoreQty) then
            return false
        end
    end
    for _,item2 in pairs(items2) do
        if not inventory.isItemInList(item2, items1, ignoreQty) then
            return false
        end
    end
    return true
end
inventory.isItemListIdentical = isItemListIdentical

-- move the items from all slots of a container to another and returning the quantity of items moved
-- the quantity and arrival slot id can be specified
local function pushItemsFromAllSlots(container, direction, quantity, toSlot)
    local n = 0
    for i=1,container.size() do
        n = n + container.pushItems(direction, i, quantity, toSlot)
    end
    return n
end
inventory.pushItemsFromAllSlots = pushItemsFromAllSlots

return inventory