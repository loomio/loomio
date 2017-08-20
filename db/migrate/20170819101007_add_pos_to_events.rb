class AddPosToEvents < ActiveRecord::Migration
  def change
    add_column :events, :pos, :integer
  end
end
