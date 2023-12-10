class API::V1::ReceivedEmailsController < API::V1::RestfulController
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
    ReceivedEmailService.route_all
    success_response
  end

  def allow
    @received_email = ReceivedEmail.unreleased.where(group_id: current_user.adminable_group_ids).find(params[:id])
    if @received_email.group.is_trial_or_demo?
      respond_with_error(403, "trial groups cannot add aliases")
    else
      user = @received_email.group.members.find(params[:user_id])
      MemberEmailAlias.create!(
        email: @received_email.sender_email,
        user: user,
        group_id: @received_email.group_id,
        require_dkim: @received_email.dkim_valid,
        require_spf: @received_email.spf_valid,
        author_id: current_user.id
      )
      ReceivedEmailService.route(@received_email)
      respond_with_resource
    end
  end

  def block
    @received_email = ReceivedEmail.unreleased.where(group_id: current_user.adminable_group_ids).find(params[:id])
    MemberEmailAlias.create!(
      email: @received_email.sender_email,
      user_id: nil,
      group_id: @received_email.group_id,
      author_id: current_user.id
    )
    @received_email.update(group_id: nil)
    respond_with_resource
  end

  private

  def accessible_records
    ReceivedEmail.where(group_id: params[:group_id], released: false)
  end
end
