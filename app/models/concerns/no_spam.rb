module NoSpam
  # eg:
  # SPAM_REGEX="(diide\.com|gusronk\.com|appnox\.com|akxpert\.com)"
  SPAM_REGEX = Regexp.new(ENV.fetch('SPAM_REGEX', "(diide\.com|gusronk\.com)"), 'i')
  
  def no_spam_for(*fields)
    Array(fields).each do |field|
      validates field, format: { without: SPAM_REGEX, message: "no spam" }
    end
  end
end
