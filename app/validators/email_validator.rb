class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attr_name, value)
    unless value =~ Devise.email_regexp
      record.errors.add(attr_name, :email, options.merge(:value => value))
    end
  end
end