require: "redis"

r = Redis Client new

r set: ("msg2", "test!")
r get: "msg2" . println

# alternatively:
r set: ("msg3", "test3!")
r get: "msg3" . println

# or even:
r set: ("msg2", "test!")
r get: "msg2" . println
