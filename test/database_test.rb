require 'test_helper'

class DatabaseTest < Minitest::Test
  def setup
    @config = Muck::Config.new('test/data')
    @server = @config.servers.first
    @database = @server.databases.first
    @sqlite_database = @server.databases.find { |db| db.type == 'sqlite' }
  end

  def test_name
    assert_equal 'test_db', @database.name
  end

  def test_app_name
    assert_equal 'test-app', @database.app_name
  end

  def test_sqlite_name
    assert_equal 'test_sqlite_db', @sqlite_database.name
  end

  def test_sqlite_type
    assert_equal 'sqlite', @sqlite_database.type
  end

  def test_sqlite_path
    assert_equal '/var/data/test-app/production.db', @sqlite_database.path
  end

  def test_sqlite_backup_command
    assert_equal 'sqlite3', @sqlite_database.backup_command
  end

  def test_sqlite_dump_command
    expected = 'sqlite3 /var/data/test-app/production.db ".backup /tmp/muck_backup_test_sqlite_db.sqlite" && cat /tmp/muck_backup_test_sqlite_db.sqlite && rm /tmp/muck_backup_test_sqlite_db.sqlite'
    assert_equal expected, @sqlite_database.dump_command
  end

  def test_mysql_backup_command
    assert_equal 'mysqldump', @database.backup_command
  end

  def test_mysql_dump_command
    assert_includes @database.dump_command, 'docker exec'
    assert_includes @database.dump_command, 'mysqldump'
  end
end
