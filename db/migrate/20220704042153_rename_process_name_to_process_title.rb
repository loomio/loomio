class RenameProcessNameToProcessTitle < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :reason_prompt, :string
  end
end
