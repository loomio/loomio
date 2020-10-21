class API::DiscussionReadersController < API::RestfulController
  def index
    @discussion = load_and_authorize(:discussion)
    instantiate_collection do |collection|
      collection.where(discussion_id: @discussion.id)
    end
    respond_with_collection
  end


  private
  def default_scope
    super.merge({include_email: @discussion.admins.exists?(current_user.id)})
  end

  def accessible_records
    @accessible_records ||= DiscussionReader.includes(:user)
      .joins("LEFT OUTER JOIN memberships m ON m.user_id = discussion_readers.user_id")
      .where("(m.group_id = :group_id AND m.accepted_at IS NOT NULL AND archived_at IS NULL)
              OR (discussion_readers.inviter_id IS NOT NULL AND discussion_readers.revoked_at IS NULL)", group_id: @discussion.group_id)
  end
end
