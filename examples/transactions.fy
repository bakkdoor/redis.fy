require: "redis"

r = Redis Client new

r transaction: {
  r[('set, 'hello, "world")]
  r[('set, 'world, "hello")]
}

r[('get, 'hello)] println
r[('get, 'world)] println