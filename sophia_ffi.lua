local ffi = require("ffi")

local Lib = ffi.load("./libsophia.so")
local pthread = ffi.load("pthread", true);

-- this is dumby text

ffi.cdef[[
typedef void *(*spallocf)(void *ptr, size_t size, void *arg);
typedef int (*spcmpf)(char *a, size_t asz, char *b, size_t bsz, void *arg);

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

typedef enum {
	SPO_RDONLY = 1,
	SPO_RDWR   = 2,
	SPO_CREAT  = 4,
	SPO_SYNC   = 8
} spflags;

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

void *	sp_env(void);
void *	sp_ctl(void *, ...);
void *	sp_object(void *, ...);
int	sp_open(void *, ...);
int	sp_destroy(void *, ...);
int	sp_error(void *, ...);
int	sp_set(void *, ...);
void *	sp_get(void *, ...);
int	sp_delete(void *, ...);
int	sp_drop(void *, ...);
void *	sp_begin(void *, ...);
int	sp_prepare(void *, ...);
int	sp_commit(void *, ...);
void *	sp_cursor(void *, ...);
void *	sp_type(void *, ...);

// int sp_ctl(void*, spopt, ...);


// int sp_set(void *db, const void *k, size_t ksize, const void *v, size_t vsize);
// int sp_delete(void *db, const void *k, size_t ksize);
// int sp_get(void *db, const void *k, size_t ksize, void **v, size_t *vsize);

// void *sp_cursor(void *db, sporder, const void *k, size_t ksize);
]]

-- Configuration string values
-- These are used in conjunction with the sp_get() function
-- depending on what type of object you're operating against, 
-- the strings have their intended values.
local config = {
    sophia = {
--        version = ffi.cast("const char *", "sophia.version");		-- string, read-only
        version = "sophia.version";		-- string, read-only
	build = "sophia.build";			-- string, read-only
	["error"] = "sophia.error";		-- string
	path = "sophia.path";			-- string, mandatory
	path_create = "sophia.path_create";	-- u32
    };

    memory = {
        limit = "memory.limit";				-- u64
	used = "memory.used";				-- u64, read-only
	pager_pool_size = "memory.pager_pool_size";	-- u32, read-only
	pager_page_size = "memory.pager_page_size";	-- u32, read-only
	pager_pools = "memory.pager_pools";		-- u32, read-only
    };

    -- TODO, need to flesh this out because of 
    -- different redzones (0, 80)
    compaction = {
        node_size = "compaction.node_size";
	page_size = "compaction.page_size";
	redzone = {
            mode = "compaction.redzone.mode";
	    compact_wm = "compaction.0.compact_wm";
        };
    };

    scheduler = {
        threads = "scheduler.threads";					-- u32
	-- <workerid>.trace = "scheduler.%d.trace";
	zone = "scheduler.zone";					-- u32, read-only
	checkpoint_active = "scheduler.checkpoint_active";
	checkpoint_lsn = "scheduler.checkpoint_lsn";
	checkpoint_lsn_last = "scheduler.checkpoint_lsn_last";
	checkpoint_on_complete = "scheduler.checkpoint_on_complete";	-- function
        checkpoint = "scheduler.checkpoint";				-- function
	gc_active = "scheduler.gc_active";				-- u32, read-only
	gc = "scheduler.gc";						-- function
	run = "scheduler.run";						-- function
    };

    metric = {
        dsn = "metric.dsn";
	nsn = "metric.nsn";
	bsn = "metric.bsn";
	lsn = "metric.lsn";
	lfsn = "metric.lfsn";
	tsn = "metric.tsn";
    };

    log = {
        enable = "log.enable";
	path = "log.path";
	sync = "log.sync";
	rotate_wm = "log.rotate_wm";
	rotate_sync = "log.rotate_sync";
	rotate = "log.rotate";
	gc = "log.gc";
	files = "log.files";
	two_phase_recovery = "log.two_phase_recovery";
	commit_lsn = "log.commit_lsn";
    };

    snapshot = {
        -- <snapshot_name>.lsn = "snapshot.%s.lsn";
    };

    backup = {
        path = "backkup.path";				-- string
	run = "backup.run";				-- function
	active = "backup.active";			-- u32, read-only
	last = "backup.last";				-- u32, read-only
	last_complete = "backup.last_complete";		-- u32, readonly
	on_complete = "backup.on_complete";		-- function
    };

    -- db configuration needs to be tied to a specific name
    db = {
        name = {
            name = "db.%s.name";
	    id = "db.%s.id";
	    status = "db.%s.status";

	};
    };
}

local exports = {
    -- reference to lib so it doesn't get
    -- garbage collected
    Lib = Lib,
    pthread = pthread;

    -- table of configuration constants
    config = config;


    sp_env = Lib.sp_env,
    sp_ctl = Lib.sp_ctl,
    sp_object = Lib.sp_object;
    sp_open = Lib.sp_open;
    sp_destroy = Lib.sp_destroy;
    sp_error = Lib.sp_error;
    
    -- Operations
    sp_set = Lib.sp_set;
    sp_get = Lib.sp_get;
    sp_delete = Lib.sp_delete;
    sp_drop = Lib.sp_drop;
    
    -- Transactions
    sp_begin = Lib.sp_begin;
    sp_prepare = Lib.sp_prepare;
    sp_commit = Lib.sp_commit;

    -- Cursors
    sp_cursor = Lib.sp_cursor;
    sp_type = Lib.sp_type;
    

    -- Error handling and meta information
    sp_error = function(thing)
        local err = Lib.sp_error(thing)
        if err ~= nil then
            return ffi.string(err);
        end
    end,
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
    --sp_rollback = exports.sp_rollback;

    -- Cursors
    sp_cursor = exports.sp_cursor;

    -- Error handling and meta information
    sp_error = exports.sp_error;

end

return exports
