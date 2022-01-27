class DropStanceChoicesCache < ActiveRecord::Migration[6.1]
  def change
    remove_column :stances, :stance_choices_cache
  end
end
