class Api::B2::MembershipsController < Api::B2::BaseController
  def create
    authorize_manage_group!
    current_emails = User.active.where(id: group.memberships.pluck(:user_id)).pluck(:email)

    params_emails = params.fetch(:emails, [])
    add_emails = params_emails - current_emails
    remove_emails = current_emails - params_emails

    self.collection = GroupService.invite(
      group: group,
      actor: current_user,
      params: { recipient_emails: add_emails }
    )
    PollService.group_members_added(group.id)

    removed_user_ids = []
    if params[:remove_absent].to_i == 1
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
    MembershipQuery.visible_to(user: current_user).where(group_id: group.id)
  end

  def group
    @group ||= Group.find(params[:group_id])
  end

  def default_scope(records = records_to_serialize)
    super(records).merge(
      include_inviter: true,
      membership_email_group_ids: current_user.adminable_group_ids
    )
  end

  private

  def authorize_manage_group!
    return if current_user.adminable_group_ids.include?(group.id)

    raise CanCan::AccessDenied, "User is not an admin"
  end
end
