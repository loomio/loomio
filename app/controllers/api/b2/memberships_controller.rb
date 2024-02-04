class API::B2::MembershipsController < API::B2::BaseController
  def create
    current_emails = User.active.where(id: group.memberships.pluck(:user_id)).pluck(:email)

    params_emails = params.fetch(:emails, [])
    add_emails = params_emails - current_emails
    remove_emails = current_emails - params_emails

    self.collection = GroupService.invite(
      group: group,
      actor: current_user,
      params: {recipient_emails: add_emails}
    )
    PollService.group_members_added(group.id)

    removed_user_ids = []
    if params[:remove_absent]
      Membership.where(
        group_id: group.id,
        user_id: User.where(email: remove_emails).pluck(:id)
      ).each do |membership|
        removed_user_ids << membership.user_id
        MembershipService.revoke(
          membership: membership,
          actor: current_user
        )
      end
    end

    render json: {
      added_emails: User.where(id: collection.pluck(:user_id)).pluck(:email),
      removed_emails: User.where(id: removed_user_ids).pluck(:email)
    }
  end

  def index
    instantiate_collection
    respond_with_collection
  end

  def accessible_records
    Membership.where(group_id: group.id)
  end

  def group
    group = current_user.adminable_groups.find_by(id: params[:group_id])
    raise CanCan::AccessDenied unless group
    group
  end

  def default_scope
    super.merge(include_email: true)
  end
end
