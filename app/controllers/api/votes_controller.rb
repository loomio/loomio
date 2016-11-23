class API::VotesController < API::RestfulController
  include UsesDiscussionReaders

  alias :update :create

  def my_votes
    @votes = current_user.votes.most_recent.includes({motion: :discussion}, :user)
    @votes = @votes.where('motions.discussion_id': @discussion.id) if load_and_authorize(:discussion, optional: true)
    @votes = @votes.where('discussions.group_id': @group.id)       if load_and_authorize(:group, optional: true)
    respond_with_collection
  end

  private

  def accessible_records
    load_and_authorize(:motion).votes.most_recent.order(:created_at)
  end

  def instantiate_resource
    @motion = Motion.find(params.dig(:vote, :proposal_id))
    self.resource = "Votes::#{@motion.kind.camelize}".constantize.new(resource_params)
  end

  def resource_class
    "Votes::#{(resource&.kind || 'loomio').camelize}".constantize
  end

end
