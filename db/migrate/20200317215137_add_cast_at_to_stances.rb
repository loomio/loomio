class AddCastAtToStances < ActiveRecord::Migration[5.2]
  def change
    add_column :stances, :cast_at, :datetime
    Stance.update_all('cast_at = created_at')
  end
end
