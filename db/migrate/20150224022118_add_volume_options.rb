class AddVolumeOptions < ActiveRecord::Migration
  def change
    add_column :memberships, :volume, :integer, default: 1
    add_column :discussion_readers, :volume, :integer
    add_column :motion_readers, :volume, :integer

    Membership.where(following_by_default: true).update_all(volume: :email)
    Membership.where(following_by_default: false).update_all(volume: :normal)
    DiscussionReader.where(following: true).update_all(volume: :email)
    DiscussionReader.where(following: false).update_all(volume: :normal)
    MotionReader.where(following: true).update_all(volume: :email)
    MotionReader.where(following: false).update_all(volume: :normal)

    remove_column :memberships, :following_by_default, :boolean
    remove_column :discussion_readers, :following, :boolean
    remove_column :motion_readers, :following, :boolean
  end
end
