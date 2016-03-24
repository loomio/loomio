class AllEmailInterceptor
  def self.delivering_email(message)
    message.to = ENV['INTERCEPTOR_EMAIL'].split(' ')
  end
end
