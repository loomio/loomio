class EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEXP = /\A[^@\s]+@[^@\s]+\z/

  def validate_each(record, attribute, value)
    unless value =~ EMAIL_REGEXP
      record.errors.add(attribute, "Not a valid email")
    end
  end
end
