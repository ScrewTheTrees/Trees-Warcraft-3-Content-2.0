

library STTUnitTestTests initializer init requires STTUnitTest
	private function TestAssertEqualsB takes nothing returns nothing
		call STTUnitTest_AssertEqualsB(true, true, "TestAssertEqualsB")
	endfunction
	private function TestAssertEqualsI takes nothing returns nothing
		call STTUnitTest_AssertEqualsI(33, 33, "TestAssertEqualsI")
	endfunction
	private function TestAssertEqualsR takes nothing returns nothing
		call STTUnitTest_AssertEqualsR(33.5, 33.5, "TestAssertEqualsR")
	endfunction
	private function TestAssertEqualsS takes nothing returns nothing
		call STTUnitTest_AssertEqualsS("cake", "cake", "TestAssertEqualsS")
	endfunction
	private function TestAssertEqualsNotB takes nothing returns nothing
		call STTUnitTest_AssertEqualsNotB(true, false, "TestAssertEqualsNotB")
	endfunction
	private function TestAssertEqualsNotI takes nothing returns nothing
		call STTUnitTest_AssertEqualsNotI(22, 31, "TestAssertEqualsNotI")
	endfunction
	private function TestAssertEqualsNotR takes nothing returns nothing
		call STTUnitTest_AssertEqualsNotR(30.8, 31.2, "TestAssertEqualsNotR")
	endfunction
	private function TestAssertEqualsNotS takes nothing returns nothing
		call STTUnitTest_AssertEqualsNotS("cake", "family", "TestAssertEqualsNotS")
	endfunction
	
	private function TestFail takes nothing returns nothing
		call STTUnitTest_Fail("Im gonna fail!")
	endfunction
	private function TestSuccess takes nothing returns nothing
		call STTUnitTest_Success("Im gonna work!")
	endfunction
	
	private function TestAssertGreaterThanI takes nothing returns nothing
		call STTUnitTest_AssertGreaterThanI(99, 22, "TestAssertGreaterThanI")
	endfunction
	private function TestAssertGreaterThanR takes nothing returns nothing
		call STTUnitTest_AssertGreaterThanR(22.27, 22.25, "TestAssertGreaterThanR")
	endfunction

	private function TestAssertLessThanI takes nothing returns nothing
		call STTUnitTest_AssertLessThanI(1996, 2005, "TestAssertLessThanI")
	endfunction
	private function TestAssertLessThanR takes nothing returns nothing
		call STTUnitTest_AssertLessThanR(2004.9, 2005, "TestAssertLessThanR")
	endfunction
	
	//===========================================================================
	private function init takes nothing returns nothing
		call STTUnitTest_Add(function TestAssertEqualsB)
		call STTUnitTest_Add(function TestAssertEqualsI)
		call STTUnitTest_Add(function TestAssertEqualsR)
		call STTUnitTest_Add(function TestAssertEqualsS)
		call STTUnitTest_Add(function TestAssertEqualsNotB)
		call STTUnitTest_Add(function TestAssertEqualsNotI)
		call STTUnitTest_Add(function TestAssertEqualsNotR)
		call STTUnitTest_Add(function TestAssertEqualsNotS)
		call STTUnitTest_Add(function TestFail)
		call STTUnitTest_Add(function TestSuccess)
		call STTUnitTest_Add(function TestAssertGreaterThanI)
		call STTUnitTest_Add(function TestAssertGreaterThanR)
		call STTUnitTest_Add(function TestAssertLessThanI)
		call STTUnitTest_Add(function TestAssertLessThanR)
	endfunction
endlibrary
