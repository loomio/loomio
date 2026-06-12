class PwnedPasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :pwned_password) if Pwned::Password.new(value).pwned?
  rescue Pwned::TimeoutError, Pwned::Error
    true
  end
end
