LJIT2Sophia
===========

Overview
--------
LuaJIT FFI binding to the Sophia database: http://sphia.org

The sophia database is a relatively new (September, 2013) key value store
which is small and embeddable.  This LuaJIT binding seems appropriate.

API Access
----------
The binding gives you access to the component at two distinct levels.
If you want to use sophia in a style similar to what you would do
using the 'C' language, then you can simply do this:

```
sophia_ffi = require("sophia_ffi");
sophia_ffi.sp_env();
sophia_ffi.sp_db(...);
```

All of the functions are accessible through a simple table interface.  If you would like to promote them to the global namespace, then call: sophia_ffi.promoteToGlobal().  If you do this, you can write code that looks almost identical to 'C' code.

Object Oriented Access
----------------------
This is Lua, and the better way to access sophia is using more lua like semantics and constructs.  An object model is presented, which makes it relatively easy to manipulate sophia databases.

To create and/or open a database, simply call the constructor on the SophiaDatabase object.  This will open up an existing database, or create it anew if it does not exist.

```
local sophia = require("sophia")
local db, err = sophia.SophiaDatabase("./db");
```
inserting a value
-----------------

Once you have a database object, there are two ways to get values into it.  The 'set()' method mimics the standard 'C' interface function, so you must pass all 4 parameters.

```
local success, err = db:set(keybuff, ffi.sizeof(keybuff), value, #str); 
```

The 'upsert()' method allows you to set a value using a simple key/value pair, which are assumed to be lua string objects.

```
local success, err = db:upsert(key, value)
```

For this upsert operation, if the value does not exist in the database, it will be added.  If the key already exists, then the value for that key will be changed to the value being presented.

retrieving a value
------------------

There are two ways to retrieve a value from the database.  The first mimics the standard 'C' interface function, and requires 4 parameters.

```
local success, err = db:get(keybuff, ffi.sizeof(keybuff), value, valuesize);
```

The second mechnism allows you to specify a single parameter, which is the key associated with the value you want to retrieve.  A second 'keysize' parameter is allowed, but if it is not supplied, the #key length will be used.


```
local value, err = db:retrieve(key, keysize)
```

Upon completion, the 'value' will contain the value specified by the key.  Otherwise, it will return false, and the associated error.



Using a cursor to iterate over the entire database
--------------------------------------------------

In addition to retrieving single values at a time, you can iterate over a range of values in the database.

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

LICENSE
-------
This Software is licensed under the Microsoft Public License, which is a fairly straight forward open source license.

http://opensource.org/licenses/ms-pl

AUTHOR
------
William A Adams

http://williamaadams.wordpress.com
