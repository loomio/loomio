class AddActivityToMotions < ActiveRecord::Migration
  def change
    add_column :motions, :activity, :integer, default: 0
  end
end
