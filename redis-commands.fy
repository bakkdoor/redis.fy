#!/usr/bin/env fancy

`curl http://redis.io/commands` lines map: |line| {
  match line {
    case /a href='/commands/(.+)'>/ -> |_, cmd|
      cmd gsub("-", "_") to_sym
  }
} . compact inspect println