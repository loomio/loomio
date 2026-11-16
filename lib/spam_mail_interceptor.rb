class SpamMailInterceptor
  # This delivery boundary also covers forwarded mail and messages prepared
  # before a ban was added. Filter individual recipients without blocking the
  # other recipients of a mixed message.
  def self.delivering_email(message)
    SpamRules.with_context do
      %i[to cc bcc].each do |field|
        addresses = Array(message.public_send(field))
        allowed = addresses.reject { |address| SpamRules.blocked?(address, target: :email, action: 'email') }
        message.public_send("#{field}=", allowed) unless addresses == allowed
      end
      message.perform_deliveries = false if message.destinations.empty?
    end
  end
end
