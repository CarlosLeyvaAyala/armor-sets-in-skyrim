Scriptname DM_ArmorSets_SpellScript extends ActiveMagicEffect
;Import UIListMenu
DM_ArmorSets_Core Property Core Auto

int FMainMenuLength

string property FLogName = "Armor Sets in Skyrim" AutoReadOnly
UIListMenu FMainMenu
UIListMenu FCategoryMenu
UIWheelMenu FArmorSetMenu

Actor player

Event OnEffectStart(Actor akTarget, Actor akCaster)
    Debug.OpenUserLog(FLogName)
    If Core.GetState() == "Busy"
        ;Debug.MessageBox("Te la pelaste")
        Debug.TraceUser(FLogName, "Trying to use spell while in Busy state. TE LA PELASTE.", 1)
        Dispel()
        Return
    EndIf
    Core.GotoState("Busy")
    player = Game.GetPlayer()
    ResetMenus()
    ExecuteMainMenu()
    Core.GotoState("")
EndEvent

Function ResetMenus()
    FMainMenu.ResetMenu()
    FCategoryMenu.ResetMenu()
    FArmorSetMenu.ResetMenu()
    FMainMenuLength = 0
EndFunction

Function ExecuteMainMenu()
    int selectedOption = GetMainMenu()
    ExecuteMainMenuInput(selectedOption)
    ResetMenus()
    Dispel()
EndFunction

; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
int Function GetMainMenu()
    FMainMenu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
    PopulateMainMenu()
    FMainMenu.OpenMenu()
    Return FMainMenu.GetResultInt()
EndFunction

Function PopulateMainMenu()
    If Core.MostUsedNum > 0
        Debug.Notification("Getting most used armor sets. Please wait...")
        Core.FindTopMostSets()
        PopulateArmorSets(FMainMenu, False, "$Armor Set: {", "}")
    EndIf
    PopulateCategories(FMainMenu)
EndFunction

Function PopulateArmorSets(UIListMenu aMenu, bool aAllowZeroUsage = True, string aPrefix = "", string aSuffix = "")
    int i = 0
    While i < Core.SortedArmorNamesNum
        If !aAllowZeroUsage
            If !HasBeenUsed(i)
                Return          ; We know items are sorted by usage. Return at first 0 found.
            EndIf
        EndIf
        aMenu.AddEntryItem(aPrefix + Core.GetSortedName(i) + aSuffix)
        i += 1
        FMainMenuLength += 1
    EndWhile
EndFunction

bool Function HasBeenUsed(int idx)
    Return Core.GetSortedUsage(idx) > 0
EndFunction

Function PopulateCategories(UIListMenu aMenu)
    int i = 0
    int category
    While i < Core.MaxCategories
        category = aMenu.AddEntryItem(Core.ArmorSetCategories[i])
        aMenu.SetPropertyIndexBool("hasChildren", category, True)
        i += 1
        FMainMenuLength += 1
    EndWhile
EndFunction

; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
Function ExecuteMainMenuInput(int aMenuIndex)
    If aMenuIndex < 0
        Return
    ElseIf ClickedOnCategory(aMenuIndex, FMainMenuLength)
        ExecuteCategoryMenu(GetMainMenuClickedCategory(aMenuIndex, FMainMenuLength))
    Else
        ExecuteArmorSetMenu(Core.GetSortedIndex(aMenuIndex))
    EndIf
EndFunction

bool Function ClickedOnCategory(int aMenuIndex, int aMenuLength)
    Return GetMainMenuClickedCategory(aMenuIndex, aMenuLength) >= 0
EndFunction

int Function GetMainMenuClickedCategory(int aMenuIndex, int aMenuLength)
    Return aMenuIndex - (aMenuLength - Core.MaxCategories)
EndFunction


; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
Function ExecuteCategoryMenu(int aCategoryIndex)
    FCategoryMenu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
    Core.FindSetsByCategory(aCategoryIndex)
    PopulateArmorSets(FCategoryMenu)
    FCategoryMenu.OpenMenu()
    int idx = FCategoryMenu.GetResultInt()
    If idx < 0 
        Return
    EndIf
    ExecuteArmorSetMenu( Core.GetSortedIndex(idx) ) 
EndFunction

; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
Function ExecuteArmorSetMenu(int aArmorSetIndex)
    FArmorSetMenu = UIExtensions.GetMenu("UIWheelMenu") as UIWheelMenu
    PopulateArmorSetMenu(aArmorSetIndex)
    int selectedItem = FArmorSetMenu.OpenMenu()
    If selectedItem < 0
        Return
    EndIf
    ExecuteArmorSetMenuInput(aArmorSetIndex, selectedItem)
EndFunction

