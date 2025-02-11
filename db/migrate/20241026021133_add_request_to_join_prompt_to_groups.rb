class AddRequestToJoinPromptToGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :groups, :request_to_join_prompt, :string
  end
end
