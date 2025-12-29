require 'test_helper'
require 'muck/backup'

class BackupTest < Minitest::Test
  def setup
    @config = Muck::Config.new('test/data')
    @server = @config.servers.first
    @database = @server.databases.first
    @sqlite_database = @server.databases.find { |db| db.type == 'sqlite' }
  end

  def test_run
    # This is a simple test that checks if the run method returns a Muck::Result object.
    # For a real-world scenario, you would want to use a mock SSH connection and file system to verify that the backup is created correctly.
    result = Muck::Backup.new(@database).run
    assert_instance_of Muck::Result, result
  end

  def test_mysql_file_extension
    backup = Muck::Backup.new(@database)
    assert_equal 'sql', backup.file_extension
  end

  def test_sqlite_file_extension
    backup = Muck::Backup.new(@sqlite_database)
    assert_equal 'sqlite', backup.file_extension
  end

  def test_mysql_export_path_extension
    backup = Muck::Backup.new(@database)
    assert_match(/\.sql$/, backup.export_path)
  end

  def test_sqlite_export_path_extension
    backup = Muck::Backup.new(@sqlite_database)
    assert_match(/\.sqlite$/, backup.export_path)
  end

  def test_mysql_encrypted_path_extension
    backup = Muck::Backup.new(@database)
    assert_match(/\.sql\.enc$/, backup.encrypted_path)
  end

  def test_sqlite_encrypted_path_extension
    backup = Muck::Backup.new(@sqlite_database)
    assert_match(/\.sqlite\.enc$/, backup.encrypted_path)
  end
end
