class API::VotesController < API::RestfulController

  def my_votes
    load_and_authorize_discussion
    @votes = @discussion.votes.most_recent.for_user(current_user)
    respond_with_collection
  end

  private

  def visible_records
    load_and_authorize_motion
    motion.votes.most_recent.order(:created_at)
  end

end
