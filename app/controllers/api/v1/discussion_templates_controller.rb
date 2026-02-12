class Api::V1::DiscussionTemplatesController < Api::V1::RestfulController
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

    templates = DiscussionTemplate
                .joins("LEFT JOIN groups ON groups.id = discussion_templates.group_id LEFT JOIN subscriptions ON groups.subscription_id = subscriptions.id")
                .where("discussion_templates.public": true)
                .where("groups.handle = ? OR subscriptions.plan != ?", 'templates', 'trial')

    if params[:query].present?
      templates = templates.where("process_name ILIKE :q OR process_subtitle ILIKE :q OR tags @> ARRAY[:a]::varchar[]", q: "%#{params[:query]}%", a: Array(params[:query]))
    end

    templates = templates.limit(50).to_a

    results = templates.map do |dt|
      {
        key: dt.key,
        process_name: dt.process_name,
        process_subtitle: dt.process_subtitle,
        tags: dt.tags
      }
    end

    render json: results, root: :results
  end

  def index
    if params[:key]
      self.collection = DiscussionTemplateService.default_templates.select { |dt| dt.key == params[:key] }
    elsif params[:id]
      self.collection = Array(DiscussionTemplate.find_by(group_id: current_user.group_ids, id: params[:id]))
    elsif (group = current_user.groups.find_by(id: params[:group_id]))
      self.collection = DiscussionTemplateService.group_templates(group: group)
    else
      self.collection = DiscussionTemplateService.default_templates
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
      DiscussionTemplate.where(id: val.to_i, group_id: group.id).update_all(position: index)
    end

    index
  end

  def discard
    @discussion_template = find_template_for_author_or_admin(:kept)
    @discussion_template.discard!
    index
  end

  def undiscard
    @discussion_template = find_template_for_author_or_admin(:discarded)
    @discussion_template.undiscard!
    index
  end

  def destroy
    @discussion_template = find_template_for_author_or_admin
    @discussion_template.destroy!
    destroy_response
  end

  private

  def find_template_for_author_or_admin(scope = nil)
    if params[:group_id]
      group = current_user.groups.find_by!(id: params[:group_id])
      templates = group.discussion_templates
      templates = templates.send(scope) if scope
      template = templates.find_by!(id: params[:id])
    else
      template = DiscussionTemplate.find(params[:id])
      group = current_user.groups.find_by!(id: template.group_id)
    end

    unless group.admins.exists?(current_user.id) || template.author_id == current_user.id
      raise CanCan::AccessDenied
    end

    template
  end

  def access_by_id(collection, id_col = 'id')
    h = {}
    collection.each do |row|
      h[row.send(id_col)] = row
    end
    h
  end

end
