require 'muck/backup'
require 'yaml'

module Muck
  class Database
    def initialize(server, properties)
      @server = server
      @properties = properties
    end

    def name
      @properties[:name]
    end

    def app_name
      @properties[:app_name]
    end

    def username
      @properties[:username]
    end

    def password
      @properties[:password]
    end

    def type
      @properties[:type]
    end

    def path
      @properties[:path]
    end

    attr_reader :server

    def export_path
      @export_path ||= server.export_path.gsub(':app_name', app_name).gsub(':database', name)
    end

    def upload_path
      @upload_path ||= server.upload_path.gsub(':app_name', app_name).gsub(':database', name)
    end

    def backup
      Muck::Backup.new(self).run
    end

    def manifest_path
      File.join(export_path, 'manifest.yml')
    end

    def manifest
      @manifest ||= File.exist?(manifest_path) ? YAML.load_file(manifest_path) : { backups: [] }
    end

    def save_manifest
      File.open(manifest_path, 'w') { |f| f.write(manifest.to_yaml) }
    end

    def backup_command
      case type
      when 'mysql' then 'mysqldump'
      when 'mariadb' then 'mariadb-dump'
      when 'sqlite' then 'sqlite3'
      else 'mysqldump'
      end
    end

    def dump_command
      if type == 'sqlite'
        tmp_file = "/tmp/muck_backup_#{name}.sqlite"
        "sqlite3 #{path} \".backup #{tmp_file}\" && cat #{tmp_file} && rm #{tmp_file}"
      else
        password_opt = password ? "-p#{password}" : ''
        "docker exec #{app_name}-mysql-1 /usr/bin/#{backup_command} --no-tablespaces -u #{username} #{password_opt} #{name}"
      end
    end

    def encrypt_command(file)
      "echo #{server.encrypt[:password]} |  gpg --pinentry-mode loopback  --passphrase-fd 0 --output #{file}.enc --symmetric --cipher-algo AES256 #{file}"
    end

    def last_backup_at
      return unless last_backup = manifest[:backups].last

      Time.at(last_backup[:timestamp])
    end

    def backup_now?
      last_backup_at.nil? || last_backup_at <= Time.now - (@server.frequency * 60)
    end
  end
end
