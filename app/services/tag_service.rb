class TagService
  def self.create(tag:, actor:)
    actor.ability.authorize! :create, tag

    return false unless tag.valid?
    tag.save!
    EventBus.broadcast 'tag_create', tag, actor
    MessageChannelService.publish_models([tag], group_id: tag.group.id)
    tag
  end

  def self.update(tag:, params:, actor:)
    actor.ability.authorize! :update, tag

    UpdateTagWorker.new.perform(tag.group_id, tag.name, params[:name].strip, params[:color])
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
    group = Group.find(group_id)
    group_ids = group.id_and_subgroup_ids
    normalized_name = name.to_s.strip

    Tag.transaction do
      # tags.name is citext (case-insensitive) but plain `where(name:)` won't
      # catch look-alike rows that differ only by whitespace (e.g. a legacy
      # "Community Energy " next to "Community Energy") - those render
      # identically in the UI, so a name-only match leaves an indistinguishable
      # duplicate behind and looks like the delete silently failed.
      variant_names = Tag.where(group_id: group_ids)
                          .where("btrim(tags.name) = ?", normalized_name)
                          .distinct.pluck(:name)

      Tag.where(group_id: group_ids, name: variant_names).destroy_all

      variant_names.each do |variant_name|
        Topic.where(group_id: group_ids).where("topics.tags @> ARRAY[?]::varchar[]", variant_name).find_each do |topic|
          topic.update_column(:tags, topic.tags - Array(variant_name))
        end
      end
    end

    update_org_tagging_counts(group.parent_or_self.id)
  end

  def self.apply_colors(group_id)
    group_ids = Group.find(group_id).parent_or_self.id_and_subgroup_ids
    Tag.where(group_id: group_id, color: nil).each do |tag|
      if parent_tag = Tag.where(group_id: group_ids, name: tag.name).where.not(color: nil).first
        tag.update_columns(color: parent_tag.color)
      else
        tag.update_columns(color: Tag::COLORS.sample)
      end
    end
  end

  def self.update_group_and_org_tags(group_id)
    return unless group = Group.find_by(id: group_id)
    update_group_tags(group_id)
    update_org_tagging_counts(group.parent_or_self.id)
  end

  def self.normalized_tag_name(name)
    name.to_s.strip.downcase
  end

  def self.update_group_tags(group_id)
    return unless group = Group.find_by(id: group_id)

    names = group.topics.pluck(:tags).flatten

    return if names.empty?

    counts = {}

    names.map { |name| normalized_tag_name(name) }.each do |dname|
      counts[dname] ||= 0
      counts[dname] += 1
    end

    group.tags.where.not(name: counts.keys).update_all(taggings_count: 0)

    # Match on the actual stored name (whitespace and all) - citext already
    # folds case for us, but a stripped key won't hit the unique index if the
    # stored row still has stray whitespace, which would upsert a *new* row
    # instead of updating the existing one.
    actual_name_by_key = group.tags.pluck(:name).index_by { |name| normalized_tag_name(name) }
    present = actual_name_by_key.keys & counts.keys
    missing = counts.keys - present

    if present.any?
      Tag.upsert_all(
        present.map { |key| {group_id: group_id, name: actual_name_by_key[key], taggings_count: counts[key]} },
        unique_by: [:group_id, :name],
        update_only: [:taggings_count]
      )
    end

    missing.each do |dname|
      Tag.insert({group_id: group_id,
                  name: names.find { |name| normalized_tag_name(name) == dname }.to_s.strip,
                  taggings_count: counts[dname]})
    end

    apply_colors(group_id)
  end

  def self.update_org_tagging_counts(group_id)
    return unless group = Group.find_by(id: group_id)

    group_ids = group.id_and_subgroup_ids

    names = Tag.where(group_id: group_ids).pluck(:name).uniq

    return if names.empty?

    counts = {}
    Tag.where(group_id: group_ids).group(:name).sum(:taggings_count).each do |name, count|
      key = normalized_tag_name(name)
      counts[key] = (counts[key] || 0) + count
    end

    group.tags.where.not(name: counts.keys).update_all(org_taggings_count: 0)

    actual_name_by_key = group.tags.pluck(:name).index_by { |name| normalized_tag_name(name) }
    present = actual_name_by_key.keys & counts.keys
    missing = counts.keys - present

    if present.any?
      Tag.upsert_all(
        present.map { |key| {group_id: group_id, name: actual_name_by_key[key], org_taggings_count: counts[key]} },
        unique_by: [:group_id, :name],
        update_only: [:org_taggings_count]
      )
    end

    missing.each do |dname|
      Tag.insert({group_id: group_id,
                  name: names.find { |name| normalized_tag_name(name) == dname }.to_s.strip,
                  org_taggings_count: counts[dname]})
    end

    apply_colors(group_id)
  end

  # Merge existing tags within the same group that only differ by whitespace
  # (citext already folds case, but two rows like "Community Energy" and
  # "Community Energy " can coexist from before whitespace was normalized on
  # write). Keeps the tag with the highest taggings_count as canonical,
  # repoints any topics tagged with the duplicate, and deletes the duplicate.
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
        canonical = tags.max_by { |tag| [tag.taggings_count, -tag.id] }

        (tags - [canonical]).each do |dupe|
          Topic.where(group_id: group_id).where("topics.tags @> ARRAY[?]::varchar[]", dupe.name).find_each do |topic|
            topic.update_column(:tags, ((topic.tags - [dupe.name]) + [canonical.name]).uniq)
          end

          canonical.update_columns(
            taggings_count: canonical.taggings_count + dupe.taggings_count,
            org_taggings_count: canonical.org_taggings_count + dupe.org_taggings_count
          )
          dupe.destroy!
          merged += 1
        end
      end
    end

    merged
  end
end
