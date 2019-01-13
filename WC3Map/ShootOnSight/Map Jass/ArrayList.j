library ArrayList
    struct IntegerList
        private integer array list[500]
        private integer length = 0
        private boolean isOrdered = true

        public method Add takes integer value returns IntegerList
            set list[length] = value
            set length = length + 1
            return this
        endmethod
        public method Remove takes integer index returns IntegerList
            if (index >= 0 and index < length) then
                if (isOrdered) then
                    call RemoveOrdered(index)
                else
                    call RemoveUnordered(index)
                endif
            endif
            return this
        endmethod
        public method Get takes integer index returns integer
            if (index >= 0 and index < length) then
                return list[index]
            endif
            return this
        endmethod
        public method GetLength takes nothing returns integer
            return length
        endmethod
        public method SetOrdered takes boolean value returns nothing
            set isOrdered = value
        endmethod
        public method GetOrdered takes nothing returns boolean
            return isOrdered
        endmethod
        
        private method RemoveOrdered takes integer index returns nothing
            set length = length - 1
            loop
                exitwhen index > length
                set list[index] = list[index + 1]

                set index = index + 1
            endloop
        endmethod
        private method RemoveUnordered takes integer index returns nothing
            set length = length - 1
            set list[index] = list[length]
        endmethod
    endstruct
endlibrary
