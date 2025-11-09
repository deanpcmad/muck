require 'net/smtp'

module Muck
  class Mailer
    def self.send_email(mail_config, recipient, subject, body)
      from_address = mail_config[:from] || 'muck@example.com'

      message = <<~MESSAGE
        From: #{from_address}
        To: #{recipient}
        Subject: #{subject}
        Date: #{Time.now.rfc2822}

        #{body}
      MESSAGE

      hostname = mail_config[:hostname] || 'localhost'
      port = mail_config[:port] || 25

      if mail_config[:username] && mail_config[:password]
        Net::SMTP.start(hostname, port, 'localhost', mail_config[:username], mail_config[:password], :plain) do |smtp|
          smtp.send_message message, from_address, recipient
        end
      else
        Net::SMTP.start(hostname, port) do |smtp|
          smtp.send_message message, from_address, recipient
        end
      end
    end

    def self.send_summary_email(mail_config, results)
      recipient = mail_config[:to] || mail_config[:recipient]
      subject = "[SUMMARY] Muck Backup Run"
      body = "Muck backup run completed. Here is the summary:\n\n"

      results.each do |result|
        if result.success?
          body += "- [SUCCESS] #{result.database.app_name} (#{result.database.name}) on #{result.database.server.name}\n"
        else
          body += "- [FAILURE] #{result.database.app_name} (#{result.database.name}) on #{result.database.server.name}: #{result.error.message}\n"
        end
      end

      send_email(mail_config, recipient, subject, body)
    end
  end
end
