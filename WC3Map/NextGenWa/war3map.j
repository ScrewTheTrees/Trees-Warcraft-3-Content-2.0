globals
//globals from STTHostileGenerator:
constant boolean LIBRARY_STTHostileGenerator=true
integer CONST_HOSTILE_ALIVE= 0
integer CONST_HOSTILE_GROUP= 1
integer CONST_HOSTILE_LOCATION= 2
hashtable HostileGroups= InitHashtable()
trigger Trig_UnitDieCleanse
integer CheckGroups= 1
//endglobals from STTHostileGenerator
//globals from STTUtils:
constant boolean LIBRARY_STTUtils=true
integer STTUtils__Count= 0
//endglobals from STTUtils
    // User-defined
force udg_AllActivePlayers= null
integer udg_Gen_TreeLines= 0
integer udg_Gen_TreeGroups= 0
integer udg_Gen_TreeHavens= 0
integer udg_Gen_TreeType= 0
boolean udg_Gen_end= false
integer udg_Gen_BerryGroups= 0
integer udg_Gen_Biomes= 0
boolean udg_Gen_runStart= false
integer udg_biome= 0
integer udg_Gen_HostileGroups= 0

    // Generated
trigger gg_trg_CreateVariables= null
trigger gg_trg_MakeUnitsUnavailable= null
trigger gg_trg_MakeInitialQuests= null
trigger gg_trg_StartUp= null
trigger gg_trg_Concede= null
trigger gg_trg_SetCamera= null
trigger gg_trg_GenHostilePackage= null
trigger gg_trg_GenGeneratorRun= null
trigger gg_trg_GenSetGeneratorVars= null
trigger gg_trg_GenCreatePlayer= null
trigger gg_trg_GenCreatePlayerStartResources= null
trigger gg_trg_GenGenerateThreaded= null
trigger gg_trg_GenSetGeneratorVarsLITE= null
trigger gg_trg_CheatVision= null
trigger gg_trg_TaurenVeteranHowlOfTerror= null
trigger gg_trg_GenOnFinish= null

trigger l__library_init

//JASSHelper struct globals:

endglobals


//library STTHostileGenerator:


function AddHostileGroup takes group units,location base returns integer
    local boolean finished= false
    local integer i= 0
    
    loop
        exitwhen ( finished == true )
        //If the unit group exists or not
        if ( LoadBoolean(HostileGroups, i, CONST_HOSTILE_ALIVE) == false ) then
            call SaveBoolean(HostileGroups, i, CONST_HOSTILE_ALIVE, true)
            call SaveGroupHandle(HostileGroups, i, CONST_HOSTILE_GROUP, units)
            call SaveLocationHandle(HostileGroups, i, CONST_HOSTILE_LOCATION, base)
        endif
        set i=i + 1
    endloop
    if ( CheckGroups < i ) then
        set CheckGroups=i + 1
    endif
    return i
endfunction

function RemoveHostileGroup takes integer index returns boolean
    //Only remove if this group exists, returns if removed
    if ( LoadBoolean(HostileGroups, index, CONST_HOSTILE_ALIVE) == true ) then
        call DestroyGroup(LoadGroupHandle(HostileGroups, index, CONST_HOSTILE_GROUP))
        call RemoveLocation(LoadLocationHandle(HostileGroups, index, CONST_HOSTILE_LOCATION))
        return true
    endif
    return false
endfunction

function PurgeHostileUnit takes unit purge returns nothing
    local group Scan= CreateGroup()
    local integer i= 0
    local group units
    local group tempUnits
    local unit var
    local boolean finished= false
    local integer last= 0
    
    loop
    exitwhen ( i > CheckGroups or finished == true )
        //If the unit group exists or not (dont check empty groups)
        if ( LoadBoolean(HostileGroups, i, CONST_HOSTILE_ALIVE) == true ) then
            set units=CreateGroup()
            set last=i + 1
            set tempUnits=LoadGroupHandle(HostileGroups, i, CONST_HOSTILE_GROUP)
            
            call GroupAddGroup(tempUnits, units)
            //If the group is empty it should be removed
            if ( CountUnitsInGroup(units) <= 0 ) then
                call RemoveHostileGroup(i)
            else
                //Else loop to check for the unit
                loop
                    exitwhen ( CountUnitsInGroup(units) > 0 or finished == true )
                    set var=FirstOfGroup(units)
                    
                    if ( var == purge ) then
                        call GroupRemoveUnit(tempUnits, var)
                        set finished=true
                    endif
                    
                    set tempUnits=null
                    call GroupRemoveUnit(units, var)
                endloop
            endif
            
            call DestroyGroup(units)
        endif
        set i=i + 1
    endloop
    
    //If the search did not finish we might aswell just cleanse to the last found Active Neutral group
    if ( finished == false ) then
        set CheckGroups=last
    endif
    
    set var=null
    call DestroyGroup(Scan)
endfunction

function STTHostileGenerator__RemoveUnitDeathAction takes nothing returns nothing
    call PurgeHostileUnit(GetDyingUnit())
endfunction

function STTHostileGenerator__IsUnitNeutralExpr takes nothing returns boolean
    if ( GetPlayerId(GetOwningPlayer(GetDyingUnit())) >= 12 ) then
        return true
    endif
    return false
endfunction

