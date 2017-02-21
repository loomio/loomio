class Queries::UsersToMentionQuery
  def self.for(model)
    model.mentioned_group_members
         .without(model.group.users.mentioned_in(model)) # avoid re-mentioning users when editing
         .without(model.users_to_not_mention)
  end
end
