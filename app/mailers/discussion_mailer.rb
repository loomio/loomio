class DiscussionMailer < ActionMailer::Base
  include ApplicationHelper
  default :from => "\"Loomio\" <noreply@loom.io>"

  def new_discussion_created(discussion, user)
    @discussion = discussion
    @group = discussion.group
    mail(
      to: user.email,
      reply_to: discussion.author_email,
      subject: "#{email_subject_prefix(@group.full_name)} New discussion - #{@discussion.title}")
  end

  def spam_new_discussion_created(discussion)
    group = discussion.group
    group.users.each do |group_user|
      if group_user != discussion.author && group_user.send_email? && group_user.send_notification?(group, 1)
        DiscussionMailer.new_discussion_created(discussion, group_user).deliver
      end
    end
  end

end
