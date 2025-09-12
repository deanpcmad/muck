require 'test_helper'
require 'muck/mailer'
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
end
