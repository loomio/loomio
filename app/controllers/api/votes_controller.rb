class API::VotesController < API::RestfulController
  include UsesDiscussionReaders

  alias :update :create

  def my_votes
    @votes = current_user.votes.includes(:motion, :user).where(motion_id: motion_ids).most_recent
    respond_with_collection
  end

  private

  def visible_records
    load_and_authorize :motion
    @motion.votes.most_recent.order(:created_at)
  end

  def motion_ids
    params[:proposal_ids].split(',').map(&:to_i) if params[:proposal_ids]
  end

end