Function ExecuteArmorSetMenuInput(int aArmorSetIndex, int aInput)
    If aInput == asEquip
        ArmorSetEquipExecute(aArmorSetIndex)
    ElseIf aInput == asSaveAr
        ArmorSetStoreExecute(aArmorSetIndex)
    ElseIf aInput == asSaveWpAr
        ArmorSetStoreWeaponExecute(aArmorSetIndex)
    ElseIf aInput == asRename
        ArmorSetRenameExecute(aArmorSetIndex)
    ElseIf aInput == asClear
        ArmorSetClearExecute(aArmorSetIndex)
    ElseIf aInput == asEmpty
        ArmorSetEmptyExecute(aArmorSetIndex)
    EndIf
EndFunction

int Property asName = 0 AutoReadOnly   
int Property asName2 = 4 AutoReadOnly   
int Property asEquip = 1 AutoReadOnly
int Property asSaveAr = 5 AutoReadOnly
int Property asSaveWpAr = 6 AutoReadOnly
int Property asRename = 2 AutoReadOnly
int Property asClear = 3 AutoReadOnly
int Property asEmpty = 7 AutoReadOnly

Function PopulateArmorSetMenu(int aArmorSetIndex)
    string name = Core.NameAtIndex(aArmorSetIndex)
    bool exists = !Core.ArmorSetIsEmpty(aArmorSetIndex)
    PopulateArmorSetMenuOption(asName, name, "", False, 0xDAA520, False)
    PopulateArmorSetMenuOption(asName2, name, "", False, 0xDAA520, False)
    PopulateArmorSetMenuOption(asEquip, "$Equip", "", exists)
    PopulateArmorSetMenuOption(asSaveAr, "$StoreAr", "$StoreArInfo", !exists)
    PopulateArmorSetMenuOption(asSaveWpAr, "$StoreWpAr", "$StoreWpArInfo", !exists)
    PopulateArmorSetMenuOption(asRename, "$Rename")
    PopulateArmorSetMenuOption(asClear, "$Clear", "$ClearInfo")
    PopulateArmorSetMenuOption(asEmpty, "$Empty", "$EmptyInfo", exists)
EndFunction

Function PopulateArmorSetMenuOption(int idx, string label, string text = "", bool enabled = True, int color = 0xFFFFFF, bool disabledColor = True)
    If disabledColor && !enabled
        color = 0x454545
    EndIf
    FArmorSetMenu.SetPropertyIndexString("optionText", idx, text)
    FArmorSetMenu.SetPropertyIndexString("optionLabelText", idx, label)
    FArmorSetMenu.SetPropertyIndexBool("optionEnabled", idx, enabled)
    FArmorSetMenu.SetPropertyIndexInt("optionTextColor", idx, color)
EndFunction


; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
bool Function ArmorSetEmptyExecute(int aArmorSetIndex)
    Debug.TraceUser(FLogName, "Empty armor set (" + Core.NameAtIndex(aArmorSetIndex) + ", " + aArmorSetIndex + ")")
    ObjectReference aContainer = Core.ContainerAtIndex(aArmorSetIndex)
    int i = aContainer.GetNumItems()
    While i > 0
        RemoveFirstItemFromContainer(aContainer)
        i -= 1
    EndWhile    
    Return True
EndFunction

; ========================================
bool Function ArmorSetClearExecute(int aArmorSetIndex)
    Debug.TraceUser(FLogName, "Clear armor set (" + Core.NameAtIndex(aArmorSetIndex) + ", " + aArmorSetIndex + ")")
    ArmorSetEmptyExecute(aArmorSetIndex)
    If Core.CurrentArmorSet.ArmorSetId == aArmorSetIndex
        Core.CurrentArmorSet.Reset()
    EndIf
    Core.ClearUsage(aArmorSetIndex)
    Core.ClearName(aArmorSetIndex)
    Return True
EndFunction

; ========================================
bool Function ArmorSetEquipExecute(int aArmorSetIndex)
    Debug.TraceUser(FLogName, "Equip armor set (" + Core.NameAtIndex(aArmorSetIndex) + ", " + aArmorSetIndex + ")")
    If Core.ArmorSetIsEmpty(aArmorSetIndex)
        Debug.TraceUser(FLogName, "Armor set equip. Armor Set is empty (" + Core.NameAtIndex(aArmorSetIndex) + ", " + aArmorSetIndex + ")", 1)
        Debug.MessageBox("$ArmorSetEmpty{" + Core.NameAtIndex(aArmorSetIndex) + "}")
        Return False
    EndIf
    ArmorSwap()
    ArmorSetEquip( Core.ContainerAtIndex(aArmorSetIndex) )
    Core.CurrentArmorSet.ArmorSetId = aArmorSetIndex
    Core.UsagePlusOne(aArmorSetIndex)
    Return True
EndFunction

Function ArmorSwap()
    If Core.CurrentArmorSet.IsEmpty()
        Debug.TraceUser(FLogName, "Armor swap. No known Armor Set equipped. Skip.")
        Return
    EndIf
    SwapItems()
    Core.CurrentArmorSet.Reset()
EndFunction

