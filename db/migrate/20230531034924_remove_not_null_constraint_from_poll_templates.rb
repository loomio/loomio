class RemoveNotNullConstraintFromPollTemplates < ActiveRecord::Migration[7.0]
  def change
    change_column :poll_templates, :title, :string, null: true, default: nil
  end
end
