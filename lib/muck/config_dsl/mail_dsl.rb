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

      def ssl(ssl)
        @hash[:ssl] = ssl
      end

      def tls(tls)
        @hash[:tls] = tls
      end

      def auth_method(auth_method)
        @hash[:auth_method] = auth_method
      end

      def ca_file(ca_file)
        @hash[:ca_file] = ca_file
      end

      def ca_path(ca_path)
        @hash[:ca_path] = ca_path
      end

      def verify_ssl(verify_ssl)
        @hash[:verify_ssl] = verify_ssl
      end
    end
  end
end
