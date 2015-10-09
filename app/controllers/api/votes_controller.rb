class API::VotesController < API::RestfulController
  include UsesDiscussionReaders

  alias :update :create

  def my_votes
    @votes = if params[:discussion_id]
      load_and_authorize :discussion
      @discussion.votes.includes({motion: [:author, :outcome_author]}, :user).for_user(current_user).most_recent
    elsif params[:proposal_ids]
      ids = params[:proposal_ids].split(',').map(&:to_i)
      current_user.votes.where(motion_id: ids)
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
