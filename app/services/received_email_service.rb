class ReceivedEmailService
  def self.create(received_email: )
    if !User.active.find_by(email: received_email.sender_address)
      user_not_found(received_email)
    elsif /(d=\d+)&(u=\d+)&(k=\w+)/.match(received_email.receiving_address_local_part)
      comment(received_email)
    elsif Group.find_by(handle: received_email.receiving_address_local_part)
      discussion(received_email)
    else
      group_not_found(received_email)
    end
  end

  def self.comment(received_email)
    params = {}
    received_email.receiving_address_local_part.split('&').each do |segment|
      key_and_value = segment.split('=')
      params[key_and_value[0]] = key_and_value[1]
    end

    discussion_id = params['d']
    user_id       = params['u']
    parent_id     = params['c']
    email_api_key = params['k']
    comment = Comment.new(discussion_id: discussion_id,
                          parent_id: parent_id,
                          body: received_email.body)
    actor = User.find_by(id: user_id,
                         email_api_key: email_api_key) || LoggedOutUser.new
    CommentService.create(comment: comment, actor: actor)
  rescue CanCan::AccessDenied
    #no-op
  end

  def self.discussion(received_email)
    group = FormalGroup.find_by(handle: received_email.receiving_address_local_part)
    sender = User.active.find_by(email: received_email.sender_address)

    discussion = Discussion.new(author: sender,
                                group: group,
                                title: received_email.subject,
                                description: received_email.body,
                                description_format: received_email.body_format)

    discussion.inherit_group_privacy!
    if DiscussionService.create(discussion: discussion, actor: sender)
      # later may want to add other recipients as guest members
      # ReceivedEmailMailer.discussion_created()
      true
    else
      # ReceivedEmailMailer.something_went_wrong
      false
    end
  end

  def self.user_not_found(received_email)
    ReceivedEmailMailer.user_not_found(received_email.sender_address).deliver_later
  end

  def self.group_not_found(received_email)
    ReceivedEmailMailer.group_not_found(received_email.sender_address,
                                        group_handle: received_email.receiving_address_local_part).deliver_later
  end
end
