class PermittedParams < Struct.new(:params)

  %w[user vote subscription motion membership_request membership
   invitation group_request group discussion discussion_reader comment
   attachment contact_message theme user_deactivation_response network_membership_request
   draft oauth_application].each do |kind|
    define_method(kind) do
      permitted_attributes = self.send("#{kind}_attributes")
      params.require(kind).permit(*permitted_attributes)
    end
    alias_method :"api_#{kind}", kind.to_sym
  end

  alias :read_attribute_for_serialization :send

  def theme_attributes
    [:name, :style, :pages_logo, :app_logo]
  end

  def user_attributes
    [:name, :avatar_kind, :email, :password, :password_confirmation, :current_password,
     :remember_me, :uploaded_avatar, :username, :uses_markdown,
     :time_zone, :selected_locale, :email_when_mentioned, :default_membership_volume,
     :email_missed_yesterday, :deactivation_response, :has_muted,
     :email_when_proposal_closing_soon, :email_new_discussions_and_proposals, :email_on_participation,
     {email_new_discussions_and_proposals_group_ids: []}]
  end

  def vote_attributes
    [:position, :statement, :proposal_id, :motion_id]
  end

  def network_membership_request_attributes
    [:group_id, :network_id, :message]
  end

  def subscription_attributes
    [:position, :statement]
  end

  def motion_attributes
    [:name, :description, :discussion_id, :closing_at, :outcome]
  end
  alias_method :proposal_attributes, :motion_attributes

  def membership_request_attributes
    [:name, :email, :introduction, :group_id]
  end

  def membership_attributes
    [:volume, :apply_to_all, :set_default]
  end

  def discussion_reader_attributes
    [:discussion_id, :volume, :starred]
  end

  def invitation_attributes
    [:recipient_email, :recipient_name, :intent]
  end

  def group_request_attributes
    [:name, :admin_name, :admin_email, :description, :is_commercial]
  end

  def group_attributes
    [:parent_id, :name, :group_privacy, :is_visible_to_public, :discussion_privacy_options,
     :members_can_add_members, :members_can_edit_discussions, :members_can_edit_comments, :motions_can_be_edited,
     :description, :next_steps_completed,
     :is_visible_to_parent_members, :parent_members_can_see_discussions,
     :membership_granted_upon, :cover_photo, :logo, :category_id, :is_commercial,
     :members_can_raise_motions, :members_can_vote,  :members_can_start_discussions, :members_can_create_subgroups]
  end

  def discussion_attributes
    [:title, :attachment_ids, :description, :uses_markdown, :group_id, :private, :iframe_src, :starred, {attachment_ids: []}]
  end

  def comment_attributes
    [:body, :attachment_ids, :uses_markdown, :discussion_id, :parent_id, {attachment_ids: []}]
  end

  def attachment_attributes
    [:file, :filename, :location, :filesize, :redirect]
  end

  def contact_message_attributes
    [:email, :message, :name, :destination]
  end

  def user_deactivation_response_attributes
    [:body]
  end

  def draft_attributes
    [:payload]
  end

  def oauth_application_attributes
    [:name, :redirect_uri, :logo]
  end
end
