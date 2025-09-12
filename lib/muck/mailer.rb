require 'net/smtp'

module Muck
  class Mailer
    def self.send_email(recipient, subject, body)
      message = <<~MESSAGE
        From: Muck Backup <muck@example.com>
        To: #{recipient}
        Subject: #{subject}
        
        #{body}
      MESSAGE

      Net::SMTP.start('localhost', 25) do |smtp|
        smtp.send_message message, 'muck@example.com', recipient
      end
    end

    def self.send_summary_email(recipient, results)
      subject = "[SUMMARY] Muck Backup Run"
      body = "Muck backup run completed. Here is the summary:\n\n"

      results.each do |result|
        if result.success?
          body += "- [SUCCESS] #{result.database.name} on #{result.database.server.name}\n"
        else
          body += "- [FAILURE] #{result.database.name} on #{result.database.server.name}: #{result.error.message}\n"
        end
      end

      send_email(recipient, subject, body)
    end
  end
end
