local ffi = require("ffi");

local sophia_ffi = require("sophia_ffi")
--sophia_ffi.promoteToGlobal();
require("test_common");
local config = sophia_ffi.config;

local function test_ctl_version()
    local env = sophia_ffi.sp_env();
    assert(env, "sp_env() failed");

    -- create ctl object for environment
    local ctl = sophia_ffi.sp_ctl(env);
    assert(ctl, "sp_ctl() failed");

    print("Config String: ", config.sophia.version);
    --local o = sophia_ffi.sp_get(ctl, ffi.cast("const char *", config.sophia.version));
    local o = sophia_ffi.sp_get(ctl, config.sophia.version);
    assert(o, "sp_get() had error");

    local value = sophia_ffi.sp_get(o, "value", nil);
    assert(value, "sp_get('value') failed");

    print("version: ", value, ffi.string(value)) ;
end

test_ctl_version();

