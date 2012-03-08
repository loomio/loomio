class AddCloseDaterToMotions < ActiveRecord::Migration
  def change
    add_column :motions, :close_date, :date
  end
end
