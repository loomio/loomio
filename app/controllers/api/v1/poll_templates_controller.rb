class API::V1::PollTemplatesController < API::V1::RestfulController
  def index
    @group = current_user.groups.find_by(id: params[:group_id]) || NullGroup.new

    ignore_keys = @group.poll_templates.pluck(:key).uniq

    self.collection = @group.poll_templates.all.to_a
    self.collection.concat PollTemplateService.default_poll_templates(default_format: current_user.default_format).reject { |pt| ignore_keys.include?(pt.key) }

    respond_with_collection
  end
end
