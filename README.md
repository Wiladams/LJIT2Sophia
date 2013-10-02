LJIT2Sophia
===========

LuaJIT FFI binding to the Sophia database: http://sphia.org

The sophia database is a new (September, 2013) key value store
which is small and embeddable.  A LuaJIT binding seems appropriate.

The binding gives you access to the component at two distinct levels.
If you want to use sophia in a style similar to what you would do
using the 'C' language, then you can simply do this:

```
sophia_ffi = require("sophia_ffi");
sophia_ffi.sp_env();
sophia_ffi.sp_db(...);
```

All of the functions are accessible through a simple table interface,
which means you can export them to the global namespace if you like, 
and make your code look even more like 'C' code.

But, this is Lua, and the better way to access it is using more lua
like semantics.

```
local sophia = require("sophia")
local db, err = sophia.SophiaDatabase("./db");
```
inserting a value
-----------------

```
local success, err = db:set(keybuff, ffi.sizeof(keybuff), value, #str); 
```

retrieving a value
------------------

```
local success, err = db:get(keybuff, ffi.sizeof(keybuff), value, valuesize);
```

Using a cursor to iterate over the entire database
--------------------------------------------------

```
for key, keysize, value, valuesize in db:iterate() do

    print(ffi.cast("int *",key)[0]);

    print(ffi.string(value, valuesize));

end
```

Rather than follow the approach of simply creating objects to wrap 
groupings of APIs, the binding presents what seems to make the most
sense from a usability standpoint.

The SophiaDatabase object is the primary interaction point.  The 
SophiaEnvironment is a secondary player, which is used by the 
SophiaDatabase internally, but for the most part is hidden.

The Database:iterate() function has the following signature:

```
SophiaDatabase.iterate = function(self, key, keysize, sporder)
    keysize = keysize or 0;
    sporder = sporder or ffi.C.SPGTE;
```

In this way, by default, the iterator will iterate over the entire
database, from the beginning.  The next logical thing the user
is likely to want is to iterate from a specific point, so the key
value is the first parameter.  Lastly, they might want to specify
an order.  The thinking is, if they're specifying an order, then they
MUST also specify a key, so the odering can come last.

Using an iterator is natural for a lua program, so that's the choice.
Of course, you can use the lower level sophia_ffi calls and create
whatever specialized interface you prefer, but this is the default
set of convenience provided.

Going forward, the set/get/iterate methods could do a little bit of
magic and assume things like lengths of lua strings can be inferred, 
and if the key is a 'number', it can be converted to a 4 or 8 byte
value.  this will make it a little bit convenient to work with these
values without having to specify lengths explicitly.

