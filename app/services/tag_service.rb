require 'set'

class TagService
  def self.create(tag:, actor:)
    tag.group = tag.group.parent_or_self if tag.group
    tag.name = clean_tag_name(tag.name)
    actor.ability.authorize! :create, tag

    return false unless tag.valid?
    tag.save!
    EventBus.broadcast 'tag_create', tag, actor
    MessageChannelService.publish_models([tag], group_id: tag.group.id)
    tag
  end

  def self.update(tag:, params:, actor:)
    actor.ability.authorize! :update, tag

    UpdateTagWorker.new.perform(tag.group_id, tag.name, clean_tag_name(params[:name]), params[:color])
    tag.reload

    MessageChannelService.publish_models([tag], group_id: tag.group.id)
    EventBus.broadcast 'tag_update', tag, actor
    tag
  end

  def self.destroy(tag:, actor:)
    actor.ability.authorize! :destroy, tag

    destroy_by_name(tag.group_id, tag.name)
    EventBus.broadcast 'tag_destroy', tag, actor
  end

  def self.destroy_by_name(group_id, name)
    group = Group.find(group_id).parent_or_self
    group_ids = group.id_and_subgroup_ids
    normalized_name = normalized_tag_name(name)

    Tag.transaction do
      # Match by normalized name so legacy rows or topic arrays that differ by
      # case or whitespace are removed together.
      variant_names = Tag.where(group_id: group_ids)
                          .select { |tag| normalized_tag_name(tag.name) == normalized_name }
                          .map(&:name)
                          .uniq

      Tag.where(group_id: group_ids, name: variant_names).destroy_all

      Topic.where(group_id: group_ids).find_each do |topic|
        next unless topic.tags.any? { |tag| normalized_tag_name(tag) == normalized_name }

        topic.update_column(:tags, clean_tag_names(topic.tags.reject { |tag| normalized_tag_name(tag) == normalized_name }))
      end
    end

    update_org_tags(group.id)
  end

  def self.apply_colors(group_id)
    group = Group.find(group_id).parent_or_self
    Tag.where(group_id: group.id, color: nil).find_each do |tag|
      tag.update_columns(color: Tag::COLORS.sample)
    end
  end

  def self.update_group_and_org_tags(group_id)
    update_org_tags(group_id)
  end

  def self.normalized_tag_name(name)
    clean_tag_name(name).downcase
  end

  def self.clean_tag_name(name)
    name.to_s.split.join(' ')
  end

  def self.clean_tag_names(names)
    seen = {}
    Array(names).filter_map do |name|
      clean = clean_tag_name(name)
      key = normalized_tag_name(clean)
      next if key.blank? || seen[key]

      seen[key] = true
      clean
    end.sort_by(&:downcase)
  end

  def self.can_create_tag?(group, actor)
    group.parent_or_self.admins_include?(actor) ||
      group.admins_include?(actor) ||
      (group.members_can_create_tags && group.members_include?(actor))
  end

  def self.new_tag_names(group, names)
    existing_keys = group.parent_or_self.tags.map { |tag| normalized_tag_name(tag.name) }.to_set
    clean_tag_names(names).reject { |name| existing_keys.include?(normalized_tag_name(name)) }
  end

  def self.authorize_create_tag_names!(group, names, actor)
    return if new_tag_names(group, names).empty?
    return if can_create_tag?(group, actor)

    raise CanCan::AccessDenied
  end

  def self.update_group_tags(group_id)
    update_org_tags(group_id)
  end

  def self.update_all_org_tags
    Group.where(parent_id: nil).find_each do |group|
      update_org_tags(group.id)
    end
  end

  def self.update_org_tags(group_id)
    return unless group = Group.find_by(id: group_id)&.parent_or_self

    group_ids = group.id_and_subgroup_ids
    used_group_ids_by_key = {}
    names_by_key = {}

    Topic.where(group_id: group_ids).pluck(:group_id, :tags).each do |topic_group_id, tags|
      clean_tag_names(tags).each do |name|
        key = normalized_tag_name(name)
        names_by_key[key] ||= name
        used_group_ids_by_key[key] ||= Set.new
        used_group_ids_by_key[key].add(topic_group_id)
      end
    end

    legacy_tags = Tag.where(group_id: group_ids - [group.id]).to_a
    legacy_color_by_key = legacy_tags.each_with_object({}) do |tag, colors|
      colors[normalized_tag_name(tag.name)] ||= tag.color
    end

    actual_tag_by_key = group.tags.index_by { |tag| normalized_tag_name(tag.name) }
    missing_keys = names_by_key.keys - actual_tag_by_key.keys

    missing_keys.each do |key|
      Tag.insert({group_id: group.id, name: names_by_key[key], color: legacy_color_by_key[key]})
    end

    Tag.where(id: legacy_tags.map(&:id)).destroy_all

    Tag.where(group_id: group.id).find_each do |tag|
      key = normalized_tag_name(tag.name)
      tag.update_column(:used_group_ids, Array(used_group_ids_by_key[key]).map(&:to_i).sort)
    end

    apply_colors(group.id)
  end

  # Merge existing tags within the same group that only differ by whitespace
  # or case. Keeps the oldest tag as canonical, repoints matching topics, and
  # deletes the duplicate metadata rows.
  def self.groom_duplicate_tags
    Tag.distinct.pluck(:group_id).sum { |group_id| groom_duplicate_tags_for_group(group_id) }
  end

  def self.groom_duplicate_tags_for_group(group_id)
    duplicate_groups = Tag.where(group_id: group_id)
                           .group_by { |tag| normalized_tag_name(tag.name) }
                           .values
                           .select { |tags| tags.length > 1 }
    return 0 if duplicate_groups.empty?

    merged = 0

    Tag.transaction do
      duplicate_groups.each do |tags|
        canonical = tags.min_by(&:id)

        (tags - [canonical]).each do |dupe|
          Topic.where(group_id: group_id).where("topics.tags @> ARRAY[?]::varchar[]", dupe.name).find_each do |topic|
            topic.update_column(:tags, clean_tag_names((topic.tags - [dupe.name]) + [canonical.name]))
          end

          dupe.destroy!
          merged += 1
        end
      end
    end

    merged
  end
end
