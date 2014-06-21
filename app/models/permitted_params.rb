class PermittedParams < Struct.new(:params, :user)

  %w[user vote subscription motion membership membership_request
   invitation group_request group discussion comment announcement_dismissal
   email_preferences attachment contact_message theme].each do |kind|
    define_method(kind) do
      permitted_attributes = self.send("#{kind}_attributes")
      params.require(kind).permit(*permitted_attributes)
    end
  end

  def theme_attributes
    [:name, :style, :pages_logo, :app_logo]
  end

  def email_preferences_attributes
    [{:group_email_preferences => []},
     :subscribed_to_daily_activity_email,
     :subscribed_to_proposal_closure_notifications,
     :subscribed_to_mention_notifications,
     :subscribed_to_missed_yesterday_email ]
  end

  def user_attributes
    [:name, :avatar_kind, :email, :password, :password_confirmation,
     :remember_me, :uploaded_avatar, :username, :uses_markdown,
     :time_zone, :selected_locale]
  end

  def vote_attributes
    [:position, :statement]
  end

  def subscription_attributes
    [:position, :statement]
  end

  def motion_attributes
    [:name, :description, :discussion_id, :closing_at, :outcome]
  end

  def membership_request_attributes
    [:name, :email, :introduction]
  end

  def invitation_attributes
    [:recipient_email, :recipient_name, :intent]
  end

  def group_request_attributes
    [:name, :admin_name, :admin_email, :payment_plan, :description]
  end

  def group_attributes
    [:parent_id, :name, :visible_to, :is_visible_to_public, :discussion_privacy_options,
     :members_can_add_members, :members_can_edit_discussions, :members_can_edit_comments, :motions_can_be_edited,
     :description, :next_steps_completed, :payment_plan,
     :is_visible_to_parent_members, :parent_members_can_see_discussions, :membership_granted_upon, :cover_photo, :logo, :category_id]
  end

  def discussion_attributes
    [:title, :description, :uses_markdown, :group_id, :private, :iframe_src]
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
    [:email, :message, :name, :destination]
  end
end
