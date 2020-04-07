class UserInviter
  def self.where_or_create!(emails:, user_ids:, inviter:)
    emails = Array(emails)
    user_ids = Array(user_ids)
    User.import(safe_emails(emails).map do |email|
      User.new(email: email, time_zone: inviter.time_zone, detected_locale: inviter.locale)
    end, on_duplicate_key_ignore: true)
    User.where("id in (:ids) or email in (:emails)", ids: user_ids, emails: emails)
  end

  private

  def self.safe_emails(emails)
    if ENV['SPAM_REGEX']
      emails.uniq.reject {|email| Regexp.new(ENV['SPAM_REGEX']).match(email) }
    else
      emails.uniq
    end
  end
end