function STTHostileGenerator__Init takes nothing returns nothing
    set Trig_UnitDieCleanse=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(Trig_UnitDieCleanse, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddCondition(Trig_UnitDieCleanse, Condition(function STTHostileGenerator__IsUnitNeutralExpr))
    call TriggerAddAction(Trig_UnitDieCleanse, function STTHostileGenerator__RemoveUnitDeathAction)
endfunction


//library STTHostileGenerator ends
//library STTUtils:


function GetRandomBiome takes nothing returns integer
    local integer retvar= 'Lgrd'
    local integer switch= GetRandomInt(1, 5)
        if switch == 1 then
            set retvar='Lgrd'
        elseif switch == 2 then
            set retvar='Bdsr'
        elseif switch == 3 then
            set retvar='Clvg'
        elseif switch == 4 then
            set retvar='Zsan'
        elseif switch == 5 then
            set retvar='Ndrt'
            
        endif
    return retvar
endfunction

function GetTreeFromBiome takes integer switch returns integer
    local integer retvar= 'LTlt'
    
    if switch == 'Bdsr' then
        set retvar='BTtw'
    elseif switch == 'Clvg' then
        set retvar='CTtc'
    elseif switch == 'Zsan' then
        set retvar='ZTtw'
    elseif switch == 'Ndrt' then
        set retvar='NTtw'
    
    endif
        
    return retvar
endfunction

//------------

function CanBuildHere takes real CenterX,real CenterY,integer checkUnit returns boolean
    local unit TestUnit= CreateUnit(Player(15), checkUnit, CenterX, CenterY, 270)
    local boolean retvar= true
    
    if ( GetUnitX(TestUnit) != CenterX and GetUnitY(TestUnit) != CenterY ) then
        set retvar=false
    endif
    
    call KillUnit(TestUnit)
    call RemoveUnit(TestUnit)
    
    set TestUnit=null
    return retvar
endfunction

function AddAngle takes real Angle,real add returns real
    set Angle=Angle + add
    loop
        exitwhen ( Angle <= 360 )
        set Angle=Angle - 360
    endloop
    loop
        exitwhen ( Angle >= 0 )
        set Angle=Angle + 360
    endloop
    return Angle
endfunction

function GenerateTreeCluster takes integer Destructable,location Position,integer Size returns nothing
    local group G= CreateGroup()
    local unit g
    local real x
    local real y
    local integer dest
    local integer ForLoop= 0
    local location temploc
    local real expand

    set expand=250 * ( 1 + ( Size / 100 ) )
    loop
        exitwhen ForLoop >= Size
        
        set g=CreateUnitAtLoc(Player(15), 'hwtw', Position, bj_UNIT_FACING)
        call GroupAddUnit(G, g)
        set temploc=Location(GetLocationX(Position) - expand, GetLocationY(Position))
        set g=CreateUnitAtLoc(Player(15), 'hwtw', temploc, bj_UNIT_FACING)
        call GroupAddUnit(G, g)
        call RemoveLocation(temploc)
        set temploc=Location(GetLocationX(Position) + expand, GetLocationY(Position))
        set g=CreateUnitAtLoc(Player(15), 'hwtw', temploc, bj_UNIT_FACING)
        call GroupAddUnit(G, g)
        call RemoveLocation(temploc)
        set temploc=Location(GetLocationX(Position), GetLocationY(Position) - expand)
        set g=CreateUnitAtLoc(Player(15), 'hwtw', temploc, bj_UNIT_FACING)
        call GroupAddUnit(G, g)
        call RemoveLocation(temploc)
        set temploc=Location(GetLocationX(Position), GetLocationY(Position) + expand)
        set g=CreateUnitAtLoc(Player(15), 'hwtw', temploc, bj_UNIT_FACING)
        call GroupAddUnit(G, g)
        call RemoveLocation(temploc)
        
        set ForLoop=ForLoop + 5
    endloop
    
    loop
        set g=FirstOfGroup(G)
        exitwhen g == null
        
            call GroupRemoveUnit(G, g)
            set x=GetUnitX(g)
            set y=GetUnitY(g)
            call RemoveUnit(g)
            
            set dest=GetTerrainType(x, y)
            set Destructable=GetTreeFromBiome(dest)
            call CreateDestructable(Destructable, x, y, GetRandomReal(0, 270), GetRandomReal(0.6, 1), GetRandomInt(0, 10))
    endloop
    call DestroyGroup(G)
endfunction


function IsRadiusFreeFromUnit takes integer UnitType,location Position,real Radius returns boolean
    local boolean retvar= true
    local group units= CreateGroup()
    local unit u
    
    call GroupEnumUnitsInRangeOfLoc(units, Position, Radius, null)
    
    loop
        set u=FirstOfGroup(units)
        exitwhen u == null
            if ( GetUnitTypeId(u) == UnitType ) then
                set retvar=false
            endif
            call GroupRemoveUnit(units, u)
        endloop
    
    call DestroyGroup(units)
    return retvar
endfunction

function IsRadiusFreeFromAllUnits takes location Position,real Radius returns boolean
    local boolean retvar= true
    local group units= CreateGroup()
    local unit u
    
    call GroupEnumUnitsInRangeOfLoc(units, Position, Radius, null)
    
    loop
        set u=FirstOfGroup(units)
        exitwhen u == null
            set retvar=false
            call GroupRemoveUnit(units, u)
        endloop
    
    call DestroyGroup(units)
    return retvar
endfunction

function IsRadiusFreeFromNeutralBuilding takes location Position,real Radius returns boolean
    local boolean retvar= true
    local group units= CreateGroup()
    local unit u
    
    call GroupEnumUnitsInRangeOfLoc(units, Position, Radius, null)
    
    loop
        set u=FirstOfGroup(units)
        exitwhen u == null
            if ( GetPlayerId(GetOwningPlayer(u)) >= 12 ) and ( IsUnitType(u, UNIT_TYPE_STRUCTURE) == true ) and ( IsUnitType(u, UNIT_TYPE_DEAD) == false ) then
                set retvar=false
            endif
            call GroupRemoveUnit(units, u)
        endloop
    
    call DestroyGroup(units)
    return retvar
endfunction

function IsRadiusFreeFromNeutralUnits takes location Position,real Radius returns boolean
    local boolean retvar= true
    local group units= CreateGroup()
    local unit u
    
    call GroupEnumUnitsInRangeOfLoc(units, Position, Radius, null)
    
    loop
        set u=FirstOfGroup(units)
        exitwhen u == null
            if ( GetPlayerId(GetOwningPlayer(u)) >= 12 ) and ( IsUnitType(u, UNIT_TYPE_STRUCTURE) == false ) and ( IsUnitType(u, UNIT_TYPE_DEAD) == false ) and ( GetUnitTypeId(u) != 'n000' ) then
                set retvar=false
            endif
            call GroupRemoveUnit(units, u)
        endloop
    
    call DestroyGroup(units)
    return retvar
endfunction

function STTUtils__IsRadiusFreeFromDestructibleFunc takes nothing returns nothing
    set STTUtils__Count=STTUtils__Count + 1
endfunction

function IsRadiusFreeFromDestructible takes location Position,real Radius returns boolean
    set STTUtils__Count=0
    call EnumDestructablesInCircleBJ(Radius, Position, function STTUtils__IsRadiusFreeFromDestructibleFunc)
    if ( STTUtils__Count > 0 ) then
        return false
    endif
    return true
endfunction

function GenerateNeutralPassiveUnitCluster takes location loc,integer size,integer Unit returns nothing
    local integer forloop= 1
    loop
        exitwhen forloop > size
        call CreateUnit(Player(15), Unit, GetLocationX(loc), GetLocationY(loc), 270)
        set forloop=forloop + 1
    endloop
endfunction


//library STTUtils ends
//===========================================================================
// 
// NextGenTreeWar
// 
//   Warcraft III map script
//   Generated by the Warcraft III World Editor
//   Date: Sat Dec 09 09:09:10 2017
//   Map Author: ScrewTheTrees
// 
//===========================================================================

//***************************************************************************
//*
//*  Global Variables
//*
//***************************************************************************


function InitGlobals takes nothing returns nothing
    set udg_AllActivePlayers=CreateForce()
    set udg_Gen_TreeLines=0
    set udg_Gen_TreeGroups=0
    set udg_Gen_TreeHavens=0
    set udg_Gen_TreeType='LTlt'
    set udg_Gen_end=false
    set udg_Gen_BerryGroups=0
    set udg_Gen_Biomes=0
    set udg_Gen_runStart=true
    set udg_biome='Lgrd'
    set udg_Gen_HostileGroups=0
endfunction

//***************************************************************************
//*
//*  Unit Creation
//*
//***************************************************************************

//===========================================================================
function CreateNeutralHostile takes nothing returns nothing
    local player p= Player(PLAYER_NEUTRAL_AGGRESSIVE)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=CreateUnit(p, 'h00C', 440.0, 151.1, 0.000)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'h00I', 449.8, - 4.2, 0.000)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'h00F', 354.9, 65.1, 0.000)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'h00C', 288.1, - 184.6, 270.000)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'h00I', 118.2, - 185.6, 270.000)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'h00F', 192.9, - 97.0, 270.000)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'h00C', 79.7, 300.8, 90.000)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'h00I', 298.7, 312.1, 90.000)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'h00F', 193.1, 223.4, 90.000)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'h00C', - 75.5, - 15.9, 180.000)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'h00I', - 60.9, 161.2, 180.000)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'h00F', 42.9, 58.3, 180.000)
    call SetUnitAcquireRange(u, 200.0)
