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

  def positions
    group = current_user.adminable_groups.find_by!(id: params[:group_id])
    
    params[:ids].each_with_index do |val, index|
      if val.is_a? Integer
        DiscussionTemplate.where(id: val, group_id: group.id).update_all(position: index)
      else
        group.discussion_template_positions[val] = index
      end
    end

    group.save!
    index
  end
end
