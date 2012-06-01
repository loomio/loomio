class DiscussionMailer < ActionMailer::Base
  default :from => "\"Loomio\" <noreply@loom.io>"

  def new_discussion_created(discussion, user)
    @discussion = discussion
    @group = discussion.group
    mail(to: user.email, subject: "[Loomio: #{@group.name}] New discussion - #{@discussion.title}")
  end

  def spam_new_discussion_created(discussion)
    group = discussion.group
    group.users.each do |user|
      DiscussionMailer.new_discussion_created(discussion, user).deliver
    end
  end

end
