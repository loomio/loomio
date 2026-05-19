module Dev::Scenarios::Inbox
  def setup_inbox
    sign_in patrick
    recent_discussion group: create_another_group
    old_discussion
    pinned_discussion.tap do |d|
      CommentService.create(comment: Comment.new(body: "a pinned comment", parent: d, author: jennifer), actor: jennifer)
    end
    redirect_to inbox_path
  end
end
