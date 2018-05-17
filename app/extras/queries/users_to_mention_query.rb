class Queries::UsersToMentionQuery
  def self.for(model)
    model.mentioned_users
         .where.not(id: model.group.members.mentioned_in(model)) # avoid re-mentioning users when editing
         .where.not(id: model.users_to_not_mention)
  end
end
