class DiscussionReadersVolumeNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column :discussion_readers, :volume, :integer, null: false
  end
end
