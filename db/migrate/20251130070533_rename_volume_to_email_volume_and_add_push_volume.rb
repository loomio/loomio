class RenameVolumeToEmailVolumeAndAddPushVolume < ActiveRecord::Migration[7.2]
  def change
    # Rename volume to email_volume in memberships
    rename_column :memberships, :volume, :email_volume
    
    # Rename volume to email_volume in discussion_readers
    rename_column :discussion_readers, :volume, :email_volume
    
    # Rename volume to email_volume in stances
    rename_column :stances, :volume, :email_volume
    
    # Rename default_membership_volume to default_membership_email_volume in users
    rename_column :users, :default_membership_volume, :default_membership_email_volume
    
    # Add push_volume to memberships (default to normal, like email)
    add_column :memberships, :push_volume, :integer, default: 2, null: false
    
    # Add push_volume to discussion_readers (default to normal, like email)
    add_column :discussion_readers, :push_volume, :integer, default: 2, null: false
    
    # Add push_volume to stances (default to normal, like email)
    add_column :stances, :push_volume, :integer, default: 2, null: false
    
    # Add default_membership_push_volume to users (default to normal)
    add_column :users, :default_membership_push_volume, :integer, default: 2, null: false
    
    # Add indexes for push_volume (similar to existing volume indexes)
    add_index :memberships, :push_volume
    add_index :memberships, [:user_id, :push_volume]
  end
end
