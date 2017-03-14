module AvatarInitials
  # Requires base class to define:
  #   avatar_initials
  #   name
  #   email
  #   deactivated_at

  extend ActiveSupport::Concern

  def set_avatar_initials
    if name.blank? || name == email
      initials = email.to_s[0..1]
    else
      initials = name.split.
                      map {|name| name[0] }.
                      join('')
    end
    initials = initials.upcase.gsub(/ /, '')
    initials = "DU" if deactivated_at
    self.avatar_initials = initials[0..2]
  end
end
