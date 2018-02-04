module Ability::Announcement
  def initialize(user)
    super(user)

    can :create, ::Announcement do |announcement|
      if event = announcement.event
        user.id == event.user_id
      else
        can? :update, announcement.model
      end
    end
  end
end
