These are files that i use in multiple mods...
include : 
External Crafting Pane Selector for object
Intelligent Interaction for object (not very configurable)

#Intelligent Interaction :
-- if given a convertionList(name or descriptor) the script will search for each listed item in the player inventory and convert them to d8Conversion_<itemName>...
  currently doesn't support descriptor
-- able to be given an interactOverride (meant to be used in conjunction of the External Crafting Pane Selector)

#External Crafting Pane Selector :
-- A list that get populated with button that allow to select a crafting pane to be opened...
  if opened through an object with the Intell... Interact... script both the pane selector and the crafting panes will close if the player is too far away from the object
