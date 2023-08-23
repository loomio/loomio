class API::V1::DiscussionTemplatesController < API::V1::RestfulController
  def index
    group = current_user.groups.find_by(id: params[:group_id]) || NullGroup.new

    if params[:key_or_id].present? && (params[:key_or_id].to_i.to_s == params[:key_or_id].to_s)
      @discussion_template = DiscussionTemplate.find_by(group_id: current_user.group_ids, id: params[:key_or_id])
      respond_with_resource
    else
      self.collection = DiscussionTemplateService.group_templates(group: group)
      respond_with_collection
    end
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

  def discard
    @group = current_user.adminable_groups.find_by!(id: params[:group_id])
    @discussion_template = @group.discussion_templates.kept.find_by!(id: params[:id])
    @discussion_template.discard!
    index
  end

  def undiscard
    @group = current_user.adminable_groups.find_by!(id: params[:group_id])
    @discussion_template = @group.discussion_templates.discarded.find_by!(id: params[:id])
    @discussion_template.undiscard!
    index
  end

  def destroy
    @discussion_template = DiscussionTemplate.find(params[:id])
    current_user.adminable_groups.find(@discussion_template.group_id)
    @discussion_template.destroy!
    destroy_response
  end

  def hide
    @group = current_user.adminable_groups.find_by!(id: params[:group_id])

    if DiscussionTemplateService.group_templates(group: @group).any? {|pt| pt.key == params[:key]}
      @group = current_user.adminable_groups.find_by(id: params[:group_id])
      @group.hidden_discussion_templates ||= []
      @group.hidden_discussion_templates.push params[:key].parameterize
      @group.hidden_discussion_templates.uniq!
      @group.save!
      index
    else
      response_with_error(404)
    end
  end

  def unhide
    @group = current_user.adminable_groups.find_by!(id: params[:group_id])

    if DiscussionTemplateService.group_templates(group: @group).any? {|pt| pt.key == params[:key]}
      @group = current_user.adminable_groups.find_by(id: params[:group_id])
      @group.hidden_discussion_templates -= [params[:key].parameterize]
      @group.save!
      self.resource = @group
      index
    else
      response_with_error(404)
    end
  end
end
