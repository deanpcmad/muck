require 'test_helper'
require 'muck/backup'

class BackupTest < Minitest::Test
  def setup
    @config = Muck::Config.new('test/data')
    @server = @config.servers.first
    @database = @server.databases.first
  end

  def test_run
    # This is a simple test that checks if the run method returns a Muck::Result object.
    # For a real-world scenario, you would want to use a mock SSH connection and file system to verify that the backup is created correctly.
    result = Muck::Backup.new(@database).run
    assert_instance_of Muck::Result, result
  end
end
