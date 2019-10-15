class CreateCommunityApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :community_applications do |t|
      t.references :user
      t.references :group
      t.jsonb :info
      t.timestamps
    end
  end
end
