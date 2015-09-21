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

-- Configuration string values
-- These are used in conjunction with the sp_get() function
-- depending on what type of object you're operating against, 
-- the strings have their intended values.
local config = {
    sophia = {
        version = "sophia.version";     -- string, read-only
    build = "sophia.build";         -- string, read-only
    ["error"] = "sophia.error";     -- string
    path = "sophia.path";           -- string, mandatory
    path_create = "sophia.path_create"; -- u32
    };

    memory = {
        limit = "memory.limit";             -- u64
    used = "memory.used";               -- u64, read-only
    pager_pool_size = "memory.pager_pool_size"; -- u32, read-only
    pager_page_size = "memory.pager_page_size"; -- u32, read-only
    pager_pools = "memory.pager_pools";     -- u32, read-only
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
        threads = "scheduler.threads";                  -- u32
    -- <workerid>.trace = "scheduler.%d.trace";
    zone = "scheduler.zone";                    -- u32, read-only
    checkpoint_active = "scheduler.checkpoint_active";
    checkpoint_lsn = "scheduler.checkpoint_lsn";
    checkpoint_lsn_last = "scheduler.checkpoint_lsn_last";
    checkpoint_on_complete = "scheduler.checkpoint_on_complete";    -- function
        checkpoint = "scheduler.checkpoint";                -- function
    gc_active = "scheduler.gc_active";              -- u32, read-only
    gc = "scheduler.gc";                        -- function
    run = "scheduler.run";                      -- function
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
        path = "backkup.path";              -- string
    run = "backup.run";             -- function
    active = "backup.active";           -- u32, read-only
    last = "backup.last";               -- u32, read-only
    last_complete = "backup.last_complete";     -- u32, readonly
    on_complete = "backup.on_complete";     -- function
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

    -- Configuration strings
    config = config;
        
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
