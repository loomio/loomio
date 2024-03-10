class PollQuery
  def self.start
    Poll.distinct.kept.includes(:poll_options, :group, :author)
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
    chain = chain.joins("LEFT OUTER JOIN discussions d on d.id = polls.discussion_id")
    chain = chain.joins("LEFT OUTER JOIN memberships m ON m.group_id = polls.group_id AND m.user_id = #{user.id || 0}")
                 .joins("LEFT OUTER JOIN discussion_readers dr ON dr.discussion_id = polls.discussion_id AND (dr.user_id = #{user.id || 0} #{or_discussion_reader_token})")
                 .joins("LEFT OUTER JOIN stances s ON s.poll_id = polls.id AND (s.participant_id = #{user.id || 0} #{or_stance_token})")
                 .where("#{'d.private = false OR ' if show_public}
                         polls.author_id = :user_id OR
                         (m.id IS NOT NULL AND m.revoked_at IS NULL) OR
                         (dr.id IS NOT NULL AND dr.revoked_at IS NULL AND dr.guest = TRUE) OR
                         (s.id IS NOT NULL AND s.revoked_at IS NULL AND s.guest = TRUE)", user_id: user.id)
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


    if (tags = (params[:tags] || '').split('|')).any?
      chain = chain.where.contains(tags: tags)
    end

    if params[:status] == 'vote'
      voted_poll_ids = Stance.where(latest: true).where.not(cast_at: nil).pluck(:poll_id)
      chain = chain.where.not(id: voted_poll_ids)
    end

    chain = chain.where(template: true) if params[:template]
    chain = chain.where(author_id: params[:author_id]) if params[:author_id]
    chain = chain.where(poll_type: params[:poll_type]) if params[:poll_type]
    chain = chain.send(params[:status]) if %w(active closed recent template).include?(params[:status])
    chain = chain.search_for(params[:query]) if params[:query]
    chain
  end
end
