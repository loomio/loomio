class SplitVolumeByDeliveryChannel < ActiveRecord::Migration[8.1]
  def up
    rename_column :memberships, :volume, :volume_email
    rename_column :topic_readers, :volume, :volume_email
    rename_column :users, :default_membership_volume, :volume_email_default

    # Quiet now represents a channel that is off. Collapse the legacy mute value
    # into quiet before enforcing the shared three-level scale.
    execute "UPDATE memberships SET volume_email = 1 WHERE volume_email = 0"
    execute "UPDATE topic_readers SET volume_email = 1 WHERE volume_email = 0"
    execute "UPDATE users SET volume_email_default = 1 WHERE volume_email_default = 0"
    execute <<~SQL
      UPDATE memberships
      SET volume_email = coalesce(
        (SELECT users.volume_email_default FROM users WHERE users.id = memberships.user_id),
        2
      )
      WHERE volume_email IS NULL
    SQL
    change_column_default :memberships, :volume_email, from: nil, to: 2
    change_column_null :memberships, :volume_email, false

    # Push delivery still requires an active browser subscription. Normal allows
    # directed notifications once a person explicitly enables a browser.
    add_column :memberships, :volume_push, :integer, default: 2, null: false
    add_column :topic_readers, :volume_push, :integer, default: 2, null: false
    add_column :users, :volume_push_default, :integer, default: 2, null: false

    add_index :memberships, :volume_push
    add_index :memberships, [ :user_id, :volume_push ]

    add_check_constraint :memberships, "volume_email IN (1, 2, 3)", name: "memberships_volume_email"
    add_check_constraint :memberships, "volume_push IN (1, 2, 3)", name: "memberships_volume_push"
    add_check_constraint :topic_readers, "volume_email IN (1, 2, 3)", name: "topic_readers_volume_email"
    add_check_constraint :topic_readers, "volume_push IN (1, 2, 3)", name: "topic_readers_volume_push"
    add_check_constraint :users, "volume_email_default IN (1, 2, 3)", name: "users_volume_email_default"
    add_check_constraint :users, "volume_push_default IN (1, 2, 3)", name: "users_volume_push_default"
  end

  def down
    remove_check_constraint :users, name: "users_volume_push_default"
    remove_check_constraint :users, name: "users_volume_email_default"
    remove_check_constraint :topic_readers, name: "topic_readers_volume_push"
    remove_check_constraint :topic_readers, name: "topic_readers_volume_email"
    remove_check_constraint :memberships, name: "memberships_volume_push"
    remove_check_constraint :memberships, name: "memberships_volume_email"

    remove_index :memberships, [ :user_id, :volume_push ]
    remove_index :memberships, :volume_push

    remove_column :users, :volume_push_default
    remove_column :topic_readers, :volume_push
    remove_column :memberships, :volume_push

    change_column_null :memberships, :volume_email, true
    change_column_default :memberships, :volume_email, from: 2, to: nil

    rename_column :users, :volume_email_default, :default_membership_volume
    rename_column :topic_readers, :volume_email, :volume
    rename_column :memberships, :volume_email, :volume
  end
end
