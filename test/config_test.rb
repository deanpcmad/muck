require 'test_helper'

class ConfigTest < Minitest::Test
  def test_initialize
    config = Muck::Config.new('test/data')
    assert_equal 1, config.servers.length
  end
end
