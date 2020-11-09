module NoSpam
  # eg:
  # SPAM_REGEX=(diide.com|gusronk.com|appnox.com|akxpert.com)
  # SPAM_REGEX=(diide\.com|gusronk\.com|appnox\.com|akxpert\.com)
  def no_spam_for(*fields)
    Array(fields).each do |field|
      validates field, format: { without: Regexp.new(ENV['SPAM_REGEX']), message: "no spam" } if ENV['SPAM_REGEX']
    end
  end
end
