module Dev::Scenarios::Notification
  def setup_all_activity_items
    create_discussion
    sign_in patrick
    create_all_activity_items
    redirect_to discussion_url(create_discussion)
  end

  def setup_all_notifications
    sign_in patrick
    create_all_notifications
    redirect_to discussion_url(create_discussion)
  end
end
