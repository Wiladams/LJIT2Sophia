local ffi = require("ffi");

local sophia_ffi = require("sophia_ffi")
sophia_ffi.promoteToGlobal();
local config = sophia_ffi.config;

require("test_common");



local function test_ctl_version()
    print("==== test_ctr_version ====");

    local env = sophia_ffi.sp_env();
    assert(env, "sp_env() failed");

    -- create ctl object for environment
    local ctl = sophia_ffi.sp_ctl(env);
    assert(ctl, "sp_ctl() failed");

    print("Config String: ", config.sophia.version);
    local o = sophia_ffi.sp_get(ctl, config.sophia.version);
    assert(o, "sp_get() had error");

    local value = sophia_ffi.sp_get(o, "value", nil);
    assert(value, "sp_get('value') failed");

    print("version: ", value, ffi.string(value)) ;
end

local function test_ctl_get_all()
    print("==== test_ctl_get_all ====");

    local env = sp_env();
    local ctl = sp_ctl(env);

    sp_set(ctl, config.sophia.path, "./sophiapath");
    sp_open(env);

    local cursor = sp_cursor(ctl);
    
    while (true) do
        local ptr = sp_get(cursor);
	if (ptr == nil) then
		break;
	end

	local key = sp_get(ptr, "key", nil);
	local value = sp_get(ptr, "value", nil);

	io.write(string.format("  %s", ffi.string(key)));
	if (value ~= nil) then
	    io.write(string.format(" = %s", ffi.string(value)))
	end

	io.write("\n");
    end
    --sp_destroy(cursor);
end

test_ctl_version();
test_ctl_get_all();

