class AddDefaultVolumeToStances < ActiveRecord::Migration[5.2]
  def change
    max = Stance.order('stances.id desc').limit(1).pluck(:id).first
    i = 0
    step = 10000
    while i < max do
      execute("update stances set volume = 2 where volume is null and id > #{i} and id <= #{i+step}")
      i = i + step
    end
    change_column :stances, :volume, :integer, default: 2, null: false
  end
end
