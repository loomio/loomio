class ChangeStatementToReason < ActiveRecord::Migration
  def change
    rename_column :stances, :statement, :reason
  end
end
