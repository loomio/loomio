class PwnedPasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    return unless Rails.env.production?

    if Pwned.check(value)
      record.errors.add(attribute, "has been found in data breaches")
    end
  end
end
