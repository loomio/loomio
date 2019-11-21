Rails.configuration.middleware.use Browser::Middleware do
  debugger
  redirect_to '/417' if !request.params['old_client'] &&
                        !request.xhr? &&
                        (browser.ie? ||
                        (browser.chrome? && browser.version.to_i < 50) ||
                        (browser.safari? && browser.version.to_i < 12) ||
                        (browser.edge?   && browser.version.to_i < 17))
end
