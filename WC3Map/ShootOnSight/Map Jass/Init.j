library Map initializer InitMap
    //We are expecting JASS3 to clean up most generic leaks when it releases.
    //So some "leaks" are currently still present in code intentionally.
    globals
        public force forcePlayers = CreateForce()
        public force forceAllies = CreateForce()
        public force forceEnemies = CreateForce()
        private trigger start = CreateTrigger()
    endglobals
    private function Msg takes string s returns nothing
        local integer i = 0
        loop
            call DisplayTimedTextToPlayer(Player(i),0,0,5,s)
            set i = i + 1
            exitwhen i == bj_MAX_PLAYERS
        endloop
    endfunction


    private function MakePlayerTeams takes nothing returns nothing
        call ForceAddPlayer(forcePlayers, Player(1))
        call ForceAddPlayer(forcePlayers, Player(2))
        call ForceAddPlayer(forcePlayers, Player(10))
        call ForceAddPlayer(forcePlayers, Player(13))
        call ForceAddPlayer(forcePlayers, Player(14))
        call ForceAddPlayer(forcePlayers, Player(21))


        call ForceAddPlayer(forceEnemies, Player(0))
        call ForceAddPlayer(forceAllies, Player(4))

    endfunction

    private function AssertAlliancePlayer takes player p, player p2 returns nothing
        if (IsPlayerInForce(p2, forcePlayers)) then //Is another player
            call SetPlayerAllianceStateBJ(p, p2, bj_ALLIANCE_ALLIED_VISION)
        elseif (IsPlayerInForce(p2, forceEnemies)) then //Is enemy
            call SetPlayerAllianceStateBJ(p, p2, bj_ALLIANCE_UNALLIED)
        elseif (IsPlayerInForce(p2, forceAllies)) then //Is ally
            call SetPlayerAllianceStateBJ(p, p2, bj_ALLIANCE_ALLIED)
        endif
    endfunction
    private function AssertAllianceEnemy takes player p, player p2 returns nothing
        if (IsPlayerInForce(p2, forcePlayers)) then //Is player
            call SetPlayerAllianceStateBJ(p, p2, bj_ALLIANCE_UNALLIED)
        elseif (IsPlayerInForce(p2, forceEnemies)) then //Is another enemy
            call SetPlayerAllianceStateBJ(p, p2, bj_ALLIANCE_ALLIED_VISION)
        elseif (IsPlayerInForce(p2, forceAllies)) then //Is ally, probably be unallied at times.
            call SetPlayerAllianceStateBJ(p, p2, bj_ALLIANCE_ALLIED)
        endif
    endfunction
    private function AssertAllianceAlly takes player p, player p2 returns nothing
        call SetPlayerAllianceStateBJ(p, p2, bj_ALLIANCE_ALLIED)
    endfunction

    private function MakePlayerAlliances takes nothing returns nothing
        local integer i = 0
        local integer j = 0
        local player p
        local player p2

        loop
            exitwhen i > bj_MAX_PLAYERS
            set p = Player(i)

            set j = 0
            loop
                exitwhen j > bj_MAX_PLAYERS
                set p2 = Player(j)
                if not(i == j) then
                    if (IsPlayerInForce(p, forcePlayers)) then //Is player
                        call AssertAlliancePlayer(p, p2)
                    elseif (IsPlayerInForce(p, forceEnemies)) then //Is enemy
                        call AssertAllianceEnemy(p, p2)
                    elseif (IsPlayerInForce(p, forceAllies)) then //Is ally
                        call AssertAllianceAlly(p, p2)
                    endif
                endif
                set j = j + 1
            endloop

            set i = i + 1
        endloop
    endfunction

    private function RemoveInactivePlayers takes nothing returns nothing
        local integer i = 0
        local player p
            
        loop
            exitwhen i > bj_MAX_PLAYERS
            set p = Player(i)
                if (GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(p) == MAP_CONTROL_COMPUTER) then
                    call ForceRemovePlayer(forcePlayers, p)
                endif
                if (GetPlayerSlotState(p) == PLAYER_SLOT_STATE_EMPTY or GetPlayerSlotState(p) == PLAYER_SLOT_STATE_LEFT) then
                    call ForceRemovePlayer(forcePlayers, p)
                endif
            set i = i + 1
        endloop
    endfunction

    private function SetMapFlags takes nothing returns nothing
        call SetMapFlag(MAP_LOCK_ALLIANCE_CHANGES, true)
        call SetMapFlag(MAP_ALLIANCE_CHANGES_HIDDEN, true)
        call SetMapFlag(MAP_LOCK_RESOURCE_TRADING, true)
        call SetMapFlag(MAP_RESOURCE_TRADING_ALLIES_ONLY, true)
    endfunction

    private function Start takes nothing returns nothing
        call MakePlayerTeams()
        call MakePlayerAlliances()
        call SetMapFlags()

        call RemoveInactivePlayers()
    endfunction

    private function InitMap takes nothing returns nothing
        call TriggerRegisterTimerEvent(start, 1, false)
        call TriggerAddAction(start, function Start)
    endfunction
endlibrary