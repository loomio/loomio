class AddQuorumPct < ActiveRecord::Migration[7.0]
  def change
    add_column :polls, :quorum_pct, :integer
    add_column :poll_templates, :quorum_pct, :integer
  end
end
