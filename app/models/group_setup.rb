class GroupSetup < ActiveRecord::Base
  belongs_to :group
  belongs_to :discussion
  belongs_to :motion

  def compose_group
    build_group
    group.name = group_name
    group.description = group_description
    group.viewable_by = viewable_by
    group.members_invitable_by = members_invitable_by
  end

  def compose_discussion
    build_discussion
    discussion.title = discussion_title
    discussion.description = discussion_description
  end

  def compose_motion
    build_motion
    motion.name = motion_title
    motion.description = motion_description
    motion.close_date = close_date
  end

  def send_invitations
  end
end
