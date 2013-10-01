local sophia = require("sophia")



local env = sophia.SophiaEnvironment("./db");

print("EnvHandle: ", env, env:getNativeHandle());

if not env then
    return false, "no environment"
end

print("about to open")

local db, err = env:open();

print("open: ", db, err);

