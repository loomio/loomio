class API::V1::DiscussionTemplatesController < API::V1::RestfulController
  def browse_tags
    tag_counts = {}
    DiscussionTemplate.where(public: true).pluck(:tags).flatten.each do |tag|
      tag_counts[tag] ||= 0
      tag_counts[tag] += 1
    end
    render json: tag_counts.sort_by {|k,v| v}.to_h.keys.slice(0, 20), root: false
  end

  def browse
    if DiscussionTemplate.where(public: true).count == 0
      DiscussionTemplateService.create_public_templates
    end
    
    templates = DiscussionTemplate.where(public: true)

    if params[:query].present?
      templates = templates.where("process_name ILIKE :q OR process_subtitle ILIKE :q OR tags @> ARRAY[:a]::varchar[]", q: "%#{params[:query]}%", a: Array(params[:query]))
    end

    templates = templates.limit(50).to_a

    authors = access_by_id(User.where(id: templates.map(&:author_id)))
    groups = access_by_id(Group.where(id: templates.map(&:group_id)))

    results = templates.map do |dt|
      author = authors[dt.author_id]
      group = groups[dt.group_id]
      {
        id: dt.id,
        process_name: dt.process_name,
        process_subtitle: dt.process_subtitle,
        author_name: author&.name,
        group_name: group&.name,
        avatar_url: (group&.logo_url || author&.avatar_url),
        tags: dt.tags
      }
    end

    render json: results, root: :results
  end

  def index
    group = current_user.groups.find_by(id: params[:group_id]) || NullGroup.new

    if group.discussion_templates_count == 0
      group.discussion_templates = DiscussionTemplateService.initial_templates
    end

    if params[:id]
      self.collection = Array(DiscussionTemplate.find_by(group_id: current_user.group_ids, id: params[:id]))
    else
      self.collection = group.discussion_templates
    end

    respond_with_collection
  end

  def show
    @discussion_template = DiscussionTemplate.where('group_id IN (?) OR public = true', current_user.group_ids).find(params[:id])
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

  private
  def access_by_id(collection, id_col = 'id')
    h = {}
    collection.each do |row|
      h[row.send(id_col)] = row
    end
    h
  end

end
