local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;

local Lib_sophia = require("sophia_ffi")


-- Error handling and meta information
local function strerror(thing)
    local err = Lib_sophia.sp_error(thing)
    if err ~= nil then
            return ffi.string(err);
    end

    return string.format("UNKNOWN ERROR [%s]", tostring(thing))
end


local exports = {
    -- reference to lib so it doesn't get
    -- garbage collected
    Lib_sophia = Lib_sophia;

    sp_env = Lib_sophia.sp_env;
    sp_object = Lib_sophia.sp_object;
    sp_open = Lib_sophia.sp_open;
    sp_drop = Lib_sophia.sp_drop;
    sp_destroy = Lib_sophia.sp_destroy;
    sp_error = Lib_sophia.sp_error;
    sp_asynchronous = Lib_sophia.sp_asynchronous;
    sp_poll = Lib_sophia.sp_poll;
    sp_setobject = Lib_sophia.sp_setobject;
    sp_setstring = Lib_sophia.sp_setstring;
    sp_setint = Lib_sophia.sp_setint;
    sp_getobject = Lib_sophia.sp_getobject;
    sp_getstring = Lib_sophia.sp_getstring;
    sp_getint = Lib_sophia.sp_getint;
    sp_set = Lib_sophia.sp_set;
    sp_update = Lib_sophia.sp_update;
    sp_delete = Lib_sophia.sp_delete;
    sp_get = Lib_sophia.sp_get;
    sp_cursor = Lib_sophia.sp_cursor;
    sp_batch = Lib_sophia.sp_batch;

    -- Transactions
    sp_begin = Lib_sophia.sp_begin;
    sp_prepare = Lib_sophia.sp_prepare;
    sp_commit = Lib_sophia.sp_commit;

    -- local functions
    sp_strerror = strerror;
        
}


--[[
    Make functions accessible through global namespace
--]]
setmetatable(exports, {

    __call = function(self, tbl)
        tbl = tbl or _G;
        for k,v in pairs(exports) do
            _G[k] = v;
        end

        return self;
    end,
})


return exports
