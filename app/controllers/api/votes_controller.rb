class Api::VotesController < Api::RestfulController
  include UsesDiscussionReaders

  alias :update :create

  def my_votes
    @votes = current_user.votes.most_recent.includes({motion: :discussion}, :user)
    @votes = @votes.where('motions.discussion_id': @discussion.id) if fetch_and_authorize(:discussion, optional: true)
    @votes = @votes.where('discussions.group_id': @group.id)       if fetch_and_authorize(:group, optional: true)
    respond_with_collection
  end

  private

  def accessible_records
    fetch_and_authorize :motion
    @motion.votes.most_recent.order(:created_at)
  end

end
