library RocketEngine initializer Init
	
	private function Debug takes string msg returns nothing
		call DisplayTimedTextToPlayer(Player(0),0,0,2,msg)
	endfunction
	
	private function GetAngleFromXY takes real x, real y returns real
		local real d = Atan2(y, x) * (180 / 3.14)
		if (d < 0) then
			set d = 360 + d
		endif
		return d
	endfunction
	
	private function AngleDiff takes real angle1, real angle2 returns real
		local real ang = angle1 - angle2
		if (ang > 180) then
			set ang = ang - 360
		elseif (ang < -180) then
			set ang = ang + 360
		endif
		return (ang)
	endfunction
	
	public struct Rocket
		player owner
		unit rocket
		
		real mouseX
		real mouseY
		real posX
		real posY
		
		real maxSpeed = 50
		real acceleration = 0.02
		real speed = 0
		real direction = 0
		real turningSpeed = 1
		
		static method create takes player owner, unit rocket returns Rocket
			local Rocket roc = Rocket.allocate()
			set roc.owner = owner
			set roc.rocket = rocket
			set roc.posX = GetUnitX(rocket)
			set roc.posY = GetUnitY(rocket)
			return roc
		endmethod
		
		private method onDestroy takes nothing returns nothing
			set owner = null
			set rocket = null
		endmethod
		
		public method SetPosition takes real x, real y returns nothing
			set posX = x
			set posY = y
			call SetUnitX(rocket, x)
			call SetUnitY(rocket, y)
		endmethod
		
		public method RotateTowards takes real angle returns nothing
			set direction = direction + angle
			set direction = ModuloReal(direction, 360)
		endmethod
		
		public method SetMousePosition takes real x, real y returns nothing
			set mouseX = x
			set mouseY = y
		endmethod
		
		public method Update takes nothing returns nothing
			local real angle = GetAngleFromXY(mouseX - posX, mouseY - posY)
			local real diff = AngleDiff(angle, direction)
			local location start = Location(posX, posY)
			local location end
			
			if (speed < maxSpeed) then
				set speed = speed + acceleration
			elseif (speed > maxSpeed) then
				set speed = maxSpeed
			endif
			if (diff > turningSpeed) then
				call RotateTowards(turningSpeed)
			elseif (diff < -turningSpeed) then
				call RotateTowards(-turningSpeed)
			else
				call RotateTowards(diff)
			endif
			call Debug("angle: "+R2S(angle))
			call Debug("dir: "+R2S(direction))
			call Debug("diff: "+R2S(diff))
			call Debug("speed: "+R2S(speed))
			call Debug("----------------------")
			
			set end = PolarProjectionBJ(start, speed, direction)
			
			call SetPosition(GetLocationX(end), GetLocationY(end))
			call RemoveLocation(start)
			call RemoveLocation(end)
		endmethod
	endstruct
	
	globals
		private Rocket array AllRockets
		private trigger engineLoop = CreateTrigger()
		private trigger mouseUpdate = CreateTrigger()
		private integer AllRocketsLength = 0
	endglobals
	
	public function CountRocketsByPlayer takes player p returns integer
		local integer i = 0
		local integer total = 0
		loop
			exitwhen (i >= AllRocketsLength)
			if (GetPlayerId(AllRockets[i].owner) == GetPlayerId(p)) then
				set total = total + 1
			endif
			set i = i + 1
		endloop
		return total
	endfunction
	
	//Returns -1 on failure, index is the index of the rocket owned by this player and not all players.
	public function GetRocketByPlayerAndIndex takes player p, integer index returns Rocket
		local integer i = 0
		local integer total = 0
		loop
			exitwhen (i >= AllRocketsLength)
			if (GetPlayerId(AllRockets[i].owner) == GetPlayerId(p)) then
				if (total == index) then
					return AllRockets[i]
				endif
				set total = total + 1
			endif
			set i = i + 1
		endloop
		return -1
	endfunction
	
	public function CreateRocket takes player owner, integer unitType returns Rocket
		local unit rocketUnit = CreateUnit(owner, unitType, 0, 0, 0)
		local Rocket roc = Rocket.create(owner, rocketUnit)
		set AllRockets[AllRocketsLength] = roc
		set AllRocketsLength = AllRocketsLength + 1
		return roc
	endfunction
	
	private function MouseUpdateAction takes nothing returns nothing
		local player p = GetTriggerPlayer()
		local real mx = BlzGetTriggerPlayerMouseX()
		local real my = BlzGetTriggerPlayerMouseY()
		local integer nrOfRockets = CountRocketsByPlayer(p)
		local integer i = 0
		local Rocket r
		
		loop
			exitwhen (i >= nrOfRockets)
			set r = GetRocketByPlayerAndIndex(p, i)
			
			if (mx != 0 and my != 0) then
				call r.SetMousePosition(mx, my)
			endif
			
			set i = i + 1
		endloop
	endfunction
	
	private function EngineLoopAction takes nothing returns nothing
		local integer i = 0
		loop
			exitwhen (i >= AllRocketsLength)
			call AllRockets[i].Update()
			set i = i + 1
		endloop
	endfunction
	
	private function CreateRocketsForAll takes nothing returns nothing
		local integer i = 0
		loop
			exitwhen (i >= GetBJMaxPlayers())
			call CreateRocket(Player(i), 'e000')
			set i = i + 1
		endloop
	endfunction

	private function Init takes nothing returns nothing
		local integer i = 0
		loop
			exitwhen (i >= GetBJMaxPlayers())
			call TriggerRegisterPlayerEvent(mouseUpdate, Player(i), EVENT_PLAYER_MOUSE_MOVE)
			set i = i + 1
		endloop
		call TriggerAddAction(mouseUpdate, function MouseUpdateAction)
	
		call TriggerRegisterTimerEvent(engineLoop, 0.0167, true)
		call TriggerAddAction(engineLoop, function EngineLoopAction)
		
		call CreateRocket(Player(0), 'e000')
	endfunction
endlibrary