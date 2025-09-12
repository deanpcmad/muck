require 'test_helper'

class DatabaseTest < Minitest::Test
  def setup
    @config = Muck::Config.new('test/data')
    @server = @config.servers.first
    @database = @server.databases.first
  end

  def test_name
    assert_equal 'test_db', @database.name
  end

  def test_app_name
    assert_equal 'test-app', @database.app_name
  end
end
