class EmailActionsController < AuthenticateByUnsubscribeTokenController
  def unfollow_discussion
    discussion_reader = DiscussionReader.for(discussion: discussion, user: user)

    if ['normal', 'quiet'].include?(params[:new_volume])
      discussion_reader.set_volume!(params[:new_volume].to_sym)
    else
      if discussion_reader.volume_is_loud?
        discussion_reader.set_volume! :normal
      else
        discussion_reader.set_volume! :quiet
      end
    end

    redirect_to root_path, notice: t(:"email_actions.unfollowed_discussion", thread_title: discussion.title)
   end

  def mark_discussion_as_read
    DiscussionService.mark_as_read(discussion: discussion,
                                   params: {ranges: event.sequence_id},
                                   actor: user)
    event.notifications.where(user: user).update_all(viewed: true)
    respond_with_pixel
  rescue ActiveRecord::RecordNotFound
    respond_with_pixel
  end

  def mark_summary_email_as_read
    DiscussionService.delay.mark_summary_email_as_read(user.id, params)

    respond_to do |format|
      format.html {
        flash[:notice] = I18n.t "email.catch_up.marked_as_read_success"
        redirect_to root_path
      }
      format.gif { respond_with_pixel }
    end
  end

  private

  def respond_with_pixel
    send_file Rails.root.join('app','assets','images', 'empty.gif'), type: 'image/gif', disposition: 'inline'
  end

  def discussion
    @discussion ||= user.discussions.find(params[:discussion_id])
  end

  def event
    @event ||= Event.find params[:event_id]
  end
end
