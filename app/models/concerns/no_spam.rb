module NoSpam
  def no_spam_for(*fields)
    Array(fields).each do |field|
      validate do
        target = field == :email ? :email : :content
        action = is_a?(User) && new_record? ? 'signup' : 'content'
        errors.add(field, 'no spam') if SpamRules.blocked?(public_send(field), target: target, action: action)
      end
    end
  end
end
