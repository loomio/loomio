module Ability::DiscussionTemplate
  def initialize(user)
    super(user)

    can([:create, :update], ::DiscussionTemplate) do |discussion_template|
    	discussion_template.group.admins.exists?(user.id)
    end
  end
end
