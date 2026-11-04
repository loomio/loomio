require 'set'

class TagService
  def self.create(tag:, actor:)
    tag.group = tag.group.parent_or_self if tag.group
    tag.name = clean_tag_name(tag.name)
    actor.ability.authorize! :create, tag

    return tag unless tag.valid?
    tag.save!
    MessageChannelService.publish_models([tag], group_id: tag.group.id)
    tag
  end

  def self.update(tag:, params:, actor:)
    actor.ability.authorize! :update, tag

    UpdateTagWorker.new.perform(tag.group_id, tag.name, clean_tag_name(params[:name]), params[:color])
    tag.reload

    MessageChannelService.publish_models([tag], group_id: tag.group.id)
    tag
  end

  def self.destroy(tag:, actor:)
    actor.ability.authorize! :destroy, tag

    destroy_by_name(tag.group_id, tag.name)
  end

  def self.destroy_by_name(group_id, name)
    group = Group.find(group_id).parent_or_self
    group_ids = group.id_and_subgroup_ids
    normalized_name = normalized_tag_name(name)

    Tag.transaction do
      # Match by normalized name so legacy rows or topic arrays that differ by
      # case or whitespace are removed together.
      variant_ids = Tag.where(group_id: group_ids)
                       .select { |tag| normalized_tag_name(tag.name) == normalized_name }
                       .map(&:id)

      Tag.where(id: variant_ids).destroy_all

      TopicItem.where(topic_id: Topic.where(group_id: group_ids).select(:id)).where('cardinality(tags) > 0').find_each do |item|
        next unless item.tags.any? { |tag| normalized_tag_name(tag) == normalized_name }

        item.update!(tags: clean_tag_names(item.tags.reject { |tag| normalized_tag_name(tag) == normalized_name }))
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

  # Template names are defaults, not organization tags. Restricted users can
  # apply existing vocabulary and names from templates available in the target
  # group; importing a foreign template never grants authority over that group.
  def self.permitted_tag_names(group, names, actor)
    names = clean_tag_names(names)
    return names if names.empty? || group.blank? || can_create_tag?(group, actor)

    allowed = group.parent_or_self.tags.pluck(:name).map { |name| normalized_tag_name(name) }.to_set
    return names if names.all? { |name| allowed.include?(normalized_tag_name(name)) }

    template_tag_names(group, actor).each { |name| allowed.add(normalized_tag_name(name)) }
    names.select { |name| allowed.include?(normalized_tag_name(name)) }
  end

  def self.template_tag_names(group, actor)
    discussions = group.discussion_templates.kept
    polls = group.poll_templates.kept
    unless group.members_include?(actor)
      # Intake guests can use visible discussion defaults; other guests can
      # only use public defaults, matching access to the templates themselves.
      guest_intake = actor.email_verified? && group.non_members_can_start_discussions? &&
        group.group_privacy != 'secret' && actor.can?(:show, group)
      discussions = guest_intake ? discussions.where('public OR hidden_at IS NULL') : discussions.where(public: true)
      polls = polls.where(public: true)
    end

    defaults = PollTemplateService.default_templates + PollTemplateService.public_example_templates
    defaults.reject! { |template| group.hidden_poll_templates.include?(template.key) }
    discussions.pluck(:tags).flatten + polls.pluck(:tags).flatten + defaults.flat_map(&:tags)
  end
  private_class_method :template_tag_names

  # Create colored metadata alongside visible assignments so responses and live
  # updates do not depend on the later organization-wide usage reconciliation.
  def self.ensure_tag_metadata(group, names)
    return if group.blank? || names.empty?

    missing = new_tag_names(group, names)
    return if missing.empty?

    Tag.insert_all(missing.map { |name| {group_id: group.parent_or_self.id, name: name, color: Tag::COLORS.sample,
      used_group_ids: [group.id]} }, unique_by: [:group_id, :name])
  end

  # Tag edits refresh summaries through TopicItem's tag callbacks. This hook
  # handles deletion/restoration of the underlying content: assignments survive,
  # but only kept contributions belong in the summaries. Other edits need no rebuild.
  def self.refresh_topic_tags_for_visibility(itemable)
    return unless itemable.saved_changes.key?('discarded_at')

    refresh_topic_tags!([itemable.topic_id])
  end

  # Maintain all thread summaries under the same lock as tag edits and moves.
  # Loading a thread can then use its existing rows without any tag lookups.
  def self.refresh_topic_tags!(topic_ids)
    Topic.where(id: topic_ids.compact.uniq).order(:id).with_write_lock do |topics|
      topics.each do |topic|
        rows = TopicItem.tags_visible.where(topic_id: topic.id).where('cardinality(tags) > 0').pluck(:sequence_id, :tags)

        topic.assign_attributes(
          tags: clean_tag_names(rows.flat_map(&:last)),
          has_tagged_replies: rows.any? { |sequence_id, _tags| sequence_id && sequence_id > 0 }
        )
        topic.save! if topic.changed?
      end
    end
  end

  def self.update_group_tags(group_id)
    update_org_tags(group_id)
  end

  def self.update_all_org_tags
    Group.where(parent_id: nil).find_each do |group|
      update_org_tags(group.id)
    end
  end

  def self.normalize_all_tag_names
    result = {
      topic_updates_count: 0,
      tag_updates_count: 0,
      tag_merges_count: 0
    }

    changed_topic_ids = Set.new
    TopicItem.where('cardinality(tags) > 0').find_each do |item|
      clean_tags = clean_tag_names(item.tags)
      next if item.tags == clean_tags

      changed_topic_ids.add(item.topic_id)
      item.update!(tags: clean_tags)
    end
    result[:topic_updates_count] = changed_topic_ids.length

    Tag.distinct.pluck(:group_id).each do |group_id|
      tags = Tag.where(group_id: group_id).to_a
      result[:tag_updates_count] += tags.count { |tag| tag.name != clean_tag_name(tag.name) }
      result[:tag_merges_count] += groom_duplicate_tags_for_group(group_id)
    end

    update_all_org_tags
    result
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

    update_used_group_ids(group.id, used_group_ids_by_key)

    apply_colors(group.id)
  end

  # Every tag has a different set of groups, so Active Record's ordinary bulk
  # update API cannot express this without one UPDATE per tag. Send the complete
  # mapping in one statement to keep tag reconciliation bounded for large orgs.
  def self.update_used_group_ids(group_id, used_group_ids_by_key)
    updates = Tag.where(group_id: group_id).pluck(:id, :name).map do |id, name|
      key = normalized_tag_name(name)
      { id: id, used_group_ids: Array(used_group_ids_by_key[key]).map(&:to_i).sort }
    end
    return if updates.empty?

    bind = ActiveRecord::Relation::QueryAttribute.new('updates', updates.to_json, ActiveRecord::Type::String.new)
    Tag.connection.exec_update(<<~SQL, 'Update tag usage', [bind])
      UPDATE tags
      SET used_group_ids = ARRAY(
        SELECT value::integer
        FROM jsonb_array_elements_text(updates.used_group_ids) AS values(value)
      )
      FROM jsonb_to_recordset($1::jsonb) AS updates(id integer, used_group_ids jsonb)
      WHERE tags.id = updates.id
    SQL
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

    merged = 0

    if duplicate_groups.any?
      Tag.transaction do
        duplicate_groups.each do |tags|
          canonical = tags.min_by(&:id)
          canonical_name = clean_tag_name(canonical.name)

          (tags - [canonical]).each do |dupe|
            TopicItem.where(topic_id: Topic.where(group_id: Group.find(group_id).id_and_subgroup_ids).select(:id))
              .where("topic_items.tags @> ARRAY[?]::varchar[]", dupe.name).find_each do |item|
              item.update!(tags: clean_tag_names((item.tags - [dupe.name]) + [canonical_name]))
            end

            dupe.destroy!
            merged += 1
          end

          canonical.update!(name: canonical_name) if canonical.name != canonical_name
        end
      end
    end

    Tag.where(group_id: group_id).find_each do |tag|
      clean = clean_tag_name(tag.name)
      tag.update!(name: clean) if tag.name != clean
    end

    merged
  end
end
