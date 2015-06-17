class EmailActionsController < AuthenticateByUnsubscribeTokenController
  skip_before_filter :boot_angular_ui
  def unfollow_discussion
    set_discussion_volume volume: :quiet, flash_notice: :"notifications.email_actions.not_following_thread"
   end

  def follow_discussion
    set_discussion_volume volume: :loud, flash_notice: :"notifications.email_actions.following_thread"
  end

  def mark_discussion_as_read
    @discussion = Discussion.find(params[:discussion_id])
    @event = Event.find(params[:event_id])
    DiscussionReader.for(discussion: @discussion, user: user).viewed!(@event.created_at)

    send_file Rails.root.join('app','assets','images', 'empty.gif'),
              type: 'image/gif',
              disposition: 'inline'
  end

  def mark_summary_email_as_read
    @inbox = Inbox.new(user)
    @inbox.load
    time_start = Time.at(params[:time_start].to_i).utc
    time_finish = Time.at(params[:time_finish].to_i).utc

    Queries::VisibleDiscussions.new(user: user,
                                    groups: user.inbox_groups).
                                    unread.
                                    last_activity_after(time_start).each do |discussion|
      DiscussionReader.for(user: user, discussion: discussion).viewed!(time_finish)
      if motion = discussion.motions.voting_or_closed_after(time_start).first
        MotionReader.for(user: user, motion: motion).viewed!(time_finish)
      end
    end

    respond_to do |format|
      format.html {
        flash[:notice] = I18n.t "email.missed_yesterday.marked_as_read_success"
        redirect_to dashboard_or_root_path
      }
      format.gif {
        send_file Rails.root.join('app','assets','images', 'empty.gif'),
                  type: 'image/gif', disposition: 'inline'
      }
    end
  end

  private

  def set_discussion_volume(volume:, flash_notice:)
    DiscussionReader.for(discussion: discussion, user: user).set_volume! volume
    redirect_to dashboard_or_root_path, notice: t(flash_notice, thread_title: discussion.title)
  end

  def discussion
    @discussion ||= Discussion.find params[:discussion_id]
  end
end
