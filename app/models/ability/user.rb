module Ability::User
  def initialize(user)
    super(user)

    can :show, ::User do |u|
      u.deactivated_at.nil?
    end

    can :deactivate, ::User do |u|
      u.adminable_groups.where(type: "FormalGroup").all? { |g| g.admins.count > 1 }
    end

    can :reactivate, ::User do |u|
      u.deactivated_at?
    end

    can [:update,
         :see_notifications_for,
         :make_draft,
         :subscribe_to], ::User do |u|
      user == u
    end
  end
end
