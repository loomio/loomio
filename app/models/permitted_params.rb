class PermittedParams < Struct.new(:params, :user)

  kinds = %w[user vote subscription motion proposal membership membership_request
   invitation group_request group discussion comment announcement_dismissal
   attachment contact_message theme user_deactivation_response]

  kinds.each do |kind|
    define_method(kind) do
      permitted_attributes = self.send("#{kind}_attributes")
      params.require(kind).permit(*permitted_attributes)
    end
    alias_method :"api_#{kind}", kind.to_sym
  end

  def theme_attributes
    [:name, :style, :pages_logo, :app_logo]
  end

  def user_attributes
    [:name, :avatar_kind, :email, :password, :password_confirmation,
     :remember_me, :uploaded_avatar, :username, :uses_markdown,
     :time_zone, :selected_locale, :email_when_mentioned,
     :email_followed_threads, :email_missed_yesterday,
     :email_when_proposal_closing_soon, :email_new_discussions_and_proposals,
     {email_new_discussions_and_proposals_group_ids: []}]
  end

  def vote_attributes
    [:position, :statement, :motion_id]
  end

  def subscription_attributes
    [:position, :statement]
  end

  def motion_attributes
    [:name, :description, :discussion_id, :closing_at, :outcome]
  end
  alias_method :proposal_attributes, :motion_attributes

  def membership_request_attributes
    [:name, :email, :introduction]
  end

  def invitation_attributes
    [:recipient_email, :recipient_name, :intent]
  end

  def group_request_attributes
    [:name, :admin_name, :admin_email, :payment_plan, :description, :is_commercial]
  end

  def group_attributes
    [:parent_id, :name, :visible_to, :is_visible_to_public, :discussion_privacy_options,
     :members_can_add_members, :members_can_edit_discussions, :members_can_edit_comments, :motions_can_be_edited,
     :description, :next_steps_completed, :payment_plan,
     :is_visible_to_parent_members, :parent_members_can_see_discussions,
     :membership_granted_upon, :cover_photo, :logo, :category_id,
     :members_can_raise_motions, :members_can_vote,  :members_can_start_discussions, :members_can_create_subgroups]
  end

  def discussion_attributes
    [:title, :description, :uses_markdown, :group_id, :private, :iframe_src]
  end

  def comment_attributes
    [:body, :new_attachment_ids, :uses_markdown, :discussion_id, :parent_id, {new_attachment_ids: []}]
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

  def user_deactivation_response_attributes
    [:body]
  end

end
