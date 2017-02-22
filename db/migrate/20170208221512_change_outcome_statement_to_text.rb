class ChangeOutcomeStatementToText < ActiveRecord::Migration
  def change
    change_column :outcomes, :statement, :text
  end
end
