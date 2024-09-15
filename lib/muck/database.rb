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

    def server
      @server
    end

    def export_path
      @export_path ||= server.export_path.gsub(':app_name', self.app_name).gsub(':database', self.name)
    end

    def upload_path
      @upload_path ||= server.upload_path.gsub(':app_name', self.app_name).gsub(':database', self.name)
    end

    def backup
      Muck::Backup.new(self).run
    end

    def manifest_path
      File.join(export_path, 'manifest.yml')
    end

    def manifest
      @manifest ||= File.exist?(manifest_path) ? YAML.load_file(manifest_path) : {:backups => []}
    end

    def save_manifest
      File.open(manifest_path, 'w') { |f| f.write(manifest.to_yaml) }
    end

    def backup_command
      if type == "mysql"
        "mysqldump"
      elsif type == "mariadb"
        "mariadb-dump"
      else
        "mysqldump"
      end
    end

    def dump_command
      password_opt = password ? "-p#{password}" : ""

      "docker exec #{app_name}-mysql-1 /usr/bin/#{backup_command} --no-tablespaces -u #{username} #{password_opt} #{name}"
    end

    def encrypt_command(file)
      "echo #{server.encrypt[:password]} |  gpg --pinentry-mode loopback  --passphrase-fd 0 --output #{file}.enc --symmetric --cipher-algo AES256 #{file}"
    end

    def last_backup_at
      if last_backup = manifest[:backups].last
        Time.at(last_backup[:timestamp])
      else
        nil
      end
    end

    def backup_now?
      last_backup_at.nil? || last_backup_at <= Time.now - (@server.frequency * 60)
    end

  end
end
