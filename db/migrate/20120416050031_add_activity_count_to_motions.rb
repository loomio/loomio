class AddActivityCountToMotions < ActiveRecord::Migration
 def change
    add_column :motions, :activity_count, :integer, default: 0
  end
end
