class AddProcessSubtitleBackOnPolls < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :process_subtitle, :string
  end
end
