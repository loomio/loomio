class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ User::EMAIL_REGEXP
      record.errors.add(attribute, "Not a valid email")
    end
  end
end