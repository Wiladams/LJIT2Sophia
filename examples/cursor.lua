package.path = package.path..";../?.lua;../lib/?.lua"

local ffi = require("ffi")
local sophia = require("sophia")()
local config = sophia.config;
local libc = require("libc")()

local function cursorForward(env, db)
	-- create cursor and do forward iteration
	local cursor = sp_cursor(env);
	local o = sp_object(db);

	repeat
		o = sp_get(cursor, o)
		if (o ~= nil) then
			local str = sp_getstring(o, "key", nil)
			local value = ffi.cast("uint32_t *", str)[0];
			print("STR, VALUE: ", str, value)
			--print(string.format("%d", value))
		end
	until o == nil
	sp_destroy(cursor);
end

local function cursorBack(env, db)
	-- create cursor and do backward iteration
	local cursor = sp_cursor(env);
	local o = sp_object(db);
	sp_setstring(o, "order", "<", 0);
	
	repeat 
		o = sp_get(cursor, o)
		print("O: ", o)
		if (o ~= nil) then
			local value = sp_getstring(o, "key", nil)
			print("Value: ", value)
			--printf("%"PRIu32"\n", *(uint32_t*)sp_getstring(o, "key", NULL));
		end
	until o == nil

	sp_destroy(cursor);
end

local function  main()
	-- Do cursor iteration.
	-- open or create environment and database
	local env = sp_env();
	sp_setstring(env, config.sophia.path, "_test", 0);
	sp_setstring(env, "db", "test", 0);
	local db = sp_getobject(env, "db.test");
	local rc = sp_open(env);
	assert(rc ~= -1, sp_strerror(env))


	-- insert 10 keys
	local key = ffi.new("uint32_t[1]",0);
	while (key[0] < 10) do
	print("KEY: ", key[0])
		local o = sp_object(db);
		sp_setstring(o, "key", key, ffi.sizeof("uint32_t"));
		rc = sp_set(db, o);
		assert(rc ~= -1, sp_strerror(env))

		key[0] = key[0] + 1;
	end

	cursorForward(env, db);
	--cursorBack(env, db);

	-- finish work
	sp_destroy(env);

	return true;


end

main()

