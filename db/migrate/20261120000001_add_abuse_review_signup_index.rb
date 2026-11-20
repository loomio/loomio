class AddAbuseReviewSignupIndex < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :users, [:created_at, :id],
      name: :index_users_on_created_at_and_id_for_abuse_review,
      algorithm: :concurrently
  end
end