endfunction

//===========================================================================
function CreateNeutralPassiveBuildings takes nothing returns nothing
    local player p= Player(PLAYER_NEUTRAL_PASSIVE)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=CreateUnit(p, 'nfoh', 192.0, 64.0, 270.000)
    set u=CreateUnit(p, 'n000', - 4608.0, 11392.0, 270.000)
    call SetResourceAmount(u, 12500)
endfunction

//===========================================================================
function CreatePlayerBuildings takes nothing returns nothing
endfunction

//===========================================================================
function CreatePlayerUnits takes nothing returns nothing
endfunction

//===========================================================================
function CreateAllUnits takes nothing returns nothing
    call CreateNeutralPassiveBuildings()
    call CreatePlayerBuildings()
    call CreateNeutralHostile()
    call CreatePlayerUnits()
endfunction

//***************************************************************************
//*
//*  Custom Script Code
//*
//***************************************************************************
//***************************************************************************
//*
//*  Triggers
//*
//***************************************************************************

//===========================================================================
// Trigger: CreateVariables
//===========================================================================
function Trig_CreateVariables_Func001Func001C takes nothing returns boolean
    if ( not ( GetPlayerSlotState(GetEnumPlayer()) == PLAYER_SLOT_STATE_PLAYING ) ) then
        return false
    endif
    return true
endfunction

function Trig_CreateVariables_Func001A takes nothing returns nothing
    if ( Trig_CreateVariables_Func001Func001C() ) then
        call ForceAddPlayerSimple(GetEnumPlayer(), udg_AllActivePlayers)
    else
    endif
endfunction

function Trig_CreateVariables_Actions takes nothing returns nothing
    call ForForce(GetPlayersAll(), function Trig_CreateVariables_Func001A)
    call ForceRemovePlayerSimple(Player(PLAYER_NEUTRAL_PASSIVE), udg_AllActivePlayers)
    call ForceRemovePlayerSimple(Player(bj_PLAYER_NEUTRAL_EXTRA), udg_AllActivePlayers)
    call ForceRemovePlayerSimple(Player(bj_PLAYER_NEUTRAL_VICTIM), udg_AllActivePlayers)
    call ForceRemovePlayerSimple(Player(PLAYER_NEUTRAL_AGGRESSIVE), udg_AllActivePlayers)
endfunction

//===========================================================================
function InitTrig_CreateVariables takes nothing returns nothing
    set gg_trg_CreateVariables=CreateTrigger()
    call TriggerAddAction(gg_trg_CreateVariables, function Trig_CreateVariables_Actions)
endfunction

//===========================================================================
// Trigger: MakeInitialQuests
//===========================================================================
function Trig_MakeInitialQuests_Actions takes nothing returns nothing
    call CreateQuestBJ(bj_QUESTTYPE_REQ_DISCOVERED, "TRIGSTR_279", "TRIGSTR_280", "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp")
    call CreateQuestBJ(bj_QUESTTYPE_OPT_DISCOVERED, "TRIGSTR_281", "TRIGSTR_282", "ReplaceableTextures\\WorldEditUI\\Editor-MultipleUnits.blp")
    call FlashQuestDialogButtonBJ()
endfunction

//===========================================================================
function InitTrig_MakeInitialQuests takes nothing returns nothing
    set gg_trg_MakeInitialQuests=CreateTrigger()
    call TriggerAddAction(gg_trg_MakeInitialQuests, function Trig_MakeInitialQuests_Actions)
endfunction

//===========================================================================
// Trigger: StartUp
//===========================================================================
function Trig_StartUp_Func001A takes nothing returns nothing
    call SetPlayerMaxHeroesAllowed(1, GetEnumPlayer())
endfunction

function Trig_StartUp_Actions takes nothing returns nothing
    call ForForce(udg_AllActivePlayers, function Trig_StartUp_Func001A)
endfunction

//===========================================================================
function InitTrig_StartUp takes nothing returns nothing
    set gg_trg_StartUp=CreateTrigger()
    call TriggerAddAction(gg_trg_StartUp, function Trig_StartUp_Actions)
endfunction

//===========================================================================
// Trigger: Concede
//
// Turned on after map generator is complete.
// TODO: Consider disabling if in team (or can only see teammate)
//===========================================================================
function Trig_Concede_Func002A takes nothing returns nothing
    call KillUnit(GetEnumUnit())
endfunction

