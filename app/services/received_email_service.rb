class ReceivedEmailService
  def self.refresh_reserved_handles
    reserved_handles = File.readlines(Rails.root.join("db/handle_banlist.txt")).map(&:chomp).map do |handle| 
      {handle: handle, email: "#{handle}@#{ENV['REPLY_HOSTNAME']}"}
    end

    ReservedHandle.delete_all
    ReservedHandle.insert_all(reserved_handles, record_timestamps: false)
  end

  def self.route_all
    ReceivedEmail.unreleased.where(group_id: nil).each do |email|
      route(email)
    end
  end

  def self.route(email)
    return nil unless email.route_address
    case email.route_path
    when /d=.+&u=.+&k=.+/
      # personal email-to-thread, eg. d=100&k=asdfghjkl&u=999@mail.loomio.com
      CommentService.create(
        comment: Comment.new(comment_params(email)),
        actor: actor_from_email(email)
      )

      email.update_attribute(:released, true)
    when /[^\s]+\+u=.+&k=.+/ 
      # personal email-to-group, eg. enspiral+u=99&k=adsfghjl@mail.loomio.com
      DiscussionService.create(
        discussion: Discussion.new(discussion_params(email)),
        actor: actor_from_email(email)
      )

      email.update_attribute(:released, true)
    else
      if reserved_handle = ReservedHandle.find_by(handle: email.route_path)
        BaseMailer.contact_message(
          email.sender_name,
          email.sender_email,
          email.subject,
          email.body,
          {
            site: ENV['CANONICAL_HOST'],
            deliver_to: email.route_address
          }
        ).deliver_later
        email.update(released: true)
        return
      end

      if group = Group.find_by(handle: email.route_path)
        if !address_is_blocked(email, group)
          email.update(group_id: group.id)

          if actor = actor_from_email_and_group(email, group)
            discussion = DiscussionService.create(
              discussion: Discussion.new(discussion_params(email)),
              actor: actor)
            email.update(released: true)
          else
            Events::UnknownSender.publish!(email)
          end
        end
      end
    end
  end

  def self.extract_reply_body(text, author_name = nil)
    return "" if text.strip.blank?
    text.gsub!("\r\n", "\n")

    # some emails match multiple split points, we run this until there are none
    while regex = reply_split_points(author_name).find { |regex| regex.match? text } do
      text = text.split(regex).first.strip
    end
    
    text.strip
  end

  def self.delete_old_emails
    ReceivedEmail.where("created_at < ?", 14.days.ago).destroy_all
  end

  private

  def self.reply_split_points(author_name = nil)
    [
      /^[[:space:]]*[-]+[[:space:]]*Original Message[[:space:]]*[-]+[[:space:]]*$/i,
      /^[[:space:]]*--[[:space:]]*$/,
      /^[[:space:]]*__[[:space:]]*$/,
      /^[[:space:]]*\>?[[:space:]]*On.*\n?.*wrote:\n?$/,
      /^[[:space:]]*\>?[[:space:]]*On.*\n?.*said:\n?$/,
      /^On.*<\r?\n?.*>.*\r?\n?wrote:\r?\n?$/,
      /On.*wrote:/,
      (author_name ? /^[[:space:]]*#{author_name}[[:space:]]*$/ : nil), # signature that starts with author name
      /#{EventMailer::REPLY_DELIMITER}/,
      /\*?From:.*$/i,
      /^[[:space:]]*\d{4}[-\/]\d{1,2}[-\/]\d{1,2}[[:space:]].*[[:space:]]<.*>?$/i,
      /(_)*\n[[:space:]]*De :.*\n[[:space:]]*Envoyé :.*\n[[:space:]]*À :.*\n[[:space:]]*Objet :.*\n$/i, # French Outlook
      /^[[:space:]]*\>?[[:space:]]*Le.*<\n?.*>.*\n?a[[:space:]]?\n?écrit :$/, # French
      /^[[:space:]]*\>?[[:space:]]*El.*<\n?.*>.*\n?escribió:$/
    ].compact
  end

  def self.parse_route_params(route_path)
    params = {}.with_indifferent_access

    if route_path.include?('+')
      params['handle'] = route_path.split('+').first
    end

    route_path.split('+').last.split('&').each do |segment|
      key_and_value = segment.split('=')
      params[key_and_value[0]] = key_and_value[1]
    end

    params
  end

  def self.actor_from_email(email)
    params = parse_route_params(email.route_path)
    User.find_by!(id: params['u'], email_api_key: params['k'])
  end

  def self.address_is_blocked(email, group)
    MemberEmailAlias.blocked.find_by(email: email.sender_email, group_id: group.id)
  end

  def self.actor_from_email_and_group(email, group)
    if actor = (email.dkim_valid || email.spf_valid) && User.find_by(email: email.sender_email)
      return actor if group.members.exists?(actor.id)
    end

    if email_alias = MemberEmailAlias.allowed.find_by(email: email.sender_email, group_id: group.id)
      return nil if email_alias.require_dkim && !email.dkim_valid
      return nil if email_alias.require_spf && !email.spf_valid
      return email_alias.user if group.members.exists?(email_alias.user.id)
    end

    nil
  end

  def self.discussion_params(email)
    params = parse_route_params(email.route_path)
    {
      group_id: Group.find_by!(handle: (params['handle'] || email.route_path)).id,
      title: email.subject,
      body: email.body,
      body_format: 'md',
      files: email.attachments.map {|a| a.blob }
    }.compact
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
        's' => 'Stance',
        'o' => 'Outcome'
      }[params['pt']]
      parent_id = params['pi']
    end

    {
      discussion_id: params['d'].to_i,
      parent_id: parent_id,
      parent_type: parent_type,
      body: email.body,
      body_format: 'md',
      files: email.attachments.map {|a| a.blob }
    }.compact
  end
end
