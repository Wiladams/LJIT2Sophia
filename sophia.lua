local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;

local sophia_ffi = require("sophia_ffi")

ffi.cdef[[
typedef struct {
    void * Handle;
} SophiaEnvHandle;
]]

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
    print(".init");

    local obj = {
        Handle = safeHandle;
    }

    setmetatable(obj, SophiaEnvironment_mt);
    return obj;
end

SophiaEnvironment.create = function(self, directory)
    directory = directory or "./db"
    
    local envHandle = SophiaEnvHandle();
--print("envHandle: ", envHandle);
    if not envHandle then
        return nil;
    end

--print("               envHandle.Handle: ", envHandle.Handle);
--print("                    ffi.C.SPDIR: ", ffi.C.SPDIR);
--print("ffi.C.SPI_CREAT | ffi.C.SPO_RDWR: ", bor(ffi.C.SPO_CREAT,ffi.C.SPO_RDWR));
--print("                      directory: ", directory);

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
    
    return SophiaDatabase(dbhandle);
end

ffi.cdef[[
typedef struct {
    void * Handle;
} SophiaDBHandle;
]]

local SophiaDBHandle = ffi.typeof("SophiaDBHandle");
local SophiaDBHandle_mt = {
    __new = function(ct, ...)
    end,

    __gc = function(self)
        if self.Handle == nil then
            return ;
        end

        sophia_ffi.sp_destroy(self.Handle);

        self.Handle = nil;
    end,
}

local SophiaDatabase = {}
setmetatable(SophiaDatabase, {
    __call = function(self, ...)
        return self:create(...);
    end,
});

local SophiaDatabase_mt = {
    __index = SophiaDatabase;
}

SophiaDatabase.init = function(self, safeHandle)
    local obj = {
        self.Handle = safeHandle;
    }

    setmetatable(obj, SophiaDatabase_mt);

    return obj
end

SophiaDatabase.create = function(self, dbHandle)
    return self:init(dbHandle);
end

SophiaDatabase.getNativeHandle = function(self)
    return self.Handle.Handle;
end


return {
    SophiaEnvironment = SophiaEnvironment,
    SophiaDatabase = SophiaDatabase,
}

