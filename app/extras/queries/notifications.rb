class Queries::Notifications < Delegator

  def initialize(user:, limit: 30)
    @user, @limit = user, limit
    @relation = @user.notifications.includes(event: [:eventable, :user]).order(created_at: :desc)
  end

  def unread
    @relation = @relation.where(view: false)
    self
  end

  def recent
    @relation = @relation.limit(@limit)
    self
  end

  def __getobj__
    @relation
  end

end
