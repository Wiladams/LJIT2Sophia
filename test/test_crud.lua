package.path = package.path..";../?.lua"

local ffi = require("ffi")
local sophia = require("sophia")()
local libc = require("libc")()



local function main(argc, argv)

	-- Do set, get, delete operations. (see transaction.c)

	-- open or create environment and database
	local env = sp_env();
	sp_setstring(env, "sophia.path", "_test", 0);
	sp_setstring(env, "db", "test", 0);
	local db = sp_getobject(env, "db.test");
	local rc = sp_open(env);
	if (rc == -1) then
		error(rc);
	end

	-- set
	local key = ffi.new("uint32_t[1]", 1);
	local o = sp_object(db);
	sp_setstring(o, "key", key, ffi.sizeof("uint32_t"));
	sp_setstring(o, "value", key, ffi.sizeof("uint32_t"));
	rc = sp_set(db, o);
	if (rc == -1) then
		error(rc);
	end

	-- get
	o = sp_object(db);
	sp_setstring(o, "key", key, ffi.sizeof(key));
	o = sp_get(db, o);
	if (o ~= nil) then
		-- ensure key and value are correct
		local size = ffi.new("int[1]");
		local ptr = sp_getstring(o, "key", size);
		assert(size[0] == ffi.sizeof("uint32_t"));
		assert(ffi.cast("uint32_t*",ptr)[0] == key[0]);

		ptr = sp_getstring(o, "value", size);
		assert(size[0] == ffi.sizeof("uint32_t"));
		assert(ffi.cast("uint32_t*",ptr)[0] == key[0]);

		sp_destroy(o);
	end

	-- delete
	o = sp_object(db);
	sp_setstring(o, "key", key, ffi.sizeof(key));
	rc = sp_delete(db, o);
	if (rc == -1) then
		error(rc);
	end

	-- finish work
	sp_destroy(env);

	return true;

--[[
error:;
	int size;
	char *error = sp_getstring(env, "sophia.error", &size);
	printf("error: %s\n", error);
	free(error);
	sp_destroy(env);
	return 1;
--]]
end

main(#arg, arg)
