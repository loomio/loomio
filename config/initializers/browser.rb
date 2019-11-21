Rails.configuration.middleware.use Browser::Middleware do
  redirect_to '/417' if browser.ie? && !(request.params['old_client'])
end
