require 'rubygems'
require 'net/smtp'

#
# Provides a Chef exception handler so you can send information about
# chef-client failures to an Email room.
#
# Docs: http://wiki.opscode.com/display/chef/Exception+and+Report+Handlers
#
# 
#

module Email
  class Notifications < Chef::Handler

    def initialize(smtp_server, from_address, to_address)
      @smtp_server  = smtp_server
      @from_address = from_address
      @to_address   = to_address
    end

    def report
      # Create the email message
      message  = "From: #{@from_address}\n"
      message << "To: #{@to_address}\n"
      message << "Subject: Chef Run Failure\n"
      message << "Date: #{Time.now.rfc2822}\n\n"

      # The Node is available as +node+
      message << "Chef run failed on #{node.name}\n"
      # +run_status+ is a value object with all of the run status data
      message << "#{run_status.formatted_exception}\n"
      # Join the backtrace lines. Coerce to an array just in case.
      message << Array(backtrace).join("\n")

      #Send the email
      Net::SMTP.start(@smtp_server, 25) do |smtp|
        smtp.send_message message, @from_address, @to_address
      end
    end
  end
end