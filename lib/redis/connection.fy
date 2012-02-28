class Redis {
  class Connection {
    class ProtocolError : Redis Error

    class Error : Redis Error {
      def initialize: @err host: @host port: @port {
        initialize: "Can't connect to Redis on: #{@host}:#{@port} : #{@err inspect}"
      }
    }


    DELIMITER = "\r\n"
    MINUS    = "-"
    PLUS     = "+"
    COLON    = ":"
    DOLLAR   = "$"
    ASTERISK = "*"

    read_slots: ('host, 'port)
    def initialize: @host port: @port

    def open {
      try {
        @sock = TCPSocket open: @host port: @port
        @sock setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      } catch Exception => e {
        Error new: e host: @host port: @port . raise!
      }
    }

    def close {
      try {
        @sock close
      } catch {
      } finally {
        @sock = nil
      }
    }

    def open? {
      @sock nil? not
    }

    def send_command: params {
      if: @sock then: {
        @sock send: $ build_command: params
      } else: {
        reconnect
        send_command: params
      }
    }

    def build_command: params {
      command = ""
      command << "*#{params size}"
      command << DELIMITER
      params each: |p| {
        p = p to_s
        command << "$#{p size}"
        command << DELIMITER
        command << p
        command << DELIMITER
      }
      command
    }

    def read_reply {
      reply = @sock read: 1
      { Error new: (Errno ECONNRESET) host: @host port: @port . raise! } unless: reply
      data = @sock readline
      format_reply: reply data: data
    }

    def format_reply: reply data: data {
      match reply {
        case MINUS -> ErrorResponse new: $ data strip
        case PLUS -> data strip
        case COLON -> data to_i
        case DOLLAR -> bulk_reply: data
        case ASTERISK -> multi_bulk_reply: data
        case _ -> ProtocolError new: reply . raise!
      }
    }

    def bulk_reply: data {
      length = data to_i
      { return nil } if: (length == -1)
      reply = @sock read: length
      @sock read: 2 # DELIMITER
      reply
    }

    def multi_bulk_reply: data {
      length = data to_i
      { return nil } if: (length == -1)
      Array new: length with: { read_reply }
    }
  }
}