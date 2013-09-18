module AvatarInitials
  # Requires base class to define:
  #   avatar_initials
  #   name
  #   email
  #   deleted_at

  extend ActiveSupport::Concern

  def set_avatar_initials
    initials = ""
    if name.blank? || name == email
      initials = email[0..1]
    else
      name.split.each { |name| initials += name[0] }
    end
    initials = initials.upcase.gsub(/ /, '')
    initials = "DU" if deleted_at
    self.avatar_initials = initials[0..2]
  end
end
