class AddAgreeTargetToPolls < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :agree_target, :integer
  end
end
