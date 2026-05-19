class DropPublicDiscussionsCountFromGroups < ActiveRecord::Migration[7.2]
  def change
    remove_column :groups, :public_discussions_count, :integer, default: 0, null: false
  end
end
