local ffi = require("ffi");

local sophia_ffi = require("sophia_ffi")
sophia_ffi.promoteToGlobal();
local config = sophia_ffi.config;

require("test_common");

local function main()
	local env = sp_env();

	-- open or create environment and database
	local env = sp_env();
	sp_setstring(env, config.sophia.path, "_test", 0);
	sp_setstring(env, "db", "test", 0);
	local db = sp_getobject(env, "db.test");
	local rc = sp_open(env);
	assert(rc ~= -1, "error on sp_open");

	-- insert some keys
	local key = ffi.new("uint32_t[1]",0);
	while (key[0] < 10) do
	local o = sp_object(db);
	rc = sp_set(o, "key", key, 4);

	print("SET KEY: ", key[0], rc);

	rc = sp_set(db, o);

	assert( rc ~= -1, "sp_set() error");

	key[0] = key[0] + 1;
end

-- create cursor to iterate in >= order (default)
local obj = sp_object(db);
sp_set(obj, "order", ">=");	-- >, >=, <, <=
local cursor = sp_cursor(db, obj);

assert(cursor ~= nil, "cursor == nil");

local o = nil;

repeat
	o = sp_get(cursor);
	print("sp_get(cursor)", o);
	if (o ~= nil) then
		print(sp_get(o, "key", nil));
	end
until o == nil;

sp_destroy(cursor);

sp_destroy(env);

