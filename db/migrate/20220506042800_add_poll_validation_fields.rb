class AddPollValidationFields < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :min_score, :integer, default: nil
    add_column :polls, :max_score, :integer, default: nil
    add_column :polls, :minimum_stance_choices, :integer, default: nil
    add_column :polls, :maximum_stance_choices, :integer, default: nil
    add_column :polls, :dots_per_person, :integer, default: nil
  end
end
