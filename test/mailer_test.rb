require 'test_helper'
require 'muck/mailer'
require 'muck/config_dsl/mail_dsl'
require 'minitest/mock'

class MailerTest < Minitest::Test
  def test_send_email
    mail_config = {
      hostname: 'smtp.example.com',
      port: 587,
      from: 'backup@example.com',
      username: 'user@example.com',
      password: 'secret123'
    }
    
    mock_smtp = Minitest::Mock.new
    mock_smtp.expect(:send_message, true, [String, String, String])

    Net::SMTP.stub(:start, true, mock_smtp) do
      Muck::Mailer.send_email(mail_config, 'test@example.com', 'Test Subject', 'Test Body')
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

  def test_send_email_uses_smtp_config
    mail_config = {
      hostname: 'smtp.test.com',
      port: 2525,
      from: 'sender@test.com'
    }
    
    # Mock Net::SMTP to verify it's called with the right hostname and port
    smtp_mock = Minitest::Mock.new
    smtp_mock.expect(:send_message, true, [String, String, String])
    
    Net::SMTP.stub(:start, lambda { |hostname, port, &block|
      assert_equal 'smtp.test.com', hostname
      assert_equal 2525, port
      block.call(smtp_mock)
    }) do
      Muck::Mailer.send_email(mail_config, 'recipient@test.com', 'Test', 'Body')
    end
    
    smtp_mock.verify
  end
end
