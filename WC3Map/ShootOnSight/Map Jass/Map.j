//! import "D:\Dropbox\Attacka Dropbox\Warcraft 3 Content\WC3Map\ShootOnSight\Map Jass\Globals.j"
//! import "D:\Dropbox\Attacka Dropbox\Warcraft 3 Content\WC3Map\ShootOnSight\Map Jass\Debug.j"
//! import "D:\Dropbox\Attacka Dropbox\Warcraft 3 Content\WC3Map\ShootOnSight\Map Jass\ArrayList.j"
//! import "D:\Dropbox\Attacka Dropbox\Warcraft 3 Content\WC3Map\ShootOnSight\Map Jass\Alliances.j"

//! import "D:\Dropbox\Attacka Dropbox\Warcraft 3 Content\WC3Map\ShootOnSight\Map Jass\PlayerController\PlayerController.j"

library Map initializer InitMap requires Alliances, PlayerControllerLib, Debug, Globals
    //We are expecting JASS3 to clean up most generic leaks when it releases.
    //So some "leaks" are currently still present in code intentionally.
    globals
        private trigger start = CreateTrigger()
        private trigger rapidLoop = CreateTrigger()
    endglobals

    private function SetMapFlags takes nothing returns nothing
        call SetMapFlag(MAP_LOCK_ALLIANCE_CHANGES, true)
        call SetMapFlag(MAP_ALLIANCE_CHANGES_HIDDEN, true)
        call SetMapFlag(MAP_LOCK_RESOURCE_TRADING, true)
        call SetMapFlag(MAP_RESOURCE_TRADING_ALLIES_ONLY, true)
    endfunction

    private function Start takes nothing returns nothing
        call Alliances_MakePlayerTeams()
        call Alliances_MakePlayerAlliances()
        call Alliances_RemoveInactivePlayers()

        call SetMapFlags()
        call PlayerControllerLib_CreateForAllPlayers()

        call Debug_LogVerboose("Great init for InitMap .")
        call TriggerClearActions(start)
        call DestroyTrigger(start)
    endfunction

    public function ForEachRapidLoop takes nothing returns nothing
        local player p = GetEnumPlayer()
        local integer pid = GetPlayerId(p)
        local MovementController mc = playerControllers[pid].movement
        local CombatController cc = playerControllers[pid].combat
        call Debug_LogVerboose("pressDown: "+B2S(mc.pressDown))
        call Debug_LogVerboose("pressLeft: "+B2S(mc.pressLeft))
        call Debug_LogVerboose("pressRight: "+B2S(mc.pressRight))
        call Debug_LogVerboose("pressUp: "+B2S(mc.pressUp))
        call Debug_LogVerboose("mouseX: "+R2S(cc.mouseX))
        call Debug_LogVerboose("mouseY: "+R2S(cc.mouseY))
    endfunction

    private function RapidLoop takes nothing returns nothing
        call ForForce(Alliances_forcePlayers, function ForEachRapidLoop)
    endfunction

    private function InitMap takes nothing returns nothing
        call TriggerRegisterTimerEvent(start, 0, false)
        call TriggerAddAction(start, function Start)

        call TriggerRegisterTimerEvent(rapidLoop, 0.02, true)
        call TriggerAddAction(rapidLoop, function RapidLoop)
    endfunction
endlibrary