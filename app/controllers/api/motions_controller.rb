class API::MotionsController < API::RestfulController
  load_and_authorize_resource only: [:show], find_by: :key

  def show
    respond_with_resource
  end

  def close
    self.resource = MotionService.close_by_user(actor: current_user, params: params)
    respond_with_resource
  end

  def create_outcome
    self.resource = MotionService.create_outcome(actor: current_user, params: params)
    respond_with_resource
  end

  def update_outcome
    self.resource = MotionService.update_outcome(actor: current_user, params: params)
    respond_with_resource
  end

  private

  def visible_records
    load_and_authorize :discussion
    Queries::VisibleMotions.new(user: current_user, groups: current_user.groups)
                           .where(discussion: @discussion)
                           .order(:created_at)
  end

  def serializer_root
    :proposals
  end

end
