redis.fy is a Redis client library for Fancy.
It's still work in progress, but most commands should work as expected.

It's licensed under the BSD license.
See LICENSE file for more information.

Example usage:

    require: "redis"
    r = Redis Client new # defaults to localhost
    r call: ('set, 'msg, "hello, world")
    r call: ('get, 'msg) println # => "hello, world"

    # Or using the call: short-cut syntax:
    r('set, 'msg, "hello, world")
    r('get, 'msg) println


Thanks go to:
Inspired in some parts by https://github.com/ezmobius/redis-rb