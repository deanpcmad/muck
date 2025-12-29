require 'net/smtp'
require 'openssl'

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

      smtp = Net::SMTP.new(hostname, port)

      if mail_config[:ssl] || mail_config[:tls]
        ssl_context = OpenSSL::SSL::SSLContext.new

        if mail_config[:verify_ssl] == false
          ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
        else
          ssl_context.verify_mode = OpenSSL::SSL::VERIFY_PEER
          ssl_context.ca_file = mail_config[:ca_file] if mail_config[:ca_file]
          ssl_context.ca_path = mail_config[:ca_path] if mail_config[:ca_path]

          # Use system CA store if no custom CA is specified
          if !mail_config[:ca_file] && !mail_config[:ca_path]
            ssl_context.cert_store = OpenSSL::X509::Store.new
            ssl_context.cert_store.set_default_paths
          end
        end

        if mail_config[:ssl]
          smtp.enable_ssl(ssl_context)
        else
          smtp.enable_starttls(ssl_context)
        end
      end

      auth_method = mail_config[:auth_method] || :login

      if mail_config[:username] && mail_config[:password]
        smtp.start('localhost', mail_config[:username], mail_config[:password], auth_method) do |s|
          s.send_message message, from_address, recipient
        end
      else
        smtp.start do |s|
          s.send_message message, from_address, recipient
        end
      end
    end

    def self.send_summary_email(mail_config, results)
      recipient = mail_config[:to] || mail_config[:recipient]
      subject = '[SUMMARY] Muck Backup Run'
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
