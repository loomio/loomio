class AddRenderSettingsToDiscussion < ActiveRecord::Migration[5.2]
  def change
    add_column :discussions, :max_depth, :integer, default: 2, null: false
    add_column :discussions, :reverse_order, :boolean, default: false, null: false
  end
end
