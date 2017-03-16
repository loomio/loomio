class API::VisitorsController < API::RestfulController

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
    (community || current_user).visitors.where(revoked: false)
  end

  def community
    @community ||= Communities::Base.find_by(id: params[:community_id]).tap do |community|
      current_user.ability.authorize!(:show, community)
    end
  end

end
