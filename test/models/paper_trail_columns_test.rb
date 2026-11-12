require "test_helper"

# Every column of a versioned model is either tracked by PaperTrail or listed
# here with the reason it is not. A new column fails this test until someone
# decides. Versions of discussions, polls, stances, outcomes, comments and
# groups appear in revision history, so tracking a column there is visible.
class PaperTrailColumnsTest < ActiveSupport::TestCase
  BOOKKEEPING = %w[id created_at updated_at].freeze

  UNTRACKED = {
    Comment => {
      derived: %w[content_locale edited_at link_previews versions_count],
      structure: %w[parent_id parent_type]
    },
    Discussion => {
      derived: %w[content_locale context_changed_at link_previews versions_count info key],
      structure: %w[topic_id template discussion_template_id discussion_template_key],
      on_topic: %w[discarded_at discarded_by]
    },
    DiscussionTemplate => {
      derived: %w[content_locale key link_previews position],
      structure: %w[author_id source_discussion_id hider_id discarded_by],
      settings: %w[allow_comments allow_reactions default_to_direct_discussion max_depth newest_first
                   poll_template_keys_or_ids polls_one_at_a_time recipient_audience title_placeholder]
    },
    Group => {
      counters: %w[admin_memberships_count discussions_count memberships_count org_members_count
                   pending_memberships_count poll_templates_count polls_count],
      derived: %w[content_locale full_name info link_previews],
      secret: %w[token],
      profile: %w[admin_tags category city country region request_to_join_prompt theme_id]
    },
    Membership => {
      secret: %w[token],
      derived: %w[experiences],
      # Recorded by WeightHistory because update_all bypasses PaperTrail.
      bulk_updated: %w[weight]
    },
    Outcome => {
      derived: %w[content_locale latest link_previews versions_count],
      structure: %w[poll_id custom_fields]
    },
    Poll => {
      counters: %w[versions_count vote_count_eligible vote_count_none_of_the_above vote_count_uncast],
      derived: %w[content_locale custom_fields key link_previews scores_by_option],
      structure: %w[topic_id template poll_template_id poll_template_key],
      schedule: %w[opened_at default_duration_in_days],
      settings: %w[chart_type limit_reason_length poll_option_name_format process_name process_subtitle
                   process_url reason_prompt shuffle_options]
    },
    PollTemplate => {
      derived: %w[content_locale key link_previews position],
      structure: %w[author_id hider_id discarded_by public],
      settings: %w[agree_target allow_comments allow_reactions outcome_review_due_in_days outcome_statement
                   outcome_statement_format poll_option_name_format quorum_pct stv_method stv_quota stv_seats
                   title_placeholder]
    },
    Stance => {
      derived: %w[content_locale latest link_previews versions_count reason_format],
      secret: %w[token],
      structure: %w[poll_id participant_id accepted_at cast_at],
      # Recorded by WeightHistory, outside the vote's revision history.
      bulk_updated: %w[weight]
    },
    Topic => {
      counters: %w[active_polls_count items_count last_activity_at seen_by_count ranges_string has_tagged_replies],
      structure: %w[topicable_id topicable_type tags],
      display: %w[comment_length_max max_depth newest_first pinned_at polls_one_at_a_time]
    },
    User => {
      secret: %w[api_key email_api_key password_digest secret_token unsubscribe_token webauthn_id email_sha256 key],
      sign_in: %w[current_sign_in_at current_sign_in_ip failed_attempts last_seen_at last_sign_in_at
                  last_sign_in_ip sign_in_count legal_accepted_at],
      counters: %w[memberships_count],
      derived: %w[content_locale detected_locale experiences link_previews avatar_initials],
      preferences: %w[auto_translate autodetect_time_zone avatar_kind date_time_pref email_catch_up_day
                      selected_locale time_zone volume_email_default volume_push_default],
      profile: %w[attachments city country location region short_bio short_bio_format]
    }
  }.freeze

  UNTRACKED.each do |model, groups|
    test "#{model.name} decides whether each column is versioned" do
      tracked = model.paper_trail_options.fetch(:only).map(&:to_s)
      untracked = groups.values.flatten

      assert_empty tracked - model.attribute_names, "#{model.name} tracks names that are not attributes"
      assert_empty tracked & untracked, "#{model.name} lists tracked columns as untracked"
      assert_empty untracked - model.column_names, "#{model.name} lists columns that no longer exist"
      assert_empty model.column_names - BOOKKEEPING - tracked - untracked,
                   "#{model.name} has new columns: track them in has_paper_trail or list them here"
    end
  end

  test "every model with versions is covered" do
    Rails.application.eager_load!
    versioned = ApplicationRecord.descendants.select do |m|
      m.base_class == m && m.respond_to?(:paper_trail_options) && m.paper_trail_options[:only].present?
    end
    assert_empty versioned.map(&:name).sort - UNTRACKED.keys.map(&:name).sort
  end
end
