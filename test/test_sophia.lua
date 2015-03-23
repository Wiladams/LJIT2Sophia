local sophia = require("sophia")

local ffi = require("ffi");

ffi.cdef[[
void free(void *);
]]

local function free(value)
    return ffi.C.free(value);
end

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

while key < 10 do
    local success, err = db:upsert(tostring(key), str);

    if not success then
        print("db:set(), ERROR: ", key, err);
    end
    print("SET: ", key);
    key = key + 1;
end

-- Retrieve values from database using raw calls
print("== GET ==")
key = 0;
while key < 10 do
    local keystr = tostring(key);
    local value = ffi.new("void *[1]");
    local valuesize = ffi.new("size_t[1]");
    local success, err = db:get(keystr, #keystr, value, valuesize);
    if not success then
        print("sp_get ERROR: ", err);
        break;
    end

    print(string.format("key: %d, value: %s", key, ffi.string(value[0], valuesize[0])));
    ffi.C.free(value[0]);
    key= key + 1;
end

-- Retrieve values from database using cooked calls
print("== RETRIEVE ==")
key = 0;
while key < 10 do
    local value, err = db:retrieve(tostring(key))
    if not value then
        print("sp_get ERROR: ", err);
        break;
    end

    print(string.format("key: %d, value: %s", key, value));
    key= key + 1;
end


-- Retrieve values using cursor
print("== ITERATE ==")
local ikey = tostring(5);
for key, keysize, value, valuesize in db:iteration(ikey, #ikey, ffi.C.SPGT) do
    print(ffi.cast("int *",key)[0], ffi.string(value, valuesize));
end


