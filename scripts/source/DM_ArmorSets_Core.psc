Scriptname DM_ArmorSets_Core extends Quest 
Import DM_Utils
Import PapyrusUtil
Import JsonUtil

int Property MaxSets = 100 AutoReadOnly
int Property MaxCategories = 5 AutoReadOnly
int Property MostUsedNum = 7 Auto

;*************************************
int[] Property ArmorSetUsage Auto               ; Don't worry about overflow. It would take 68 years calling this, each second, non-stop, to overflow it.
string[] Property ArmorSetNames Auto
string[] Property ArmorSetCategories Auto
string[] Property _sortedArmorSets Auto         ; <Key>,<value> pair. <Usage>,<Index>
;*************************************
Formlist Property Containers Auto
DM_ArmorSets_CurrentArmorSet Property CurrentArmorSet Auto
int Property SortedArmorNamesNum = 0 Auto       ; How many armor sets to show in the main menu
Spell Property ManageOutfitSpell Auto
string property FLogName = "DM Armor sets" AutoReadOnly
string property ProfilesPath = "../Armor Sets in Skyrim/" AutoReadOnly

; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
Event OnInit()
    ;_sortedArmorSets = New String[100]
    InitCategories()
    InitNames()
    InitUsage()
    game.getPlayer().AddSpell(ManageOutfitSpell)
EndEvent

Function InitNames()
    ArmorSetNames = New String[100]
    int i = 0
    While i < MaxSets
        ArmorSetNames[i] = "$-Empty-"
        i += 1
    EndWhile
EndFunction

Function InitCategories()
    ArmorSetCategories = New String[5]
    int i = 0
    While i < MaxSets
        ArmorSetCategories[i] = "$Category {" + PadZeros(i + 1, 2) + "}"
        i += 1
    EndWhile
EndFunction

Function InitUsage()
    ArmorSetUsage = New int[100]
    int i = 0
    While i < MaxSets
        ArmorSetUsage[i] = 0
        i += 1
    EndWhile
EndFunction

; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
Function FindTopMostSets()
    Debug.TraceUser(FLogName, "========== FindTopMostSets() ==========")
    _sortedArmorSets = New String[100]
    SortedArmorNamesNum = MostUsedNum
    CreateSortedArray(MaxSets, 0)
    SortStringArray(_sortedArmorSets, true)
EndFunction

Function FindSetsByCategory(int aCategoryIndex)
    Debug.TraceUser(FLogName, "========== FindSetsByCategory() ==========")
    _sortedArmorSets = New String[20]
    SortedArmorNamesNum = MaxSets / MaxCategories
    CreateSortedArray(SortedArmorNamesNum, aCategoryIndex * SortedArmorNamesNum)
    SortStringArray(_sortedArmorSets, true)
    LogSortedArray()
EndFunction

Function LogSortedArray()
    Debug.TraceUser(FLogName, "Full sorted array")
    int i = 0
    While i < MaxSets
        Debug.TraceUser(FLogName, "_sortedArmorSets[" + i + "] = " + _sortedArmorSets[i])
        i += 1
    EndWhile
EndFunction

; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
Function ClearSortedArrayIdx(int startIdx)
    ; Lento. Se puede optimizar más
    int i = startIdx
    While i < MaxSets
        _sortedArmorSets[i] = ""
        i += 1
    EndWhile
EndFunction

Function ClearSortedArray()
    _sortedArmorSets = Utility.CreateStringArray(MaxSets)
EndFunction

Function CreateSortedArray(int numItems, int startIdx)
    Debug.TraceUser(FLogName, "CreateSortedArray()")
    Debug.TraceUser(FLogName, "numItems = " + numItems)
    Debug.TraceUser(FLogName, "startIdx = " + startIdx)

    int i = startIdx
    int j = 0
    While (j < numItems) && (i < MaxSets) && (j < MaxSets)
        _sortedArmorSets[j] = UsageAsString(i) + "," + i; ArmorSetNames[i]           ; usage,index
        Debug.TraceUser(FLogName, "_sortedArmorSets[" + j + "] = " + _sortedArmorSets[j])
        Debug.TraceUser(FLogName, "i = " + i)
        i += 1
        j += 1
    EndWhile
    ;ClearSortedArrayIdx(j)      ; Optimized
EndFunction

; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
string Function GetSortedName(int idx)
    Return ArmorSetNames[GetSortedIndex(idx)]
EndFunction

int Function GetSortedUsage(int idx)
    Return ArmorSetUsage[GetSortedIndex(idx)]
EndFunction

int Function GetSortedIndex(int idx)
    string[] result = new string[2]
    result = StringSplit(_sortedArmorSets[idx])
    Return result[1] as int
EndFunction

; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
string Function UsageAsString(int idx)
    int usage = ArmorSetUsage[idx]
    ; Optimized
    If usage < 10 
        Return "000000000" + usage
    ElseIf usage < 100
        Return "00000000" + usage
    ElseIf usage < 1000
        Return "0000000" + usage
    ElseIf usage < 10000
        Return "000000" + usage
    ElseIf usage < 100000
        Return "00000" + usage
    ElseIf usage < 1000000
        Return "0000" + usage
    ElseIf usage < 10000000
        Return "000" + usage
    ElseIf usage < 100000000
        Return "00" + usage
    ElseIf usage < 100000000
        Return "0" + usage
    Else
        Return usage
    EndIf
EndFunction

string Function NameAtIndex(int idx)
    Return ArmorSetNames[idx]
EndFunction

Function RenameArmorSet(int idx, string aName)
    ArmorSetNames[idx] = aName
EndFunction

ObjectReference Function ContainerAtIndex(int aArmorSetIndex)
    Return Containers.GetAt(aArmorSetIndex) as ObjectReference
EndFunction

Function UsageMod(int aArmorSetIndex, int aVal)
    ArmorSetUsage[aArmorSetIndex] = ArmorSetUsage[aArmorSetIndex] + aVal
EndFunction

Function UsagePlusOne(int aArmorSetIndex)
    UsageMod(aArmorSetIndex, 1)
EndFunction

Bool Function ArmorSetIsEmpty(int aArmorSetIndex)
    Return ContainerAtIndex(aArmorSetIndex).GetNumItems() < 1
EndFunction

Function ClearUsage(int aArmorSetIndex)
    ArmorSetUsage[aArmorSetIndex] = 0
EndFunction

Function ClearName(int aArmorSetIndex)
    ArmorSetNames[aArmorSetIndex] = "$-Empty-"
EndFunction

; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
bool Function PapyrusExists()
    Return PapyrusUtil.GetVersion() > 1
EndFunction

Function SaveData(string fileName)
    string f = ProfilesPath + fileName + ".json"
    int i = 0
    While i < MaxCategories
        SetStringValue(f, "cat" + i, ArmorSetCategories[i])
        i = i + 1
    EndWhile
    i = 0
    While i < MaxSets
        SetStringValue(f, "nam" + i, ArmorSetNames[i])
        i = i + 1
    EndWhile
    ;StringListCopy(f, "names", ArmorSetNames)
    Save(f)    
EndFunction

Function LoadData(string fileName)
    string f = ProfilesPath + fileName ;+ ".json"
    int i = 0
    While i < MaxCategories
        ArmorSetCategories[i] = GetStringValue(f, "cat" + i, "Category " + PadZeros(i + 1, 2))
        i = i + 1
    EndWhile
    i = 0
    While i < MaxSets
        ArmorSetNames[i] = GetStringValue(f, "nam" + i, "$-Empty-")
        i = i + 1
    EndWhile
EndFunction

Function OnGameReload()
    GotoState("")
EndFunction
