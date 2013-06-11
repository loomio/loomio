
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
    self.group_email_preferences = attributes.delete('group_email_preferences')
    @user.update_attributes(attributes)
  end

  def all_memberships
    memberships.includes(:group).order("groups.name").sort{|a,b| a.group_full_name <=> b.group_full_name }
  end

  def self.model_name
    ActiveModel::Name.new(self)
  end

  def group_email_preferences
    memberships.
      where(:subscribed_to_notification_emails => true).
      map(&:id)
  end

  def group_email_preferences=(membership_id_strings)
    if membership_id_strings
      self.subscribed_membership_ids = membership_id_strings.reject(&:blank?).map(&:to_i)
    end
  end

  private

    def subscribed_membership_ids=(membership_ids)
      update_subscriptions memberships, false
      update_subscriptions memberships.where(id: membership_ids), true
    end

    def update_subscriptions(scope, value)
      scope.update_all(subscribed_to_notification_emails: value)
    end

    def memberships
      @user.memberships
    end
end
