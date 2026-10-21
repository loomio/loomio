class Api::V1::ReceivedEmailsController < Api::V1::RestfulController
  def index
    raise CanCan::AccessDenied unless current_user.adminable_group_ids.include?(params[:group_id].to_i)
    instantiate_collection
    respond_with_collection
  end

  def aliases
    raise CanCan::AccessDenied unless current_user.adminable_group_ids.include?(params[:group_id].to_i)
    aliases = MemberEmailAlias.where(group_id: params[:group_id])
    render json: aliases, scope: default_scope, each_serializer: MemberEmailAliasSerializer, root: :aliases, meta: meta.merge({root: :aliases, total: collection_count})
  end

  def destroy_alias
    member_email_alias = MemberEmailAlias.where(group_id: current_user.adminable_group_ids).find(params[:id])
    member_email_alias.destroy
    InboundEmailService.retry_pending
    success_response
  end

  def allow
    @received_email = PendingEmail.pending.where(group_id: current_user.adminable_group_ids).find(params[:id])
    if @received_email.group.is_trial_or_demo?
      respond_with_error(403, "trial groups cannot add aliases")
    else
      user = @received_email.group.members.active.find(params[:user_id])
      PendingEmail.transaction do
        MemberEmailAlias.find_or_initialize_by(
          email: @received_email.sender_email,
          group_id: @received_email.group_id
        ).update!(user: user, author_id: current_user.id)
        InboundEmailService.approve(@received_email)
      end
      respond_with_resource
    end
  end

  def block
    @received_email = PendingEmail.pending.where(group_id: current_user.adminable_group_ids).find(params[:id])
    PendingEmail.transaction do
      MemberEmailAlias.find_or_initialize_by(
        email: @received_email.sender_email,
        group_id: @received_email.group_id
      ).update!(user_id: nil, author_id: current_user.id)
      @received_email.notifications.destroy_all
      @received_email.blocked!
    end
    respond_with_resource
  end

  private

  # Preserve the established approval API while its storage is now a queue.
  def resource_class
    PendingEmail
  end

  def serializer_class
    PendingEmailSerializer
  end

  def serializer_root
    :received_emails
  end

  def accessible_records
    PendingEmail.pending.where(group_id: params[:group_id])
  end
end
