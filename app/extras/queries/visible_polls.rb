class Queries::VisiblePolls < Delegator
  def initialize(user: nil, group_ids: [], show_public: false)
    user = user || LoggedOutUser.new
    group_ids = group_ids

    if user.discussion_reader_token
      or_discussion_reader_token = "OR dr.token = #{ActiveRecord::Base.connection.quote(user.discussion_reader_token)}"
    end

    if user.stance_token
      or_stance_token = "OR s.token = #{ActiveRecord::Base.connection.quote(user.discussion_reader_token)}"
    end

    @relation = Poll.includes(:poll_options, :group, :author)
    @relation = @relation.where('polls.group_id IN (:group_ids)', group_ids: group_ids) if group_ids.any?
    @relation.joins("LEFT OUTER JOIN memberships m ON m.group_id = polls.group_id AND m.user_id = #{user.id || 0}")
             .joins("LEFT OUTER JOIN discussion_readers dr ON dr.discussion_id = polls.discussion_id AND (dr.user_id = #{user.id || 0} #{or_discussion_reader_token})")
             .joins("LEFT OUTER JOIN stances s ON s.poll_id = polls.id AND (s.participant_id = #{user.id || 0} #{or_stance_token})")
             .joins("LEFT OUTER JOIN groups g on g.id = polls.group_id")
             .joins("LEFT OUTER JOIN discussions on discussions.id = polls.discussion_id")
             .where("g.archived_at IS NULL")
             .where("#{'(discussions.private = false) OR' if show_public}
                     (m.id IS NOT NULL AND m.archived_at IS NULL) OR
                     (dr.id IS NOT NULL AND dr.revoked_at IS NULL AND dr.inviter_id IS NOT NULL) OR
                     (s.id IS NOT NULL AND s.revoked_at IS NULL)")


    super(@relation)
  end

  def closed
    @relation.closed
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end
end
