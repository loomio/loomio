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
      memberships: memberships,
    }.merge(authed_serializer_scope)
  end

  def authed_serializer_scope
    return {} unless user.is_logged_in? && !user.restricted
    {
      notifications:      notifications,
      identities:         identities
    }
  end

  def memberships
    @memberships ||= user.memberships.includes(:user, :group)
  end

  def notifications
    @notifications ||= NotificationCollection.new(user).notifications
  end

  def identities
    @identities ||= user.identities.order(created_at: :desc)
  end
end
