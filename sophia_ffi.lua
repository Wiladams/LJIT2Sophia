local ffi = require("ffi")

local Lib = ffi.load("./libsophia.so")

ffi.cdef[[
/*
 * sophia database
 * sphia.org
 *
 * Copyright (c) Dmitry Simonenko
 * BSD License
*/


typedef void *(*spallocf)(void*, size_t, void*);
typedef int (*spcmpf)(char*, size_t, char*, size_t, void*);

typedef enum {
	/* env related */
	SPDIR,     /* uint32_t, char* */
	SPALLOC,   /* spallocf, void* */
	SPCMP,     /* spcmpf, void* */
	SPPAGE,    /* uint32_t */
	SPGC,      /* int */
	SPGCF,     /* double */
	SPGROW,    /* uint32_t, double */
	SPMERGE,   /* int */
	SPMERGEWM, /* uint32_t */
	/* db related */
	SPMERGEFORCE,
	/* unrelated */
	SPVERSION  /* uint32_t*, uint32_t* */
} spopt;

enum {
	SPO_RDONLY = 1,
	SPO_RDWR   = 2,
	SPO_CREAT  = 4,
	SPO_SYNC   = 8
};

typedef enum {
	SPGT,
	SPGTE,
	SPLT,
	SPLTE
} sporder;

typedef struct {
	uint32_t epoch;
	uint64_t psn;
	uint32_t repn;
	uint32_t repndb;
	uint32_t repnxfer;
	uint32_t catn;
	uint32_t indexn;
	uint32_t indexpages;
} spstat;

void *sp_env(void);
void *sp_open(void*);
int sp_ctl(void*, spopt, ...);
int sp_destroy(void*);
int sp_set(void*, const void*, size_t, const void*, size_t);
int sp_delete(void*, const void*, size_t);
int sp_get(void*, const void*, size_t, void**, size_t*);
void *sp_cursor(void*, sporder, const void*, size_t);
int sp_fetch(void*);
const char *sp_key(void*);
size_t sp_keysize(void*);
const char *sp_value(void*);
size_t sp_valuesize(void*);
char *sp_error(void*);
void sp_stat(void*, spstat*);
]]

return {
    sp_env = Lib.sp_env,
    sp_open = Lib.sp_open,
    sp_ctl = Lib.sp_ctl,
    sp_destroy = Lib.sp_destroy,
    sp_set = Lib.sp_set,
    sp_delete = Lib.sp_delete,
    sp_get = Lib.sp_get,
    sp_cursor = Lib.sp_cursor,
    sp_fetch = Lib.sp_fetch,
    sp_key = Lib.sp_key,
    sp_keysize = Lib.sp_keysize,
    sp_value = Lib.sp_value,
    sp_valuesize = Lib.sp_valuesize,
    sp_error = function(thing)
        local err = Lib.sp_error(thing)
        if err ~= nil then
            return ffi.string(err);
        end
    end,
    sp_stat = Lib.sp_stat,
}

