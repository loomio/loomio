Griddler.configure do |config|
  config.processor_class = EmailProcessor # CommentViaEmail
  config.processor_method = :process # :create_comment (A method on CommentViaEmail)
  config.reply_delimiter = ['-- REPLY ABOVE THIS LINE OR DIE --']
  config.custom_regex_split_points = [
    /^.+\(Loomio\).+#{BaseMailer::NOTIFICATIONS_EMAIL_ADDRESS}.+:$/i,
    /#{ThreadMailer::REPLY_DELIMITER}/,
  ]
  config.email_service = :mailin # :cloudmailin, :postmark, :mandrill, :mailgun
end
