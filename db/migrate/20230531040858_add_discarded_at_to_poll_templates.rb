class AddDiscardedAtToPollTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :poll_templates, :discarded_at, :datetime
    add_index :poll_templates, :discarded_at
  end
end
