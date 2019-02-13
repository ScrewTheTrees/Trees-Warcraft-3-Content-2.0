library Globals
    globals
        constant integer UNITTYPE_PLAYER = 'H000'
    endglobals



    function B2S takes boolean b returns string
        if (b) then
            return "true"
        endif
        return "false"
    endfunction
endlibrary