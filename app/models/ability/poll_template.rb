module Ability::PollTemplate
  def initialize(user)
    super(user)

    can([:create, :update], ::PollTemplate) do |poll_template|
    	poll_template.group.admins.exists?(user.id)
    end
  end
end
