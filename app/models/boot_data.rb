BootData = Struct.new(:user) do

  def data
    @data ||= ActiveModel::ArraySerializer.new(Array(user),
      scope: serializer_scope,
      each_serializer: serializer,
      root: :current_users
    ).as_json.tap { |json| add_current_user_to(json) }
  end

  private

  def add_current_user_to(json)
    return unless user.is_logged_in?
    json[:current_user_id] = user.id
    json[:users] = Array(json[:users]).reject { |u| u[:id] == user.id } + json.delete(:current_users)
  end

  def serializer
    if user.restricted
      Restricted::UserSerializer
    else
      Full::UserSerializer
    end
  end

  def serializer_scope
    {
      formal_memberships: formal_memberships,
      guest_memberships:  guest_memberships
    }.merge(authed_serializer_scope)
  end

  def authed_serializer_scope
    return {} unless user.is_logged_in? && !user.restricted
    {
      notifications:      notifications,
      unread:             unread,
      reader_cache:       readers,
      poll_cache:         active_polls,
      identities:         identities
    }
  end

  def guest_memberships
    @guest_memberships ||= user.memberships.guest.includes(:user, :inviter, {group: :parent})
  end

  def formal_memberships
    @formal_memberships ||= user.memberships.formal.includes(:user, :group)
  end

  def notifications
    @notifications ||= NotificationCollection.new(user).notifications
  end

  def unread
    @unread ||= Queries::VisibleDiscussions.new(user: user)
                                           .recent
                                           .unread
                                           .not_muted
                                           .sorted_by_latest_activity
                                           .includes(:group, :author)
  end

  def readers
    @readers ||= Caches::DiscussionReader.new(user: user, parents: unread)
  end

  def active_polls
    @active_polls ||= Caches::Poll.new(parents: unread)
  end

  def identities
    @identities ||= user.identities.order(created_at: :desc)
  end
end
