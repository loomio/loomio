class SplitVolumeByDeliveryChannel < ActiveRecord::Migration[8.1]
  def up
    rename_column :memberships, :volume, :volume_email
    rename_column :topic_readers, :volume, :volume_email
    rename_column :users, :default_membership_volume, :default_membership_volume_email

    # Preserve existing email behaviour and leave push off until each person
    # explicitly enables it for a group or thread.
    add_column :memberships, :volume_push, :integer, default: 0, null: false
    add_column :topic_readers, :volume_push, :integer, default: 0, null: false
    add_column :users, :default_membership_volume_push, :integer, default: 0, null: false

    add_index :memberships, :volume_push
    add_index :memberships, [:user_id, :volume_push]

    add_check_constraint :memberships, "volume_email IN (0, 1, 2, 3)", name: "memberships_volume_email"
    add_check_constraint :memberships, "volume_push IN (0, 1, 2, 3)", name: "memberships_volume_push"
    add_check_constraint :topic_readers, "volume_email IN (0, 1, 2, 3)", name: "topic_readers_volume_email"
    add_check_constraint :topic_readers, "volume_push IN (0, 1, 2, 3)", name: "topic_readers_volume_push"
    add_check_constraint :users, "default_membership_volume_email IN (0, 1, 2, 3)", name: "users_default_membership_volume_email"
    add_check_constraint :users, "default_membership_volume_push IN (0, 1, 2, 3)", name: "users_default_membership_volume_push"
  end

  def down
    remove_check_constraint :users, name: "users_default_membership_volume_push"
    remove_check_constraint :users, name: "users_default_membership_volume_email"
    remove_check_constraint :topic_readers, name: "topic_readers_volume_push"
    remove_check_constraint :topic_readers, name: "topic_readers_volume_email"
    remove_check_constraint :memberships, name: "memberships_volume_push"
    remove_check_constraint :memberships, name: "memberships_volume_email"

    remove_index :memberships, [:user_id, :volume_push]
    remove_index :memberships, :volume_push

    remove_column :users, :default_membership_volume_push
    remove_column :topic_readers, :volume_push
    remove_column :memberships, :volume_push

    rename_column :users, :default_membership_volume_email, :default_membership_volume
    rename_column :topic_readers, :volume_email, :volume
    rename_column :memberships, :volume_email, :volume
  end
end
