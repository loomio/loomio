
class EmailPreferences
  attr_reader :user

  delegate :to_key,
           :to_param,
           :subscribed_to_daily_activity_email,
           :subscribed_to_proposal_closure_notifications,
           :subscribed_to_mention_notifications, :to => :user

  def initialize(user)
    @user = user
  end

  def update_attributes(attributes)
    @user.update_attributes(attributes)
  end

  def all_memberships
    @user.memberships.includes(:group).order("groups.name")
  end

  def self.model_name
    ActiveModel::Name.new(self)
  end

  def group_email_preferences
    Membership.
      where(:user_id => @user.id, :subscribed_to_notification_emails => true).
      map(&:id)
  end
end