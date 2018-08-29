
library STTUnitTest initializer init
	private struct UnitTest
		public trigger Trigger = null
		public triggeraction TriggerAction = null
		public triggeraction TriggerActionCallback = null
	endstruct
	
	globals
		public boolean enabled = true
		private trigger MainTrigger
	
		private UnitTest array UnitTests
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
	
	private function RunNextUnitTest takes nothing returns nothing
		if (CurrentTestedTrigger < NrOfTestTriggers) then
			set isRunning = true
			set success = true
			call TriggerExecute(UnitTests[CurrentTestedTrigger].Trigger)
		endif
	endfunction

	private function Remove takes integer id returns nothing
		local UnitTest ut = UnitTests[id]
		if (id != null) then
			call TriggerRemoveAction(ut.Trigger, ut.TriggerAction)
			call TriggerRemoveAction(ut.Trigger, ut.TriggerActionCallback)
			call DestroyTrigger(ut.Trigger)
			set ut.Trigger = null
			set ut.TriggerAction = null
			set ut.TriggerActionCallback = null
			call ut.destroy()
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
		local UnitTest ut
		if (enabled) then
			set ut = UnitTest.create()
			set ut.Trigger = CreateTrigger()
			set ut.TriggerAction = TriggerAddAction(ut.Trigger, testFunc)
			set ut.TriggerActionCallback = TriggerAddAction(ut.Trigger, function ActionCallback)
			set UnitTests[NrOfTestTriggers] = ut
			set NrOfTestTriggers = NrOfTestTriggers + 1
		endif
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
			call TriggerAddAction(MainTrigger, function RunNextUnitTest)
			call Msg("UnitTest system by ScrewTheTrees.")
		endif
	endfunction
endlibrary
