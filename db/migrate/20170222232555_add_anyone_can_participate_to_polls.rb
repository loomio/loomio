class AddAnyoneCanParticipateToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :anyone_can_participate, :boolean, default: false, null: false
  end
end
