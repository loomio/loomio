class PermittedParams < Struct.new(:params)
  MODELS = %w(
    user membership_request membership poll outcome
    stance invitation group_request group discussion discussion_reader comment
    contact_message user_deactivation_response announcement document
    draft oauth_application group_identity contact_request reaction
  )

  MODELS.each do |kind|
    define_method(kind) do
      permitted_attributes = self.send("#{kind}_attributes")
      params.require(kind).permit(*permitted_attributes)
    end
    alias_method :"api_#{kind}", kind.to_sym
  end

  alias :read_attribute_for_serialization :send

  def user_attributes
    [:name, :avatar_kind, :email, :password, :password_confirmation, :current_password,
     :remember_me, :uploaded_avatar, :username, :short_bio, :location,
     :time_zone, :selected_locale, :email_when_mentioned, :default_membership_volume,
     :email_catch_up, :deactivation_response, :has_password, :has_token, :email_status,
     :email_when_proposal_closing_soon, :email_new_discussions_and_proposals, :email_on_participation, :email_newsletter,
     :legal_accepted, {email_new_discussions_and_proposals_group_ids: []}]
  end

  def poll_attributes
    [:title, :details, :poll_type, :discussion_id, :group_id, :closing_at, :anonymous,
     :multiple_choice, :key, :anyone_can_participate, :notify_on_participate, :voter_can_add_options,
     :custom_fields, {custom_fields: [:can_respond_maybe, :deanonymize_after_close, :dots_per_person, :max_score, :time_zone, :meeting_duration, :minimum_stance_choices, :pending_emails, {pending_emails: []}]},
     :document_ids, {document_ids: []},
     :poll_option_names, {poll_option_names: []}]
  end

  def stance_attributes
    [:poll_id, :reason,
     :visitor_attributes, {visitor_attributes: [:name, :email, :legal_accepted, :recaptcha]},
     :stance_choices_attributes, {stance_choices_attributes: [:score, :poll_option_id]}]
  end

  def stance_choice_attributes
    [:score, :poll_option_id, :stance_id]
  end

  def outcome_attributes
    [:statement, :poll_id, :poll_option_id,
     :document_ids, {document_ids: []},
     :custom_fields, custom_fields: [:event_location, :event_summary, :event_description]]
  end

  def membership_request_attributes
    [:name, :email, :introduction, :group_id]
  end

  def membership_attributes
    [:title, :volume, :apply_to_all, :set_default]
  end

  def discussion_reader_attributes
    [:discussion_id, :volume]
  end

  def invitation_attributes
    [:recipient_email, :recipient_name, :intent, :group_id]
  end

  def group_request_attributes
    [:name, :admin_name, :admin_email, :description]
  end

  def group_attributes
    [:parent_id, :name, :group_privacy, :is_visible_to_public, :discussion_privacy_options,
     :members_can_add_members, :members_can_announce, :members_can_edit_discussions, :members_can_edit_comments, :motions_can_be_edited,
     :description, :is_visible_to_parent_members, :parent_members_can_see_discussions,
     :membership_granted_upon, :cover_photo, :logo, :category_id, :members_can_raise_motions,
     :members_can_vote,  :members_can_start_discussions, :members_can_create_subgroups,
     :document_ids, {document_ids: []}, :features, {features: AppConfig.group_features.presence || {}}
   ]
  end

  def announcement_attributes
    [:kind, :recipients, recipients: [{user_ids: []}, {emails: []}]]
  end

  def group_identity_attributes
    [:group_id, :identity_type, :make_announcement, :custom_fields, custom_fields: [:slack_channel_name, :slack_channel_id]]
  end

  def discussion_attributes
    [:title, :description, :group_id, :private,
     :forked_event_ids, {forked_event_ids: []},
     :document_ids, {document_ids: []}
    ]
  end

  def comment_attributes
    [:body, :body_format, :discussion_id, :parent_id, :document_ids, {document_ids: []}, files: []]
  end

  def reaction_attributes
    [:reaction, :reactable_id, :reactable_type]
  end

  def contact_message_attributes
    [:email, :subject, :user_id, :message, :name]
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

  def contact_request_attributes
    [:recipient_id, :message]
  end

  def document_attributes
    [:url, :title, :model_id, :model_type, :file, :filename]
  end
end
