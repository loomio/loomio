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

  def poll
    @poll ||= Poll.find(resource_params[:poll_id])
  end

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
      current_user.ability.authorize!(:manage_visitors, community)
    end
  end

end
