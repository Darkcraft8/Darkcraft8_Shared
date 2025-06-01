### Inventory Utils

---

**Require access to the `player` function Table and [openStarbound][oSbLink] or a [fork][oSbLinkFork]**


Add the `inventory` functions table to help with reading the players inventory,</br>
usefull for panes that need to check a player full inventory such as a crafting pane.</br></br>
path : "/shared/darkcraft8/util/inventory.lua"
</br></br>

---

#### **inventory.normalize()**

Return a array containing two arrays</br>
`soft` contain the number of item by their `itemName`</br>
`exact` contain the number of item by their `itemName` and `parameters`.

---

#### **inventory.hasItem(itemDescriptorOrName, exactMatch)**

Return true and the count of the requested item in the player inventory,</br> this count is divided by the itemDescriptor count(default to 1 if count isn't present in the descriptor),</br></br>
will check for items that have both the same `itemName` and `parameters` has the itemDescriptor given if exactMatch is true</br></br>
return false if there is no such item.

---

[oSbLink]: <https://github.com/OpenStarbound/OpenStarbound> 'click here to access openStarbound Repository'
[oSbLinkFork]: <https://github.com/OpenStarbound/OpenStarbound/forks> 'click here to access a list of openStarbound Forks'