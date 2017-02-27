class API::VisitorsController < API::RestfulController

  def remind
    service.remind(visitor: load_resource, actor: current_user, poll: ModelLocator.new(:poll, params).locate)
    respond_with_resource
  end

  private

  def default_page_size
    100
  end

  def accessible_records
    load_and_authorize(:poll).community_of_type(params.fetch(:community_type, :email))&.members || resource_class.none
  end

end
