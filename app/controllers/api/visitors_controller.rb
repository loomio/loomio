class API::VisitorsController < API::RestfulController

  def create
    service.create(visitor: instantiate_resource, actor: current_user, poll: load_and_authorize(:poll))
    respond_with_resource
  end

  def remind
    service.remind(visitor: load_resource, actor: current_user, poll: load_and_authorize(:poll))
    respond_with_resource
  end

  private

  def current_user
    current_visitor.presence || super
  end

  def default_page_size
    100
  end

  def accessible_records
    (load_and_authorize(:poll, optional: true) || current_user).visitors.where(revoked: false)
  end
end
