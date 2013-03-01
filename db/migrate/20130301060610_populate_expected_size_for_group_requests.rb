class PopulateExpectedSizeForGroupRequests < ActiveRecord::Migration
  def up
    GroupRequest.where("expected_size = '' OR expected_size IS NULL").update_all(expected_size: "(Not specified)")
  end

  def down
  end
end
