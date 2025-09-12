require 'test_helper'
require 'muck/mailer'
require 'muck/config_dsl/mail_dsl'
require 'minitest/mock'

class MailerTest < Minitest::Test
  def test_send_email
    mock_smtp = Minitest::Mock.new
    mock_smtp.expect(:send_message, true, [String, String, String])

    Net::SMTP.stub(:start, true, mock_smtp) do
      Muck::Mailer.send_email('test@example.com', 'Test Subject', 'Test Body')
    end

    mock_smtp.verify
  end

  def test_mail_dsl_configuration
    hash = {}
    dsl = Muck::ConfigDSL::MailDSL.new(hash)
    
    dsl.enabled(true)
    dsl.hostname('smtp.example.com')
    dsl.port(587)
    dsl.username('user@example.com')
    dsl.password('secret123')
    dsl.from('backup@example.com')
    dsl.to('admin@example.com')
    
    assert_equal true, hash[:enabled]
    assert_equal 'smtp.example.com', hash[:hostname]
    assert_equal 587, hash[:port]
    assert_equal 'user@example.com', hash[:username]
    assert_equal 'secret123', hash[:password]
    assert_equal 'backup@example.com', hash[:from]
    assert_equal 'admin@example.com', hash[:to]
  end
end
