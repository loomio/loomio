module Ability::User
  def initialize(user)
    super(user)

    can :show, ::User do |u|
      u.deactivated_at.nil?
    end

    can :deactivate, ::User do |u|
      u.deactivated_at.nil?
    end

    can :reactivate, ::User do |u|
      u.deactivated_at?
    end

    can [:update,
         :see_notifications_for,
         :subscribe_to], ::User do |u|
      user == u
    end
  end
end
