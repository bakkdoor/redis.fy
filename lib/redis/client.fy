class Redis {
  class Client {
    DefaultHost = "localhost"
    DefaultPort = 6379
    DefaultUser = "anonymous"
    DefaultPassword = "anonymous"

    def initialize: host port: port user: user password: password {
      @connection = Connection new: host port: port user: user password: password
      @connection open
      @thread_safe = true
      @mutex = Mutex new
    }

    def disable_thread_safety! {
      @thread_safe = false
      def @mutex synchronize: block {
        block call
      }
    }

    def thread_safe? {
      @thread_safe
    }

    def initialize: host (DefaultHost) user: user (DefaultUser) password: password (DefaultPassword) {
      initialize: host port: DefaultPort user: user password: password
    }

    def call: command {
      cmd_name = command first

      match cmd_name {
        case 'hgetall -> return hgetall: command
        case 'keys -> return keys: command
      }

      reply = command: command

      match cmd_name {
        case 'smove -> boolean: reply

        case 'sadd ->
          match command skip: 2 . size {
            case 1 -> boolean: reply
            case _ -> reply
          }

        case 'srem ->
          match command skip: 2 . size {
            case 1 -> boolean: reply
            case _ -> repl
          }

        case _ -> reply
      }
    }

    # special commands handled differently

    def [key]: value {
      call: ('set, key, value)
    }

    def [key] {
      call: ('get, key)
    }

    def hgetall: command {
      reply = command: command
      match reply {
        case Array ->
          h = <[]>
          reply in_groups_of: 2 . each: |pair| {
            field, value = pair
            h[field]: value
          }
          h
        case _ -> reply
      }
    }

    def keys: command {
      reply = command: command
      match reply {
        case String -> reply split: " "
        case _ -> reply
      }
    }

    # private

    def command: command {
      @mutex synchronize: {
        @connection send_command: command
        @connection read_reply
      }
    }

    def boolean: reply {
      reply to_i == 1
    }

    def disconnect {
      @connection close
    }
  }
}