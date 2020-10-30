class DiscussionReadersVolumeNotNull < ActiveRecord::Migration[5.2]
  def change
    max = DiscussionReader.order('id desc').limit(1).pluck(:id).first
    i = 0
    step = 10000
    while i < max do
      execute("update discussion_readers set volume = 2 where volume is null and id > #{i} and id <= #{i+step}")
      i = i + step
    end
    change_column :discussion_readers, :volume, :integer, null: false, default: 2
  end
end
