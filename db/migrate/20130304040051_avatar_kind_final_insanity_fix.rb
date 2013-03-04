class AvatarKindFinalInsanityFix < ActiveRecord::Migration
  def up
    users = User.where("avatar_kind != 'initials' AND avatar_kind != 'uploaded' AND avatar_kind != 'gravatar'")
    users.each do |user|
      user.name ||= user.email
      user.avatar_kind = 'initials'
      user.save!
    end
  end

  def down
  end
end
