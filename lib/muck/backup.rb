require 'muck/logging'
require 'muck/utils'
require 'fileutils'
require "aws-sdk-s3"

module Muck
  class Backup

    include Muck::Logging
    include Muck::Utils

    def initialize(database)
      @database = database
      @time = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
    end

    def export_path
      @export_path ||= File.join(@database.export_path, "master", @time + ".sql")
    end

    def upload_path
      @upload_path ||= File.join(@database.upload_path, @time + ".sql.gz")
    end

    def upload_bucket
      @upload_bucket ||= @database.server.upload[:bucket]
    end

    def s3_client
      options = {}

      options[:access_key_id] = @database.server.upload[:aws_client_id]
      options[:secret_access_key] = @database.server.upload[:aws_client_secret]
      options[:region] = @database.server.upload[:aws_region]
      if @database.server.upload[:aws_endpoint]
        options[:endpoint] = @database.server.upload[:aws_endpoint]
      end

      Aws::S3::Client.new(options)
    end

    def run
      logger.info "Backing up #{blue @database.name} from #{blue @database.server.hostname}"
      take_backup
      compress
      upload
      store_in_manifest
      tidy_masters
      tidy_uploads
    end

    def take_backup
      logger.info "Connecting to #{blue @database.server.ssh_username}@#{blue @database.server.hostname}:#{blue @database.server.ssh_port}"
      FileUtils.mkdir_p(File.dirname(self.export_path))
      file = File.open(export_path, 'w')
      ssh_session = @database.server.create_ssh_session
      channel = ssh_session.open_channel do |channel|
        logger.debug "Running: #{@database.dump_command.gsub(@database.password, '****')}"
        channel.exec(@database.dump_command) do |channel, success|
          raise Error, "Could not execute dump command" unless success
          channel.on_data do |c, data|
            file.write(data)
          end

          channel.on_extended_data do |c, _, data|
            logger.debug red(data.gsub(/[\r\n]/, ''))
          end

          channel.on_request("exit-status") do |_, data|
            exit_code = data.read_long
            if exit_code != 0
              logger.debug "Exit status was #{exit_code}"
              raise Error, "mysqldump returned an error when executing."
            end
          end
        end
      end
      channel.wait
      ssh_session.close
      file.close
      logger.info "Successfully backed up to #{green export_path}"
    end

    def store_in_manifest
      if File.exist?(export_path)
        details = {timestamp: Time.now.to_i, path: export_path, size: File.size(export_path)}
        @database.manifest[:backups] << details
        @database.save_manifest
      else
        raise Error, "Couldn't store backup in manifest because it doesn't exist at #{export_path}"
      end
    end

    def compress
      if File.exist?(export_path)
        if system("gzip #{export_path}")
          @export_path = @export_path + ".gz"
          logger.info "Compressed #{blue export_path} with gzip"
        else
          logger.warn "Couldn't compress #{export_path} with gzip"
        end
      else
        raise Error, "Couldn't compress backup because it doesn't exist at #{export_path}"
      end
    end

    # Upload the compressed backup file to AWS S3/Backblaze B2
    def upload
      if @database.server.upload[:enabled]

        if File.exist?(export_path)
          response = s3_client.put_object(
            bucket: upload_bucket,
            key: upload_path,
            body: File.open(export_path)
          )
          
          if response.etag
            uploaded = [upload_bucket, upload_path].join("/")
            logger.info "Uploaded #{blue uploaded}"
          else
            raise Error, "Couldn't upload backup because it doesn't exist at #{export_path}"
          end
        end

      else
        logger.warn "Upload is not enabled so skipping"
      end
    end

    def tidy_masters
      files = Dir[File.join(@database.export_path, 'master', '*')].sort.reverse.drop(@database.server.masters_to_keep)
      unless files.empty?
        logger.info "Tidying master backup files. Keeping #{@database.server.masters_to_keep} back."
        files.each do |file|
          if system("rm #{file}")
            @database.manifest[:backups].delete_if { |b| b[:path] == file }
            logger.info "-> Removed #{green file}"
          else
            logger.error red("-> Couldn't remove unwanted master file at #{file}")
          end
        end
      end
    ensure
      @database.save_manifest
    end

    def tidy_uploads
      if @database.server.upload[:enabled]

        objects = s3_client.list_objects({
          bucket: upload_bucket,
          prefix: @database.upload_path
        })

        files = objects.contents.collect(&:key).sort.reverse.drop(@database.server.upload[:keep])

        unless files.empty?
          logger.info "Tidying uploaded backup files. Keeping #{@database.server.upload[:keep]} back."
          files.each do |file|
            resp = s3_client.delete_object({
              bucket: upload_bucket, 
              key: file
            })

            if resp
              @database.manifest[:backups].delete_if { |b| b[:path] == file }
              logger.info "-> Deleted #{green file}"
            else
              logger.error red("-> Couldn't delete file at #{file}")
            end
          end
        end
        
      end
    end

  end
end
