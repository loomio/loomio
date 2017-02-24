class API::VisitorsController < API::RestfulController

  def remind
    service.remind(visitor: load_resource, actor: current_user)
    respond_with_resource
  end

  private

  def default_page_size
    100
  end

  def accessible_records
    load_and_authorize(:poll).visitors.where(revoked: false)
  end

end