function Trig_Concede_Actions takes nothing returns nothing
    call CreateFogModifierRectBJ(true, GetTriggerPlayer(), FOG_OF_WAR_VISIBLE, GetPlayableMapRect())
    call ForGroupBJ(GetUnitsOfPlayerAll(GetTriggerPlayer()), function Trig_Concede_Func002A)
endfunction

//===========================================================================
function InitTrig_Concede takes nothing returns nothing
    set gg_trg_Concede=CreateTrigger()
    call DisableTrigger(gg_trg_Concede)
    call TriggerRegisterPlayerChatEvent(gg_trg_Concede, Player(0), "-concede", true)
    call TriggerRegisterPlayerChatEvent(gg_trg_Concede, Player(1), "-concede", true)
    call TriggerRegisterPlayerChatEvent(gg_trg_Concede, Player(2), "-concede", true)
    call TriggerRegisterPlayerChatEvent(gg_trg_Concede, Player(3), "-concede", true)
    call TriggerRegisterPlayerChatEvent(gg_trg_Concede, Player(4), "-concede", true)
    call TriggerRegisterPlayerChatEvent(gg_trg_Concede, Player(5), "-concede", true)
    call TriggerRegisterPlayerChatEvent(gg_trg_Concede, Player(6), "-concede", true)
    call TriggerRegisterPlayerChatEvent(gg_trg_Concede, Player(7), "-concede", true)
    call TriggerRegisterPlayerChatEvent(gg_trg_Concede, Player(8), "-concede", true)
    call TriggerRegisterPlayerChatEvent(gg_trg_Concede, Player(9), "-concede", true)
    call TriggerRegisterPlayerChatEvent(gg_trg_Concede, Player(10), "-concede", true)
    call TriggerRegisterPlayerChatEvent(gg_trg_Concede, Player(11), "-concede", true)
    call TriggerAddAction(gg_trg_Concede, function Trig_Concede_Actions)
endfunction

//===========================================================================
// Trigger: SetCamera
//
// Make your camera negative, go nuts
//===========================================================================
function Trig_SetCamera_Conditions takes nothing returns boolean
    if ( not ( SubStringBJ(GetEventPlayerChatString(), 1, 4) == "-cam" ) ) then
        return false
    endif
    return true
endfunction

function Trig_SetCamera_Actions takes nothing returns nothing
    call SetCameraFieldForPlayer(GetTriggerPlayer(), CAMERA_FIELD_TARGET_DISTANCE, S2R(SubStringBJ(GetEventPlayerChatString(), 6, 9)), 0.50)
endfunction

//===========================================================================
function InitTrig_SetCamera takes nothing returns nothing
    set gg_trg_SetCamera=CreateTrigger()
    call TriggerRegisterPlayerChatEvent(gg_trg_SetCamera, Player(0), "-cam ", false)
    call TriggerRegisterPlayerChatEvent(gg_trg_SetCamera, Player(1), "-cam ", false)
    call TriggerRegisterPlayerChatEvent(gg_trg_SetCamera, Player(2), "-cam ", false)
    call TriggerRegisterPlayerChatEvent(gg_trg_SetCamera, Player(3), "-cam ", false)
    call TriggerRegisterPlayerChatEvent(gg_trg_SetCamera, Player(4), "-cam ", false)
    call TriggerRegisterPlayerChatEvent(gg_trg_SetCamera, Player(5), "-cam ", false)
    call TriggerRegisterPlayerChatEvent(gg_trg_SetCamera, Player(6), "-cam ", false)
    call TriggerRegisterPlayerChatEvent(gg_trg_SetCamera, Player(7), "-cam ", false)
    call TriggerRegisterPlayerChatEvent(gg_trg_SetCamera, Player(8), "-cam ", false)
    call TriggerRegisterPlayerChatEvent(gg_trg_SetCamera, Player(9), "-cam ", false)
    call TriggerRegisterPlayerChatEvent(gg_trg_SetCamera, Player(10), "-cam ", false)
    call TriggerRegisterPlayerChatEvent(gg_trg_SetCamera, Player(11), "-cam ", false)
    call TriggerAddCondition(gg_trg_SetCamera, Condition(function Trig_SetCamera_Conditions))
    call TriggerAddAction(gg_trg_SetCamera, function Trig_SetCamera_Actions)
endfunction

//===========================================================================
// Trigger: GenHostilePackage
//===========================================================================




//===========================================================================
function InitTrig_GenHostilePackage takes nothing returns nothing

endfunction

//===========================================================================
// Trigger: GenGeneratorRun
//===========================================================================
function Trig_GenGeneratorRun_Actions takes nothing returns nothing
    call DisplayTimedTextToForce(GetPlayersAll(), 5.00, "TRIGSTR_225")
    call ConditionalTriggerExecute(gg_trg_GenSetGeneratorVars)
    call TriggerSleepAction(5.00)
    call EnableTrigger(gg_trg_GenGenerateThreaded)
endfunction

//===========================================================================
function InitTrig_GenGeneratorRun takes nothing returns nothing
    set gg_trg_GenGeneratorRun=CreateTrigger()
    call TriggerRegisterTimerEventSingle(gg_trg_GenGeneratorRun, 1.00)
    call TriggerAddAction(gg_trg_GenGeneratorRun, function Trig_GenGeneratorRun_Actions)
endfunction

//===========================================================================
// Trigger: GenSetGeneratorVars
//===========================================================================
function Trig_GenSetGeneratorVars_Actions takes nothing returns nothing
    set udg_Gen_Biomes=GetRandomInt(60, 100)
    set udg_Gen_TreeGroups=GetRandomInt(450, 550)
    set udg_Gen_TreeLines=GetRandomInt(0, 0)
    set udg_Gen_TreeHavens=GetRandomInt(2, 4)
    set udg_Gen_BerryGroups=GetRandomInt(80, 100)
    set udg_Gen_HostileGroups=GetRandomInt(40, 60)
    set udg_Gen_end=false
    set udg_Gen_runStart=true
endfunction

//===========================================================================
function InitTrig_GenSetGeneratorVars takes nothing returns nothing
    set gg_trg_GenSetGeneratorVars=CreateTrigger()
    call TriggerAddAction(gg_trg_GenSetGeneratorVars, function Trig_GenSetGeneratorVars_Actions)
endfunction

