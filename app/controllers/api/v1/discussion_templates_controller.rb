class API::V1::DiscussionTemplatesController < API::V1::RestfulController
  def index
    group = current_user.groups.find_by(id: params[:group_id]) || NullGroup.new

    # self.collection = PollTemplateService.group_templates(group: group, default_format: current_user.default_format)
    self.collection = DiscussionTemplate.where(group_id: group.id)

    respond_with_collection
  end 

  def show
    @discussion_template = DiscussionTemplate.find_by(group_id: current_user.group_ids, id: params[:id])
    respond_with_resource
  end
end
