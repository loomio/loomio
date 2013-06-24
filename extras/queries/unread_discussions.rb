class Queries::UnreadDiscussions
  def self.for(user, group)
    group.
      discussions.
      joins("LEFT OUTER JOIN discussion_read_logs drl ON
            drl.discussion_id = discussions.id AND drl.user_id = #{user.id}").
      where('(drl.discussion_last_viewed_at < discussions.last_comment_at) OR drl.id IS NULL', user.id)
  end
end
