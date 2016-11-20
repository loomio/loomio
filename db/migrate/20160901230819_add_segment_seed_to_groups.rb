class AddSegmentSeedToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :segment_seed, :integer, default: '0', null: false
    ActiveRecord::Base.connection.execute "UPDATE groups SET segment_seed = (random() * 1000) WHERE segment_seed = 0"
  end
end
