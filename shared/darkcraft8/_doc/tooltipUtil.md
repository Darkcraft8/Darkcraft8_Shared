### D8Tooltip

---

Add a new function table "D8Tooltip" comprised of function to prepare or help using tooltip.</br>
path : "/shared/darkcraft8/d8ToolTipUtil/tooltips.lua"
</br></br>

---

#### **'Void' D8Tooltip.init()**

Prepare any needed scripts config... currently only serve to</br>
add the label widget used to get the size of string's.

---

#### **'Tooltip' D8Tooltip.text(`String` tooltipText)**

Prepare and Return a text tooltip, unlike the vanilla version this one will take into account lineBreak and wrapWidth, it will resize itself accordingly.

---

#### **'Tooltip' D8Tooltip.itemList(`Table` itemList, `Json` override)**

Prepare and Return a tooltip that mimic the appearance of the ingredients tooltip of the crafting panes,</br>
vanillaBasedItemList still work for compatibility reason.

---

#### **'nil' D8Tooltip.scriptedItemList(`Table` itemList, `Vec2U` mousePosition, `Json` override, `Json` backgroundImage)**

Prepare and open a scripted pane that mimic the ingredients tooltip of the crafting panes.

---

#### **'nil' D8Tooltip.prepareScriptedTooltip(<`ScriptPaneConfig` json or `String` absolute path>, `Vec2U` mousePosition)**

Prepare the coroutine for the openning of the scripted Tooltip Pane,</br>
also tell the script that there is already a scriptedTooltip open

---