//===========================================================================
// Trigger: GenCreatePlayer
//===========================================================================
function Trig_GenCreatePlayer_Func001A takes nothing returns nothing
    call CreateNUnitsAtLoc(1, 'h002', GetEnumPlayer(), GetPlayerStartLocationLoc(GetEnumPlayer()), bj_UNIT_FACING)
    call UnitAddAbilityBJ('A002', GetLastCreatedUnit())
    call CreateNUnitsAtLoc(8, 'h000', GetEnumPlayer(), GetPlayerStartLocationLoc(GetEnumPlayer()), bj_UNIT_FACING)
    call SetPlayerStateBJ(GetEnumPlayer(), PLAYER_STATE_RESOURCE_GOLD, 200)
    call SetPlayerStateBJ(GetEnumPlayer(), PLAYER_STATE_RESOURCE_LUMBER, 500)
endfunction

function Trig_GenCreatePlayer_Actions takes nothing returns nothing
    call ForForce(udg_AllActivePlayers, function Trig_GenCreatePlayer_Func001A)
endfunction

//===========================================================================
function InitTrig_GenCreatePlayer takes nothing returns nothing
    set gg_trg_GenCreatePlayer=CreateTrigger()
    call TriggerAddAction(gg_trg_GenCreatePlayer, function Trig_GenCreatePlayer_Actions)
endfunction

//===========================================================================
// Trigger: GenCreatePlayerStartResources
//===========================================================================
function CreatePlayerUniqueTrees_LOOP takes nothing returns nothing

    local real Angle= GetRandomReal(0, 360)
    local location spawnlocation
    local integer forLoop= 0
    
    loop
        exitwhen forLoop == 14
        set Angle=AddAngle(Angle , 20)
        set spawnlocation=PolarProjectionBJ(GetPlayerStartLocationLoc(GetEnumPlayer()), 1300.00, Angle)
        call GenerateTreeCluster(udg_Gen_TreeType , spawnlocation , 25)
        call RemoveLocation(spawnlocation)
        set forLoop=forLoop + 1
    endloop
    
    //Expansion berries
    set Angle=AddAngle(Angle , 60)
    set spawnlocation=PolarProjectionBJ(GetPlayerStartLocationLoc(GetEnumPlayer()), 2000.00, Angle)
    
        call GenerateNeutralPassiveUnitCluster(spawnlocation , 2 , 'n000')
    
    call RemoveLocation(spawnlocation)
    
    //Start berry
    set Angle=AddAngle(Angle , 40)
    set spawnlocation=PolarProjectionBJ(GetPlayerStartLocationLoc(GetEnumPlayer()), 800.00, Angle)
    
        call GenerateNeutralPassiveUnitCluster(spawnlocation , 1 , 'n000')
        
    call RemoveLocation(spawnlocation)
endfunction

function Trig_CreatePlayerUniqueTrees_Actions takes nothing returns nothing
    call ForForce(udg_AllActivePlayers, function CreatePlayerUniqueTrees_LOOP)
endfunction

//===========================================================================
function InitTrig_GenCreatePlayerStartResources takes nothing returns nothing
    set gg_trg_GenCreatePlayerStartResources=CreateTrigger()
    call TriggerAddAction(gg_trg_GenCreatePlayerStartResources, function Trig_CreatePlayerUniqueTrees_Actions)
endfunction

//===========================================================================
// Trigger: GenGenerateThreaded
//===========================================================================
//Generally it makes vision for all players around their base briefly.
function GenGenerateThreadedFinished takes nothing returns nothing
    local player p= GetEnumPlayer()
    local location l= GetPlayerStartLocationLoc(p)
    
    local fogmodifier fomod= CreateFogModifierRadius(p, FOG_OF_WAR_VISIBLE, GetLocationX(l), GetLocationY(l), 3500, true, false)
    call FogModifierStart(fomod)
    
    call FogModifierStop(fomod)
    call DestroyFogModifier(fomod)
    call RemoveLocation(l)
    set p=null
endfunction


//Generate Functions
function GetRandomHostileUnit takes integer Level returns integer
    local integer RetUnit= 'h00D'
    local integer Theme= GetRandomInt(1, 1)
    local integer Num
    
    if Level <= 1 then
        if Theme <= 1 then
            //Normal humans Level 1
            set Num=GetRandomInt(1, 3)
            if Num == 1 then
                set RetUnit='h00D'
            elseif Num == 2 then
                set RetUnit='h00E'
            elseif Num == 3 then
                set RetUnit='h00I'
            endif
        endif
    endif
    
    
    return RetUnit
endfunction

function GenGenerateBiome takes location StartLoc returns nothing
    call SetTerrainType(GetLocationX(StartLoc), GetLocationY(StartLoc), GetRandomBiome(), - 1, GetRandomInt(22, 30), 0)
    set udg_Gen_Biomes=udg_Gen_Biomes - 1
endfunction

function GenGenerateStart takes location StartLoc returns nothing
    call TriggerExecute(gg_trg_GenCreatePlayer)
    call TriggerExecute(gg_trg_GenCreatePlayerStartResources)
    call ForForce(udg_AllActivePlayers, function GenGenerateThreadedFinished) //Make Temporary vision around base.
            
    set udg_Gen_runStart=false
endfunction

function GenGenerateBerryGroup takes location StartLoc returns nothing
    if IsRadiusFreeFromUnit('h002' , StartLoc , 2500) then
        if IsRadiusFreeFromNeutralBuilding(StartLoc , 1000) then
            call GenerateNeutralPassiveUnitCluster(StartLoc , GetRandomInt(1, 2) , 'n000')
            set udg_Gen_BerryGroups=udg_Gen_BerryGroups - 1
        endif
    endif
endfunction

function GenGenerateTreeGroup takes location StartLoc returns nothing
    if IsRadiusFreeFromUnit('h002' , StartLoc , 2500) then
        if IsRadiusFreeFromNeutralBuilding(StartLoc , 700) then
            if IsRadiusFreeFromNeutralUnits(StartLoc , 700) then
                call GenerateTreeCluster(udg_Gen_TreeType , StartLoc , GetRandomInt(20, 35))
                
                set udg_Gen_TreeGroups=udg_Gen_TreeGroups - 1
            endif
        endif
    endif
endfunction

