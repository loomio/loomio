class Api::V1::PendingEmailsController < Api::V1::RestfulController
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
    @pending_email = PendingEmail.pending.where(group_id: current_user.adminable_group_ids).find(params[:id])
    if @pending_email.group.is_trial_or_demo?
      respond_with_error(403, "trial groups cannot add aliases")
    else
      user = @pending_email.group.members.active.find(params[:user_id])
      PendingEmail.transaction do
        MemberEmailAlias.find_or_initialize_by(
          email: @pending_email.sender_email,
          group_id: @pending_email.group_id
        ).update!(user: user, author_id: current_user.id)
        InboundEmailService.approve(@pending_email)
      end
      respond_with_resource
    end
  end

  def block
    @pending_email = PendingEmail.pending.where(group_id: current_user.adminable_group_ids).find(params[:id])
    PendingEmail.transaction do
      MemberEmailAlias.find_or_initialize_by(
        email: @pending_email.sender_email,
        group_id: @pending_email.group_id
      ).update!(user_id: nil, author_id: current_user.id)
      @pending_email.notifications.destroy_all
      @pending_email.blocked!
    end
    respond_with_resource
  end

  private

  def accessible_records
    PendingEmail.pending.where(group_id: params[:group_id])
  end
end
