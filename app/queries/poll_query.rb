class PollQuery
  def self.start
    Poll.includes(:poll_options, :group, :author)
  end

  def self.visible_to(user: LoggedOutUser.new,
                      chain: start,
                      group_ids: [],
                      show_public: false)

    if user.discussion_reader_token
      or_discussion_reader_token = "OR dr.token = #{ActiveRecord::Base.connection.quote(user.discussion_reader_token)}"
    end

    if user.stance_token
      or_stance_token = "OR s.token = #{ActiveRecord::Base.connection.quote(user.discussion_reader_token)}"
    end

    chain = chain.where('polls.group_id IN (:group_ids)', group_ids: group_ids) if group_ids.any?
    chain = chain.joins("LEFT OUTER JOIN discussions on discussions.id = polls.discussion_id") if show_public
    chain = chain.joins("LEFT OUTER JOIN memberships m ON m.group_id = polls.group_id AND m.user_id = #{user.id || 0}")
                 .joins("LEFT OUTER JOIN discussion_readers dr ON dr.discussion_id = polls.discussion_id AND (dr.user_id = #{user.id || 0} #{or_discussion_reader_token})")
                 .joins("LEFT OUTER JOIN stances s ON s.poll_id = polls.id AND (s.participant_id = #{user.id || 0} #{or_stance_token})")
                 .joins("LEFT OUTER JOIN groups g on g.id = polls.group_id").where("g.archived_at IS NULL")
                 .where("#{'discussions.private = FALSE OR polls.anyone_can_participate = TRUE OR ' if show_public}
                         polls.author_id = :user_id OR
                         (m.id IS NOT NULL AND m.archived_at IS NULL) OR
                         (dr.id IS NOT NULL AND dr.revoked_at IS NULL AND dr.inviter_id IS NOT NULL) OR
                         (s.id IS NOT NULL AND s.revoked_at IS NULL)", user_id: user.id)
    chain
  end


  def self.filter(chain: , params: )
    # how to do this....
    if group = Group.find_by(key: params[:group_key])
      group_ids = (params[:subgroups] == "none") ? [group.id] : group.id_and_subgroup_ids
      chain = chain.where(group_id: group_ids)
    end

    if discussion = Discussion.find_by(key: params[:discussion_key]) || Discussion.find_by(id: params[:discussion_id])
      chain = chain.where(discussion_id: discussion.id)
    end

    chain = chain.where(author_id: params[:author_id]) if params[:author_id]
    chain = chain.where(poll_type: params[:poll_type]) if params[:poll_type]
    chain = chain.send(params[:status]) if %w(active closed).include?(params[:status])
    chain = chain.search_for(params[:query]) if params[:query]
    chain
  end
end
