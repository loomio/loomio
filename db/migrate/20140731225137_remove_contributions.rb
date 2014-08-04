class RemoveContributions < ActiveRecord::Migration
  def change
    drop_table :contributions
  end
end
