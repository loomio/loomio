class PopulateAvatarInitialsOnUser < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

  def up
    User.all.each do |user|
      initials = ""
      if  user.name.blank? || user.name == user.email
        initials = user.email[0..1]
      else
        user.name.gsub(/(?:^|\s|-|')[A-Z,a-z]/) { |first_character| initials += first_character }
      end
      initials = initials.upcase.gsub(/ /, '')
      initials = "DU" if user.deleted_at
      user.avatar_initials = initials[0..1]
      user.save
    end
  end

  def down
  end
end
