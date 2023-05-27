module Ability::PollTemplate
  def initialize(user)
    super(user)

    can :create, ::PollTemplate do |poll_template|
    	poll_template.group.admins.exists?(user.id)
    end
  end
end
