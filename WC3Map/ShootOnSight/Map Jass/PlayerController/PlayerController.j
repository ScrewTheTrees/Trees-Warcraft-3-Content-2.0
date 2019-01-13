//! import "D:\Dropbox\Attacka Dropbox\Warcraft 3 Content\WC3Map\ShootOnSight\Map Jass\PlayerController\Movement.j"
//! import "D:\Dropbox\Attacka Dropbox\Warcraft 3 Content\WC3Map\ShootOnSight\Map Jass\PlayerController\Combat.j"

library PlayerController requires Movement, Combat, Alliances
    globals
        private trigger keyboardInput = CreateTrigger()
        private trigger mouseInput = CreateTrigger()
    endglobals

    struct PlayerController
        private MovementController movement
        private CombatController combat
        private player myPlayer

        public static method create takes player p returns PlayerController
            local PlayerController plcr = PlayerController.allocate()
            set plcr.myPlayer = p
            set plcr.movement = MovementController.create()
            set plcr.combat = CombatController.create()
            return plcr
        endmethod

        public method onDestroy takes nothing returns nothing
            call movement.destroy()
            call combat.destroy()
        endmethod

        public method SetTarget takes unit target returns nothing
            set movement.target = target
            set combat.target = target
        endmethod
    endstruct


    private function onKeyboardEvent takes nothing returns nothing

    endfunction
    private function onMouseEvent takes nothing returns nothing
        
    endfunction

    private function forEachEnum takes nothing returns nothing
        local player p = GetEnumPlayer()

        call TriggerRegisterPlayerEvent(keyboardInput, p, EVENT_PLAYER_ARROW_LEFT_DOWN)
        call TriggerRegisterPlayerEvent(keyboardInput, p, EVENT_PLAYER_ARROW_RIGHT_DOWN)
        call TriggerRegisterPlayerEvent(keyboardInput, p, EVENT_PLAYER_ARROW_DOWN_DOWN)
        call TriggerRegisterPlayerEvent(keyboardInput, p, EVENT_PLAYER_ARROW_UP_DOWN)

        call TriggerRegisterPlayerEvent(keyboardInput, p, EVENT_PLAYER_ARROW_LEFT_UP)
        call TriggerRegisterPlayerEvent(keyboardInput, p, EVENT_PLAYER_ARROW_RIGHT_UP)
        call TriggerRegisterPlayerEvent(keyboardInput, p, EVENT_PLAYER_ARROW_DOWN_UP)
        call TriggerRegisterPlayerEvent(keyboardInput, p, EVENT_PLAYER_ARROW_UP_UP)

        call TriggerRegisterPlayerEvent(mouseInput, p, EVENT_PLAYER_MOUSE_DOWN)
        call TriggerRegisterPlayerEvent(mouseInput, p, EVENT_PLAYER_MOUSE_UP)
        call TriggerRegisterPlayerEvent(mouseInput, p, EVENT_PLAYER_MOUSE_MOVE)
    endfunction

    public function CreateForAllPlayers takes nothing returns nothing
        call ForForce(Alliances_forcePlayers, function forEachEnum)
        call TriggerAddAction(keyboardInput, onKeyboardEvent)
        call TriggerAddAction(mouseInput, onMouseEvent)
    endfunction
endlibrary