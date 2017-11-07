class Queries::UsersToMentionQuery
  def self.for(model)
    model.new_mentioned_group_members
  end
end
