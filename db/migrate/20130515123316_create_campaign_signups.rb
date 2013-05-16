class CreateCampaignSignups < ActiveRecord::Migration
  def change
    create_table :campaign_signups do |t|
      t.references :campaign
      t.string :name
      t.string :email
      t.boolean :spam

      t.timestamps
    end
    add_index :campaign_signups, :campaign_id
  end
end
