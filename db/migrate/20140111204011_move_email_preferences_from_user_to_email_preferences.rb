class MoveEmailPreferencesFromUserToEmailPreferences < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end
  class EmailPreferences < ActiveRecord::Base
  end

  def up
    User.all.each do |user|
      EmailPreferences.create!(user_id: user.id, 
                              subscribed_to_mention_notifications: user.subscribed_to_mention_notifications,
                              subscribed_to_proposal_closure_notifications: user.subscribed_to_proposal_closure_notifications
                              )
    end
    remove_column :users, :subscribed_to_mention_notifications
    remove_column :users, :subscribed_to_proposal_closure_notifications
  end

  def down
    add_column :users, :subscribed_to_mention_notifications, :boolean, default: true, null: false
    add_column :users, :subscribed_to_proposal_closure_notifications, :boolean, default: true, null: false
    User.reset_column_information
    EmailPreferences.all.each do |email_preferences|
      user = User.find(email_preferences.user_id)
      user.subscribed_to_mention_notifications = email_preferences.subscribed_to_mention_notifications
      user.subscribed_to_proposal_closure_notifications = email_preferences.subscribed_to_proposal_closure_notifications
      user.save!
      email_preferences.destroy
    end
  end
end
