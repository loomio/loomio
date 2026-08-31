# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_31_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "hstore"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"

  create_table "action_mailbox_inbound_emails", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "message_checksum", null: false
    t.string "message_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.bigint "author_id"
    t.string "author_type"
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.string "namespace"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "group_id"
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["group_id"], name: "index_active_storage_attachments_on_group_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["id"], name: "active_storage_blobs_idx", unique: true
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "anonymous_ballot_choices", id: false, force: :cascade do |t|
    t.uuid "anonymous_ballot_id", null: false
    t.bigint "poll_option_id", null: false
    t.integer "score", default: 1, null: false
    t.index ["anonymous_ballot_id", "poll_option_id"], name: "index_anonymous_ballot_choices_on_ballot_and_option", unique: true
    t.index ["anonymous_ballot_id"], name: "index_anonymous_ballot_choices_on_anonymous_ballot_id"
    t.index ["poll_option_id"], name: "index_anonymous_ballot_choices_on_poll_option_id"
  end

  add_check_constraint "anonymous_ballot_choices", "score >= 0", name: "anonymous_ballot_choices_score_nonnegative", validate: false

  create_table "anonymous_ballots", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "none_of_the_above", default: false, null: false
    t.bigint "poll_id", null: false
    t.index ["poll_id"], name: "index_anonymous_ballots_on_poll_id"
  end

  create_table "anonymous_poll_voters", force: :cascade do |t|
    t.boolean "ballot_submitted", default: false, null: false
    t.boolean "group_member", default: false
    t.bigint "inviter_id"
    t.bigint "poll_id", null: false
    t.bigint "voter_id", null: false
    t.index ["inviter_id"], name: "index_anonymous_poll_voters_on_inviter_id"
    t.index ["poll_id", "voter_id"], name: "index_anonymous_poll_voters_on_poll_id_and_voter_id", unique: true
    t.index ["poll_id"], name: "index_anonymous_poll_voters_on_poll_id"
    t.index ["voter_id"], name: "index_anonymous_poll_voters_on_voter_id"
  end

  create_table "attachments", id: :serial, force: :cascade do |t|
    t.integer "attachable_id"
    t.string "attachable_type"
    t.integer "comment_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "file_content_type"
    t.string "file_file_name"
    t.integer "file_file_size"
    t.datetime "file_updated_at", precision: nil
    t.string "filename", limit: 255
    t.integer "filesize"
    t.text "location"
    t.boolean "migrated_to_document", default: false, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["attachable_id", "attachable_type"], name: "index_attachments_on_attachable_id_and_attachable_type"
    t.index ["comment_id"], name: "index_attachments_on_comment_id"
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "data_source"
    t.bigint "query_id"
    t.text "statement"
    t.bigint "user_id"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.string "check_type"
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.text "emails"
    t.datetime "last_run_at", precision: nil
    t.text "message"
    t.bigint "query_id"
    t.string "schedule"
    t.text "slack_channels"
    t.string "state"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "dashboard_id"
    t.integer "position"
    t.bigint "query_id"
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.string "data_source"
    t.text "description"
    t.string "name"
    t.text "statement"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "blocked_domains", force: :cascade do |t|
    t.string "name"
    t.index ["name"], name: "index_blocked_domains_on_name", unique: true
  end

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "bookmarkable_id", null: false
    t.string "bookmarkable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["bookmarkable_type", "bookmarkable_id"], name: "index_bookmarks_on_bookmarkable"
    t.index ["discarded_at"], name: "index_bookmarks_on_discarded_at"
    t.index ["user_id", "bookmarkable_type", "bookmarkable_id"], name: "index_bookmarks_on_user_and_bookmarkable", unique: true
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "chatbots", force: :cascade do |t|
    t.string "access_token"
    t.integer "author_id"
    t.string "channel"
    t.datetime "created_at", null: false
    t.string "event_kinds", array: true
    t.integer "group_id"
    t.string "kind"
    t.string "name"
    t.boolean "notification_only", default: false, null: false
    t.string "server"
    t.datetime "updated_at", null: false
    t.string "webhook_kind"
    t.index ["group_id"], name: "index_chatbots_on_group_id"
  end

  create_table "cohorts", id: :serial, force: :cascade do |t|
    t.date "end_on"
    t.date "start_on"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.jsonb "attachments", default: [], null: false
    t.integer "attachments_count", default: 0, null: false
    t.text "body", default: ""
    t.string "body_format", limit: 10, default: "md", null: false
    t.integer "comment_votes_count", default: 0, null: false
    t.string "content_locale"
    t.datetime "created_at", precision: nil
    t.datetime "discarded_at", precision: nil
    t.integer "discarded_by"
    t.datetime "edited_at", precision: nil
    t.jsonb "link_previews", default: [], null: false
    t.integer "parent_id"
    t.string "parent_type", null: false
    t.datetime "updated_at", precision: nil
    t.integer "user_id", default: 0
    t.integer "versions_count", default: 0
    t.index ["created_at"], name: "index_comments_on_created_at"
    t.index ["parent_type", "parent_id"], name: "index_comments_on_parent_type_and_parent_id"
  end

  create_table "default_group_covers", id: :serial, force: :cascade do |t|
    t.string "cover_photo_content_type"
    t.string "cover_photo_file_name"
    t.integer "cover_photo_file_size"
    t.datetime "cover_photo_updated_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "demos", force: :cascade do |t|
    t.integer "author_id", null: false
    t.datetime "created_at", null: false
    t.string "demo_handle"
    t.string "description"
    t.integer "group_id", null: false
    t.string "name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "recorded_at", precision: nil, null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_demos_on_author_id"
  end

  create_table "discussion_templates", force: :cascade do |t|
    t.boolean "allow_comments", default: true, null: false
    t.boolean "allow_concurrent_polls", default: false, null: false
    t.boolean "allow_reactions", default: true, null: false
    t.jsonb "attachments", default: [], null: false
    t.integer "author_id"
    t.integer "comment_length_max"
    t.string "content_locale"
    t.datetime "created_at", null: false
    t.boolean "default_to_direct_discussion", default: false, null: false
    t.text "description"
    t.string "description_format", limit: 10, default: "html", null: false
    t.datetime "discarded_at", precision: nil
    t.integer "discarded_by"
    t.integer "group_id"
    t.string "key"
    t.jsonb "link_previews", default: [], null: false
    t.integer "max_depth", default: 2, null: false
    t.boolean "newest_first", default: false, null: false
    t.jsonb "poll_template_keys_or_ids", default: [], null: false
    t.integer "position"
    t.string "process_introduction"
    t.string "process_introduction_format", default: "html", null: false
    t.string "process_name"
    t.string "process_subtitle"
    t.boolean "public", default: false, null: false
    t.string "recipient_audience"
    t.integer "source_discussion_id"
    t.string "tags", default: [], array: true
    t.string "title"
    t.string "title_placeholder"
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_discussion_templates_on_discarded_at"
  end

  create_table "discussions", id: :serial, force: :cascade do |t|
    t.jsonb "attachments", default: [], null: false
    t.integer "author_id"
    t.string "content_locale"
    t.datetime "created_at", precision: nil
    t.text "description"
    t.string "description_format", limit: 10, default: "md", null: false
    t.datetime "discarded_at", precision: nil
    t.integer "discarded_by"
    t.integer "discussion_template_id"
    t.string "discussion_template_key"
    t.string "iframe_src", limit: 255
    t.integer "importance", default: 0, null: false
    t.jsonb "info", default: {}, null: false
    t.string "key", limit: 255
    t.datetime "last_comment_at", precision: nil
    t.jsonb "link_previews", default: [], null: false
    t.string "tags", default: [], array: true
    t.boolean "template", default: false, null: false
    t.string "title", limit: 255
    t.integer "topic_id"
    t.datetime "updated_at", precision: nil
    t.integer "versions_count", default: 0
    t.index ["author_id"], name: "index_discussions_on_author_id"
    t.index ["created_at"], name: "index_discussions_on_created_at"
    t.index ["discarded_at"], name: "index_discussions_on_discarded_at", where: "(discarded_at IS NULL)"
    t.index ["key"], name: "index_discussions_on_key", unique: true
    t.index ["tags"], name: "index_discussions_on_tags", using: :gin
    t.index ["template"], name: "index_discussions_on_template", where: "(template IS TRUE)"
    t.index ["topic_id"], name: "index_discussions_on_topic_id"
  end

  create_table "forward_email_rules", force: :cascade do |t|
    t.string "email"
    t.citext "handle", null: false
  end

  create_table "group_handle_redirects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.citext "handle", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "handle"], name: "index_group_handle_redirects_on_group_id_and_handle", unique: true
    t.index ["group_id"], name: "index_group_handle_redirects_on_group_id"
    t.index ["handle"], name: "index_group_handle_redirects_on_handle", unique: true
  end

  create_table "group_identities", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.jsonb "custom_fields", default: {}, null: false
    t.integer "group_id", null: false
    t.integer "identity_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["group_id"], name: "index_group_identities_on_group_id"
    t.index ["identity_id"], name: "index_group_identities_on_identity_id"
  end

  create_table "group_surveys", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", precision: nil, null: false
    t.string "declaration"
    t.string "desired_feature"
    t.integer "group_id", null: false
    t.string "location"
    t.text "misc"
    t.text "purpose"
    t.string "referrer"
    t.string "role"
    t.string "segment"
    t.string "size"
    t.datetime "updated_at", precision: nil, null: false
    t.string "usage"
    t.string "website"
    t.index ["group_id"], name: "index_group_surveys_on_group_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.integer "admin_memberships_count", default: 0, null: false
    t.string "admin_tags"
    t.boolean "admins_can_edit_user_content", default: true, null: false
    t.datetime "archived_at", precision: nil
    t.jsonb "attachments", default: [], null: false
    t.string "category"
    t.integer "category_id"
    t.string "city"
    t.integer "closed_motions_count", default: 0, null: false
    t.integer "closed_polls_count", default: 0, null: false
    t.integer "cohort_id"
    t.string "content_locale"
    t.string "country"
    t.string "cover_photo_content_type", limit: 255
    t.string "cover_photo_file_name", limit: 255
    t.integer "cover_photo_file_size"
    t.datetime "cover_photo_updated_at", precision: nil
    t.datetime "created_at", precision: nil
    t.integer "creator_id"
    t.integer "default_group_cover_id"
    t.integer "delegates_count", default: 0, null: false
    t.text "description"
    t.string "description_format", limit: 10, default: "md", null: false
    t.string "discussion_privacy_options", default: "private_only", null: false
    t.integer "discussion_templates_count", default: 0, null: false
    t.integer "discussions_count", default: 0, null: false
    t.string "full_name", limit: 255
    t.citext "handle"
    t.jsonb "info", default: {}, null: false
    t.integer "invitations_count", default: 0, null: false
    t.boolean "is_referral", default: false, null: false
    t.boolean "is_visible_to_parent_members", default: false, null: false
    t.boolean "is_visible_to_public", default: true, null: false
    t.string "key", limit: 255
    t.jsonb "link_previews", default: [], null: false
    t.boolean "listed_in_explore", default: false, null: false
    t.string "logo_content_type", limit: 255
    t.string "logo_file_name", limit: 255
    t.integer "logo_file_size"
    t.datetime "logo_updated_at", precision: nil
    t.boolean "members_can_add_guests", default: true, null: false
    t.boolean "members_can_add_members", default: false, null: false
    t.boolean "members_can_announce", default: true, null: false
    t.boolean "members_can_create_subgroups", default: false, null: false
    t.boolean "members_can_create_tags", default: true, null: false
    t.boolean "members_can_create_templates", default: false, null: false
    t.boolean "members_can_delete_comments", default: true, null: false
    t.boolean "members_can_edit_comments", default: true
    t.boolean "members_can_edit_discussions", default: true, null: false
    t.boolean "members_can_raise_motions", default: true, null: false
    t.boolean "members_can_start_discussions", default: true, null: false
    t.boolean "members_can_vote", default: true, null: false
    t.string "membership_granted_upon", default: "approval", null: false
    t.integer "memberships_count", default: 0, null: false
    t.string "name", limit: 255
    t.integer "org_members_count", default: 0, null: false
    t.integer "parent_id"
    t.boolean "parent_members_can_see_discussions", default: false, null: false
    t.integer "pending_memberships_count", default: 0, null: false
    t.integer "poll_templates_count", default: 0, null: false
    t.integer "polls_count", default: 0, null: false
    t.integer "proposal_outcomes_count", default: 0, null: false
    t.string "region"
    t.string "request_to_join_prompt"
    t.integer "subgroups_count", default: 0, null: false
    t.integer "subscription_id"
    t.integer "theme_id"
    t.string "token"
    t.datetime "updated_at", precision: nil
    t.index ["archived_at"], name: "index_groups_on_archived_at", where: "(archived_at IS NULL)"
    t.index ["created_at"], name: "index_groups_on_created_at"
    t.index ["full_name"], name: "index_groups_on_full_name"
    t.index ["handle"], name: "index_groups_on_handle", unique: true
    t.index ["key"], name: "index_groups_on_key", unique: true
    t.index ["name"], name: "index_groups_on_name"
    t.index ["parent_id"], name: "index_groups_on_parent_id"
    t.index ["subscription_id"], name: "groups_subscription_id_idx"
    t.index ["token"], name: "index_groups_on_token", unique: true
  end

  create_table "legacy_anonymous_vote_reasons", primary_key: "anonymous_ballot_id", id: :uuid, default: nil, force: :cascade do |t|
    t.text "body", null: false
  end

  create_table "login_tokens", id: :serial, force: :cascade do |t|
    t.integer "code", null: false
    t.datetime "created_at", precision: nil
    t.integer "failed_attempts", default: 0, null: false
    t.boolean "is_reactivation", default: false, null: false
    t.string "redirect"
    t.string "token"
    t.datetime "updated_at", precision: nil
    t.boolean "used", default: false, null: false
    t.integer "user_id"
    t.index ["token"], name: "index_login_tokens_on_token"
  end

  create_table "member_email_aliases", force: :cascade do |t|
    t.integer "author_id", null: false
    t.datetime "created_at", null: false
    t.citext "email", null: false
    t.integer "group_id", null: false
    t.boolean "require_dkim", default: true, null: false
    t.boolean "require_spf", default: true, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["email", "group_id"], name: "index_member_email_aliases_on_email_and_group_id", unique: true
  end

  create_table "membership_requests", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "email", limit: 255
    t.integer "group_id"
    t.text "introduction"
    t.string "name", limit: 255
    t.integer "requestor_id"
    t.datetime "responded_at", precision: nil
    t.integer "responder_id"
    t.string "response", limit: 255
    t.datetime "updated_at", precision: nil, null: false
    t.index ["group_id"], name: "index_membership_requests_on_group_id"
    t.index ["requestor_id"], name: "index_membership_requests_on_requestor_id"
    t.index ["responder_id"], name: "index_membership_requests_on_responder_id"
  end

  create_table "memberships", id: :serial, force: :cascade do |t|
    t.datetime "accepted_at", precision: nil
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", precision: nil
    t.boolean "delegate", default: false, null: false
    t.jsonb "experiences", default: {}, null: false
    t.integer "group_id"
    t.integer "inbox_position", default: 0
    t.integer "invitation_id"
    t.integer "inviter_id"
    t.datetime "revoked_at", precision: nil
    t.integer "revoker_id"
    t.datetime "saml_session_expires_at", precision: nil
    t.string "title"
    t.string "token"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.integer "volume"
    t.index ["created_at"], name: "index_memberships_on_created_at"
    t.index ["group_id", "user_id"], name: "index_memberships_on_group_id_and_user_id", unique: true
    t.index ["inviter_id"], name: "index_memberships_on_inviter_id"
    t.index ["revoked_at", "id"], name: "index_memberships_on_revoked_at_and_id_for_relay", where: "(revoked_at IS NOT NULL)"
    t.index ["token"], name: "index_memberships_on_token", unique: true
    t.index ["user_id", "volume"], name: "index_memberships_on_user_id_and_volume"
    t.index ["volume"], name: "index_memberships_on_volume"
  end

  create_table "notification_deliveries", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.datetime "available_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "channel", null: false
    t.datetime "claimed_at"
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.datetime "last_attempt_at"
    t.text "last_error"
    t.datetime "next_attempt_at"
    t.bigint "notification_id", null: false
    t.string "provider_message_id"
    t.bigint "recipient_id", null: false
    t.string "recipient_type", null: false
    t.string "status", default: "pending", null: false
    t.jsonb "translation_values", default: {}, null: false
    t.datetime "updated_at", null: false
    t.datetime "viewed_at"
    t.index ["notification_id", "channel", "recipient_type", "recipient_id"], name: "index_notification_deliveries_on_identity", unique: true
    t.index ["notification_id"], name: "index_notification_deliveries_on_notification_id"
    t.index ["recipient_type", "recipient_id"], name: "index_notification_deliveries_on_recipient"
    t.index ["status", "available_at"], name: "index_notification_deliveries_on_status_and_available_at"
    t.check_constraint "attempt_count >= 0", name: "notification_deliveries_attempt_count"
    t.check_constraint "channel::text = ANY (ARRAY['in_app'::character varying, 'email'::character varying, 'push'::character varying, 'chatbot'::character varying]::text[])", name: "notification_deliveries_channel"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'claimed'::character varying, 'delivered'::character varying, 'failed'::character varying, 'cancelled'::character varying]::text[])", name: "notification_deliveries_status"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "actor_id"
    t.jsonb "audience_values", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "deliveries_generated_at"
    t.string "kind", null: false
    t.integer "recipient_chatbot_ids", default: [], null: false, array: true
    t.text "recipient_message"
    t.integer "recipient_user_ids", default: [], null: false, array: true
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.jsonb "translation_values", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_notifications_on_pending_delivery_resolution", where: "(deliveries_generated_at IS NULL)"
    t.index ["subject_type", "subject_id"], name: "index_notifications_on_subject"
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "application_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.integer "resource_owner_id", null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.string "token", null: false
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "application_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "expires_in"
    t.string "refresh_token"
    t.integer "resource_owner_id"
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.string "token", null: false
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "logo_content_type"
    t.string "logo_file_name"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at", precision: nil
    t.string "name", null: false
    t.integer "owner_id"
    t.string "owner_type"
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.string "secret", null: false
    t.string "uid", null: false
    t.datetime "updated_at", precision: nil
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "omniauth_identities", id: :serial, force: :cascade do |t|
    t.string "access_token", default: ""
    t.datetime "created_at", precision: nil, null: false
    t.jsonb "custom_fields", default: {}, null: false
    t.string "email", limit: 255
    t.string "identity_type", limit: 255
    t.string "logo"
    t.string "name", limit: 255
    t.string "uid", limit: 255
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["email"], name: "index_personas_on_email"
    t.index ["identity_type", "uid"], name: "index_omniauth_identities_on_identity_type_and_uid", unique: true
    t.index ["user_id"], name: "index_personas_on_user_id"
  end

  create_table "outcomes", id: :serial, force: :cascade do |t|
    t.jsonb "attachments", default: [], null: false
    t.integer "author_id", null: false
    t.string "content_locale"
    t.datetime "created_at", precision: nil
    t.jsonb "custom_fields", default: {}, null: false
    t.boolean "latest", default: true, null: false
    t.jsonb "link_previews", default: [], null: false
    t.integer "poll_id"
    t.integer "poll_option_id"
    t.date "review_on"
    t.text "statement", null: false
    t.string "statement_format", limit: 10, default: "md", null: false
    t.datetime "updated_at", precision: nil
    t.integer "versions_count", default: 0, null: false
    t.index ["created_at"], name: "index_outcomes_on_created_at"
    t.index ["poll_id"], name: "index_outcomes_on_poll_id"
  end

  create_table "partition_sequences", primary_key: ["key", "id"], force: :cascade do |t|
    t.integer "counter", default: 0
    t.integer "id", null: false
    t.text "key", null: false
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.bigint "author_id"
    t.datetime "authored_at"
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "discussion_id"
    t.bigint "group_id"
    t.bigint "poll_id"
    t.bigint "searchable_id"
    t.string "searchable_type"
    t.string "tags", default: [], array: true
    t.bigint "topic_id"
    t.tsvector "ts_content"
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_pg_search_documents_on_author_id"
    t.index ["discussion_id"], name: "index_pg_search_documents_on_discussion_id"
    t.index ["group_id"], name: "index_pg_search_documents_on_group_id"
    t.index ["poll_id"], name: "index_pg_search_documents_on_poll_id"
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
    t.index ["tags"], name: "index_pg_search_documents_on_tags", using: :gin
    t.index ["topic_id"], name: "index_pg_search_documents_on_topic_id"
    t.index ["ts_content"], name: "pg_search_documents_searchable_index", using: :gin
  end

  create_table "pg_search_words", id: false, force: :cascade do |t|
    t.integer "document_count", null: false
    t.text "word", null: false
    t.index ["word"], name: "index_pg_search_words_on_word", unique: true
    t.index ["word"], name: "index_pg_search_words_on_word_trigram", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "poll_options", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "icon"
    t.string "meaning"
    t.string "name", null: false
    t.integer "poll_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "prompt"
    t.jsonb "score_counts", default: {}, null: false
    t.string "test_against"
    t.string "test_operator"
    t.integer "test_percent"
    t.integer "total_score", default: 0, null: false
    t.datetime "updated_at", precision: nil
    t.integer "voter_count", default: 0, null: false
    t.jsonb "voter_scores", default: {}, null: false
    t.index ["poll_id"], name: "index_poll_options_on_poll_id"
  end

  create_table "poll_templates", force: :cascade do |t|
    t.integer "agree_target"
    t.boolean "allow_comments", default: true, null: false
    t.boolean "allow_reactions", default: true, null: false
    t.boolean "anonymous", default: false, null: false
    t.jsonb "atttachments", default: [], null: false
    t.integer "author_id", null: false
    t.boolean "can_respond_maybe", default: true, null: false
    t.string "chart_type"
    t.integer "comment_length_max"
    t.string "content_locale"
    t.datetime "created_at", null: false
    t.integer "default_duration_in_days", default: 7, null: false
    t.text "details"
    t.string "details_format", limit: 10, default: "md", null: false
    t.datetime "discarded_at"
    t.integer "dots_per_person"
    t.integer "group_id", null: false
    t.integer "hide_results", default: 0, null: false
    t.string "key"
    t.boolean "limit_reason_length", default: true, null: false
    t.jsonb "link_previews", default: [], null: false
    t.integer "max_score"
    t.integer "maximum_stance_choices"
    t.integer "meeting_duration"
    t.integer "min_score"
    t.integer "minimum_stance_choices"
    t.integer "notify_on_closing_soon", default: 0, null: false
    t.boolean "notify_on_open", default: true, null: false
    t.integer "outcome_review_due_in_days"
    t.string "outcome_statement"
    t.string "outcome_statement_format", default: "html", null: false
    t.string "poll_option_name_format", default: "plain", null: false
    t.jsonb "poll_options", default: [], null: false
    t.string "poll_type", null: false
    t.integer "position", default: 0, null: false
    t.string "process_introduction"
    t.string "process_introduction_format", default: "md", null: false
    t.string "process_name"
    t.string "process_subtitle"
    t.boolean "public", default: false, null: false
    t.integer "quorum_pct"
    t.string "reason_prompt"
    t.boolean "show_none_of_the_above", default: false, null: false
    t.boolean "shuffle_options", default: false, null: false
    t.boolean "specified_voters_only", default: false, null: false
    t.integer "stance_reason_required", default: 1, null: false
    t.string "tags", default: [], array: true
    t.string "title"
    t.string "title_placeholder"
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_poll_templates_on_discarded_at"
  end

  create_table "polls", id: :serial, force: :cascade do |t|
    t.integer "agree_target"
    t.boolean "anonymous", default: false, null: false
    t.jsonb "attachments", default: [], null: false
    t.integer "author_id", null: false
    t.string "chart_type"
    t.datetime "closed_at", precision: nil
    t.datetime "closing_at", precision: nil
    t.string "content_locale"
    t.datetime "created_at", precision: nil
    t.jsonb "custom_fields", default: {}, null: false
    t.integer "default_duration_in_days"
    t.text "details"
    t.string "details_format", limit: 10, default: "md", null: false
    t.datetime "discarded_at", precision: nil
    t.integer "discarded_by"
    t.integer "dots_per_person"
    t.integer "hide_results", default: 0, null: false
    t.string "key", null: false
    t.boolean "limit_reason_length", default: true, null: false
    t.jsonb "link_previews", default: [], null: false
    t.jsonb "matrix_counts", default: [], null: false
    t.integer "max_score"
    t.integer "maximum_stance_choices"
    t.integer "min_score"
    t.integer "minimum_stance_choices"
    t.boolean "multiple_choice", default: false, null: false
    t.integer "none_of_the_above_count", default: 0, null: false
    t.integer "notify_on_closing_soon", default: 0, null: false
    t.boolean "notify_on_open", default: true, null: false
    t.datetime "opened_at"
    t.datetime "opening_at"
    t.string "poll_option_name_format"
    t.integer "poll_template_id"
    t.string "poll_template_key"
    t.string "poll_type", null: false
    t.string "process_name"
    t.string "process_subtitle"
    t.string "process_url"
    t.integer "quorum_pct"
    t.string "reason_prompt"
    t.boolean "show_none_of_the_above", default: false, null: false
    t.boolean "shuffle_options", default: false, null: false
    t.boolean "specified_voters_only", default: false, null: false
    t.jsonb "stance_counts", default: [], null: false
    t.jsonb "stance_data", default: {}
    t.integer "stance_reason_required", default: 1, null: false
    t.string "stv_method"
    t.string "stv_quota"
    t.integer "stv_seats"
    t.string "tags", default: [], array: true
    t.boolean "template", default: false, null: false
    t.string "title", null: false
    t.integer "topic_id"
    t.integer "undecided_voters_count", default: 0, null: false
    t.datetime "updated_at", precision: nil
    t.integer "versions_count", default: 0
    t.boolean "voter_can_add_options", default: false, null: false
    t.integer "voters_count", default: 0, null: false
    t.integer "voting_system", default: 0, null: false
    t.index ["author_id"], name: "index_polls_on_author_id"
    t.index ["closed_at", "closing_at"], name: "index_polls_on_closed_at_and_closing_at"
    t.index ["closed_at", "topic_id"], name: "index_polls_on_closed_at_and_topic_id"
    t.index ["key"], name: "index_polls_on_key", unique: true
    t.index ["tags"], name: "index_polls_on_tags", using: :gin
    t.index ["topic_id"], name: "index_polls_on_topic_id"
    t.check_constraint "anonymous = true AND voting_system = 1 OR anonymous = false AND voting_system = 0", name: "polls_anonymous_voting_system"
  end

  create_table "reactions", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "reactable_id"
    t.string "reactable_type", default: "Comment", null: false
    t.string "reaction", default: "+1", null: false
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["created_at"], name: "index_reactions_on_created_at"
    t.index ["reactable_id", "reactable_type"], name: "index_reactions_on_reactable_id_and_reactable_type"
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "received_emails", force: :cascade do |t|
    t.string "body_html"
    t.string "body_text"
    t.datetime "created_at", null: false
    t.boolean "dkim_valid", default: false, null: false
    t.integer "group_id"
    t.hstore "headers", default: {}, null: false
    t.string "message_id"
    t.boolean "released", default: false, null: false
    t.boolean "spf_valid", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_received_emails_on_message_id", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.bigint "channel_hash", null: false
    t.datetime "created_at", null: false
    t.binary "payload", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.binary "key", null: false
    t.bigint "key_hash", null: false
    t.binary "value", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "stance_choices", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "poll_option_id", null: false
    t.integer "score", default: 1, null: false
    t.integer "stance_id", null: false
    t.datetime "updated_at", precision: nil
    t.index ["poll_option_id"], name: "index_stance_choices_on_poll_option_id"
    t.index ["stance_id", "poll_option_id"], name: "index_stance_choices_on_stance_id_and_poll_option_id", unique: true
    t.index ["stance_id"], name: "index_stance_choices_on_stance_id"
  end

  add_check_constraint "stance_choices", "score >= 0", name: "stance_choices_score_nonnegative", validate: false

  create_table "stance_receipts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "invited_at"
    t.bigint "inviter_id"
    t.bigint "poll_id"
    t.datetime "updated_at", null: false
    t.boolean "vote_cast"
    t.bigint "voter_id"
  end

  create_table "stances", id: :serial, force: :cascade do |t|
    t.datetime "accepted_at", precision: nil
    t.jsonb "attachments", default: [], null: false
    t.datetime "cast_at", precision: nil
    t.string "content_locale"
    t.datetime "created_at", precision: nil
    t.integer "inviter_id"
    t.boolean "latest", default: true, null: false
    t.jsonb "link_previews", default: [], null: false
    t.boolean "none_of_the_above", default: false, null: false
    t.jsonb "option_scores", default: {}, null: false
    t.integer "participant_id"
    t.integer "poll_id", null: false
    t.string "reason"
    t.string "reason_format", limit: 10, default: "md", null: false
    t.datetime "redacted_at"
    t.integer "redactor_id"
    t.datetime "revoked_at", precision: nil
    t.integer "revoker_id"
    t.string "token"
    t.datetime "updated_at", precision: nil
    t.integer "versions_count", default: 0
    t.index ["cast_at", "id"], name: "index_stances_on_cast_at_and_id_for_relay", where: "((cast_at IS NOT NULL) AND (redacted_at IS NULL))"
    t.index ["created_at"], name: "index_stances_on_created_at"
    t.index ["participant_id"], name: "index_stances_on_participant_id"
    t.index ["poll_id", "cast_at"], name: "index_stances_on_poll_id_and_cast_at", order: "NULLS FIRST"
    t.index ["poll_id", "participant_id", "latest"], name: "index_stances_on_poll_id_and_participant_id_and_latest", unique: true, where: "(latest = true)"
    t.index ["poll_id"], name: "index_stances_on_poll_id"
    t.index ["token"], name: "index_stances_on_token", unique: true
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.datetime "activated_at", precision: nil
    t.boolean "allow_guests", default: true, null: false
    t.boolean "allow_subgroups", default: true, null: false
    t.datetime "canceled_at", precision: nil
    t.integer "chargify_subscription_id"
    t.datetime "created_at", precision: nil
    t.datetime "expires_at", precision: nil
    t.jsonb "info"
    t.string "lead_status"
    t.integer "max_members"
    t.integer "max_orgs"
    t.integer "max_threads"
    t.integer "members_count"
    t.integer "owner_id"
    t.string "payment_method", default: "none", null: false
    t.string "plan", default: "free"
    t.datetime "renewed_at", precision: nil
    t.datetime "renews_at", precision: nil
    t.string "state", default: "active", null: false
    t.datetime "updated_at", precision: nil
    t.index ["expires_at", "id"], name: "index_subscriptions_on_trial_expiry_for_relay", where: "(((plan)::text = 'trial'::text) AND (expires_at IS NOT NULL))"
    t.index ["owner_id"], name: "index_subscriptions_on_owner_id"
    t.index ["plan"], name: "index_subscriptions_on_plan"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "tag_id", null: false
    t.integer "taggable_id", null: false
    t.string "taggable_type", null: false
    t.datetime "updated_at", precision: nil
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", precision: nil
    t.integer "group_id"
    t.citext "name", null: false
    t.integer "org_taggings_count", default: 0, null: false
    t.integer "priority", default: 0, null: false
    t.integer "taggings_count", default: 0, null: false
    t.datetime "updated_at", precision: nil
    t.integer "used_group_ids", default: [], null: false, array: true
    t.index ["group_id", "name"], name: "index_tags_on_group_id_and_name", unique: true
    t.index ["group_id"], name: "index_tags_on_group_id"
    t.index ["name"], name: "index_tags_on_name"
    t.index ["used_group_ids"], name: "index_tags_on_used_group_ids", using: :gin
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at", precision: nil
    t.integer "doer_id"
    t.boolean "done", null: false
    t.datetime "done_at", precision: nil
    t.date "due_on"
    t.string "name", null: false
    t.bigint "record_id"
    t.string "record_type"
    t.integer "remind"
    t.datetime "remind_at", precision: nil
    t.integer "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_tasks_on_author_id"
    t.index ["discarded_at"], name: "index_tasks_on_discarded_at"
    t.index ["done"], name: "index_tasks_on_done"
    t.index ["due_on"], name: "index_tasks_on_due_on"
    t.index ["record_type", "record_id"], name: "index_tasks_on_record_type_and_record_id"
    t.index ["remind_at"], name: "index_tasks_on_remind_at"
  end

  create_table "tasks_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "task_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["task_id"], name: "index_tasks_users_on_task_id"
    t.index ["user_id"], name: "index_tasks_users_on_user_id"
  end

  create_table "topic_items", id: :serial, force: :cascade do |t|
    t.integer "child_count", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.integer "depth", default: 0, null: false
    t.integer "itemable_id", null: false
    t.string "itemable_type", limit: 255, null: false
    t.integer "itemable_version_id"
    t.string "kind", limit: 255, null: false
    t.integer "parent_id"
    t.boolean "pinned", default: false, null: false
    t.text "pinned_title"
    t.integer "position", default: 0, null: false
    t.string "position_key"
    t.integer "sequence_id"
    t.integer "topic_id", null: false
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["created_at"], name: "index_topic_items_on_created_at"
    t.index ["id", "topic_id"], name: "index_topic_items_on_id_and_topic_id", unique: true
    t.index ["itemable_id", "kind"], name: "index_topic_items_on_itemable_id_and_kind"
    t.index ["itemable_type", "itemable_id", "kind"], name: "index_topic_items_on_unique_discussion_root", unique: true, where: "(((itemable_type)::text = 'Discussion'::text) AND ((kind)::text = 'new_discussion'::text))"
    t.index ["itemable_type", "itemable_id", "kind"], name: "index_topic_items_on_unique_poll_root", unique: true, where: "(((itemable_type)::text = 'Poll'::text) AND ((kind)::text = 'poll_created'::text))"
    t.index ["itemable_type", "itemable_id"], name: "index_topic_items_on_itemable_type_and_itemable_id"
    t.index ["parent_id", "topic_id"], name: "index_topic_items_on_parent_id_and_topic_id", where: "(topic_id IS NOT NULL)"
    t.index ["parent_id"], name: "index_topic_items_on_parent_id"
    t.index ["position_key"], name: "index_topic_items_on_position_key"
    t.index ["topic_id", "depth", "sequence_id"], name: "index_topic_items_on_topic_id_depth_sequence_id"
    t.index ["topic_id", "sequence_id"], name: "index_topic_items_on_topic_id_and_sequence_id", unique: true
    t.index ["topic_id", "sequence_id"], name: "index_topic_items_on_topic_id_sequence_id_pinned", where: "(pinned = true)"
    t.index ["topic_id"], name: "index_topic_items_on_topic_id"
    t.index ["user_id"], name: "index_topic_items_on_user_id"
    t.check_constraint "btrim(itemable_type::text) <> ''::text", name: "topic_items_itemable_type_present"
    t.check_constraint "btrim(kind::text) <> ''::text", name: "topic_items_kind_present"
  end

  create_table "topic_readers", id: :serial, force: :cascade do |t|
    t.datetime "accepted_at", precision: nil
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "dismissed_at", precision: nil
    t.boolean "guest", default: false, null: false
    t.integer "inviter_id"
    t.datetime "last_read_at", precision: nil
    t.boolean "participating", default: false, null: false
    t.string "read_ranges_string"
    t.datetime "revoked_at", precision: nil
    t.integer "revoker_id"
    t.string "token"
    t.integer "topic_id", null: false
    t.datetime "updated_at", precision: nil
    t.integer "user_id", null: false
    t.integer "volume", default: 2, null: false
    t.index ["guest"], name: "discussion_readers_guests", where: "(guest = true)"
    t.index ["inviter_id"], name: "inviter_id_not_null", where: "(inviter_id IS NOT NULL)"
    t.index ["token"], name: "index_discussion_readers_on_token", unique: true
    t.index ["topic_id", "user_id"], name: "index_topic_readers_on_topic_id_and_user_id", unique: true
    t.index ["user_id", "topic_id"], name: "index_topic_readers_guest_user_id", where: "(guest = true)"
  end

  create_table "topics", force: :cascade do |t|
    t.integer "active_polls_count", default: 0, null: false
    t.boolean "allow_comments", default: true, null: false
    t.boolean "allow_concurrent_polls", default: false, null: false
    t.boolean "allow_reactions", default: true, null: false
    t.integer "anonymous_polls_count", default: 0, null: false
    t.integer "closed_polls_count", default: 0, null: false
    t.integer "comment_length_max"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.integer "discarded_by"
    t.integer "group_id"
    t.integer "items_count", default: 0, null: false
    t.datetime "last_activity_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.integer "locker_id"
    t.integer "max_depth", default: 3, null: false
    t.integer "members_count"
    t.boolean "newest_first", default: false, null: false
    t.datetime "pinned_at", precision: nil
    t.boolean "private", default: true, null: false
    t.string "ranges_string"
    t.integer "seen_by_count", default: 0, null: false
    t.string "tags", default: [], array: true
    t.integer "topicable_id", null: false
    t.string "topicable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_topics_on_discarded_at_null", where: "(discarded_at IS NULL)"
    t.index ["group_id", "last_activity_at"], name: "index_topics_on_group_last_activity_inbox", order: { last_activity_at: :desc }, where: "(discarded_at IS NULL)"
    t.index ["group_id"], name: "index_topics_on_group_id"
    t.index ["last_activity_at"], name: "index_topics_on_last_activity_at", order: :desc
    t.index ["locked_at"], name: "index_topics_on_locked_at"
    t.index ["tags"], name: "index_topics_on_tags", using: :gin
    t.index ["topicable_type", "topicable_id"], name: "index_topics_on_topicable_type_and_topicable_id", unique: true
  end

  create_table "translations", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.hstore "fields"
    t.string "language", limit: 255
    t.integer "translatable_id"
    t.string "translatable_type", limit: 255
    t.datetime "updated_at", precision: nil, null: false
    t.index ["language"], name: "index_translations_on_language"
    t.index ["translatable_type", "translatable_id"], name: "index_translations_on_translatable_type_and_translatable_id"
  end

  create_table "user_deactivation_responses", id: :serial, force: :cascade do |t|
    t.text "body"
    t.integer "user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "api_key", null: false
    t.jsonb "attachments", default: [], null: false
    t.boolean "auto_translate", default: false, null: false
    t.boolean "autodetect_time_zone", default: true, null: false
    t.string "avatar_initials", limit: 255
    t.string "avatar_kind", limit: 255, default: "initials", null: false
    t.boolean "bot", default: false, null: false
    t.integer "bounces_count", default: 0, null: false
    t.string "city"
    t.integer "complaints_count", default: 0, null: false
    t.string "content_locale"
    t.string "country"
    t.datetime "created_at", precision: nil
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.string "date_time_pref"
    t.datetime "deactivated_at", precision: nil
    t.integer "deactivator_id"
    t.integer "default_membership_volume", default: 2, null: false
    t.string "detected_locale", limit: 255
    t.citext "email"
    t.string "email_api_key", limit: 255, null: false
    t.boolean "email_catch_up", default: true, null: false
    t.integer "email_catch_up_day"
    t.boolean "email_newsletter", default: false, null: false
    t.boolean "email_on_participation", default: false, null: false
    t.string "email_sha256"
    t.boolean "email_verified", default: false, null: false
    t.boolean "email_when_mentioned", default: true, null: false
    t.boolean "email_when_proposal_closing_soon", default: false, null: false
    t.jsonb "experiences", default: {}, null: false
    t.integer "facebook_community_id"
    t.integer "failed_attempts", default: 0, null: false
    t.boolean "is_admin", default: false
    t.string "key", limit: 255
    t.datetime "last_seen_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.datetime "legal_accepted_at", precision: nil
    t.jsonb "link_previews", default: [], null: false
    t.string "location", default: "", null: false
    t.datetime "locked_at", precision: nil
    t.integer "memberships_count", default: 0, null: false
    t.string "name", limit: 255
    t.string "password_digest", limit: 128, default: ""
    t.string "region"
    t.string "secret_token", default: -> { "public.gen_random_uuid()" }, null: false
    t.string "selected_locale", limit: 255
    t.string "short_bio", default: "", null: false
    t.string "short_bio_format", limit: 10, default: "md", null: false
    t.integer "sign_in_count", default: 0
    t.integer "slack_community_id"
    t.string "time_zone", limit: 255
    t.string "unsubscribe_token", limit: 255, null: false
    t.datetime "updated_at", precision: nil
    t.string "uploaded_avatar_content_type", limit: 255
    t.string "uploaded_avatar_file_name", limit: 255
    t.integer "uploaded_avatar_file_size"
    t.datetime "uploaded_avatar_updated_at", precision: nil
    t.string "username", limit: 255
    t.index ["api_key"], name: "index_users_on_api_key"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email_verified"], name: "index_users_on_email_verified"
    t.index ["key"], name: "index_users_on_key", unique: true
    t.index ["unsubscribe_token"], name: "index_users_on_unsubscribe_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "event", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "item_type", limit: 255, null: false
    t.jsonb "object_changes"
    t.integer "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "webhooks", force: :cascade do |t|
    t.integer "actor_id"
    t.integer "author_id"
    t.datetime "created_at", precision: nil
    t.jsonb "event_kinds", default: [], null: false
    t.string "format", default: "markdown"
    t.integer "group_id", null: false
    t.boolean "include_body", default: false
    t.boolean "include_subgroups", default: false, null: false
    t.boolean "is_broken", default: false, null: false
    t.datetime "last_used_at"
    t.string "name", null: false
    t.string "permissions", default: [], null: false, array: true
    t.string "token"
    t.datetime "updated_at", precision: nil
    t.string "url"
    t.index ["group_id"], name: "index_webhooks_on_group_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "anonymous_ballot_choices", "anonymous_ballots"
  add_foreign_key "anonymous_ballot_choices", "poll_options"
  add_foreign_key "anonymous_ballots", "polls"
  add_foreign_key "anonymous_poll_voters", "polls"
  add_foreign_key "anonymous_poll_voters", "users", column: "inviter_id"
  add_foreign_key "anonymous_poll_voters", "users", column: "voter_id"
  add_foreign_key "discussions", "topics", deferrable: :deferred
  add_foreign_key "group_handle_redirects", "groups"
  add_foreign_key "legacy_anonymous_vote_reasons", "anonymous_ballots", on_delete: :cascade
  add_foreign_key "notification_deliveries", "notifications", on_delete: :cascade
  add_foreign_key "notifications", "users", column: "actor_id", on_delete: :nullify
  add_foreign_key "poll_options", "polls", on_delete: :cascade
  add_foreign_key "polls", "topics", deferrable: :deferred
  add_foreign_key "sessions", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "stance_choices", "poll_options", on_delete: :cascade
  add_foreign_key "stance_choices", "stances", on_delete: :cascade
  add_foreign_key "tasks_users", "tasks", on_delete: :cascade
  add_foreign_key "tasks_users", "users", on_delete: :cascade
  add_foreign_key "topic_items", "topic_items", column: ["parent_id", "topic_id"], primary_key: ["id", "topic_id"], name: "topic_items_parent_same_topic", on_delete: :cascade, deferrable: :immediate
end
