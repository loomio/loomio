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
    if community = load_and_authorize(:poll).community_of_type(params.fetch(:community_type, :email))
      community.members
    else
      Visitor.none
    end
  end

end
