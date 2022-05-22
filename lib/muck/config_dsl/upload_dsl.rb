module Muck
  module ConfigDSL
    class UploadDSL

      def initialize(hash)
        @hash = hash
      end

      def enabled(enabled)
        @hash[:enabled] = enabled
      end

      def bucket(bucket)
        @hash[:bucket] = bucket
      end

      def path(path)
        @hash[:path] = path
      end

      def keep(keep)
        @hash[:keep] = keep
      end
      
      def aws_endpoint(aws_endpoint)
        @hash[:aws_endpoint] = aws_endpoint
      end

      def aws_region(aws_region)
        @hash[:aws_region] = aws_region
      end

      def aws_client_id(aws_client_id)
        @hash[:aws_client_id] = aws_client_id
      end

      def aws_client_secret(aws_client_secret)
        @hash[:aws_client_secret] = aws_client_secret
      end

    end
  end
end
