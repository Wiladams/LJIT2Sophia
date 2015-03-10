local ffi = require("ffi");

local sophia = require("sophia_ffi")
sophia.promoteToGlobal();




ffi.cdef[[
void free(void *);
]]

function free(value)
    return ffi.C.free(value);
end

function strdup(str)
    local newstr = ffi.new("char[?]", #str+1);
    ffi.copy(newstr, ffi.cast("char *",str), #str);
    newstr[#str] = 0;
    return newstr;
end

