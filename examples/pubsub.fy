require: "redis"

subscribe_handlers = <[
  'channel => |m| {
    "message in channel: #{m}" println
  }
]>

# subscribe twice
Redis Client new call: ('subscribe, subscribe_handlers)
Redis Client new call: ('subscribe, subscribe_handlers)


r3 = Redis Client new
10 times: |i| {
  r3 call: ('publish, 'channel, "message: #{i}")
}
