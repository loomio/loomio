class PollQuery
  def self.start
    Poll.distinct.kept.includes(:poll_options, :author)
  end

  def self.visible_to(user: LoggedOutUser.new,
                      chain: start,
                      group_ids: [],
                      or_public: true)

    if user.topic_reader_token
      or_topic_reader_token = "OR tr.token = #{ActiveRecord::Base.connection.quote(user.topic_reader_token)}"
    end

    chain = chain.joins("LEFT OUTER JOIN topics t ON t.id = polls.topic_id")
    chain = chain.where('t.group_id IN (:group_ids)', group_ids: group_ids) if group_ids.any?
    chain = chain.joins("LEFT OUTER JOIN memberships m ON m.group_id = t.group_id AND m.user_id = #{user.id || 0}")
                 .joins("LEFT OUTER JOIN topic_readers tr ON tr.topic_id = t.id AND (tr.user_id = #{user.id || 0} #{or_topic_reader_token})")

    chain = chain.where("polls.author_id = :user_id OR
                         #{'t.private = FALSE OR' if or_public}
                         (m.id IS NOT NULL AND m.revoked_at IS NULL) OR
                         (tr.id IS NOT NULL AND tr.revoked_at IS NULL AND tr.guest = TRUE)", user_id: user.id)
    chain
  end


  def self.filter(chain: , params: )
    # how to do this....
    if group = Group.find_by(key: params[:group_key])
      group_ids = (params[:subgroups] == "none") ? [group.id] : group.id_and_subgroup_ids
      chain = chain.joins(:topic).where("topics.group_id": group_ids)
    end

    if discussion = Discussion.find_by(key: params[:discussion_key]) || Discussion.find_by(id: params[:discussion_id])
      chain = chain.where(topic_id: discussion.topic_id)
    end

    if (tags = (params[:tags] || '').split('|')).any?
      chain = chain.joins(:topic).where("topics.tags @> ARRAY[?]::varchar[]", tags)
    end

    if params[:status] == 'vote'
      voted_poll_ids = Stance.where(latest: true).where.not(cast_at: nil).pluck(:poll_id)
      chain = chain.where.not(id: voted_poll_ids)
    end

    chain = chain.where(author_id: params[:author_id]) if params[:author_id]
    chain = chain.where(poll_type: params[:poll_type]) if params[:poll_type]
    chain = chain.send(params[:status]) if %w(active closed recent template).include?(params[:status])
    chain = chain.search_for(params[:query]) if params[:query]
    chain
  end
end
