class API::V1::ReceivedEmailsController < API::V1::RestfulController
  def index
    raise CanCan::AccessDenied unless current_user.adminable_group_ids.include?(params[:group_id].to_i)
    instantiate_collection
    respond_with_collection
  end

  def allow
    @received_email = ReceivedEmail.unreleased.where(group_id: current_user.adminable_group_ids).find(params[:id])
    user = @received_email.group.members.find(params[:user_id])
    MemberEmailAlias.create!(
      email: @received_email.sender_email,
      user: user,
      group_id: @received_email.group_id,
      must_validate: @received_email.is_validated?,
      author_id: current_user.id
    )
    ReceivedEmailService.route(@received_email)
    respond_with_resource
  end

  def destroy
    raise "not ready"
  end

  private

  def accessible_records
    ReceivedEmail.where(group_id: params[:group_id], released: false)
  end
end
