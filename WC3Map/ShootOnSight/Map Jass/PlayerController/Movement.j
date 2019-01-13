library Movement
    struct MovementController
        public real cameraAngle = 0
        public real movementAngle = 0

        public unit target = null

        public boolean pressUp = false
        public boolean pressDown = false
        public boolean pressLeft = false
        public boolean pressRight = false
    endstruct
endlibrary