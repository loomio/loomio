require 'aws-sdk-sesv2'

# Optional read-only operator diagnostic. Sending, feedback processing and local
# suppression do not depend on this lookup or on AWS availability.
class SesEmailSuppressionService
  def self.client
    Aws::SESV2::Client.new(region: ENV.fetch('SES_SUPPRESSION_REGION'),
      retry_limit: 0, http_open_timeout: 5, http_read_timeout: 5)
  end

  def self.suppression_for(email, client:)
    client.get_suppressed_destination(email_address: email).suppressed_destination
  rescue Aws::SESV2::Errors::NotFoundException
    nil
  end
end
