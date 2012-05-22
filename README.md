# redis.fy
A Fancy Redis client library.

It's still work in progress, but most commands should work as expected.

It's licensed under the BSD license.
See LICENSE file for more information.

## Example usage:

    require: "redis"
    r = Redis Client new # defaults to localhost
    r set: ('msg, "hello, world")
    r get: 'msg . println # => "hello, world"


## Credits
Inspired in some parts by https://github.com/ezmobius/redis-rb