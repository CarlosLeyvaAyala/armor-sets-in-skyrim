Scriptname DM_ArmorSets_CurrentArmorSet extends Quest 

;Formlist Property Weapons Auto
Formlist Property Armors Auto
int Property ArmorSetId Auto
int Property Invalid = -1 AutoReadOnly

Function Reset()
    ArmorSetId = Invalid
    Armors.Revert()
EndFunction

bool Function IsEmpty()
    Return ArmorSetId == Invalid
EndFunction