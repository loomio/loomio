class EmailActionsController < AuthenticateByUnsubscribeTokenController
  layout "basic"

  def unsubscribe
    load_models_or_404
    @membership = Membership.find_by(group_id: @group.id, user_id: current_user.id) if @group
    @discussion_reader = DiscussionReader.for(discussion: @discussion, user: current_user) if @discussion
    @stance = Stance.latest.find_by(poll_id: @poll.id, participant_id: current_user.id) if @poll
  end

  def set_group_volume
    load_models_or_404
    membership = Membership.find_by!(user_id: current_user.id, group_id: @group.id)
    MembershipService.set_volume(membership: membership, actor: current_user, params: {volume: params[:value]})
    redirect_to_unsubscribe
  end

  def set_discussion_volume
    load_models_or_404
    discussion_reader = DiscussionReader.find_by!(discussion_id: @discussion.id, user_id: current_user.id)
    discussion_reader.set_volume!(params[:value])
    redirect_to_unsubscribe
  end

  def set_poll_volume
    load_models_or_404
    stance = Stance.latest.find_by!(poll_id: @poll.id, participant_id: current_user.id)
    stance.set_volume!(params[:value])
    redirect_to_unsubscribe
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

  def redirect_to_unsubscribe
    args = params.permit!.slice(:discussion_id, :outcome_id, :poll_id, :group_id).compact.merge(unsubscribe_token: params[:unsubscribe_token])
    redirect_to email_actions_unsubscribe_path(args), notice: t(:'change_volume_form.saved')
  end

  def load_models_or_404
    @discussion = if (@comment = load_and_authorize(:comment, :show, optional: true))
                    @comment.discussion
                  else
                    load_and_authorize(:discussion, :show, optional: true)
                  end

    @poll = if (@outcome = load_and_authorize(:outcome, :show, optional: true))
              @outcome.poll
            elsif (@stance = load_and_authorize(:stance, :show, optional: true))
              @stance.poll
            else
              load_and_authorize(:poll, :show, optional: true)
            end

    @group = load_and_authorize(:group, :show, optional: true)
    @group = @poll.group if !@group && @poll
    @group = @discussion.group if !@group && @discussion
    raise ActiveRecord::RecordNotFound unless @group || @discussion || @poll
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
