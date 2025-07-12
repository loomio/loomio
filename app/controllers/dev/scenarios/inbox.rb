module Dev::Scenarios::Inbox
  def setup_inbox
    sign_in patrick
    recent_discussion group: create_another_group
    old_discussion; pinned_discussion
    redirect_to inbox_path
  end
end