function GenGenerateTreeHaven takes location StartLoc returns nothing
    local real Angle= GetRandomReal(0, 360)
    local integer forLoop
    local location EndLoc
    
    if IsRadiusFreeFromUnit('h002' , StartLoc , 5000) then
        if IsRadiusFreeFromNeutralBuilding(StartLoc , 2000) then
            //Units can be placed inside the haven.
            if IsRadiusFreeFromNeutralUnits(StartLoc , 500) == false or IsRadiusFreeFromNeutralUnits(StartLoc , 2000) then
                set forLoop=0
                loop
                    exitwhen forLoop > 16
                    set Angle=AddAngle(Angle , 20)
                    set EndLoc=PolarProjectionBJ(StartLoc, 1350, Angle)
                    call GenerateTreeCluster(udg_Gen_TreeType , EndLoc , 15)
                    call RemoveLocation(EndLoc)
                    set forLoop=forLoop + 1
                endloop
                        
                call GenerateNeutralPassiveUnitCluster(StartLoc , GetRandomInt(3, 4) , 'n000')
                        
                set udg_Gen_TreeHavens=udg_Gen_TreeHavens - 1
            endif
        endif
    endif
    
    call RemoveLocation(EndLoc)
endfunction

function GenGenerateHostileGroup takes location StartLoc,integer Level returns nothing
    local integer Size= GetRandomInt(3, 5)
    local group units
    local location spawnlocation
    local unit u
    
    if IsRadiusFreeFromUnit('h002' , StartLoc , 2500) then
        if IsRadiusFreeFromNeutralBuilding(StartLoc , 1000) then
            if IsRadiusFreeFromDestructible(StartLoc , 175) then
                set units=CreateGroup()
                set udg_Gen_HostileGroups=udg_Gen_HostileGroups - 1
                
                loop
                    exitwhen Size <= 0
                    set spawnlocation=PolarProjectionBJ(StartLoc, GetRandomReal(50, 175), GetRandomReal(0, 360))
                    set u=CreateUnitAtLoc(Player(12), GetRandomHostileUnit(Level), spawnlocation, GetRandomReal(0, 360))
                    call SetUnitAcquireRange(u, 200)
                    call GroupAddUnit(units, u)
                    call RemoveLocation(spawnlocation)
                    set u=null
                    set Size=Size - 1
                endloop
                call AddHostileGroup(units , StartLoc)
            endif
        endif
    endif
endfunction

//Primary Trigger
function Trig_GenGenerateThreaded_Actions takes nothing returns nothing
    local location StartLoc
    
    if ( udg_Gen_end == false ) then
    
        //Pick Random Position
        set StartLoc=GetRandomLocInRect(bj_mapInitialCameraBounds)
        call PauseAllUnitsBJ(true)
        
        //Draw Debug text
        call ClearTextMessages()
        call DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 1, "Generator Debug: ")
        call DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 1, "Biomes: " + I2S(udg_Gen_Biomes))
        call DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 1, "BerryGroups: " + I2S(udg_Gen_BerryGroups))
        call DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 1, "TreeGroups: " + I2S(udg_Gen_TreeGroups))
        call DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 1, "TreeLines: " + I2S(udg_Gen_TreeLines))
        call DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 1, "TreeHavens: " + I2S(udg_Gen_TreeHavens))
        call DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 1, "HostileGroups: " + I2S(udg_Gen_HostileGroups))
        
        
        //Generation
        //Generate Biomes
        if ( udg_Gen_Biomes > 0 ) then
            call GenGenerateBiome(StartLoc)
        //Run after biomes creating player locations
        elseif ( udg_Gen_runStart == true ) then
            call GenGenerateStart(StartLoc)
        //Create berries
        elseif ( udg_Gen_BerryGroups > 0 ) then
            call GenGenerateBerryGroup(StartLoc)
        //Create Happy little Trees
        elseif ( udg_Gen_TreeGroups > 0 ) then
            call GenGenerateTreeGroup(StartLoc)
        //Unused so far
        elseif ( udg_Gen_TreeLines > 0 ) then
            set udg_Gen_TreeLines=udg_Gen_TreeLines - 1
        //Tree havens
        elseif ( udg_Gen_TreeHavens > 0 ) then
            call GenGenerateTreeHaven(StartLoc)
        //Hostile Neutral Units
        elseif ( udg_Gen_HostileGroups > 0 ) then
            call GenGenerateHostileGroup(StartLoc , 1)
        
        //The final thing before it all ends
        else
            set udg_Gen_end=true
            call PauseAllUnitsBJ(false)
            call ForForce(udg_AllActivePlayers, function GenGenerateThreadedFinished) //Make Temporary vision around base.
        endif
        
        //call PanCameraToTimed(GetLocationX(StartLoc), GetLocationY(StartLoc), 0)
        
    elseif ( udg_Gen_end == true ) then
        call EnableTrigger(gg_trg_GenOnFinish)
        call EnableTrigger(gg_trg_Concede)
        call DisableTrigger(gg_trg_GenGenerateThreaded)
    endif
        
    call RemoveLocation(StartLoc)
    
endfunction

//===========================================================================
function InitTrig_GenGenerateThreaded takes nothing returns nothing
    set gg_trg_GenGenerateThreaded=CreateTrigger()
    call DisableTrigger(gg_trg_GenGenerateThreaded)
    call TriggerRegisterTimerEventPeriodic(gg_trg_GenGenerateThreaded, 0.04)
    call TriggerAddAction(gg_trg_GenGenerateThreaded, function Trig_GenGenerateThreaded_Actions)
endfunction

//===========================================================================
// Trigger: GenSetGeneratorVarsLITE
//===========================================================================
function Trig_GenSetGeneratorVarsLITE_Actions takes nothing returns nothing
    set udg_Gen_Biomes=2
    set udg_Gen_TreeGroups=5
    set udg_Gen_TreeLines=0
    set udg_Gen_TreeHavens=1
    set udg_Gen_BerryGroups=2
    set udg_Gen_HostileGroups=2
    set udg_Gen_end=false
    set udg_Gen_runStart=true
endfunction

//===========================================================================
function InitTrig_GenSetGeneratorVarsLITE takes nothing returns nothing
    set gg_trg_GenSetGeneratorVarsLITE=CreateTrigger()
    call TriggerAddAction(gg_trg_GenSetGeneratorVarsLITE, function Trig_GenSetGeneratorVarsLITE_Actions)
endfunction

//===========================================================================
// Trigger: CheatVision
//===========================================================================
function Trig_CheatVision_Func001A takes nothing returns nothing
    call CreateFogModifierRectBJ(true, GetEnumPlayer(), FOG_OF_WAR_VISIBLE, GetPlayableMapRect())
    call DisableTrigger(GetTriggeringTrigger())
