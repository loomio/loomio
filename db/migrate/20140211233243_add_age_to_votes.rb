require 'ruby-progressbar'
class AddAgeToVotes < ActiveRecord::Migration
  def up
    add_column :votes, :age, :integer
    add_column :votes, :previous_vote_id, :integer unless column_exists? :votes, :previous_vote_id
    add_index :votes, [:motion_id, :user_id, :age], unique: true, name: 'aged_votes_for_motions'
    add_index :votes, [:motion_id, :user_id]

    puts "updating vote age on #{Vote.count} Vote records"
    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ", progress_mark: "\e[32m/\e[0m", total: Vote.count )

    Vote.reset_column_information
    Motion.find_each do |motion|
      motion.voter_ids.each do |user_id|
        count = 0
        motion.votes.where(user_id: user_id).order('created_at DESC').each do |vote|
          Vote.where(id: vote.id).update_all("age = #{count}")
          count += 1
          progress_bar.increment
        end
      end
    end

    change_column :votes, :age, :integer, null: false, default: 0
    remove_index :votes, :user_id
  end

  def down
    add_index :votes, :user_id
    remove_column :votes, :age
  end
end