Function SwapItems()
    int n = Core.CurrentArmorSet.Armors.GetSize()
    ObjectReference aContainer = Core.ContainerAtIndex(Core.CurrentArmorSet.ArmorSetId)
    Debug.TraceUser(FLogName, "Swapping items...")
    While n > 0
        n -= 1
        SwapItem(n, aContainer)
    EndWhile
EndFunction

Function SwapItem(int n, ObjectReference aContainer)
    Form item = Core.CurrentArmorSet.Armors.GetAt(n)
    If player.GetItemCount(item) > 0
        player.RemoveItem(item, 1, True, aContainer)
    EndIf
    Debug.TraceUser(FLogName, "Swapping item: " + item.GetName())
EndFunction

Function ArmorSetEquip(ObjectReference aContainer)
    Debug.TraceUser(FLogName, "Equipping items...")
    int i = aContainer.GetNumItems()
    While i > 0
        Core.CurrentArmorSet.Armors.AddForm( ArmorSetEquipItem(aContainer) )
        i -= 1
    EndWhile    
EndFunction

Form Function ArmorSetEquipItem(ObjectReference aContainer)
    Form item = RemoveFirstItemFromContainer(aContainer)
    Debug.TraceUser(FLogName, "Equip Item: " + item.GetName())
    player.EquipItem(item, False, True)
    Return item
EndFunction

Form Function RemoveFirstItemFromContainer(ObjectReference aContainer)
    Form item = aContainer.GetNthForm(0)
    aContainer.RemoveItem(item, 1, True, player as ObjectReference)
    Debug.TraceUser(FLogName, "Returning item to player: " + item.getName())
    Return item
EndFunction

; ========================================
bool Function ArmorSetStoreExecute(int aArmorSetIndex)
    If !Core.ArmorSetIsEmpty(aArmorSetIndex)
        Debug.MessageBox("$ArmorSetNotEmpty{" + Core.NameAtIndex(aArmorSetIndex) + "}")
        Return False
    EndIf
    If !ArmorSetRenameIfDefault(aArmorSetIndex)
        Return False
    EndIf
    Debug.TraceUser(FLogName, "Storing armor set: " + Core.NameAtIndex(aArmorSetIndex) + "(" + aArmorSetIndex + ")")
    ArmorSetStore( Core.ContainerAtIndex(aArmorSetIndex) )
    Core.UsagePlusOne(aArmorSetIndex)
    Core.CurrentArmorSet.Reset()
    Return True
EndFunction

bool Function ArmorSetRenameIfDefault(int aArmorSetIndex)
    If Core.NameAtIndex(aArmorSetIndex) == "$-Empty-"
       Return ArmorSetRename(aArmorSetIndex)
    EndIf
    Return True
EndFunction

bool Function ArmorSetStoreWeaponExecute(int aArmorSetIndex)
    If ArmorSetStoreExecute(aArmorSetIndex)
        Debug.TraceUser(FLogName, "Storing weapons and armor")
        ArmorSetStoreWeapons( Core.ContainerAtIndex(aArmorSetIndex) )
        Return True
    EndIf
    Return False
EndFunction

Function ArmorSetStore(ObjectReference aContainer)
    int slot = 0x00000001
    While (slot <= 0x40000000)
        ArmorSetSaveSlot(slot, aContainer)
        slot *= 2
    EndWhile
EndFunction

Function ArmorSetSaveSlot(int slot, ObjectReference aContainer)
    Armor wornArmor = player.GetWornForm(slot) as Armor
    string armorName = wornArmor.GetName()              ; Don't save unnamed items
    If wornArmor && armorName
        player.RemoveItem(wornArmor as Form, 1, True, aContainer)
        Debug.TraceUser(FLogName, "Storing Armor: " + armorName)
    EndIf
EndFunction

Function ArmorSetStoreWeapons(ObjectReference aContainer)
    int hand = 0
    While hand <= 1
        Form equippedItem = player.GetEquippedObject(hand)
        string weaponName = equippedItem.GetName()
        If (equippedItem as Weapon) && weaponName
            Debug.TraceUser(FLogName, "Storing weapon: " + weaponName)
            player.RemoveItem(equippedItem, 1, True, aContainer)
        ; Keep this for maybe future use
        ;ElseIf !EquippedItem
        ;   ; Nothing
        ;ElseIf 
        ;   ; Object
        EndIf
        hand += 1
    EndWhile
EndFunction

; ========================================
bool Function ArmorSetRenameExecute(int aArmorSetIndex)
    If ArmorSetRename(aArmorSetIndex)
        ExecuteArmorSetMenu(aArmorSetIndex) ; Open armor set menu again
        Return True
    EndIf
    Return False
EndFunction

bool Function ArmorSetRename(int aArmorSetIndex)
    UIExtensions.OpenMenu("UITextEntryMenu")
    string newName = UIExtensions.GetMenuResultString("UITextEntryMenu")
    If newName != ""
        Core.RenameArmorSet(aArmorSetIndex, newName)
        Return True
    EndIf
    Return False
EndFunction