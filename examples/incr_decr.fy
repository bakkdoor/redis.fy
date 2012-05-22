require: "redis"

r = Redis Client new

"incr:" println
r del: 'counter

10 times: {
  r incr: 'counter . println
}

"\ndecr:" println
10 times: {
  r decr: 'counter . println
}