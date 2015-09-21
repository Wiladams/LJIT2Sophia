--libc.lua
local ffi = require("ffi")

ffi.cdef[[
// string.h
void *memset (void *, int, size_t);


// Memory
void free(void *);
void * malloc(const size_t size);


// Files
typedef struct _IO_FILE FILE;

FILE *fopen(const char *__restrict, const char *__restrict);
int fclose(FILE *);

int fprintf(FILE *__restrict, const char *__restrict, ...);
size_t fread(void *__restrict, size_t, size_t, FILE *__restrict);
size_t fwrite(const void *__restrict, size_t, size_t, FILE *__restrict);

]]

local exports = {

	-- Memory Management
	free = ffi.C.free;
	malloc = ffi.C.malloc;
	memset = ffi.C.memset;
		
	-- File manipulation
	fopen = ffi.C.fopen;
	fclose = ffi.C.fclose;
	fprintf = ffi.C.fprintf;
	fwrite = ffi.C.fwrite;
}

setmetatable(exports, {
	__call = function(self, tbl)
		tbl = tbl or _G;
		for k,v in pairs(self) do
			tbl[k] = v;
		end;
		return self;
	end,
})

return exports
