local sophia = require("sophia")

local ffi = require("ffi");

local function strdup(str)
    local newstr = ffi.new("char[?]", #str+1);
    ffi.copy(newstr, ffi.cast("char *",str), #str);
    newstr[#str] = 0;
    return newstr;
end

local db, err = sophia.SophiaDatabase("./db");

print("DB: ", db, err);

if not db then
    print("Database Creation ERROR: ", err);
    return false, err
end

-- Insert some values into the database
local str = "hello world"
local value = strdup(str);
local key = 0;
local keybuff = ffi.new("int[1]",key);

while key < 10 do
    keybuff[0] = key
    local success, err = db:set(keybuff, ffi.sizeof(keybuff), value, #str); 
    if not success then
        print("db:set(), ERROR: ", key, err);
    end
    print("SET: ", key);
    key = key + 1;
end

-- Retrieve values from database
key = 0;
while key < 10 do
    keybuff[0] = key
    local value = ffi.new("void *[1]");
    local valuesize = ffi.new("size_t[1]");
    local success, err = db:get(keybuff, ffi.sizeof(keybuff), value, valuesize);
    
    if not success then
        print("sp_get ERROR: ", err);
        break;
    end

    print(string.format("key: %d, value: %s", key, ffi.string(value[0], valuesize[0])));
    --ffi.C.free(value[0]);
    key= key + 1;
end

