class API::V1::PollTemplatesController < API::V1::RestfulController
  def index
    group = current_user.groups.find_by(id: params[:group_id]) || NullGroup.new

    self.collection = PollTemplateService.group_templates(group: group)

    respond_with_collection
  end 

  def show
    @poll_template = PollTemplate.find_by(group_id: current_user.group_ids, id: params[:id])
    respond_with_resource
  end

  def update
    if params[:id].to_i.to_s != params[:id].to_s
      self.resource = PollTemplate.find_by(group_id: params[:poll_template][:group_id], key: params[:id])
    else
      load_resource
    end

    update_action
    update_response
  end

  def positions
    group = current_user.adminable_groups.find_by!(id: params[:group_id])
    params[:ids].each_with_index do |val, index|
      if val.is_a? Integer
        PollTemplate.where(id: val, group_id: group.id).update_all(position: index)
      else
        group.poll_template_positions[val] = index
      end
    end

    group.save!
    index
  end

  def settings
    group = current_user.adminable_groups.find_by!(id: params[:group_id])
    if params.has_key?(:categorize_poll_templates)
      group.categorize_poll_templates = params[:categorize_poll_templates]
      group.save!
      MessageChannelService.publish_models([group], group_id: group.id)
      success_response
    else
      error_response(404)
    end
  end

  def discard
    @group = current_user.adminable_groups.find_by!(id: params[:group_id])
    @poll_template = @group.poll_templates.kept.find_by!(id: params[:id])
    @poll_template.discard!
    index
  end

  def undiscard
    @group = current_user.adminable_groups.find_by!(id: params[:group_id])
    @poll_template = @group.poll_templates.discarded.find_by!(id: params[:id])
    @poll_template.undiscard!
    index
  end

  def destroy
    @poll_template = PollTemplate.find(params[:id])
    current_user.adminable_groups.find(@poll_template.group_id)
    @poll_template.destroy!
    destroy_response
  end

  def hide
    @group = current_user.adminable_groups.find_by!(id: params[:group_id])

    if PollTemplateService.group_templates(group: @group).any? {|pt| pt.key == params[:key]}
      @group = current_user.adminable_groups.find_by(id: params[:group_id])
      @group.hidden_poll_templates ||= []
      @group.hidden_poll_templates.push params[:key].parameterize
      @group.hidden_poll_templates.uniq!
      @group.save!
      index
    else
      response_with_error(404)
    end
  end

  def unhide
    @group = current_user.adminable_groups.find_by!(id: params[:group_id])

    if PollTemplateService.group_templates(group: @group).any? {|pt| pt.key == params[:key]}
      @group = current_user.adminable_groups.find_by(id: params[:group_id])
      @group.hidden_poll_templates -= [params[:key].parameterize]
      @group.save!
      self.resource = @group
      index
    else
      response_with_error(404)
    end
  end
end
