class Redis {
  class Client {
    DefaultHost = "localhost"
    DefaultPort = 6379
    read_slots: ('db, 'password)

    def initialize: host (DefaultHost) port: port (DefaultPort) db: @db (nil) password: @password (nil) {
      @connection = Connection new: host port: port
      @thread_safe = true
      @mutex = Mutex new
      @channel_handlers = <[]>
      connect
    }

    def initialize: host db: db password: password (nil) {
      initialize: host port: DefaultPort db: db password: password
    }

    def initialize: host password: password {
      initialize: host port: DefaultPort db: nil password: password
    }

    def disable_thread_safety! {
      @thread_safe = false
      def @mutex synchronize: block {
        block call
      }
    }

    def connect {
      unless: connected? do: {
        @connection open
        { call: ['auth, @password] } if: @password
        { call: ['select, @db] } if: @db
      }
    }

    def reconnect {
      disconnect
      connect
    }

    def disconnect {
      @connection close
    }

    def connected? {
      @connection open?
    }

    def thread_safe? {
      @thread_safe
    }

    def call: command {
      cmd_name = command first

      match cmd_name {
        case 'hgetall -> return hgetall: command
        case 'keys -> return keys: command
        case 'subscribe -> return subscribe: command
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

    def [command] {
      call: $ command to_a
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

    def subscribe: command {
      channel_handlers = command second
      channel_handlers each: |chan block| {
        chan = chan to_s
        { @channel_handlers[chan]: [] } unless: $ @channel_handlers[chan]
        @channel_handlers[chan] << block
      }

      command = command second keys unshift: 'subscribe
      reply = command: $ command

      { start_subscribe_thread } unless: @subscribe_thread

      reply
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

    def start_subscribe_thread {
      @subscribe_thread = Thread new: {
        loop: {
          @mutex synchronize: {
            reply = @connection read_reply
            if: (reply first == "message") then: {
              type, chan, message = reply
              @channel_handlers[chan] each: @{ call: [message] }
            } else: {
              @subscribe_thread = nil
              *stderr* println: "Expected message publish reply. Got: #{reply inspect}"
            }
          }
        }
      }
    }
  }
}