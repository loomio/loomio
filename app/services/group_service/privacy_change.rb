class GroupService::PrivacyChange
  attr_accessor :group
  def initialize(group)
    @group = group
    @changed = group.changed
  end

  def commit!
    @changed.each do |attribute|
      case attribute
      when 'is_visible_to_public'
        if group.is_hidden_from_public?
          make_discussions_private_in(group)
          make_discussions_private_in(group.subgroups)
          # Hiding the parent restricts public subgroups, while preserving the
          # separate access boundaries of Secret and already parent-visible ones.
          group.subgroups.where(is_visible_to_public: true).each do |subgroup|
            subgroup.group_privacy = 'parent_members'
            # Apply the same boundary throughout nested subgroup trees.
            privacy_change = self.class.new(subgroup)
            subgroup.save!
            privacy_change.commit!
          end
        end
      when 'discussion_privacy_options'
        case group.discussion_privacy_options
        when 'private_only' then make_discussions_private_in(group)
        when 'public_only' then make_discussions_public_in(group)
        end
      end
    end
  end

  private
  def make_discussions_private_in(group_or_groups)
    Topic.where(group_id: group_or_groups).update_all(private: true)
  end

  def make_discussions_public_in(group_or_groups)
    Topic.where(group_id: group_or_groups).update_all(private: false)
  end
end
