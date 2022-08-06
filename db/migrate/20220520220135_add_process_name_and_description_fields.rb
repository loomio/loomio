class AddProcessNameAndDescriptionFields < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :process_name, :string, default: nil
  end
end
