class NontrivialPasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if BlacklistedPassword.where(string: value.downcase).any?
      record.errors.add attribute, "password is too simple, please choose a different one"
    end
  end
end
