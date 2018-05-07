module AvatarInitials
  # Requires base class to define:
  #   avatar_initials
  #   name
  #   email
  #   deactivated_at

  extend ActiveSupport::Concern

  def set_avatar_initials
    self.avatar_initials = get_avatar_initials[0..2]
  end

  def get_avatar_initials
    if respond_to?(:deactivated_at) && deactivated_at
      "DU"
    elsif name.blank? || name == email
      email.to_s[0..1]
    else
      name.split.map(&:first).join
    end.upcase.gsub(/ /, '')
  end
end
