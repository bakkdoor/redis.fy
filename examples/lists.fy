require: "redis"

r = Redis Client new

"Adding messages to a list:" println
r('rpush, 'list, "hello, world")
r('rpush, 'list, "this is a message")
r('rpush, 'list, "this is another one")

"Contents are: " println
r('lrange, 'list, 0, -1) inspect println


"Only keeping first 2 elements:" println
r('ltrim, 'list, 0, 1)
r('lrange, 'list, 0, -1) inspect println