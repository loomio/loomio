class Api::Server0::MembershipsController < Api::Server0::BaseController
  def index
    memberships = group.memberships.includes(:user).order(:id)
    render json: {
      memberships: page_collection_bounded(memberships).map { |membership| membership_json(membership) },
      meta: { total: memberships.count }
    }
  end

  def create
    # Rails removes null entries from parameter arrays. Preserve the JSON email
    # list so [null] cannot become [] and accidentally clear a group during sync.
    input = request.content_mime_type == Mime[:json] ? JSON.parse(request.raw_post) : params
    raise ServerMembershipService::InvalidParameters, 'Expected an object' unless input.is_a?(Hash) || input.is_a?(ActionController::Parameters)

    result = ServerMembershipService.sync(
      group: group,
      emails: input['emails'],
      remove_absent: input.fetch('remove_absent', false)
    )
    render json: result
  end

  def update
    membership = Membership.active.find(params[:id])
    attributes = params.require(:membership).permit(:admin, :delegate).to_h.symbolize_keys
    ServerMembershipService.update(membership: membership, params: attributes)
    render json: { membership: membership_json(membership) }
  end

  def destroy
    ServerMembershipService.revoke(membership: Membership.find(params[:id]))
    render json: { success: true }
  end

  private

  def group
    @group ||= Group.kept.find(params[:group_id])
  end

  # Deliberately enumerate server-visible fields: invitation/login tokens,
  # account credentials, notification preferences and votes are never exposed.
  def membership_json(membership)
    {
      id: membership.id,
      group_id: membership.group_id,
      user_id: membership.user_id,
      user_email: membership.user.email,
      user_name: membership.user.name,
      admin: membership.admin,
      delegate: membership.delegate,
      accepted_at: membership.accepted_at,
      pending: membership.accepted_at.nil?
    }
  end
end
