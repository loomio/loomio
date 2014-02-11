class AddAgeToVotes < ActiveRecord::Migration
  require 'ruby-progressbar'

  def up
    remove_index :votes, :user_id
    add_column :votes, :age, :integer

    add_index :votes, [:motion_id, :user_id, :age], unique: true, name: 'aged_votes_for_motions'

    puts "updating vote age on #{Motion.count} Motion records"
    progress_bar = ProgressBar.create( format: "(%c/%C) |%B| %a", progress_mark: "\e[32m/\e[0m", total: Motion.count )

    Vote.reset_column_information
    Motion.find_each do |motion|
      progress_bar.increment

      motion.voters.each do |user|
        count = 0
        Vote.where(motion_id: motion.id, user_id: user.id).order('created_at DESC').each do |vote|
          vote.update_attribute(:age, count)
          count += 1
        end
      end
    end

    change_column :votes, :age, :integer, null: false, default: 0
  end

  def down
    add_index :votes, :user_id
    remove_column :votes, :age
  end
end
