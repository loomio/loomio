class API::V1::PollTemplatesController < API::V1::RestfulController
  def index
    group = current_user.groups.find_by(id: params[:group_id]) || NullGroup.new

    self.collection = PollTemplateService.group_templates(group: group, default_format: current_user.default_format)

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

  def hidden
    group = current_user.groups.find_by(id: params[:group_id])

    self.collection = group.poll_templates.discarded

    respond_with_collection
  end

  def discard
    @group = current_user.adminable_groups.find_by!(id: params[:group_id])
    @poll_template = @group.poll_templates.kept.find_by!(id: params[:id])
    @poll_template.discard!
    respond_with_resource
  end

  def undiscard
    @group = current_user.adminable_groups.find_by!(id: params[:group_id])
    @poll_template = @group.poll_templates.discarded.find_by!(id: params[:id])
    @poll_template.undiscard!
    respond_with_resource
  end

  def destroy
    @poll_template = PollTemplate.find(params[:id])
    current_user.adminable_groups.find(@poll_template.group_id)
    @poll_template.destroy
    respond_with_resource
  end

  def hide
    @group = current_user.adminable_groups.find_by!(id: params[:group_id])

    if PollTemplateService.group_templates(group: @group).any? {|pt| pt.key == params[:key]}
      @group = current_user.adminable_groups.find_by(id: params[:group_id])
      @group.hidden_poll_templates ||= []
      @group.hidden_poll_templates.push params[:key].parameterize
      @group.hidden_poll_templates.uniq!
      @group.save!
      self.resource = @group
      respond_with_resource
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
      respond_with_resource
    else
      response_with_error(404)
    end
  end
end
