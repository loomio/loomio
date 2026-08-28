class AddSessionToPushSubscriptions < ActiveRecord::Migration[8.1]
  def up
    add_reference :push_subscriptions,
                  :session,
                  foreign_key: { on_delete: :cascade }

    # Existing subscriptions cannot be safely attributed to a browser session.
    execute "DELETE FROM push_subscriptions"
    change_column_null :push_subscriptions, :session_id, false
  end

  def down
    remove_reference :push_subscriptions, :session, foreign_key: true
  end
end
