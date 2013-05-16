class AddNameAndManagerEmailToCampaigns < ActiveRecord::Migration
  class Campaign < ActiveRecord::Base
  end

  def up
    add_column :campaigns, :name, :string
    add_column :campaigns, :manager_email, :string

    Campaign.reset_column_information
    Campaign.update_all(name: "woc", manager_email: "contact@loomio.org")

    change_column :campaigns, :name, :string, null: false
    change_column :campaigns, :manager_email, :string, null: false
  end

  def down
    remove_column :campaigns, :name
    remove_column :campaigns, :manager_email
  end
end
