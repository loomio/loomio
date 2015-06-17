class API::VotesController < API::RestfulController

  alias :update :create

  def my_votes
    @votes = if params[:discussion_id]
      load_and_authorize :discussion
      @discussion.votes.for_user(current_user).most_recent
    else
      current_user.votes.most_recent.since(3.months.ago).most_recent
    end
    respond_with_collection
  end

  private

  def visible_records
    load_and_authorize :motion
    @motion.votes.most_recent.order(:created_at)
  end

end
