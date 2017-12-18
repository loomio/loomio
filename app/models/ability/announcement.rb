module Ability::Announcement
  def initialize(user)
    super(user)

    can :create, ::Announcement do |announcement|
      user_is_author_of?(announcement.announceable) ||
      user_is_admin_of?(announcement.announceable.group_id)
    end
  end
end
