local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;

local sophia_ffi = require("sophia_ffi")

ffi.cdef[[
typedef struct {
    void * Handle;
} SophiaEnvHandle;
]]

ffi.cdef[[
typedef struct {
    void * Handle;
} SophiaDBHandle;
]]
local SophiaDBHandle = ffi.typeof("SophiaDBHandle");
local SophiaDBHandle_mt = {
    __new = function(ct, rawHandle)
        print("SophiaDBHandle.__new(): ", rawHandle);
        return ffi.new(ct, rawHandle);
    end,

    __gc = function(self)
        if self.Handle == nil then
            return ;
        end

        sophia_ffi.sp_destroy(self.Handle);

        self.Handle = nil;
    end,
}
ffi.metatype(SophiaDBHandle, SophiaDBHandle_mt);

-- Safe Handle for sophia environment type
local SophiaEnvHandle = ffi.typeof("SophiaEnvHandle");
local SophiaEnvHandle_mt = {
    __gc = function(self)
	if self.Handle ~= nil then
            sophia_ffi.sp_destroy(self.Handle);
        end
        self.Handle = nil;
    end,

    __new = function(ct, ...)
        local env = sophia_ffi.sp_env();
	if env == nil then
            return nil;
        end

	return ffi.new(ct, env);
    end,
}
ffi.metatype(SophiaEnvHandle, SophiaEnvHandle_mt)

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
    
    local envHandle = SophiaEnvHandle();
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
    
    return SophiaDBHandle(dbhandle);
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

SophiaDatabase.get = function(self, key, keysize, value, valuesize)
    --print(key, keysize, value, valuesize);
    local rc = sophia_ffi.sp_get(self:getNativeHandle(), key, keysize, value, valuesize);

    if rc == -1 then
        return false, sophia_ffi.sp_error(self:getNativeHandle());
    end

    return true
end

SophiaDatabase.delete = function(self, key, keysize)
    local rc = sophia_ffi.sp_delete(self:getNativeHandle(), key, keysize);
    if rc == -1 then
        return false, sophia_ffi.sp_error(self:getNativeHandle());
    end
   
    return true
end


return {
    SophiaEnvironment = SophiaEnvironment,
    SophiaDatabase = SophiaDatabase,
}

