### Item Utils

---
</br>
Add new functions to the `item` table to help with finding parameters or config value,</br>
can be more precise than config.getParameter when used well
</br></br>
path : "/shared/darkcraft8/util/item.lua"
</br></br>

---

#### **`Void` D8Shared_BuildItemFunction()**

Build the functions of the script, might need to be called from the init function if loaded before

---

#### **`Value` root.getItemParameter(`String or itemDescriptor` itemDescriptorOrName, `String` variable, `Value` defaultValue)**

**If used in buildScripts it will cause an exception**
Return the value of the variable from the parameters of the given item,</br> will return nil otherwise

---

#### **`Value` root.getItemConfig(`String or itemDescriptor` itemDescriptorOrName, `String` variable, `Value` defaultValue)**

**If used in buildScripts it will cause an exception**
Return the value of the variable from the config of the given item,</br> will return nil otherwise

---

#### **`Value` root.getItemVariable(`String or itemDescriptor` itemDescriptorOrName, `String` variable, `Value` defaultValue)**

**If used in buildScripts it will cause an exception**
Return the value of the variable from either the parameters or config of the given item,</br> will return nil otherwise

---

#### **`Value` item.getItemParameter(`String` variable, `Value` defaultValue)**

Return the value of the variable from the parameters of the current item,</br> will return nil otherwise

---

#### **`Value` item.getItemConfig(`String` variable, `Value` defaultValue)**

Return the value of the variable from the config of the current item,</br> will return nil otherwise

---

#### **`Value` item.getItemVariable(`String` variable, `value` defaultValue)**

Return the value of the variable from either the parameters or config of the current item,</br> will return nil otherwise

---