endfunction

function Trig_CheatVision_Actions takes nothing returns nothing
    call ForForce(udg_AllActivePlayers, function Trig_CheatVision_Func001A)
endfunction

//===========================================================================
function InitTrig_CheatVision takes nothing returns nothing
    set gg_trg_CheatVision=CreateTrigger()
    call TriggerRegisterPlayerChatEvent(gg_trg_CheatVision, Player(0), "-showall", true)
    call TriggerAddAction(gg_trg_CheatVision, function Trig_CheatVision_Actions)
endfunction

//===========================================================================
// Trigger: TaurenVeteranHowlOfTerror
//===========================================================================
function Trig_TaurenVeteranHowlOfTerror_Conditions takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A00I' ) ) then
        return false
    endif
    return true
endfunction

function Trig_TaurenVeteranHowlOfTerror_Actions takes nothing returns nothing
    local location castPoint= GetUnitLoc(GetSpellAbilityUnit())
    local unit caster= CreateUnitAtLoc(GetOwningPlayer(GetSpellAbilityUnit()), 'e000', castPoint, bj_UNIT_FACING)
    call UnitAddAbility(caster, 'A00N')
    call IssueImmediateOrder(caster, "roar")
    call KillUnit(caster)
    call RemoveUnit(caster)
    
    set caster=null
    call RemoveLocation(castPoint)
endfunction

//===========================================================================
function InitTrig_TaurenVeteranHowlOfTerror takes nothing returns nothing
    set gg_trg_TaurenVeteranHowlOfTerror=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_TaurenVeteranHowlOfTerror, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddCondition(gg_trg_TaurenVeteranHowlOfTerror, Condition(function Trig_TaurenVeteranHowlOfTerror_Conditions))
    call TriggerAddAction(gg_trg_TaurenVeteranHowlOfTerror, function Trig_TaurenVeteranHowlOfTerror_Actions)
endfunction

//===========================================================================
// Trigger: GenOnFinish
//===========================================================================
function Trig_GenOnFinish_Actions takes nothing returns nothing
    call StartCampaignAI(Player(1), "war3mapImported\\AI.ai")
endfunction

//===========================================================================
function InitTrig_GenOnFinish takes nothing returns nothing
    set gg_trg_GenOnFinish=CreateTrigger()
    call TriggerAddAction(gg_trg_GenOnFinish, function Trig_GenOnFinish_Actions)
endfunction

//===========================================================================
function InitCustomTriggers takes nothing returns nothing
    call InitTrig_CreateVariables()
    call InitTrig_MakeInitialQuests()
    call InitTrig_StartUp()
    call InitTrig_Concede()
    call InitTrig_SetCamera()
    call InitTrig_GenHostilePackage()
    call InitTrig_GenGeneratorRun()
    call InitTrig_GenSetGeneratorVars()
    call InitTrig_GenCreatePlayer()
    call InitTrig_GenCreatePlayerStartResources()
    call InitTrig_GenGenerateThreaded()
    call InitTrig_GenSetGeneratorVarsLITE()
    call InitTrig_CheatVision()
    call InitTrig_TaurenVeteranHowlOfTerror()
    call InitTrig_GenOnFinish()
endfunction

//===========================================================================
function RunInitializationTriggers takes nothing returns nothing
    call ConditionalTriggerExecute(gg_trg_CreateVariables)
    call ConditionalTriggerExecute(gg_trg_MakeInitialQuests)
    call ConditionalTriggerExecute(gg_trg_StartUp)
endfunction

//***************************************************************************
//*
//*  Players
//*
//***************************************************************************

function InitCustomPlayerSlots takes nothing returns nothing

    // Player 0
    call SetPlayerStartLocation(Player(0), 0)
    call SetPlayerColor(Player(0), ConvertPlayerColor(0))
    call SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(0), true)
    call SetPlayerController(Player(0), MAP_CONTROL_USER)

    // Player 1
    call SetPlayerStartLocation(Player(1), 1)
    call ForcePlayerStartLocation(Player(1), 1)
    call SetPlayerColor(Player(1), ConvertPlayerColor(1))
    call SetPlayerRacePreference(Player(1), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(1), true)
    call SetPlayerController(Player(1), MAP_CONTROL_COMPUTER)

    // Player 2
    call SetPlayerStartLocation(Player(2), 2)
    call SetPlayerColor(Player(2), ConvertPlayerColor(2))
    call SetPlayerRacePreference(Player(2), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(2), true)
    call SetPlayerController(Player(2), MAP_CONTROL_USER)

    // Player 3
    call SetPlayerStartLocation(Player(3), 3)
    call SetPlayerColor(Player(3), ConvertPlayerColor(3))
    call SetPlayerRacePreference(Player(3), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(3), true)
    call SetPlayerController(Player(3), MAP_CONTROL_USER)

    // Player 4
    call SetPlayerStartLocation(Player(4), 4)
    call SetPlayerColor(Player(4), ConvertPlayerColor(4))
    call SetPlayerRacePreference(Player(4), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(4), true)
    call SetPlayerController(Player(4), MAP_CONTROL_USER)

    // Player 5
    call SetPlayerStartLocation(Player(5), 5)
    call SetPlayerColor(Player(5), ConvertPlayerColor(5))
    call SetPlayerRacePreference(Player(5), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(5), true)
    call SetPlayerController(Player(5), MAP_CONTROL_USER)

    // Player 6
    call SetPlayerStartLocation(Player(6), 6)
    call SetPlayerColor(Player(6), ConvertPlayerColor(6))
    call SetPlayerRacePreference(Player(6), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(6), true)
    call SetPlayerController(Player(6), MAP_CONTROL_USER)

    // Player 7
    call SetPlayerStartLocation(Player(7), 7)
    call SetPlayerColor(Player(7), ConvertPlayerColor(7))
    call SetPlayerRacePreference(Player(7), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(7), true)
    call SetPlayerController(Player(7), MAP_CONTROL_USER)

    // Player 8
    call SetPlayerStartLocation(Player(8), 8)
    call SetPlayerColor(Player(8), ConvertPlayerColor(8))
    call SetPlayerRacePreference(Player(8), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(8), true)
    call SetPlayerController(Player(8), MAP_CONTROL_USER)

    // Player 9
    call SetPlayerStartLocation(Player(9), 9)
    call SetPlayerColor(Player(9), ConvertPlayerColor(9))
    call SetPlayerRacePreference(Player(9), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(9), true)
    call SetPlayerController(Player(9), MAP_CONTROL_USER)

    // Player 10
    call SetPlayerStartLocation(Player(10), 10)
    call SetPlayerColor(Player(10), ConvertPlayerColor(10))
    call SetPlayerRacePreference(Player(10), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(10), true)
    call SetPlayerController(Player(10), MAP_CONTROL_USER)

    // Player 11
    call SetPlayerStartLocation(Player(11), 11)
    call SetPlayerColor(Player(11), ConvertPlayerColor(11))
    call SetPlayerRacePreference(Player(11), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(11), true)
    call SetPlayerController(Player(11), MAP_CONTROL_USER)

