class FixAnonymousStances < ActiveRecord::Migration[6.0]
  def change
    return if ENV['CANONICAL_HOST'] == 'www.loomio.org'
    put "migrating poll data, please wait"
    Poll.find_each do |poll|
      poll.stances.each(&:update_option_scores!)
      poll.update_counts!
    end
  end
end
