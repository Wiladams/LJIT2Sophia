local ffi = require("ffi");

local sophia_ffi = require("test_common")
local config = sophia_ffi.config;

local env = sp_env();
local ctl = sp_ctl(env);

sp_set(ctl, config.sophia.path, "./storage");
sp_set(ctl, "db", "test");

local rc = sp_open(env);
assert(rc ~= -1, "error on sp_open");

local db = sp_get(ctl, "db.test");


key = "hello";
value = "world";


local o = sp_object(db);
sp_set(o, "key", key, #key+1);
sp_set(o, "value", value, #value+1);
rc = sp_set(db, o);

assert(rc ~= -1, "sp_set() failure");

-- get
o = sp_object(db);
sp_set(o, "key", key, #key+1);
local result = sp_get(db, o);

if result ~= nil then
    local valuesize = ffi.new("uint32_t[1]");
    local value = sp_get(result, "value", valuesize);
    print(string.format("%s", value));
    sp_destroy(result);
end

-- finish
rc = sp_destroy(env);


