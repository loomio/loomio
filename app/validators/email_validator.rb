class EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEX = URI::MailTo::EMAIL_REGEXP

  def validate_each(record, attribute, value)
    unless value =~ EMAIL_REGEX
      record.errors.add(attribute, "Not a valid email")
    end
  end
end