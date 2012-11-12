SanitizeEmail::Config.configure do |config|
  config[:sanitized_to] = 'jon@loomio.org'
  # sanitize emails from development and test, or set whatever logic should turn sanitize_email on and off here:
  config[:activation_proc] = Proc.new { %w(staging).include?(Rails.env) }
  config[:use_actual_email_prepended_to_subject] = true   # or false
  config[:use_actual_email_as_sanitized_user_name] = true # or false
end