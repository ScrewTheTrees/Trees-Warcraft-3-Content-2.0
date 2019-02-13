library Combat
    struct CombatController
        public real mouseX = 0
        public real mouseY = 0

        public unit target = null


        public method SetTargetPosition takes real x, real y returns CombatController
            set mouseX = x
            set mouseY = y
            return this
        endmethod
    endstruct
endlibrary