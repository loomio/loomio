class ReceivedEmailService
	def self.route(email)
		if email.route_path.include?('&')
			CommentService.create(
				comment: Comment.new(comment_params(email)),
				actor: actor_from_email(email)
			)
			# schedule email for destruction tomorrow
		else
			if group = Group.published.find_by(handle: email.route_path)

				if group.members.where(email: email.sender_email).exists? # || group.email_aliases(email: email.sender_email).exists?
					# create the discussion
				else
					email.update(group_id: group.id)
					# wait for someone to approve the email
					# approving email means inviting sender to group, or as guest, or adding an alias for an existing member
				end
			end

			raise "group not found: we may not raise in the future"
		end
	end

	def self.parse_route_params(route_path)
		params = {}.with_indifferent_access

    route_path.split('&').each do |segment|
      key_and_value = segment.split('=')
      params[key_and_value[0]] = key_and_value[1]
    end

    params
  end

  def self.actor_from_email(email)
		params = parse_route_params(email.route_path)
		User.find_by!(id: params['u'], email_api_key: params['k'])
  end

  def self.comment_params(email)
  	params = parse_route_params(email.route_path)

    if params['c'].present?
      parent_id     = params['c']
      parent_type   = "Comment"
    end

    if params['pt'].present?
      parent_type = {
        'p' => 'Poll',
        'c' => 'Comment',
        's' => 'Stance'
      }[params['pt']]
	    parent_id = params['pi']
    end

    {
    	discussion_id: params['d'].to_i,
    	parent_id: parent_id,
    	parent_type: parent_type,
    	body: email.body,
    	files: email.attachments.map {|a| a.blob }
    }.compact
	end
end