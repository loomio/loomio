class AddMultipleChoiceToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :multiple_choice, :boolean, default: false, null: false
  end
end
