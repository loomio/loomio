class EmailActionsController < AuthenticateByUnsubscribeTokenController
  def unsubscribe
    load_models_or_404
    topic_reader = TopicReader.for(user: current_user, topic: @topic) if @topic
    membership = Membership.find_by(group_id: @group.id, user_id: current_user.id) if @group
    render Views::EmailActions::Unsubscribe.new(
      topic_reader: topic_reader,
      membership: membership,
      unsubscribe_token: params[:unsubscribe_token]
    )
  end

  def set_group_volume
    load_models_or_404
    membership = Membership.find_by!(user_id: current_user.id, group_id: @group.id)
    MembershipService.set_volume(
      membership: membership,
      actor: current_user,
      params: volume_attributes(membership)
    )
    redirect_to_unsubscribe
  end

  def set_discussion_volume
    load_models_or_404
    topic_reader = TopicReader.find_by!(topic_id: @topic.id, user_id: current_user.id)
    attributes = volume_attributes(topic_reader)
    topic_reader.set_volume!(email: attributes[:volume_email], push: attributes[:volume_push])
    redirect_to_unsubscribe
  end

  def mark_discussion_as_read
    MarkDiscussionAsReadWorker.perform_later(discussion.id, topic_item.sequence_id || [], current_user.id)
    NotificationService.mark_as_read(topic_item.itemable_type, topic_item.itemable_id, current_user.id)
    respond_with_pixel
  rescue ActiveRecord::RecordNotFound
    respond_with_pixel
  end

  def mark_notification_as_read
    notification = Notification.find(params[:id])
    NotificationDelivery.find_by!(
      notification: notification,
      recipient: current_user,
      channel: "in_app"
    ).update!(viewed_at: Time.current)
    respond_with_pixel
  rescue ActiveRecord::RecordNotFound
    respond_with_pixel
  end

  def mark_digest_as_read
    MarkDigestAsReadWorker.perform_later(current_user.id, params[:time_start].to_i, params[:time_finish].to_i)

    respond_to do |format|
      format.html do
        flash[:notice] = I18n.t 'email.catch_up.marked_as_read_success'
        redirect_to root_path
      end
      format.gif { respond_with_pixel }
    end
  end

  private

  def volume_attributes(record)
    email = params[:volume_email] || params[:value] || record.volume_email
    push = params[:volume_push] || record.volume_push
    case params[:delivery_channel]
    when "email" then push = "quiet"
    when "push" then email = "quiet"
    end
    { volume_email: email, volume_push: push }
  end

  def redirect_to_unsubscribe
    args = params.permit!.slice(:topic_id, :group_id).compact.merge(unsubscribe_token: params[:unsubscribe_token])
    redirect_to email_actions_unsubscribe_path(args), notice: t(:'change_volume_form.saved')
  end

  def load_models_or_404
    if @topic = load_and_authorize(:topic, :show, optional: true)
      @group = @topic.group
    else
      @group = load_and_authorize(:group, :show, optional: true)
    end

    raise ActiveRecord::RecordNotFound unless @group || @topic
  end

  def respond_with_pixel
    send_file Rails.root.join('app', 'assets', 'images', 'empty.gif'), type: 'image/gif', disposition: 'inline'
  end

  def discussion
    @discussion ||= current_user.discussions.find(params[:discussion_id])
  end

  def topic_item
    @topic_item ||= TopicItem.find params[:topic_item_id]
  end
end
