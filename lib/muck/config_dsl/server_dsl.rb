require 'muck/config_dsl/ssh_dsl'
require 'muck/config_dsl/storage_dsl'
require 'muck/config_dsl/encrypt_dsl'
require 'muck/config_dsl/upload_dsl'
require 'muck/config_dsl/database_dsl'

module Muck
  module ConfigDSL
    class ServerDSL

      def initialize(hash)
        @hash = hash
      end

      def name(name)
        @hash[:name] = name
      end

      def ip_address(ip_address)
        @hash[:ip_address] = ip_address
      end

      def frequency(frequency)
        @hash[:frequency] = frequency
      end

      def ssh(&block)
        dsl = SSHDSL.new(@hash[:ssh] = Hash.new)
        dsl.instance_eval(&block)
      end

      def storage(&block)
        dsl = StorageDSL.new(@hash[:storage] = Hash.new)
        dsl.instance_eval(&block)
      end

      def encrypt(&block)
        dsl = EncryptDSL.new(@hash[:encrypt] = Hash.new)
        dsl.instance_eval(&block)
      end

      def upload(&block)
        dsl = UploadDSL.new(@hash[:upload] = Hash.new)
        dsl.instance_eval(&block)
      end

      def database(&block)
        hash = {}
        dsl = DatabaseDSL.new(hash)
        dsl.instance_eval(&block)
        @hash[:databases] ||= []
        @hash[:databases] << hash
      end

    end
  end
end
