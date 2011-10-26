require: "redis"

r = Redis Client new

r["msg"]: "hello world" # SET
r["msg"] println  # GET

# alternatively:
r('set, "msg2", "test!")
r('get, "msg2") println

# or even:
r call: ('set, "msg3", "test3!")
r call: ('get, "msg3") println