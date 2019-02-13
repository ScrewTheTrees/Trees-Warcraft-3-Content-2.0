//! import "D:\Dropbox\Attacka Dropbox\Warcraft 3 Content\WC3Map\ShootOnSight\Map Jass\PlayerController\Movement.j"
//! import "D:\Dropbox\Attacka Dropbox\Warcraft 3 Content\WC3Map\ShootOnSight\Map Jass\PlayerController\Combat.j"

library PlayerControllerLib requires Movement, Combat, Alliances
    globals
        private trigger keyPressRight = CreateTrigger()
        private trigger keyPressLeft = CreateTrigger()
        private trigger keyPressUp = CreateTrigger()
        private trigger keyPressDown = CreateTrigger()
        private trigger keyReleaseRight = CreateTrigger()
        private trigger keyReleaseLeft = CreateTrigger()
        private trigger keyReleaseUp = CreateTrigger()
        private trigger keyReleaseDown = CreateTrigger()

        private trigger mouseClickInput = CreateTrigger()
        private trigger mouseMoveInput = CreateTrigger()
        PlayerController array playerControllers
    endglobals

    struct PlayerController
        public MovementController movement
        public CombatController combat
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
        public method HandleKeyInput takes integer key, boolean pressed returns PlayerController
            call movement.HandleKeyInput(key, pressed)
            return this
        endmethod
        public static method GetByPlayer takes player p returns PlayerController
            local integer pid = GetPlayerId(p)
            return playerControllers[pid]
        endmethod
    endstruct


    private function onPressRight takes nothing returns nothing
        local PlayerController pc = PlayerController.GetByPlayer(GetTriggerPlayer())
        call pc.HandleKeyInput(KEY_RIGHT, true)
    endfunction
    private function onPressLeft takes nothing returns nothing
        local PlayerController pc = PlayerController.GetByPlayer(GetTriggerPlayer())
        call pc.HandleKeyInput(KEY_LEFT, true)
    endfunction
    private function onPressUp takes nothing returns nothing
        local PlayerController pc = PlayerController.GetByPlayer(GetTriggerPlayer())
        call pc.HandleKeyInput(KEY_UP, true)
    endfunction
    private function onPressDown takes nothing returns nothing
        local PlayerController pc = PlayerController.GetByPlayer(GetTriggerPlayer())
        call pc.HandleKeyInput(KEY_DOWN, true)
    endfunction
    private function onReleaseRight takes nothing returns nothing
        local PlayerController pc = PlayerController.GetByPlayer(GetTriggerPlayer())
        call pc.HandleKeyInput(KEY_RIGHT, false)
    endfunction
    private function onReleaseLeft takes nothing returns nothing
        local PlayerController pc = PlayerController.GetByPlayer(GetTriggerPlayer())
        call pc.HandleKeyInput(KEY_LEFT, false)
    endfunction
    private function onReleaseUp takes nothing returns nothing
        local PlayerController pc = PlayerController.GetByPlayer(GetTriggerPlayer())
        call pc.HandleKeyInput(KEY_UP, false)
    endfunction
    private function onReleaseDown takes nothing returns nothing
        local PlayerController pc = PlayerController.GetByPlayer(GetTriggerPlayer())
        call pc.HandleKeyInput(KEY_DOWN, false)
    endfunction


    private function onMouseClickEvent takes nothing returns nothing
        local mousebuttontype buttonType = BlzGetTriggerPlayerMouseButton()
        local real x = BlzGetTriggerPlayerMouseX()
        local real y = BlzGetTriggerPlayerMouseY()
        local PlayerController pc = PlayerController.GetByPlayer(GetTriggerPlayer())
        set pc.combat.mouseX = x
        set pc.combat.mouseY = y
    endfunction
    private function onMouseMoveEvent takes nothing returns nothing
        local real x = BlzGetTriggerPlayerMouseX()
        local real y = BlzGetTriggerPlayerMouseY()
        local PlayerController pc = PlayerController.GetByPlayer(GetTriggerPlayer())
        set pc.combat.mouseX = x
        set pc.combat.mouseY = y
    endfunction

    private function ForEachEnum takes nothing returns nothing
        local player p = GetEnumPlayer()
        local integer pid = GetPlayerId(p)
        set playerControllers[pid] = PlayerController.create(p)

        call TriggerRegisterPlayerEvent(keyPressLeft, p, EVENT_PLAYER_ARROW_LEFT_DOWN)
        call TriggerRegisterPlayerEvent(keyPressRight, p, EVENT_PLAYER_ARROW_RIGHT_DOWN)
        call TriggerRegisterPlayerEvent(keyPressDown, p, EVENT_PLAYER_ARROW_DOWN_DOWN)
        call TriggerRegisterPlayerEvent(keyPressUp, p, EVENT_PLAYER_ARROW_UP_DOWN)

        call TriggerRegisterPlayerEvent(keyReleaseLeft, p, EVENT_PLAYER_ARROW_LEFT_UP)
        call TriggerRegisterPlayerEvent(keyReleaseRight, p, EVENT_PLAYER_ARROW_RIGHT_UP)
        call TriggerRegisterPlayerEvent(keyReleaseDown, p, EVENT_PLAYER_ARROW_DOWN_UP)
        call TriggerRegisterPlayerEvent(keyReleaseUp, p, EVENT_PLAYER_ARROW_UP_UP)

        call TriggerRegisterPlayerEvent(mouseClickInput, p, EVENT_PLAYER_MOUSE_DOWN)
        call TriggerRegisterPlayerEvent(mouseClickInput, p, EVENT_PLAYER_MOUSE_UP)
        call TriggerRegisterPlayerEvent(mouseMoveInput, p, EVENT_PLAYER_MOUSE_MOVE)
    endfunction

    public function CreateForAllPlayers takes nothing returns nothing
        call ForForce(Alliances_forcePlayers, function ForEachEnum)

        call TriggerAddAction(keyPressRight, function onPressRight)
        call TriggerAddAction(keyPressLeft, function onPressLeft)
        call TriggerAddAction(keyPressUp, function onPressUp)
        call TriggerAddAction(keyPressDown, function onPressDown)
        call TriggerAddAction(keyReleaseRight, function onReleaseRight)
        call TriggerAddAction(keyReleaseLeft, function onReleaseLeft)
        call TriggerAddAction(keyReleaseUp, function onReleaseUp)
        call TriggerAddAction(keyReleaseDown, function onReleaseDown)
        
        call TriggerAddAction(mouseClickInput, function onMouseClickEvent)
        call TriggerAddAction(mouseMoveInput, function onMouseMoveEvent)
    endfunction
endlibrary