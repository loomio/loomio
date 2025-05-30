class PermittedParams < Struct.new(:params)
  MODELS = %w(
    user group membership_request membership poll poll_template outcome
    stance discussion discussion_template discussion_reader comment
    contact_message document
    webhook chatbot contact_request reaction tag
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
     :autodetect_time_zone, :time_zone, :selected_locale, :email_when_mentioned, :default_membership_volume,
     :email_catch_up_day, :has_password, :has_token, :email_status,
     :email_when_proposal_closing_soon, :email_new_discussions_and_proposals, :email_on_participation, :email_newsletter,
     :date_time_pref, :bot,
     :legal_accepted, {email_new_discussions_and_proposals_group_ids: []},
     :link_previews, :files, :image_files, {link_previews: [:image, :title, :description, :url, :hostname, :fit, :align]}, {files: []}, {image_files: []}
   ]
  end

  def poll_attributes
    [
      :agree_target,
      :title,
      :details,
      :details_format,
      :discussion_id,
      :default_duration_in_days,
      :poll_type,
      :group_id,
      :closing_at,
      :anonymous,
      :hide_results,
      :key,
      :limit_reason_length,
      :shuffle_options,
      :show_none_of_the_above,
      :notify_on_closing_soon,
      :voter_can_add_options,
      :specified_voters_only,
      :recipient_audience,
      :recipient_message,
      :tags, {tags: []},
      :notify_recipients,
      :recipient_user_ids, {recipient_user_ids: []},
      :recipient_chatbot_ids, {recipient_chatbot_ids: []},
      :recipient_emails, {recipient_emails: []},
      :can_respond_maybe,
      :dots_per_person,
      :max_score,
      :min_score,
      :options, {options: []},
      :process_name,
      :process_subtitle,
      :poll_option_name_format,
      :reason_prompt,
      :template,
      :time_zone,
      :stance_reason_required,
      :meeting_duration,
      :minimum_stance_choices,
      :maximum_stance_choices,
      :chart_type,
      :document_ids, {document_ids: []},
      :poll_template_id,
      :poll_template_key,
      :poll_options_attributes, {poll_options_attributes: [:id, :name, :icon, :meaning, :prompt, :priority, :_destroy]},
      :link_previews, :files, :image_files, {link_previews: [:image, :title, :description, :url, :hostname, :fit, :align]}, {files: []}, {image_files: []}
    ]
  end

  def poll_template_attributes
    [
      :key,
      :group_id,
      :position,
      :author_id,
      :poll_type,
      :process_name,
      :process_subtitle,
      :process_introduction,
      :process_introduction_format,
      :title,
      :title_placeholder,
      :details,
      :details_format,
      :notify_on_participate,
      :anonymous,
      :specified_voters_only,
      :notify_on_closing_soon,
      :content_locale,
      :shuffle_options,
      :show_none_of_the_above,
      :hide_results,
      :chart_type,
      :min_score,
      :max_score,
      :minimum_stance_choices,
      :maximum_stance_choices,
      :dots_per_person,
      :reason_prompt,
      :tags, {tags: []},
      :poll_options, {poll_options: [:name, :icon, :meaning, :prompt, :priority]},
      :stance_reason_required,
      :limit_reason_length,
      :default_duration_in_days,
      :agree_target,
      :meeting_duration,
      :can_respond_maybe,
      :poll_option_name_format,
      :outcome_statement,
      :outcome_statement_format,
      :outcome_review_due_in_days,
      :link_previews, :files, :image_files, {link_previews: [:image, :title, :description, :url, :hostname, :fit, :align]}, {files: []}, {image_files: []}
    ]
  end

  def stance_attributes
    [:poll_id, :reason, :reason_format, :none_of_the_above,
     :stance_choices_attributes, {stance_choices_attributes: [:score, :poll_option_id]},
     :link_previews, :files, :image_files, {link_previews: [:image, :title, :description, :url, :hostname, :fit, :align]}, {files: []}, {image_files: []}
   ]
  end

  def stance_choice_attributes
    [:score, :poll_option_id, :stance_id]
  end

  def outcome_attributes
    [:statement, :statement_format, :poll_id, :poll_option_id, :review_on, :recipient_audience, :include_actor,
     :event_location, :event_summary, :event_description,
     :notify_recipients,
     :recipient_user_ids, {recipient_user_ids: []},
     :recipient_chatbot_ids, {recipient_chatbot_ids: []},
     :recipient_emails, {recipient_emails: []},
     :document_ids, {document_ids: []},
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
     :membership_granted_upon, :cover_photo, :logo, :category, :members_can_raise_motions,
     :members_can_start_discussions, :members_can_create_subgroups, :admins_can_edit_user_content,
     :new_threads_max_depth, :new_threads_newest_first, :request_to_join_prompt,
     :document_ids, {document_ids: []},
     :link_previews, :files, :image_files, {link_previews: [:image, :title, :description, :url, :hostname, :fit, :align]}, {files: []}, {image_files: []}
   ]
  end

  def webhook_attributes
   [:group_id, :url, :name, :format, :include_body, :include_subgroups, :permissions, :event_kinds, {event_kinds: [], permissions: []}]
  end

  def chatbot_attributes
   [:name, :group_id, :kind, :webhook_kind, :server, :access_token, :channel, :notification_only, :event_kinds, {event_kinds: []}]
  end

  def discussion_attributes
    [:title,
     :description,
     :description_format,
     :discussion_template_id,
     :discussion_template_key,
     :group_id,
     :newest_first,
     :max_depth,
     :private,
     :notify_recipients,
     :recipient_audience,
     :recipient_message,
     :tags, {tags: []},
     :recipient_user_ids, {recipient_user_ids: []},
     :recipient_chatbot_ids, {recipient_chatbot_ids: []},
     :recipient_emails, {recipient_emails: []},
     :forked_event_ids, {forked_event_ids: []},
     :document_ids, {document_ids: []},
     :link_previews, :files, :image_files, {link_previews: [:image, :title, :description, :url, :hostname, :fit, :align]}, {files: []}, {image_files: []}
    ]
  end

  def discussion_template_attributes
    [
     :key,
     :title,
     :title_placeholder,
     :description,
     :description_format,
     :process_name,
     :process_subtitle,
     :process_introduction,
     :process_introduction_format,
     :recipient_audience,
     :group_id,
     :newest_first,
     :max_depth,
     :public,
     :poll_template_keys_or_ids, {poll_template_keys_or_ids: []},
     :tags, {tags: []},
     :link_previews, :files, :image_files, {link_previews: [:image, :title, :description, :url, :hostname, :fit, :align]}, {files: []}, {image_files: []}
    ]
  end

  def tag_attributes
    [:name, :color, :group_id, :priority]
  end

  def comment_attributes
    [:body, :body_format, :discussion_id, :parent_id, :parent_type,
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
end
