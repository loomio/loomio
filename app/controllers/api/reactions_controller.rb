class API::ReactionsController < API::RestfulController
  alias :create :update

  private

  def accessible_records
    current_user.ability.authorize!(:show, reactable).reactions
  end

  def load_resource
    self.resource = case action_name
    when 'create', 'update' then resource_class.find_or_initialize_by(user: current_user, reactable: reactable)
    else super
    end
  end

  def reactable
    @reactable ||= reactable_params[:reactable_type].classify.constantize.find(reactable_params[:reactable_id])
  end

  def reactable_params
    case action_name
    when 'create', 'update' then resource_params
    when 'index'            then params
    end
  end
end
