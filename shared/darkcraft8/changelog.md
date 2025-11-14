### 1.2.0

#### Tooltip Util
- renamed `vanillaBasedItemList` to `itemList` and enhanced the tooltip creation system, it should now look almost identical to the crafting pane ingredient tooltip


#### Canvas Util
- (base.lua) `setCanvas` can now differentiate between `string` and `userdata`

- (draw.lua) fixed issues resulting in `canvas.isVisible` causing erroneus detection of if the position/image is out of bound that caused some issue such as particles thinking they nocliped outside their reality

- (logic.lua) added the named parameter `doCallbackWhenDisabled`

- (logic.lua) made some change with disabled canvas btn logic

- (logic.lua) added simulateMouseClickDetection, experimental handling of click for the `interface.bindRegisteredPane` function added by openStarbound

- (logic.lua) `bindCanvas` can be given a canvasUserData as a third argument

- (logic.lua) the btn can now be scaled