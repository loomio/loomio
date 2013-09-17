Devise.setup do |config|
  config.warden do |manager|
    manager.default_strategies(:scope => :user).unshift :browserid_authenticatable
  end
  config.browserid_url = 'login.persona.org'
end
