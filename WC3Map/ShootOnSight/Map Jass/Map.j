//! import "D:\Dropbox\Attacka Dropbox\Warcraft 3 Content\WC3Map\ShootOnSight\Map Jass\Debug.j"
//! import "D:\Dropbox\Attacka Dropbox\Warcraft 3 Content\WC3Map\ShootOnSight\Map Jass\ArrayList.j"
//! import "D:\Dropbox\Attacka Dropbox\Warcraft 3 Content\WC3Map\ShootOnSight\Map Jass\Alliances.j"

//! import "D:\Dropbox\Attacka Dropbox\Warcraft 3 Content\WC3Map\ShootOnSight\Map Jass\PlayerController\PlayerController.j"

library Map initializer InitMap requires Alliances, PlayerController, Debug
    //We are expecting JASS3 to clean up most generic leaks when it releases.
    //So some "leaks" are currently still present in code intentionally.
    globals
        private trigger start = CreateTrigger()
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
        call PlayerController_CreateForAllPlayers()

        call Debug_LogVerboose("Great init for InitMap .")
        call TriggerClearActions(start)
        call DestroyTrigger(start)
    endfunction

    private function InitMap takes nothing returns nothing
        call TriggerRegisterTimerEvent(start, 0, false)
        call TriggerAddAction(start, function Start)
    endfunction
endlibrary