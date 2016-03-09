class API::MotionsController < API::RestfulController
  load_and_authorize_resource only: :show, find_by: :key
  include UsesDiscussionReaders

  named_action :close_by_user,  params: true
  named_action :create_outcome, params: true
  named_action :update_outcome, params: true

  def close_by_user
    @event = MotionService.close_by_user(load_and_authorize(:motion, :close), current_user)
    respond_with_resource
  end

  def index
    instantiate_collection do |collection|
      collection = collection.where(discussion: @discussion) if load_and_authorize(:discussion, optional: true)
      collection.order(:created_at)
    end
    respond_with_collection
  end

  def closed
    load_and_authorize :group, :view_previous_proposals
    instantiate_collection { |collection| collection.closed.where(discussion_id: @group.discussion_ids).order(closed_at: :desc) }
    respond_with_collection(serializer: ClosedMotionSerializer, scope: closed_motion_scope)
  end

  private

  def closed_motion_scope
    { vote_cache: VoteCache.new(current_user, current_user.votes.where(motion: collection)) }
  end

  def accessible_records
    Queries::VisibleMotions.new(user: current_user, groups: current_user.groups)
  end

  def serializer_root
    :proposals
  end

end
