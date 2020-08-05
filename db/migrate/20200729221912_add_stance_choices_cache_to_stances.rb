class AddStanceChoicesCacheToStances < ActiveRecord::Migration[5.2]
  def change
    add_column :stances, :stance_choices_cache, :jsonb, default: []
  end
end
