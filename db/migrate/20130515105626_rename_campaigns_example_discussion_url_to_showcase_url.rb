class RenameCampaignsExampleDiscussionUrlToShowcaseUrl < ActiveRecord::Migration
  def change
    rename_column :campaigns, :example_discussion_url, :showcase_url
  end
end
