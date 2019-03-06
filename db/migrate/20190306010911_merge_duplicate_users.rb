require_relative './legacy/merge_duplicate_users_task.rb'

class MergeDuplicateUsers < ActiveRecord::Migration[5.2]

  def change
    puts "merge verified"
    MergeDuplicateUsersTask.print_stats
    MergeDuplicateUsersTask.merge_verified
    puts "merge unverified"
    MergeDuplicateUsersTask.print_stats
    MergeDuplicateUsersTask.merge_unverified
    puts "after"
    MergeDuplicateUsersTask.print_stats
    remove_index :users, name: :index_users_on_email
    remove_index :users, name: :email_verified_and_unique
    add_index    :users, :email, unique: true
  end
end
