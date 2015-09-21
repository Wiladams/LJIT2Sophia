package.path = package.path..";../?.lua;../lib/?.lua"

local ffi = require("ffi")
local sophia = require("sophia")()
local libc = require("libc")()

-- Do fast atomic write of 100 inserts.

local function main()
	-- open or create environment and database
	local env = sp_env();
	sp_setstring(env, config.sophia.path, "_test", 0);
	sp_setstring(env, "db", "test", 0);
	local db = sp_getobject(env, "db.test");
	local rc = sp_open(env);
	assert(rc ~= -1, sp_strerror(env))


	-- create batch object
	local batch = sp_batch(db);

	-- insert 100 keys
	local key = ffi.new("uint32_t[1]", 0);
	while (key[0] < 100) do
		local o = sp_object(db);
		sp_setstring(o, "key", key, ffi.sizeof("uint32_t"));
		rc = sp_set(batch, o);
		assert(rc ~= -1, sp_strerror(env))

		key[0] = key[0] + 1;
	end

	-- write batch
	rc = sp_commit(batch);
	assert(rc ~= -1, sp_strerror(env))

	-- finish work
	sp_destroy(env);

	return true;
end

main()

