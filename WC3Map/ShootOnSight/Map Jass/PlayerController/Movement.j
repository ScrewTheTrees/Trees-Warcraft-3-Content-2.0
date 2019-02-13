library Movement
    globals
        constant integer KEY_RIGHT = 0
        constant integer KEY_LEFT = 1
        constant integer KEY_DOWN = 2
        constant integer KEY_UP = 3
    endglobals
    struct MovementController
        public real cameraAngle = 0
        public real movementAngle = 0

        public unit target = null

        public boolean pressUp = false
        public boolean pressDown = false
        public boolean pressLeft = false
        public boolean pressRight = false

        public method HandleKeyInput takes integer key, boolean state returns nothing
            if (key == KEY_RIGHT) then
                set pressRight = state
            elseif (key == KEY_LEFT) then
                set pressLeft = state
            elseif (key == KEY_DOWN) then
                set pressDown = state
            elseif (key == KEY_UP) then
                set pressUp = state
            endif
        endmethod
    endstruct
endlibrary
