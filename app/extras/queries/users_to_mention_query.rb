class Queries::UsersToMentionQuery
  def self.for(model)
    model.mentioned_group_members - model.group.users.mentioned_in(model)
  end
end
