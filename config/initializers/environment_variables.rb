unless Rails.env.test?
  required_env_vars = [] # can be expanded in future iteration                    
  missing_env_vars = required_env_vars.select { |key| !ENV.has_key?(key.to_s) }
  error_message = "You are missing the following required environment variables: #{missing_env_vars}\n Please set them to continue."
  raise error_message if missing_env_vars.any?
  
  optional_env_vars = {'SECRET_COOKIE_TOKEN' => '',
                       'EXCEPTION_RECIPIENT' => '',
                       'AWS_ACCESS_KEY_ID' => '',
                       'AWS_SECRET_ACCESS_KEY' => '',
                       'AWS_ATTACHMENT_BUCKET' => '',
                       'SENDGRID_USERNAME' => '',
                       'SENDGRID_PASSWORD' => '',
                       'BING_TRANSLATION_APPID' => '',
                       'BING_TRANSLATION_SECRET' => '',
                       'NAVBAR_LOGO_PATH' => 'top-bar-loomio.png',
                       'NAVBAR_CONTRIBUTE' => 'show',
                       'CANONICAL_HOST' => 'loomio.org',
                       'FOG_DIRECTORY' => '',
                       'TAG_MANAGER_ID' => '' }
  optional_env_vars.keys.each do |key|
    ENV[key] ||= optional_env_vars[key]
  end
end