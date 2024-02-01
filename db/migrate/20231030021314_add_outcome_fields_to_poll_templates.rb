class AddOutcomeFieldsToPollTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :poll_templates, :outcome_statement, :string
    add_column :poll_templates, :outcome_statement_format, :string, default: 'html', null: false
    add_column :poll_templates, :outcome_review_due_in_days, :integer, default: nil
    add_column :poll_templates, :public, :boolean, default: false, null: false
  end
end
