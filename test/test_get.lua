local ffi = require("ffi");

local sophia_ffi = require("test_common")
local sophia = require("sophia")
local config = sophia.config;

local env = sp_env();

sp_setstring(env, config.sophia.path, "./storage")
sp_setstring(env, "db", "test")

local db = sp_getobject(env, "db.test")
sp_open(db)

	local key = "hello";
	local value = "world";

local function setValues()

	local o = sp_object(db);
	sp_setstring(o, "key", ffi.cast("char *",key), #key);
	sp_setstring(o, "value", ffi.cast("char *", value), #value);
	local rc = sp_set(db, o);

	assert(rc ~= -1, "sp_set() failure");
end

local function getValues()
	-- get
	local o = sp_object(db);
	sp_set(o, "key", key, #key);
	local result = sp_get(db, o);

	if result ~= nil then
    	local valuesize = ffi.new("uint32_t[1]");
    	local value = sp_get(result, "value", valuesize);
    	print(string.format("%s", value));
    	sp_destroy(result);
	end
end

-- finish
--rc = sp_destroy(env);


setValues();
getValues();
