require: "redis"

subscribe_handlers = <[
  'channel => |m| {
    "message in channel: #{m}" println
  }
]>

# subscribe twice
Redis Client new[('subscribe, subscribe_handlers)]
Redis Client new[('subscribe, subscribe_handlers)]


r3 = Redis Client new
10 times: |i| {
  r3 publish: ('channel, "message: #{i}")
}
