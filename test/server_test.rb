require 'test_helper'

class ServerTest < Minitest::Test
  def setup
    @config = Muck::Config.new('test/data')
    @server = @config.servers.first
  end

  def test_name
    assert_equal 'test-server', @server.name
  end

  def test_ip_address
    assert_equal '127.0.0.1', @server.ip_address
  end

  def test_frequency
    assert_equal 60, @server.frequency
  end

  def test_databases
    assert_equal 1, @server.databases.length
  end
end
