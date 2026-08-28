class Api::V1::OutcomesController < Api::V1::RestfulController
  def create_action
    outcome = service.create(**{resource_symbol => resource, actor: current_user, params: resource_params}) { |topic_item| @topic_item = topic_item }
    self.resource = outcome
  end

  def exclude_types
    %w[discussion topic_item]
  end
end
