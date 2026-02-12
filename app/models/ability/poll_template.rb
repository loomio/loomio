module Ability::PollTemplate
  def initialize(user)
    super(user)

    can(:create, ::PollTemplate) do |poll_template|
      group = poll_template.group
      group.admins.exists?(user.id) ||
        (group.members_can_create_templates && group.members.exists?(user.id))
    end

    can(:update, ::PollTemplate) do |poll_template|
      group = poll_template.group
      group.admins.exists?(user.id) ||
        (group.members_can_create_templates && poll_template.author_id == user.id && group.members.exists?(user.id))
    end
  end
end
