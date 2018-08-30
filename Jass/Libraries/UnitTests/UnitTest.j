
library STTUnitTest initializer init
	globals
		public boolean enabled = true
		private trigger MainTrigger
		private sound errorSound
		
		private hashtable UnitTests = InitHashtable()
	
		private boolean isRunning = false
		private boolean triggerSuccess = true
		
		private integer CurrentTestedTrigger = 0
		private integer NrOfTestTriggers = 0
		
		private real WaitBeforeTesting = 1.00
		private real WaitDurationBetweenTests = 0.10
		private real WaitExtraOnFail = 4.00
	endglobals
	
	private function B2S takes boolean b returns string
		if (b == true) then
			return "true"
		endif
		return "false"
	endfunction
	
	private function Msg takes string s returns nothing
		call BJDebugMsg(s)
	endfunction
	
	private function RunNextUnitTests takes nothing returns nothing
		if (CurrentTestedTrigger < NrOfTestTriggers) then
			set isRunning = true
			set triggerSuccess = true
			call TriggerExecute(LoadTriggerHandle(UnitTests, CurrentTestedTrigger, 0))
		endif
	endfunction

	private function Remove takes integer id returns nothing
		if (id != null) then
			call TriggerRemoveAction(LoadTriggerHandle(UnitTests, id, 0), LoadTriggerActionHandle(UnitTests, id, 1))
			call TriggerRemoveAction(LoadTriggerHandle(UnitTests, id, 0), LoadTriggerActionHandle(UnitTests, id, 2))
			call DestroyTrigger(LoadTriggerHandle(UnitTests, id, 0))
			call FlushChildHashtable(UnitTests, id)
		endif
	endfunction
	
	private function ActionCallback takes nothing returns nothing
		call TriggerSleepAction(WaitDurationBetweenTests)
		if (not triggerSuccess) then
			call TriggerSleepAction(WaitExtraOnFail)
		endif
		set isRunning = false
		call Remove(CurrentTestedTrigger)
		set CurrentTestedTrigger = CurrentTestedTrigger + 1
		call TriggerExecute(MainTrigger)
	endfunction
	
	public function Add takes code testFunc returns nothing
		local trigger t
		if (enabled) then
			set t = CreateTrigger()
			call SaveTriggerHandle(UnitTests, NrOfTestTriggers, 0, t)
			call SaveTriggerActionHandle(UnitTests, NrOfTestTriggers, 1, TriggerAddAction(t, testFunc))
			call SaveTriggerActionHandle(UnitTests, NrOfTestTriggers, 2, TriggerAddAction(t, function ActionCallback))
			set NrOfTestTriggers = NrOfTestTriggers + 1
		endif
		set t = null
	endfunction
	
	public function Success takes string msg returns nothing
		set triggerSuccess = true
		call Msg("|c0000FF00Success!|r: "+msg)
	endfunction
	
	public function Fail takes string msg returns nothing
		set triggerSuccess = false
		call Msg("|c00FF0000Failure!: |r" + msg)
		call StartSound(errorSound)
	endfunction
	
	public function AssertEqualsB takes boolean bool1, boolean bool2, string msg returns boolean
		local string assertMsg =  msg + ":: AssertEqualsB:: "+B2S(bool1)+"=="+B2S(bool2)
		local boolean ret = true
		if (bool1 == bool2) then
			call Success(assertMsg)
		else
			call Fail(assertMsg)
			set ret = false
		endif
		return ret
	endfunction
	
	public function AssertEqualsI takes integer int1, integer int2, string msg returns boolean
		local string assertMsg =  msg + ":: AssertEqualsI:: "+I2S(int1)+"=="+I2S(int2)
		local boolean ret = true
		if (int1 == int2) then
			call Success(assertMsg)
		else
			call Fail(assertMsg)
			set ret = false
		endif
		return ret
	endfunction
	
	public function AssertEqualsR takes real real1, real real2, string msg returns boolean
		local string assertMsg =  msg + ":: AssertEqualsR:: "+R2S(real1)+"=="+R2S(real2)
		local boolean ret = true
		if (real1 == real2) then
			call Success(assertMsg)
		else
			call Fail(assertMsg)
			set ret = false
		endif
		return ret
	endfunction
	
	public function AssertEqualsS takes string str1, string str2, string msg returns boolean
		local string assertMsg =  msg + ":: AssertEqualsS:: "+ str1 + "==" + str2
		local boolean ret = true
		if (str1 == str2) then
			call Success(assertMsg)
		else
			call Fail(assertMsg)
			set ret = false
		endif
		return ret
	endfunction
	
	public function AssertEqualsNotB takes boolean bool1, boolean bool2, string msg returns boolean
		local string assertMsg =  msg + ":: AssertEqualsNotB:: "+B2S(bool1)+"=="+B2S(bool2)
		local boolean ret = true
		if not(bool1 == bool2) then
			call Success(assertMsg)
		else
			call Fail(assertMsg)
			set ret = false
		endif
		return ret
	endfunction
	
	public function AssertEqualsNotI takes integer int1, integer int2, string msg returns boolean
		local string assertMsg =  msg + ":: AssertEqualsNotI:: "+I2S(int1)+"=="+I2S(int2)
		local boolean ret = true
		if not(int1 == int2) then
			call Success(assertMsg)
		else
			call Fail(assertMsg)
			set ret = false
		endif
		return ret
	endfunction
	
	public function AssertEqualsNotR takes real real1, real real2, string msg returns boolean
		local string assertMsg =  msg + ":: AssertEqualsNotR:: "+R2S(real1)+"=="+R2S(real2)
		local boolean ret = true
		if not(real1 == real2) then
			call Success(assertMsg)
		else
			call Fail(assertMsg)
			set ret = false
		endif
		return ret
	endfunction
	
	public function AssertEqualsNotS takes string str1, string str2, string msg returns boolean
		local string assertMsg =  msg + ":: AssertEqualsNotS:: "+ str1 + "==" + str2
		local boolean ret = true
		if not(str1 == str2) then
			call Success(assertMsg)
		else
			call Fail(assertMsg)
			set ret = false
		endif
		return ret
	endfunction
	
	
	private function init takes nothing returns nothing
		if (enabled) then
			set errorSound=CreateSound("Sound\\Interface\\QuestFailed.wav", false, false, false, 10, 10, "DefaultEAXON")
			call SetSoundParamsFromLabel(errorSound, "ErrorSound")
			call SetSoundDuration(errorSound, 4690)
		
			set MainTrigger = CreateTrigger()
			call TriggerRegisterTimerEvent(MainTrigger, WaitBeforeTesting, false)
			call TriggerAddAction(MainTrigger, function RunNextUnitTests)
			call Msg("UnitTest system by ScrewTheTrees.")
		endif
	endfunction
endlibrary
