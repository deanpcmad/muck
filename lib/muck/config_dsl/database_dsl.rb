module Muck
  module ConfigDSL
    class DatabaseDSL
      def initialize(hash)
        @hash = hash
      end

      def name(name)
        @hash[:name] = name
      end

      def app_name(app_name)
        @hash[:app_name] = app_name
      end

      def username(username)
        @hash[:username] = username
      end

      def password(password)
        @hash[:password] = password
      end

      def type(type)
        @hash[:type] = type
      end

      def path(path)
        @hash[:path] = path
      end
    end
  end
end
