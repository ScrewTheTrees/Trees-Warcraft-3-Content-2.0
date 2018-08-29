
library STTUnitTest initializer init
	globals
		public boolean enabled = true
		private trigger MainTrigger
	
		private hashtable UnitTests = InitHashtable()
		private integer NrOfTestTriggers = 0
		private boolean isRunning = false
		private integer CurrentTestedTrigger = 0
		
		private boolean success = true
		private real WaitBeforeTesting = 1.00
		private real WaitDurationBetweenTests = 1.00
		private real WaitExtraOnFail = 4.00
	endglobals
	
	private function Msg takes string s returns nothing
		call BJDebugMsg(s)
	endfunction
	
	private function RunNextUnitTests takes nothing returns nothing
		if (CurrentTestedTrigger < NrOfTestTriggers) then
			set isRunning = true
			set success = true
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
		if (not success) then
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
	
	public function AssertEqualsI takes integer int1, integer int2, string msg returns boolean
		if (int1 == int2) then
			call Msg("|c0096FF96"+msg+", Success!: |r"+I2S(int1)+"=="+I2S(int2))
			set success = true
		else
			call Msg("|c00FF0000"+msg+", Failure!: |r"+I2S(int1)+"=="+I2S(int2))
			set success = false
			return false
		endif
		return true
	endfunction
	
	private function init takes nothing returns nothing
		if (enabled) then
			set MainTrigger = CreateTrigger()
			call TriggerRegisterTimerEvent(MainTrigger, WaitBeforeTesting, false)
			call TriggerAddAction(MainTrigger, function RunNextUnitTests)
			call Msg("UnitTest system by ScrewTheTrees.")
		endif
	endfunction
endlibrary
