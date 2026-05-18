module Ability::DiscussionTemplate
  def initialize(user)
    super(user)

    can(:create, ::DiscussionTemplate) do |discussion_template|
      group = discussion_template.group
      group.admins.exists?(user.id) ||
        (group.members_can_create_templates && group.members.exists?(user.id))
    end

    can(:update, ::DiscussionTemplate) do |discussion_template|
      group = discussion_template.group
      group.admins.exists?(user.id) ||
        (group.members_can_create_templates && discussion_template.author_id == user.id && group.members.exists?(user.id))
    end
  end
end
