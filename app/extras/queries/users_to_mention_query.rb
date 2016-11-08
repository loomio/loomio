class Queries::UsersToMentionQuery
  def self.for(model)
    model.mentioned_group_members - model.group.users.mentioned_in(model) - model.users_to_not_mention
  end
end
