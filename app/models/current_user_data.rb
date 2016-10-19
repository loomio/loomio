CurrentUserData = Struct.new(:user, :restricted) do
  def data
    if restricted
      Restricted::UserSerializer.new(user).as_json
    else
      Full::UserSerializer.new(user, scope: serializer_scope, root: :current_user).as_json.tap do |json|
        json[:current_user].except!(:group_ids, :membership_ids)
      end
    end
  end

  private

  def serializer_scope
    return {} unless user.is_logged_in?
    {
      cache: {
        memberships:   memberships,
        notifications: notifications,
        unread:        unread
      },
      reader_cache: DiscussionReaderCache.new(user: user, discussions: unread)
    }
  end

  def memberships
    @memberships ||= user.memberships.includes(group: [:default_group_cover]).order(created_at: :desc)
  end

  def notifications
    @notifications ||= user.notifications.includes(event: [:eventable, :user]).order(created_at: :desc).limit(30)
  end

  def unread
    @unread ||= Queries::VisibleDiscussions.new(user: user).not_muted.unread.sorted_by_latest_activity
  end
end
