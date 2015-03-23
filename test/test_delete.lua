--
-- test_delete.lua
--
local ffi = require("ffi");

local sophia_ffi = require("test_common");
local config = sophia_ffi.config;


local env = sp_env();
local ctl = sp_ctl(env);

sp_set(ctl, config.sophia.path, "./storage");
sp_set(ctl, "db", "test");

local rc = sp_open(env);
assert(rc ~= -1, "error on sp_open");

local db = sp_get(ctl, "db.test");
assert(db ~= nil, "failed to get database test from control object");

-- insert some keys
local key = "hello";
local value = "world";

-- insert
--
local o = sp_object(db);
sp_set(o, "key", key, ffi.cast("uint32_t", #key));
sp_set(o, "value", value, ffi.cast("uint32_t", #value));
rc = sp_set(db, o);

assert(rc~= -1, "error with setting key/value on db object");

-- 
-- delete
--
od = sp_object(db);
sp_set(od, "key", key, #key);
rc = sp_delete(db, od);

assert(rc ~= -1, "error deleting key");

-- finish
rc = sp_destroy(env);

