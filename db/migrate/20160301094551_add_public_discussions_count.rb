class AddPublicDiscussionsCount < ActiveRecord::Migration
  def change
    add_column :groups, :public_discussions_count, :integer, null: false, default: 0
  end
end
