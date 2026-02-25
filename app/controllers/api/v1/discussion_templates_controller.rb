class Api::V1::DiscussionTemplatesController < Api::V1::RestfulController
  def browse_tags
    tag_counts = {}
    DiscussionTemplateService.default_templates.each do |dt|
      Array(dt.tags).each do |tag|
        tag_counts[tag] ||= 0
        tag_counts[tag] += 1
      end
    end
    render json: tag_counts.sort_by {|k,v| -v}.to_h.keys.slice(0, 20), root: false
  end

  def browse
    templates = DiscussionTemplateService.default_templates

    if params[:query].present?
      q = params[:query].downcase
      templates = templates.select do |dt|
        dt.process_name.to_s.downcase.include?(q) ||
        dt.process_subtitle.to_s.downcase.include?(q) ||
        Array(dt.tags).any? { |tag| tag.downcase.include?(q) }
      end
    end

    results = templates.first(50).map { |dt|
      {
        key: dt.key,
        process_name: dt.process_name,
        process_subtitle: dt.process_subtitle,
        tags: dt.tags
      }
    }

    # Include parent group's DB templates when browsing from a subgroup
    if params[:group_id].present?
      group = current_user.groups.find_by(id: params[:group_id])
      if group&.parent_id && current_user.group_ids.include?(group.parent_id)
        parent_results = DiscussionTemplate.where(group_id: group.parent_id, discarded_at: nil).order(:position).map { |dt|
          {
            id: dt.id,
            key: dt.key,
            process_name: dt.process_name,
            process_subtitle: dt.process_subtitle,
            group_name: dt.group.name,
            tags: dt.tags || []
          }
        }
        results = parent_results + results
      end
    end

    render root: false, json: results
  end

  def index
    if params[:key]
      self.collection = DiscussionTemplateService.default_templates.select { |dt| dt.key == params[:key] }
    elsif params[:id]
      self.collection = Array(DiscussionTemplate.find_by(group_id: current_user.group_ids, id: params[:id]))
    elsif (group = current_user.groups.find_by(id: params[:group_id]))
      self.collection = DiscussionTemplateService.group_templates(group: group)
      unless group.admins.exists?(current_user.id)
        self.collection = self.collection.reject { |t| t.discarded_at.present? }
      end
    else
      blank = DiscussionTemplateService.default_templates.select { |dt| dt.key == 'blank' }
      direct = DiscussionTemplate.where(group_id: current_user.group_ids, default_to_direct_discussion: true).where(discarded_at: nil).to_a
      self.collection = blank + direct
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
