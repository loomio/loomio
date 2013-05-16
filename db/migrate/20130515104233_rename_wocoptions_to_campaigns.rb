class RenameWocoptionsToCampaigns < ActiveRecord::Migration
  def change
    rename_table :woc_options, :campaigns
  end
end
