require 'email_processor'

Griddler.configure do |config|
  config.processor_class = EmailProcessor # MyEmailProcessor
  # config.processor_method = :process # :custom_method
  config.to = :hash # :full, :email, :token
  config.from = :email # :full, :token, :hash
  # :raw    => 'AppName <s13.6b2d13dc6a1d33db7644@mail.myapp.com>'
  # :email  => 's13.6b2d13dc6a1d33db7644@mail.myapp.com'
  # :token  => 's13.6b2d13dc6a1d33db7644'
  # :hash   => { raw: [...], email: [...], token: [...], host: [...],
  # name: [...] }
  config.reply_delimiter = '-- REPLY ABOVE THIS LINE --'
  config.email_service = :sendgrid # :cloudmailin, :postmark, :mandrill, :mailgun
end