class PermittedParams < Struct.new(:params)
  MODELS = %w(
    user group membership_request membership poll outcome
    stance discussion discussion_reader comment
    contact_message announcement document
    webhook contact_request reaction tag group_survey
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
     :remember_me, :uploaded_avatar, :username, :short_bio, :short_bio_format, :location,
     :time_zone, :selected_locale, :email_when_mentioned, :default_membership_volume,
     :email_catch_up_day, :has_password, :has_token, :email_status,
     :email_when_proposal_closing_soon, :email_new_discussions_and_proposals, :email_on_participation, :email_newsletter,
     :legal_accepted, {email_new_discussions_and_proposals_group_ids: []},
     :link_previews, :files, :image_files, {link_previews: [:image, :title, :description, :url, :hostname, :fit, :align]}, {files: []}, {image_files: []}
   ]
  end

  def poll_attributes
    [ :title, :details, :details_format, :poll_type, :discussion_id, :group_id,
      :closing_at, :anonymous, :hide_results_until_closed, :multiple_choice, :key,
      :allow_long_reason,
      :shuffle_options,
      :anyone_can_participate,
      :notify_on_closing_soon,
      :voter_can_add_options,
      :specified_voters_only,
      :recipient_audience,
      :recipient_message,
      :tag_ids, {tag_ids: []},
      :notify_recipients,
      :recipient_user_ids, {recipient_user_ids: []},
      :recipient_emails, {recipient_emails: []},
      :custom_fields, {custom_fields: [:can_respond_maybe, :dots_per_person, :max_score,
                                       :min_score, :time_zone, :meeting_duration,
                                       :minimum_stance_choices, :pending_emails, {pending_emails: []}]},
      :document_ids, {document_ids: []},
      :poll_option_names, {poll_option_names: []},
      :options, {options: []},
      :link_previews, :files, :image_files, {link_previews: [:image, :title, :description, :url, :hostname, :fit, :align]}, {files: []}, {image_files: []}
   ]
  end

  def stance_attributes
    [:poll_id, :reason, :reason_format,
     :stance_choices_attributes, {stance_choices_attributes: [:score, :poll_option_id]},
     :link_previews, :files, :image_files, {link_previews: [:image, :title, :description, :url, :hostname, :fit, :align]}, {files: []}, {image_files: []}
   ]
  end

  def stance_choice_attributes
    [:score, :poll_option_id, :stance_id]
  end

  def outcome_attributes
    [:statement, :statement_format, :poll_id, :poll_option_id, :review_on, :recipient_audience, :include_actor,
     :notify_recipients,
     :recipient_user_ids, {recipient_user_ids: []},
     :recipient_emails, {recipient_emails: []},
     :document_ids, {document_ids: []},
     :custom_fields, {custom_fields: [:event_location, :event_summary, :event_description, :should_send_calendar_invite]},
     :link_previews, :files, :image_files, {link_previews: [:image, :title, :description, :url, :hostname, :fit, :align]}, {files: []}, {image_files: []}
   ]
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

  def group_attributes
    [:parent_id, :name, :handle, :group_privacy, :is_visible_to_public, :discussion_privacy_options,
     :members_can_add_members, :members_can_add_guests, :members_can_announce,
     :members_can_edit_discussions, :members_can_edit_comments, :members_can_delete_comments,
     :description, :description_format, :is_visible_to_parent_members, :parent_members_can_see_discussions,
     :membership_granted_upon, :cover_photo, :logo, :category_id, :members_can_raise_motions,
     :members_can_start_discussions, :members_can_create_subgroups, :admins_can_edit_user_content,
     :new_threads_max_depth, :new_threads_newest_first,
     :document_ids, {document_ids: []}, :features, {features: AppConfig.group_features.presence || {}},
     :link_previews, :files, :image_files, {link_previews: [:image, :title, :description, :url, :hostname, :fit, :align]}, {files: []}, {image_files: []}
   ]
  end

  def announcement_attributes
    [:kind, :message, :recipients, {recipients: [:audience, {user_ids: []}, {emails: []}]}, :invited_group_ids, {invited_group_ids: []}]
  end

  def webhook_attributes
   [:group_id, :url, :name, :format, :include_body, :include_subgroups, :permissions, :event_kinds, {event_kinds: [], permissions: []}]
  end

  def discussion_attributes
    [:title, :description, :description_format, :group_id,
      :newest_first, :max_depth, :private,
     :notify_recipients,
     :recipient_audience,
     :recipient_message,
     :tag_ids, {tag_ids: []},
     :recipient_user_ids, {recipient_user_ids: []},
     :recipient_emails, {recipient_emails: []},
     :forked_event_ids, {forked_event_ids: []},
     :document_ids, {document_ids: []},
     :link_previews, :files, :image_files, {link_previews: [:image, :title, :description, :url, :hostname, :fit, :align]}, {files: []}, {image_files: []}
    ]
  end

  def tag_attributes
    [:name, :color, :group_id]
  end

  def comment_attributes
    [:body, :body_format, :discussion_id, :parent_id,
      :document_ids, {document_ids: []},
      :link_previews, {link_previews: [:image, :title, :description, :url, :hostname, :fit, :align]},
      :files, {files: []},
      :image_files, {image_files: []}]
  end

  def reaction_attributes
    [:reaction, :reactable_id, :reactable_type]
  end

  def contact_message_attributes
    [:email, :subject, :user_id, :message, :name]
  end

  def contact_request_attributes
    [:recipient_id, :message]
  end

  def document_attributes
    [:url, :title, :model_id, :model_type, :file, :filename]
  end

  def group_survey_attributes
    [:group_id, :declaration, :category, :segment, :location, :size, :purpose, :referrer, :role, :website, :misc, :usage, :desired_feature]
  end
end
