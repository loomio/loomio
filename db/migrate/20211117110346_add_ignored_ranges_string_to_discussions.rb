class AddIgnoredRangesStringToDiscussions < ActiveRecord::Migration[6.1]
  def change
    add_column :discussions, :ignored_ranges_string, :string
  end
end
