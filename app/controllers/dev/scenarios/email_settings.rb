module Dev::Scenarios::EmailSettings
  def email_settings_as_logged_in_user
    Group.find_by(handle: 'shoes') || create_group
    sign_in patrick
    redirect_to email_preferences_path
  end

  def view_email_catch_up_settings
    recipient = patrick
    redirect_to email_actions_catch_up_path(unsubscribe_token: recipient.unsubscribe_token)
  end

  def view_thread_email_settings
    group = Group.find_by(handle: 'shoes') || create_group
    discussion = Discussion.joins(:topic).find_by(title: 'What star sign are you?', topics: {group_id: group.id}) ||
      DiscussionService.create(params: {group_id: group.id, title: 'What star sign are you?'}, actor: patrick)
    raise ActiveRecord::RecordInvalid, discussion unless discussion.persisted?

    redirect_to email_actions_unsubscribe_path(topic_id: discussion.topic.id, unsubscribe_token: patrick.unsubscribe_token)
  end
end
