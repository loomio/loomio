class MoveEmailPreferencesFromUserToEmailPreferences < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end
  class EmailPreferences < ActiveRecord::Base
  end

  require 'ruby-progressbar'

  def up
    progress_bar = ProgressBar.create( format: "(%c/%C) |%B| %a", total: User.count )

    User.find_each do |user|
      progress_bar.increment

      EmailPreferences.create!(user_id: user.id,
                              subscribed_to_daily_activity_email: user.subscribed_to_daily_activity_email,
                              subscribed_to_mention_notifications: user.subscribed_to_mention_notifications,
                              subscribed_to_proposal_closure_notifications: user.subscribed_to_proposal_closure_notifications
                              )
    end
    remove_column :users, :subscribed_to_daily_activity_email
    remove_column :users, :subscribed_to_mention_notifications
    remove_column :users, :subscribed_to_proposal_closure_notifications
  end

  def down
    progress_bar = ProgressBar.create( format: "(%c/%C) |%B| %a", total: EmailPreferences.count )

    add_column :users, :subscribed_to_daily_activity_email, :boolean, default: false, null: false
    add_column :users, :subscribed_to_mention_notifications, :boolean, default: true, null: false
    add_column :users, :subscribed_to_proposal_closure_notifications, :boolean, default: true, null: false
    User.reset_column_information
    EmailPreferences.find_each do |email_preferences|
      progress_bar.increment

      user = User.find(email_preferences.user_id)
      user.subscribed_to_daily_activity_email = email_preferences.subscribed_to_daily_activity_email
      user.subscribed_to_mention_notifications = email_preferences.subscribed_to_mention_notifications
      user.subscribed_to_proposal_closure_notifications = email_preferences.subscribed_to_proposal_closure_notifications
      user.save!
      email_preferences.destroy
    end
  end
end
