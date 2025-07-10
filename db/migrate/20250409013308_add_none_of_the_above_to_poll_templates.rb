class AddNoneOfTheAboveToPollTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :poll_templates, :show_none_of_the_above, :boolean, default: false, null: false
  end
end
