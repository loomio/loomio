class RemoveEmailWhenMentionedFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :email_when_mentioned
  end
end
