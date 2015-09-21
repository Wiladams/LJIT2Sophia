package.path = package.path..";../?.lua"

local ffi = require("ffi");

local sophia = require("sophia")()
local libc = require("libc")()


function strdup(str)
    local newstr = ffi.new("char[?]", #str+1);
    ffi.copy(newstr, ffi.cast("const char *",str), #str);
    newstr[#str] = 0;
    return newstr;
end

return sophia