endfunction

function InitCustomTeams takes nothing returns nothing
    // Force: TRIGSTR_002
    call SetPlayerTeam(Player(0), 0)
    call SetPlayerTeam(Player(1), 0)
    call SetPlayerTeam(Player(2), 0)
    call SetPlayerTeam(Player(3), 0)
    call SetPlayerTeam(Player(4), 0)
    call SetPlayerTeam(Player(5), 0)
    call SetPlayerTeam(Player(6), 0)
    call SetPlayerTeam(Player(7), 0)
    call SetPlayerTeam(Player(8), 0)
    call SetPlayerTeam(Player(9), 0)
    call SetPlayerTeam(Player(10), 0)
    call SetPlayerTeam(Player(11), 0)

endfunction

function InitAllyPriorities takes nothing returns nothing

    call SetStartLocPrioCount(0, 4)
    call SetStartLocPrio(0, 0, 1, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(0, 1, 2, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(0, 2, 10, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(0, 3, 11, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(1, 4)
    call SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(1, 1, 2, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(1, 2, 3, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(1, 3, 11, MAP_LOC_PRIO_LOW)

    call SetStartLocPrioCount(2, 4)
    call SetStartLocPrio(2, 0, 0, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(2, 1, 1, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(2, 2, 3, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(2, 3, 4, MAP_LOC_PRIO_LOW)

    call SetStartLocPrioCount(3, 4)
    call SetStartLocPrio(3, 0, 1, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(3, 1, 2, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(3, 2, 4, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(3, 3, 5, MAP_LOC_PRIO_LOW)

    call SetStartLocPrioCount(4, 4)
    call SetStartLocPrio(4, 0, 2, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(4, 1, 3, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(4, 2, 5, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(4, 3, 6, MAP_LOC_PRIO_LOW)

    call SetStartLocPrioCount(5, 4)
    call SetStartLocPrio(5, 0, 3, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(5, 1, 4, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(5, 2, 6, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(5, 3, 7, MAP_LOC_PRIO_LOW)

    call SetStartLocPrioCount(6, 4)
    call SetStartLocPrio(6, 0, 4, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(6, 1, 5, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(6, 2, 7, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(6, 3, 8, MAP_LOC_PRIO_LOW)

    call SetStartLocPrioCount(7, 4)
    call SetStartLocPrio(7, 0, 5, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(7, 1, 6, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(7, 2, 8, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(7, 3, 9, MAP_LOC_PRIO_LOW)

    call SetStartLocPrioCount(8, 4)
    call SetStartLocPrio(8, 0, 6, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(8, 1, 7, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(8, 2, 9, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(8, 3, 10, MAP_LOC_PRIO_LOW)

    call SetStartLocPrioCount(9, 4)
    call SetStartLocPrio(9, 0, 7, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(9, 1, 8, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(9, 2, 10, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(9, 3, 11, MAP_LOC_PRIO_LOW)

    call SetStartLocPrioCount(10, 4)
    call SetStartLocPrio(10, 0, 0, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(10, 1, 8, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(10, 2, 9, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(10, 3, 11, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(11, 4)
    call SetStartLocPrio(11, 0, 0, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(11, 1, 1, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(11, 2, 9, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(11, 3, 10, MAP_LOC_PRIO_HIGH)
endfunction

//***************************************************************************
//*
//*  Main Initialization
//*
//***************************************************************************

//===========================================================================
function main takes nothing returns nothing
    call SetCameraBounds(- 15616.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), - 15872.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 15616.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 15360.0 - GetCameraMargin(CAMERA_MARGIN_TOP), - 15616.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 15360.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 15616.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), - 15872.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    call SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    call SetTerrainFogEx(0, 8000.0, 10000.0, 0.500, 0.000, 0.000, 0.000)
    call NewSoundEnvironment("Default")
    call SetAmbientDaySound("LordaeronSummerDay")
    call SetAmbientNightSound("LordaeronSummerNight")
    call SetMapMusic("Music", true, 0)
    call CreateAllUnits()
    call InitBlizzard()

call ExecuteFunc("STTHostileGenerator__Init")

    call InitGlobals()
    call InitCustomTriggers()
    call RunInitializationTriggers()

endfunction

//***************************************************************************
//*
//*  Map Configuration
//*
//***************************************************************************

function config takes nothing returns nothing
    call SetMapName("TRIGSTR_023")
    call SetMapDescription("TRIGSTR_025")
    call SetPlayers(12)
    call SetTeams(12)
    call SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)

    call DefineStartLocation(0, - 12160.0, 12032.0)
    call DefineStartLocation(1, - 4608.0, 12160.0)
    call DefineStartLocation(2, 3328.0, 11776.0)
    call DefineStartLocation(3, 10048.0, 11520.0)
    call DefineStartLocation(4, 11136.0, 5568.0)
    call DefineStartLocation(5, 11456.0, - 2688.0)
    call DefineStartLocation(6, 11136.0, - 11136.0)
    call DefineStartLocation(7, 3520.0, - 12160.0)
    call DefineStartLocation(8, - 4736.0, - 11904.0)
    call DefineStartLocation(9, - 12416.0, - 10688.0)
    call DefineStartLocation(10, - 12352.0, - 2432.0)
    call DefineStartLocation(11, - 12160.0, 5952.0)

    // Player setup
    call InitCustomPlayerSlots()
    call SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(1), MAP_CONTROL_COMPUTER)
    call SetPlayerSlotAvailable(Player(2), MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(3), MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(4), MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(5), MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(6), MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(7), MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(8), MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(9), MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(10), MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(11), MAP_CONTROL_USER)
    call InitGenericPlayerSlots()
    call InitAllyPriorities()
endfunction




//Struct method generated initializers/callers:

