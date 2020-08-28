; https://github.com/schlangster/skyui/wiki/MCM-State-Options
Scriptname DM_ArmorSets_MCM extends SKI_ConfigBase
Import JsonUtil

DM_ArmorSets_Core Property Core Auto

int function GetVersion()
    return 1
endFunction

event OnPageReset(string aPage)
    PageMain()
endEvent

string slFmt0r = "{0}"

Event OnGameReload()
    parent.OnGameReload()
    Core.OnGameReload()
EndEvent

Function PageMain()
    SetCursorFillMode(TOP_TO_BOTTOM)
    
    SetCursorPosition(0)
    AddHeaderOption("<font color='#daa520'>$Presets</font>")
    AddInputOptionST("IN_PRESETSAVE", "$Save as...", "")
    AddMenuOptionST("MN_PRESETLOAD", "$Load", "")
    AddEmptyOption()
    AddHeaderOption("<font color='#daa520'>$Category names</font>")
    AddInputOptionST("IN_CAT00", "$Rename", Core.ArmorSetCategories[0])
    AddInputOptionST("IN_CAT01", "$Rename", Core.ArmorSetCategories[1])
    AddInputOptionST("IN_CAT02", "$Rename", Core.ArmorSetCategories[2])
    AddInputOptionST("IN_CAT03", "$Rename", Core.ArmorSetCategories[3])
    AddInputOptionST("IN_CAT04", "$Rename", Core.ArmorSetCategories[4])
    
    SetCursorPosition(1)
    AddHeaderOption("<font color='#daa520'>$Options</font>")
    AddSliderOptionST("SL_MOSTUSED", "$Most used", Core.MostUsedNum, slFmt0r)
EndFunction

State MN_PRESETLOAD 
    Event OnMenuOpenST()
        If !CheckPapyrusExists()
            Return
        EndIf
        string[] default = New string[1]
        default[0] = "$None"
        SetMenuDialogStartIndex(0)
        SetMenuDialogDefaultIndex(-1)
        SetMenuDialogOptions( PapyrusUtil.MergeStringArray(default, JsonInFolder(Core.ProfilesPath)) )
    EndEvent

    Event OnMenuAcceptST(int index)
        If index > 0
            Core.LoadData( JsonInFolder(Core.ProfilesPath)[index - 1] )
            ShowMessage("$Data loaded", False)
            ForcePageReset()
        EndIf
        ;SetMenuOptionValueST("")
    EndEvent

    Event OnDefaultST()
        SetMenuOptionValueST("")
    EndEvent

    Event OnHighlightST()
    EndEvent
EndState

State SL_MOSTUSED
    Event OnSliderOpenST()
        float val = Core.MostUsedNum
        SetSliderDialogStartValue(val)
        SetSliderDialogDefaultValue(val)
        SetSliderDialogRange(0, 15)
        SetSliderDialogInterval(1)
    EndEvent

    Event OnSliderAcceptST(float val)
        Core.MostUsedNum =  val as int
        SetSliderOptionValueST(val, slFmt0r)
    EndEvent

    Event OnDefaultST()
        Core.MostUsedNum = 7
        SetSliderOptionValueST(Core.MostUsedNum, slFmt0r)
    EndEvent
    
    Event OnHighlightST()
        SetInfoText("$MCM_MostUsedInfo")
    EndEvent
EndState

State IN_PRESETSAVE 
    Event OnInputAcceptST(string aInput)
        If CheckPapyrusExists() && aInput
            Core.SaveData(aInput)
            ShowMessage("$Data saved", False)
        EndIf
    EndEvent
EndState

bool Function CheckPapyrusExists()
    If !Core.PapyrusExists()
        ShowMessage("$ErrorPapyrusUtil")
        Return False
    EndIf
    Return True
EndFunction

State IN_CAT00
    Event OnInputAcceptST(string aInput)
        RenameCategory(0, aInput)
    EndEvent
EndState

State IN_CAT01
    Event OnInputAcceptST(string aInput)
        RenameCategory(1, aInput)
    EndEvent
EndState

State IN_CAT02
    Event OnInputAcceptST(string aInput)
        RenameCategory(2, aInput)
    EndEvent
EndState

State IN_CAT03
    Event OnInputAcceptST(string aInput)
        RenameCategory(3, aInput)
    EndEvent
EndState

State IN_CAT04
    Event OnInputAcceptST(string aInput)
        RenameCategory(4, aInput)
    EndEvent
EndState

Function RenameCategory(int id, string aName)
    Core.ArmorSetCategories[id] = aName
    SetInputOptionValueST(aName)
EndFunction