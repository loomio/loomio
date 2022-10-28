class API::B1::MembershipsController < API::B1::BaseController
  def create
    raise CanCan::AccessDenied unless current_webhook.permissions.include?('manage_memberships')

    current_emails = User.active.where(id: current_webhook.group.memberships.pluck(:user_id)).pluck(:email)

    params_emails = params.fetch(:emails, [])
    add_emails = params_emails - current_emails
    remove_emails = current_emails - params_emails

    self.collection = GroupService.invite(
      group: current_webhook.group,
      actor: current_webhook.actor,
      params: {recipient_emails: add_emails}
    )

    removed_user_ids = []
    if params[:remove_absent]
      Membership.where(
        group_id: current_webhook.group_id,
        user_id: User.where(email: remove_emails).pluck(:id)
      ).each do |membership|
        removed_user_ids << membership.user_id
        MembershipService.destroy(
          membership: membership,
          actor: current_webhook.actor
        )
      end
    end

    render json: {
      added_emails: User.where(id: collection.pluck(:user_id)).pluck(:email),
      removed_emails: User.where(id: removed_user_ids).pluck(:email)
    }
  end

  def index
    raise CanCan::AccessDenied unless current_webhook.permissions.include?('read_memberships')
    instantiate_collection
    respond_with_collection
  end

  def accessible_records
    Membership.where(group_id: current_webhook.group_id)
  end

  def default_scope
    super.merge(include_email: true)
  end
end
