module Muck
  module ConfigDSL
    class EncryptDSL

      def initialize(hash)
        @hash = hash
      end

      def enabled(enabled)
        @hash[:enabled] = enabled
      end

      def password(password)
        @hash[:password] = password
      end

    end
  end
end
