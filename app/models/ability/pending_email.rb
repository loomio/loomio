module Ability::PendingEmail
  def initialize(user)
    super(user)

    can :show, ::PendingEmail do |email|
      user.adminable_group_ids.include? email.group_id
    end
  end
end
