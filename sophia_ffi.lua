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
int      sp_setobject(void*, const char*, const void*);
int      sp_setstring(void*, const char*, const void*, int);
int      sp_setint(void*, const char*, int64_t);
void    *sp_getobject(void*, const char*);
void    *sp_getstring(void*, const char*, int*);
int64_t  sp_getint(void*, const char*);
int      sp_set(void*, void*);
int      sp_update(void*, void*);
int      sp_delete(void*, void*);
void    *sp_get(void*, void*);
void    *sp_cursor(void*);
void    *sp_batch(void*);
void    *sp_begin(void*);
int      sp_prepare(void*);
int      sp_commit(void*);
]]

return Lib_sophia;

