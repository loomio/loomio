class API::MotionsController < API::RestfulController
  include UsesDiscussionReaders

  def show
    load_and_authorize(:motion)
    respond_with_resource
  end

  def close
    @event = service.close_by_user(load_and_authorize(:motion, :close), current_user)
    respond_with_resource
  end

  def create_outcome
    @event = service.create_outcome(motion: load_and_authorize(:motion, :create_outcome),
                                    params: permitted_params.motion,
                                    actor:  current_user)
    respond_with_resource
  end

  def update_outcome
    @event = service.update_outcome(motion: load_and_authorize(:motion, :update_outcome),
                                    params: permitted_params.motion,
                                    actor:  current_user)
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
    instantiate_collection do |collection|
      collection.closed.where(discussion_id: load_and_authorize(:group).discussion_ids).order(closed_at: :desc)
    end
    respond_with_collection(serializer: ClosedMotionSerializer, scope: closed_motion_scope)
  end

  private

  def closed_motion_scope
    return {} unless current_user.is_logged_in?
    { vote_cache: VoteCache.new(current_user, current_user.votes.where(motion: collection)) }
  end

  def accessible_records
    Queries::VisibleMotions.new(user: current_user, groups: current_user.groups)
  end

  def serializer_root
    :proposals
  end

end
