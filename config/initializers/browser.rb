Rails.configuration.middleware.use Browser::Middleware do
  redirect_to '/417' if !(request.params['old_client']) && !request.xhr? && browser.ie?
end
