class PopulateAvatarInitialsOnUser < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

  def up
    User.reset_column_information
    User.all.each do |user|
      initials = ""
      if user.name.blank? || user.name == user.email
        initials = user.email[0..1]
      else
        user.name.split.each { |name| initials += name[0] }
      end
      initials = initials.upcase.gsub(/ /, '')
      initials = "DU" if user.deleted_at
      user.avatar_initials = initials[0..2]
      user.save!
    end
  end

  def down
  end
end
