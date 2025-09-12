module Muck
  module ConfigDSL
    class MailDSL

      def initialize(hash)
        @hash = hash
      end

      def enabled(enabled)
        @hash[:enabled] = enabled
      end

      def recipient(recipient)
        @hash[:recipient] = recipient
      end

    end
  end
end
