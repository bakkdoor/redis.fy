require: "redis"

r = Redis Client new

threads = []
10 times: |i| {
  t = Thread new: {
    r('set, "foo", "test: #{i}")
    r('get, "foo") println
  }
  threads << t
}

threads each: 'join
