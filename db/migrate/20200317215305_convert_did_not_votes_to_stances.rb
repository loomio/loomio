class ConvertDidNotVotesToStances < ActiveRecord::Migration[5.2]
  def change
    stances = []
    puts "before"
    puts "did not vote count:", PollDidNotVote.count
    puts "stance count:", Stance.count
    PollDidNotVote.find_each do |dnv|
      stances << Stance.new(
        poll_id: dnv.poll_id,
        participant_id: dnv.user_id,
        created_at: poll.created_at,
        updated_at: poll.updated_at
      )
    end
    Stance.import(stances)
    puts "after"
    puts "did not vote count:", PollDidNotVote.count
    puts "stance count:", Stance.count
    puts "cast stance count:", Stance.cast.count
    puts "not cast stance count:", Stance.not_cast.count
  end
end
