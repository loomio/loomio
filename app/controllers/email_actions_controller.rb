class EmailActionsController < AuthenticateByUnsubscribeTokenController
  layout "basic"

  def unsubscribe
    @model = load_model
    @membership = Membership.find_by(group_id: @model.group_id, user_id: current_user.id)
    @discussion_reader = DiscussionReader.for(discussion: @model.discussion, user: current_user)
    @stance = Stance.latest.find_by(poll_id: @model.poll_id, participant_id: current_user.id)
  end

  def set_group_volume
    @model = load_model
    membership = Membership.find_by!(user_id: current_user.id, group_id: @model.group_id)
    MembershipService.set_volume(membership: membership, actor: current_user, params: {volume: params[:value]})

    redirect_to email_actions_unsubscribe_path(@model.named_id.merge(unsubscribe_token: params[:unsubscribe_token])),
                notice: t(:'change_volume_form.saved')
  end

  def set_discussion_volume
    @model = load_model
    discussion_reader = DiscussionReader.find_by!(discussion_id: @model.discussion_id, user_id: current_user.id)
    discussion_reader.set_volume!(params[:value])

    redirect_to email_actions_unsubscribe_path(@model.named_id.merge(unsubscribe_token: params[:unsubscribe_token])),
                notice: t(:'change_volume_form.saved')
  end

  def unfollow_discussion
    discussion_reader = DiscussionReader.for(discussion: discussion, user: current_user)

    if %w[normal quiet].include?(params[:new_volume])
      discussion_reader.set_volume!(params[:new_volume].to_sym)
    elsif discussion_reader.volume_is_loud?
      discussion_reader.set_volume! :normal
    else
      discussion_reader.set_volume! :quiet
    end

    redirect_to root_path, notice: t(:"email_actions.unfollowed_discussion", thread_title: discussion.title)
  end

  def mark_discussion_as_read
    GenericWorker.perform_async(
      'DiscussionService',
      'mark_as_read_simple_params',
      discussion.id,
      event.sequence_id || [],
      current_user.id
    )
    event.notifications.where(user: current_user).update_all(viewed: true)
    respond_with_pixel
  rescue ActiveRecord::RecordNotFound
    respond_with_pixel
  end

  def mark_notification_as_read
    Notification.find_by!(id: params[:id], user_id: current_user.id).update(viewed: true)
    respond_with_pixel
  rescue ActiveRecord::RecordNotFound
    respond_with_pixel
  end

  def mark_summary_email_as_read
    GenericWorker.perform_async('DiscussionService', 'mark_summary_email_as_read', current_user.id, params[:time_start].to_i,
                                params[:time_finish].to_i)

    respond_to do |format|
      format.html do
        flash[:notice] = I18n.t 'email.catch_up.marked_as_read_success'
        redirect_to root_path
      end
      format.gif { respond_with_pixel }
    end
  end

  private

  def load_model
    load_and_authorize(:discussion, :show, optional: true) ||
    load_and_authorize(:group, :show, optional: true) ||
    load_and_authorize(:comment, :show, optional: true) ||
    load_and_authorize(:poll, :show, optional: true) ||
    load_and_authorize(:outcome, :show, optional: true)
  end

  def respond_with_pixel
    send_file Rails.root.join('app', 'assets', 'images', 'empty.gif'), type: 'image/gif', disposition: 'inline'
  end

  def discussion
    @discussion ||= current_user.discussions.find(params[:discussion_id])
  end

  def event
    @event ||= Event.find params[:event_id]
  end
end
