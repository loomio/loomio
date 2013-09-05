class PermittedParams < Struct.new(:params, :user)

  %w[user vote subscription motion membership membership_request
   invitation group_request group discussion comment announcement_dismissal
   email_preferences attachment contact_message].each do |kind|
    define_method(kind) do
      permitted_attributes = self.send("#{kind}_attributes")
      params.require(kind).permit(*permitted_attributes)
    end
  end

  def email_preferences_attributes
    [{:group_email_preferences => []},
     :subscribed_to_daily_activity_email,
     :subscribed_to_proposal_closure_notifications,
     :subscribed_to_mention_notifications]
  end

  def user_attributes
    [:name, :avatar_kind, :email, :password, :password_confirmation,
     :remember_me, :uploaded_avatar, :username, :uses_markdown,
     :time_zone, :language_preference]
  end

  def vote_attributes
    [:position, :statement]
  end

  def subscription_attributes
    [:position, :statement]
  end

  def motion_attributes
    [:name, :description, :discussion_url, :discussion_id, :close_at_date, :close_at_time, :close_at_time_zone, :outcome]
  end

  def membership_request_attributes
    [:name, :email, :introduction]
  end

  def invitation_attributes
    [:recipient_email, :recipient_name, :intent]
  end

  def group_request_attributes
    [:name, :admin_name, :admin_email, :payment_plan]
  end

  def group_attributes
    [:parent_id, :name, :viewable_by, :members_invitable_by, :description, :next_steps_completed, :payment_plan]
    #if user.is_admin?
      #[:parent_id, :name, :viewable_by, :members_invitable_by, :description, :next_steps_completed, :payment_plan, :max_size]
    #else
    #end
  end

  def discussion_attributes
    [:title, :description, :uses_markdown, :group_id]
  end

  def comment_attributes
    [:body, :uses_markdown, :attachment_ids]
  end

  def announcement_dismissal_attributes
    [:announcement_id]
  end

  def attachment_attributes
    [:filename, :location, :filesize, :redirect]
  end

  def contact_message_attributes
    [:email, :message, :name]
  end
end
