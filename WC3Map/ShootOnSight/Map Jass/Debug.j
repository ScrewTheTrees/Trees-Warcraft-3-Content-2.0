library Debug
    globals
        private boolean do_debug = true
    endglobals

    public function LogVerboose takes string s returns nothing
        if (do_debug) then
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 2, "Verboose: " + s)
        endif
    endfunction
    public function LogWarning takes string s returns nothing
        if (do_debug) then
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 5, "|cFFFFB300Warning: " + s + "|r")
        endif
    endfunction
    public function LogCritical takes string s returns nothing
        if (do_debug) then
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10, "|cFF000000Critical: " + s + "|r")
        endif
    endfunction
endlibrary