class AddProcessUrlToPolls < ActiveRecord::Migration[7.0]
  def change
    add_column :polls, :process_url, :string
  end
end
