class RemoveAnyoneCanParticipateBoolean < ActiveRecord::Migration
  def change
    remove_column :polls, :anyone_can_participate
  end
end
