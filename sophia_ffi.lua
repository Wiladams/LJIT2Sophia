local ffi = require("ffi")

local Lib_sophia = ffi.load("sophia")
local Lib_pthread = ffi.load("pthread", true);


ffi.cdef[[
void    *sp_env(void);
void    *sp_object(void*);
int      sp_open(void*);
int      sp_drop(void*);
int      sp_destroy(void*);
int      sp_error(void*);
void    *sp_asynchronous(void*);
void    *sp_poll(void*);
int      sp_setobject(void*, char*, void*);
int      sp_setstring(void*, char*, void*, int);
int      sp_setint(void*, char*, int64_t);
void    *sp_getobject(void*, char*);
void    *sp_getstring(void*, char*, int*);
int64_t  sp_getint(void*, char*);
int      sp_set(void*, void*);
int      sp_update(void*, void*);
int      sp_delete(void*, void*);
void    *sp_get(void*, void*);
void    *sp_cursor(void*, void*);
void    *sp_batch(void*);
void    *sp_begin(void*);
int      sp_prepare(void*);
int      sp_commit(void*);
]]


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
    Lib_pthread = Lib_pthread;

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

exports.promoteToGlobal = function()
    sp_env = exports.sp_env;
    sp_open = exports.sp_open;
    sp_ctl = exports.sp_ctl;
    sp_destroy = exports.sp_destroy;
    sp_object = exports.sp_object;

    -- Operations
    sp_set = exports.sp_set;
    sp_delete = exports.sp_delete;
    sp_get = exports.sp_get;

    -- Transactions
    sp_begin = exports.sp_begin;
    sp_commit = exports.sp_commit;

    -- Cursors
    sp_cursor = exports.sp_cursor;

    -- Error handling and meta information
    sp_error = exports.sp_error;

end

return exports
