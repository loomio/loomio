module NoSpam
  def no_spam_for(*fields)
    Array(fields).each do |field|
      validates field, format: { without: Regexp.new(ENV['SPAM_REGEX']), message: "no spam" } if ENV['SPAM_REGEX']
    end
  end
end
