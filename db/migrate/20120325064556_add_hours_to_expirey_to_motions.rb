class AddHoursToExpireyToMotions < ActiveRecord::Migration
  def up
    add_column :motions, :hours_to_expirey, :integer
  end
  def down
    remove_column :motions, :hours_to_expirey
  end
end
