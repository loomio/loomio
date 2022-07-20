class AddProcessTitleAndSubtitleToDiscussions < ActiveRecord::Migration[6.1]
  def change
    add_column :discussions, :process_title, :string
    add_column :discussions, :process_subtitle, :string
  end
end
