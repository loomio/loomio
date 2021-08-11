class UpdatePollStanceData < ActiveRecord::Migration[6.0]
  def change
    put "migrating poll data, please wait"
    Poll.find_each do |poll|
      poll.stances.each(&:update_option_scores!)
      poll.update_counts!
    end
  end
end
