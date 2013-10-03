local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;

local sophia_ffi = require("sophia_ffi")

ffi.cdef[[
typedef struct {
    void * Handle;
} SophiaHandle;
]]

local SophiaHandle = ffi.typeof("SophiaHandle");
local SophiaHandle_mt = {
    __new = function(ct, rawHandle)
        return ffi.new(ct, rawHandle);
    end,

    __gc = function(self)
        --print("GC SophiaHandle: ", self.Handle)
        if self.Handle == nil then
            return ;
        end

        sophia_ffi.sp_destroy(self.Handle);

        self.Handle = nil;
    end,

    __index = {
        free = function(self)
            sophia_ffi.sp_destroy(self.Handle);
            self.Handle = nil;
        end,
    },
}
ffi.metatype(SophiaHandle, SophiaHandle_mt);



local SophiaEnvironment = {}
setmetatable(SophiaEnvironment, {
    __call = function(self, ...)
        return self:create(...);
    end;
});

SophiaEnvironment_mt = {
    __index = SophiaEnvironment;
}

SophiaEnvironment.init = function(self, safeHandle)

    local obj = {
        Handle = safeHandle;
    }

    setmetatable(obj, SophiaEnvironment_mt);
    return obj;
end

SophiaEnvironment.create = function(self, directory)

    directory = directory or "./db"
    
    local rawHandle = sophia_ffi.sp_env();
    if rawHandle == nil then
        return nil;
    end

    local envHandle = SophiaHandle(rawHandle);
    if not envHandle then
        return nil;
    end

    local rc = sophia_ffi.sp_ctl(envHandle.Handle, ffi.C.SPDIR, 
	ffi.cast("int32_t",bor(ffi.C.SPO_CREAT,ffi.C.SPO_RDWR)), 
	directory);

    if (rc == -1) then
        return nil, sophia_ffi.sp_error(envHandle.Handle);
    end

    return self:init(envHandle);
end


SophiaEnvironment.getNativeHandle = function(self)
    return self.Handle.Handle;
end

SophiaEnvironment.open = function(self)
    local dbhandle = sophia_ffi.sp_open(self:getNativeHandle());
    

    if (dbhandle == nil) then
        return nil, sophia_ffi.sp_error(self:getNativeHandle());
    end
    
    return SophiaHandle(dbhandle);
end





local SophiaDatabase = {}
setmetatable(SophiaDatabase, {
    __call = function(self, ...)
        return self:create(...);
    end,
});

local SophiaDatabase_mt = {
    __index = SophiaDatabase;
}

SophiaDatabase.init = function(self, env, dbhandle)
    local obj = {
        Environment = env;
        DBHandle = dbhandle;
    }

    setmetatable(obj, SophiaDatabase_mt);

    return obj
end

SophiaDatabase.create = function(self, dbname)
    -- create the environment
    local env, err = SophiaEnvironment(dbname);

    if not env then
        return nil, err;
    end

    -- open the database
    local dbhandle, err = env:open();

    if not dbhandle then
        return nil, err
    end

    -- initialize the object
    return self:init(env, dbhandle);
end

SophiaDatabase.getNativeHandle = function(self)
    return self.DBHandle.Handle;
end

-- Database operations
SophiaDatabase.set = function(self, key, keysize, value, valuesize)
    local rc = sophia_ffi.sp_set(self:getNativeHandle(),
        key, keysize,
        value, valuesize);

    if rc == -1 then
        return false, sophia_ffi.sp_error(self:getNativeHandle());
    end

    return true
end

SophiaDatabase.upsert = function(self, ...)
    local nargs = select('#',...)
    -- if it's 4 values, then they MUST be
    -- key, keysize, value, valuesize
    -- if it's two values, then they MUST be
    -- key, value

    local key, keysize, value, valuesize

    if nargs == 4 then
        key = select(1, ...)
        keysize = select(2, ...)
        value = select(3, ...)
        valuesize = select(4, ...)
    elseif nargs == 2 then
        key = select(1, ...)
        keysize = #key
        value = select(2, ...)
        valuesize = #value
    else
        return false, "invalid number of arguments"
    end

    return self:set(key, keysize, value, valuesize);
end


SophiaDatabase.get = function(self, key, keysize, value, valuesize)
    local rc = sophia_ffi.sp_get(self:getNativeHandle(), key, keysize, value, valuesize);

    if rc == -1 then
        return false, sophia_ffi.sp_error(self:getNativeHandle());
    end

    return true
end

SophiaDatabase.retrieve = function(self, ...)
    local nargs = select('#',...)

    -- if it's 4 values, then they MUST be
    -- key, keysize, value, valuesize
    -- if it's two values, then they MUST be
    -- key, value
    local key, keysize, value, valuesize
    if nargs == 4 then
        key = select(1, ...)
        keysize = select(2, ...)
        value = select(3, ...)
        valuesize = select(4, ...)
    elseif nargs == 1 then
        key = select(1, ...)
        keysize = #key
        value = ffi.new("void *[1]");
        valuesize = ffi.new("size_t[1]");
    else
        return false, "invalid number of arguments"
    end

    local success, err = self:get(key, keysize, value, valuesize);
    if not success then
        return false, err
    end

    local str = ffi.string(value[0], valuesize[0])
    ffi.C.free(value[0]);
    
    return str
end

SophiaDatabase.delete = function(self, key, keysize)
    keysize = keysize or #key

    local rc = sophia_ffi.sp_delete(self:getNativeHandle(), key, keysize);
    if rc == -1 then
        return false, sophia_ffi.sp_error(self:getNativeHandle());
    end
   
    return true
end

-- Transactions
SophiaDatabase.begin = function(self)
    local rc = sophia_ffi.sp_begin(self:getNativeHandle());
    
    if rc == -1 then
        return false, sophia_ffi.sp_error(self:getNativeHandle());
    end
   
    return true
end

SophiaDatabase.commit = function(self)
    local rc = sophia_ffi.commit(self:getNativeHandle());

    if rc == -1 then
        return false, sophia_ffi.sp_error(self:getNativeHandle());
    end
   
    return true
end

SophiaDatabase.rollback = function(self)
    local rc = sophia_ffi.rollback(self:getNativeHandle());

    if rc == -1 then
        return false, sophia_ffi.sp_error(self:getNativeHandle());
    end
   
    return true
end

-- Cursors
SophiaDatabase.iteration = function(self, key, keysize, sporder)
    keysize = keysize or 0;
    sporder = sporder or ffi.C.SPGTE;

    local cHandle = SophiaHandle(sophia_ffi.sp_cursor(self:getNativeHandle(), sporder, key, keysize));

    print("cursor HANDLE: ", cHandle.Handle);

    local function closure()
        if cHandle.Handle == nil then
            return nil;
        end

        local rc = sophia_ffi.sp_fetch(cHandle.Handle)
        -- a value of '0' indicates no more records
        if rc == 0 then
            cHandle:free();
            --collectgarbage();
            return nil;
        end

        return sophia_ffi.sp_key(cHandle.Handle), sophia_ffi.sp_keysize(cHandle.Handle),
            sophia_ffi.sp_value(cHandle.Handle), sophia_ffi.sp_valuesize(cHandle.Handle)
    end

    return closure;
end




return {
    SophiaDatabase = SophiaDatabase,
}

