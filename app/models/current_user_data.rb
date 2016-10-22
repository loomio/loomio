CurrentUserData = Struct.new(:user, :restricted) do
  def data
    serializer.new(user, scope: serializer_scope, root: :current_user).as_json.tap do |json|
      json[:current_user].except!(:group_ids, :membership_ids)
    end
  end

  private

  def serializer
    if restricted
      Restricted::UserSerializer
    else
      Full::UserSerializer
    end
  end

  def serializer_scope
    { memberships: memberships }.tap do |hash|
      hash.merge!(
        notifications: notifications,
        unread:        unread,
        reader_cache:  readers
      ) unless restricted || !user.is_logged_in?
    end
  end

  def memberships
    @memberships ||= user.memberships.includes(group: [:default_group_cover]).order(created_at: :desc)
  end

  def notifications
    @notifications ||= user.notifications.includes(event: [:eventable, :user]).order(created_at: :desc).limit(30)
  end

  def unread
    @unread ||= Queries::VisibleDiscussions.new(user: user).recent.unread.not_muted.sorted_by_latest_activity
  end

  def readers
    @readers ||= DiscussionReaderCache.new(user: user, discussions: unread)
  end
end
