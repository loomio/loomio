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
          group.subgroups.each do |subgroup|
            subgroup.group_privacy = 'closed'
            subgroup.save!
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
    Discussion.where(group_id: group_or_groups).update_all(private: true)
    Array(group_or_groups).map(&:update_public_discussions_count)
  end

  def make_discussions_public_in(group_or_groups)
    Discussion.where(group_id: group_or_groups).update_all(private: false)
    Array(group_or_groups).map(&:update_public_discussions_count)
  end
end
