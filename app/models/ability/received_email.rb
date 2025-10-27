module Ability::ReceivedEmail
  def initialize(user)
    super(user)

    can :show, ::ReceivedEmail do |email|
      user.adminable_group_ids.include? email.group_id
    end
  end
end
