class AddBio < ActiveRecord::Migration
  def change
    add_column :users, :short_bio, :string, default: "", null: false
  end
end
