class SetGroupEmailsOnByDefault < ActiveRecord::Migration
  class Membership < ActiveRecord::Base
  end

  def up
    Membership.update_all :subscribed_to_notification_emails => true
    change_column_default :memberships, :subscribed_to_notification_emails, true
  end

  def down
  end
end
