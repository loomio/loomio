class DiscussionMailer < ActionMailer::Base
  default :from => "\"Loomio\" <noreply@loom.io>"

  def new_discussion_created(discussion, user)
    @discussion = discussion
    @group = discussion.group
    mail(to: user.email, subject: "[Loomio: #{@group.full_name}] New discussion - #{@discussion.title}")
  end

  def spam_new_discussion_created(discussion, user)
    group = discussion.group
    group.users.each do |group_user|
      DiscussionMailer.new_discussion_created(discussion, group_user).deliver if user.id != group_user.id
    end
  end

end
