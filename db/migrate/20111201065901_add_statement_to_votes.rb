class AddStatementToVotes < ActiveRecord::Migration
  def change
    add_column :votes, :statement, :string
  end
end
