class Api::V1::OutcomesController < Api::V1::RestfulController
  def create_action
    capture_topic_item(service.create(**{resource_symbol => resource, actor: current_user, params: resource_params}))
  end

  def exclude_types
    %w[discussion topic_item]
  end
end
