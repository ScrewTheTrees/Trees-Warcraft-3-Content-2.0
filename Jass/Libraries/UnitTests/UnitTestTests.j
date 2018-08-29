

library STTUnitTestTests initializer init requires STTUnitTest
	private function TestAssertEqualsI takes nothing returns nothing
		call STTUnitTest_AssertEqualsI(33, 33, "TestAssertEqualsI")
	endfunction
	private function TestAssertEqualsIFailure takes nothing returns nothing
		call STTUnitTest_AssertEqualsI(22, 31, "TestAssertEqualsIFailure")
	endfunction

	//===========================================================================
	private function init takes nothing returns nothing
		call STTUnitTest_Add(function TestAssertEqualsI)
		call STTUnitTest_Add(function TestAssertEqualsIFailure)
	endfunction
endlibrary
