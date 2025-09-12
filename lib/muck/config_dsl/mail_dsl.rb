module Muck
  module ConfigDSL
    class MailDSL

      def initialize(hash)
        @hash = hash
      end

      def enabled(enabled)
        @hash[:enabled] = enabled
      end

      def hostname(hostname)
        @hash[:hostname] = hostname
      end

      def port(port)
        @hash[:port] = port
      end

      def username(username)
        @hash[:username] = username
      end

      def password(password)
        @hash[:password] = password
      end

      def from(from)
        @hash[:from] = from
      end

      def to(to)
        @hash[:to] = to
      end

    end
  end
end
