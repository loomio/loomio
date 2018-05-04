AnnouncementRecipientEmails = Struct.new(:emails, :locale) do
  def id
    nil
  end

  def email_hash
    Digest::MD5.hexdigest(object.emails.join)
  end

  def email
    "multiple"
  end

  def name
    I18n.t :announcement_count_emails, locale: locale, count: emails.length
  end

  def avatar_kind
    'mdi-email-outline'
  end

  alias :read_attribute_for_serialization :send
end
