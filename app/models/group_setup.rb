class GroupSetup < ActiveRecord::Base
  attr_accessible :group_name, :group_description, :viewable_by, :members_invitable_by,
                  :discussion_title, :discussion_description, :motion_title, :motion_description,
                  :close_date, :admin_email, :members_list, :invite_subject, :invite_body

  belongs_to :group

  def compose_group!(author)
    self.group.update_attributes(name: group_name,
                                 description: group_description,
                                 viewable_by: viewable_by,
                                 members_invitable_by: members_invitable_by)
    self.group.creator = author
    self.group.save!
  end

  def compose_discussion!(author, group)
    discussion = Discussion.new(title: discussion_title,
                                description: discussion_description)
    discussion.author = author
    discussion.group = group
    discussion.save!
  end

  def compose_motion!(author, discussion)
    motion =  Motion.new( name: motion_title,
                          description: motion_description,
                          close_date: close_date,
                          )
    motion.author = author
    motion.discussion = discussion
    motion.save!
  end

  def send_invitations
  end


  def finish!(author)
    return true if compose_group!(author) &&
                   compose_discussion!(author, group) &&
                   compose_motion!(author, group.discussions.first)
    false
  end
end
