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

    smtp_instance = Minitest::Mock.new
    smtp_instance.expect(:start, nil) do |helo, user, pass, authtype, &block|
      assert_equal 'localhost', helo
      assert_equal 'user@example.com', user
      assert_equal 'secret123', pass
      assert_equal :login, authtype
      inner_mock = Minitest::Mock.new
      inner_mock.expect(:send_message, true, [String, String, String])
      block.call(inner_mock)
      inner_mock.verify
      true
    end

    Net::SMTP.stub(:new, smtp_instance) do
      Muck::Mailer.send_email(mail_config, 'test@example.com', 'Test Subject', 'Test Body')
    end

    smtp_instance.verify
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
    dsl.ssl(true)
    dsl.tls(false)

    assert_equal true, hash[:enabled]
    assert_equal 'smtp.example.com', hash[:hostname]
    assert_equal 587, hash[:port]
    assert_equal 'user@example.com', hash[:username]
    assert_equal 'secret123', hash[:password]
    assert_equal 'backup@example.com', hash[:from]
    assert_equal 'admin@example.com', hash[:to]
    assert_equal true, hash[:ssl]
    assert_equal false, hash[:tls]
  end

  def test_send_email_uses_smtp_config
    mail_config = {
      hostname: 'smtp.test.com',
      port: 2525,
      from: 'sender@test.com'
    }

    # Mock Net::SMTP to verify it's called with the right hostname and port
    smtp_instance = Minitest::Mock.new
    smtp_instance.expect(:start, nil) do |&block|
      inner_mock = Minitest::Mock.new
      inner_mock.expect(:send_message, true, [String, String, String])
      block.call(inner_mock)
      inner_mock.verify
      true
    end

    Net::SMTP.stub(:new, lambda { |hostname, port|
      assert_equal 'smtp.test.com', hostname
      assert_equal 2525, port
      smtp_instance
    }) do
      Muck::Mailer.send_email(mail_config, 'recipient@test.com', 'Test', 'Body')
    end

    smtp_instance.verify
  end

  def test_send_email_with_ssl
    mail_config = {
      hostname: 'smtp.test.com',
      port: 465,
      from: 'sender@test.com',
      ssl: true
    }

    smtp_instance = Minitest::Mock.new
    smtp_instance.expect(:enable_ssl, nil, [OpenSSL::SSL::SSLContext])
    smtp_instance.expect(:start, nil) do |&block|
      inner_mock = Minitest::Mock.new
      inner_mock.expect(:send_message, true, [String, String, String])
      block.call(inner_mock)
      inner_mock.verify
      true
    end

    Net::SMTP.stub(:new, smtp_instance) do
      Muck::Mailer.send_email(mail_config, 'recipient@test.com', 'Test', 'Body')
    end

    smtp_instance.verify
  end

  def test_send_email_with_tls
    mail_config = {
      hostname: 'smtp.test.com',
      port: 587,
      from: 'sender@test.com',
      tls: true
    }

    smtp_instance = Minitest::Mock.new
    smtp_instance.expect(:enable_starttls, nil, [OpenSSL::SSL::SSLContext])
    smtp_instance.expect(:start, nil) do |&block|
      inner_mock = Minitest::Mock.new
      inner_mock.expect(:send_message, true, [String, String, String])
      block.call(inner_mock)
      inner_mock.verify
      true
    end

    Net::SMTP.stub(:new, smtp_instance) do
      Muck::Mailer.send_email(mail_config, 'recipient@test.com', 'Test', 'Body')
    end

    smtp_instance.verify
  end
end
