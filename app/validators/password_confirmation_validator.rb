class PasswordConfirmationValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.password.present? && record.password != record.password_confirmation
      record.errors.add attribute, "doesn't match confirmation"
    end
  end
end