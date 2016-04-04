if ENV['INTERCEPTOR_EMAIL']
  ActionMailer::Base.register_interceptor(AllEmailInterceptor)
end
