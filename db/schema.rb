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

ActiveRecord::Schema.define(version: 2021_08_31_085201) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "hstore"
  enable_extension "pg_stat_statements"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.integer "group_id"
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["group_id"], name: "index_active_storage_attachments_on_group_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ahoy_events", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid "visit_id"
    t.integer "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
  end

  create_table "ahoy_messages", id: :serial, force: :cascade do |t|
    t.string "token"
    t.text "to"
    t.integer "user_id"
    t.string "user_type"
    t.string "mailer"
    t.datetime "sent_at"
    t.datetime "opened_at"
    t.datetime "clicked_at"
    t.index ["token"], name: "index_ahoy_messages_on_token"
    t.index ["user_id"], name: "index_ahoy_messages_on_user_id", where: "(user_id IS NOT NULL)"
  end

  create_table "ahoy_visits", id: :uuid, default: nil, force: :cascade do |t|
    t.string "visitor_token"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.text "landing_page"
    t.integer "user_id"
    t.string "referring_domain"
    t.string "search_keyword"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.integer "screen_height"
    t.integer "screen_width"
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.datetime "started_at"
    t.string "gclid"
    t.string "visit_token"
    t.uuid "latitude"
    t.uuid "longitude"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "attachments", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "filename", limit: 255
    t.text "location"
    t.integer "comment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "filesize"
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.integer "attachable_id"
    t.string "attachable_type"
    t.boolean "migrated_to_document", default: false, null: false
    t.index ["attachable_id", "attachable_type"], name: "index_attachments_on_attachable_id_and_attachable_type"
    t.index ["comment_id"], name: "index_attachments_on_comment_id"
  end

  create_table "blacklisted_passwords", id: :serial, force: :cascade do |t|
    t.string "string", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["string"], name: "index_blacklisted_passwords_on_string", using: :hash
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.bigint "creator_id"
    t.bigint "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.text "slack_channels"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.bigint "dashboard_id"
    t.bigint "query_id"
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "cohorts", id: :serial, force: :cascade do |t|
    t.date "start_on"
    t.date "end_on"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "discussion_id", default: 0
    t.text "body", default: ""
    t.integer "user_id", default: 0
    t.integer "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "uses_markdown", default: false, null: false
    t.integer "comment_votes_count", default: 0, null: false
    t.integer "attachments_count", default: 0, null: false
    t.datetime "edited_at"
    t.integer "versions_count", default: 0
    t.string "body_format", limit: 10, default: "md", null: false
    t.jsonb "attachments", default: [], null: false
    t.datetime "discarded_at"
    t.integer "discarded_by"
    t.string "secret_token", default: -> { "public.gen_random_uuid()" }
    t.string "content_locale"
    t.jsonb "link_previews", default: [], null: false
    t.index ["discussion_id"], name: "index_comments_on_discussion_id"
  end

  create_table "default_group_covers", id: :serial, force: :cascade do |t|
    t.string "cover_photo_file_name"
    t.string "cover_photo_content_type"
    t.integer "cover_photo_file_size"
    t.datetime "cover_photo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discussion_readers", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "discussion_id", null: false
    t.datetime "last_read_at"
    t.integer "last_read_sequence_id", default: 0, null: false
    t.integer "volume", default: 2, null: false
    t.boolean "participating", default: false, null: false
    t.datetime "dismissed_at"
    t.string "read_ranges_string"
    t.integer "inviter_id"
    t.string "token"
    t.datetime "revoked_at"
    t.boolean "admin", default: false, null: false
    t.datetime "accepted_at"
    t.index ["discussion_id"], name: "index_discussion_readers_discussion_id"
    t.index ["inviter_id"], name: "inviter_id_not_null", where: "(inviter_id IS NOT NULL)"
    t.index ["token"], name: "index_discussion_readers_on_token", unique: true
    t.index ["user_id", "discussion_id"], name: "index_discussion_readers_on_user_id_and_discussion_id", unique: true
  end

  create_table "discussion_search_vectors", id: :serial, force: :cascade do |t|
    t.integer "discussion_id"
    t.tsvector "search_vector"
    t.index ["discussion_id"], name: "index_discussion_search_vectors_on_discussion_id"
    t.index ["search_vector"], name: "discussion_search_vector_index", using: :gin
  end

  create_table "discussions", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.integer "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title", limit: 255
    t.datetime "last_comment_at"
    t.text "description"
    t.boolean "uses_markdown", default: false, null: false
    t.integer "items_count", default: 0, null: false
    t.datetime "closed_at"
    t.boolean "private", default: true, null: false
    t.string "key", limit: 255
    t.string "iframe_src", limit: 255
    t.datetime "last_activity_at"
    t.integer "last_sequence_id", default: 0, null: false
    t.integer "first_sequence_id", default: 0, null: false
    t.integer "versions_count", default: 0
    t.integer "closed_polls_count", default: 0, null: false
    t.boolean "pinned", default: false, null: false
    t.integer "importance", default: 0, null: false
    t.integer "seen_by_count", default: 0, null: false
    t.string "ranges_string"
    t.integer "guest_group_id"
    t.string "description_format", limit: 10, default: "md", null: false
    t.jsonb "attachments", default: [], null: false
    t.jsonb "info", default: {}, null: false
    t.integer "max_depth", default: 2, null: false
    t.boolean "newest_first", default: false, null: false
    t.datetime "discarded_at"
    t.string "secret_token", default: -> { "public.gen_random_uuid()" }
    t.integer "members_count"
    t.integer "anonymous_polls_count", default: 0, null: false
    t.string "content_locale"
    t.jsonb "link_previews", default: [], null: false
    t.index ["author_id"], name: "index_discussions_on_author_id"
    t.index ["created_at"], name: "index_discussions_on_created_at"
    t.index ["group_id"], name: "index_discussions_on_group_id"
    t.index ["key"], name: "index_discussions_on_key", unique: true
    t.index ["last_activity_at"], name: "index_discussions_on_last_activity_at", order: :desc
    t.index ["private"], name: "index_discussions_on_private"
  end

  create_table "documents", id: :serial, force: :cascade do |t|
    t.integer "model_id"
    t.string "model_type"
    t.string "title"
    t.string "url"
    t.string "doctype", null: false
    t.string "color", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "icon"
    t.integer "author_id", null: false
    t.string "web_url"
    t.string "thumb_url"
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "group_id"
    t.index ["group_id"], name: "index_documents_on_group_id"
    t.index ["model_id"], name: "index_documents_on_model_id"
    t.index ["model_type"], name: "index_documents_on_model_type"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "kind", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "eventable_id"
    t.string "eventable_type", limit: 255
    t.integer "user_id"
    t.integer "discussion_id"
    t.integer "sequence_id"
    t.boolean "announcement", default: false, null: false
    t.jsonb "custom_fields", default: {}, null: false
    t.integer "parent_id"
    t.integer "position", default: 0, null: false
    t.integer "child_count", default: 0, null: false
    t.integer "depth", default: 0, null: false
    t.boolean "pinned", default: false, null: false
    t.string "position_key"
    t.integer "descendant_count", default: 0, null: false
    t.integer "eventable_version_id"
    t.index ["created_at"], name: "index_events_on_created_at"
    t.index ["discussion_id", "sequence_id"], name: "index_events_on_discussion_id_and_sequence_id", unique: true
    t.index ["eventable_id", "kind"], name: "index_events_on_eventable_id_and_kind"
    t.index ["eventable_type", "eventable_id"], name: "index_events_on_eventable_type_and_eventable_id"
    t.index ["parent_id", "discussion_id"], name: "index_events_on_parent_id_and_discussion_id", where: "(discussion_id IS NOT NULL)"
    t.index ["parent_id"], name: "index_events_on_parent_id"
    t.index ["position_key"], name: "index_events_on_position_key"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "group_identities", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "identity_id", null: false
    t.jsonb "custom_fields", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_identities_on_group_id"
    t.index ["identity_id"], name: "index_group_identities_on_identity_id"
  end

  create_table "group_surveys", force: :cascade do |t|
    t.integer "group_id", null: false
    t.string "category"
    t.string "location"
    t.string "size"
    t.string "declaration"
    t.text "purpose"
    t.string "usage"
    t.string "referrer"
    t.string "role"
    t.string "website"
    t.text "misc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "desired_feature"
    t.string "segment"
    t.index ["group_id"], name: "index_group_surveys_on_group_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "parent_id"
    t.text "description"
    t.integer "memberships_count", default: 0, null: false
    t.datetime "archived_at"
    t.integer "discussions_count", default: 0, null: false
    t.string "full_name", limit: 255
    t.boolean "parent_members_can_see_discussions", default: false, null: false
    t.string "key", limit: 255
    t.integer "category_id"
    t.citext "handle"
    t.integer "theme_id"
    t.boolean "is_visible_to_public", default: true, null: false
    t.boolean "is_visible_to_parent_members", default: false, null: false
    t.string "discussion_privacy_options", default: "private_only", null: false
    t.boolean "members_can_add_members", default: true, null: false
    t.string "membership_granted_upon", default: "approval", null: false
    t.boolean "members_can_edit_discussions", default: true, null: false
    t.string "cover_photo_file_name", limit: 255
    t.string "cover_photo_content_type", limit: 255
    t.integer "cover_photo_file_size"
    t.datetime "cover_photo_updated_at"
    t.string "logo_file_name", limit: 255
    t.string "logo_content_type", limit: 255
    t.integer "logo_file_size"
    t.datetime "logo_updated_at"
    t.boolean "members_can_edit_comments", default: true
    t.boolean "members_can_raise_motions", default: true, null: false
    t.boolean "members_can_vote", default: true, null: false
    t.boolean "members_can_start_discussions", default: true, null: false
    t.boolean "members_can_create_subgroups", default: false, null: false
    t.integer "creator_id"
    t.boolean "is_referral", default: false, null: false
    t.integer "cohort_id"
    t.integer "default_group_cover_id"
    t.integer "subscription_id"
    t.integer "invitations_count", default: 0, null: false
    t.integer "admin_memberships_count", default: 0, null: false
    t.integer "public_discussions_count", default: 0, null: false
    t.string "country"
    t.string "region"
    t.string "city"
    t.integer "closed_motions_count", default: 0, null: false
    t.boolean "enable_experiments", default: false
    t.boolean "analytics_enabled", default: false, null: false
    t.integer "proposal_outcomes_count", default: 0, null: false
    t.jsonb "experiences", default: {}, null: false
    t.integer "pending_memberships_count", default: 0, null: false
    t.jsonb "features", default: {}, null: false
    t.integer "recent_activity_count", default: 0, null: false
    t.integer "closed_polls_count", default: 0, null: false
    t.integer "polls_count", default: 0, null: false
    t.integer "subgroups_count", default: 0, null: false
    t.integer "open_discussions_count", default: 0, null: false
    t.integer "closed_discussions_count", default: 0, null: false
    t.string "token"
    t.string "admin_tags"
    t.boolean "members_can_announce", default: true, null: false
    t.string "description_format", limit: 10, default: "md", null: false
    t.jsonb "attachments", default: [], null: false
    t.jsonb "info", default: {}, null: false
    t.integer "new_threads_max_depth", default: 2, null: false
    t.boolean "new_threads_newest_first", default: false, null: false
    t.boolean "admins_can_edit_user_content", default: true, null: false
    t.boolean "listed_in_explore", default: false, null: false
    t.string "secret_token", default: -> { "public.gen_random_uuid()" }
    t.string "content_locale"
    t.boolean "members_can_add_guests", default: true, null: false
    t.boolean "members_can_delete_comments", default: true, null: false
    t.jsonb "link_previews", default: [], null: false
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

  create_table "login_tokens", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "token"
    t.boolean "used", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "redirect"
    t.integer "code", null: false
    t.boolean "is_reactivation", default: false, null: false
    t.index ["token"], name: "index_login_tokens_on_token"
  end

  create_table "membership_requests", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "email", limit: 255
    t.text "introduction"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "requestor_id"
    t.integer "responder_id"
    t.string "response", limit: 255
    t.datetime "responded_at"
    t.index ["group_id"], name: "index_membership_requests_on_group_id"
    t.index ["requestor_id"], name: "index_membership_requests_on_requestor_id"
    t.index ["responder_id"], name: "index_membership_requests_on_responder_id"
  end

  create_table "memberships", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "inviter_id"
    t.datetime "archived_at"
    t.integer "inbox_position", default: 0
    t.boolean "admin", default: false, null: false
    t.integer "volume"
    t.jsonb "experiences", default: {}, null: false
    t.integer "invitation_id"
    t.string "token"
    t.datetime "accepted_at"
    t.string "title"
    t.datetime "saml_session_expires_at"
    t.index ["created_at"], name: "index_memberships_on_created_at"
    t.index ["group_id", "user_id"], name: "index_memberships_on_group_id_and_user_id", unique: true
    t.index ["inviter_id"], name: "index_memberships_on_inviter_id"
    t.index ["token"], name: "index_memberships_on_token", unique: true
    t.index ["user_id", "volume"], name: "index_memberships_on_user_id_and_volume"
    t.index ["volume"], name: "index_memberships_on_volume"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_id"
    t.boolean "viewed", default: false, null: false
    t.jsonb "translation_values", default: {}, null: false
    t.string "url"
    t.integer "actor_id"
    t.index ["event_id"], name: "index_notifications_on_event_id"
    t.index ["id"], name: "index_notifications_on_id", order: :desc
    t.index ["user_id", "id"], name: "notifications_user_id_id_idx"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "owner_id"
    t.string "owner_type"
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at"
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "omniauth_identities", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "email", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "identity_type", limit: 255
    t.string "uid", limit: 255
    t.string "name", limit: 255
    t.string "access_token", default: ""
    t.string "logo"
    t.jsonb "custom_fields", default: {}, null: false
    t.index ["email"], name: "index_personas_on_email"
    t.index ["identity_type", "uid"], name: "index_omniauth_identities_on_identity_type_and_uid"
    t.index ["user_id"], name: "index_personas_on_user_id"
  end

  create_table "outcomes", id: :serial, force: :cascade do |t|
    t.integer "poll_id"
    t.text "statement", null: false
    t.integer "author_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "latest", default: true, null: false
    t.integer "poll_option_id"
    t.jsonb "custom_fields", default: {}, null: false
    t.string "statement_format", limit: 10, default: "md", null: false
    t.jsonb "attachments", default: [], null: false
    t.string "secret_token", default: -> { "public.gen_random_uuid()" }
    t.integer "versions_count", default: 0, null: false
    t.date "review_on"
    t.string "content_locale"
    t.jsonb "link_previews", default: [], null: false
    t.index ["poll_id"], name: "index_outcomes_on_poll_id"
  end

  create_table "poll_options", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "poll_id"
    t.integer "priority", default: 0, null: false
    t.jsonb "score_counts", default: {}, null: false
    t.jsonb "voter_scores", default: {}, null: false
    t.integer "total_score", default: 0, null: false
    t.index ["poll_id"], name: "index_poll_options_on_poll_id"
  end

  create_table "poll_unsubscriptions", id: :serial, force: :cascade do |t|
    t.integer "poll_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["poll_id", "user_id"], name: "index_poll_unsubscriptions_on_poll_id_and_user_id", unique: true
  end

  create_table "polls", id: :serial, force: :cascade do |t|
    t.integer "author_id", null: false
    t.string "title", null: false
    t.text "details"
    t.datetime "closing_at"
    t.datetime "closed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "discussion_id"
    t.string "key", null: false
    t.string "poll_type", null: false
    t.jsonb "stance_data", default: {}
    t.integer "voters_count", default: 0, null: false
    t.boolean "multiple_choice", default: false, null: false
    t.jsonb "custom_fields", default: {}, null: false
    t.jsonb "stance_counts", default: [], null: false
    t.integer "group_id"
    t.jsonb "matrix_counts", default: [], null: false
    t.boolean "notify_on_participate", default: false, null: false
    t.boolean "example", default: false, null: false
    t.integer "undecided_voters_count", default: 0, null: false
    t.boolean "voter_can_add_options", default: false, null: false
    t.integer "guest_group_id"
    t.boolean "anonymous", default: false, null: false
    t.integer "versions_count", default: 0
    t.string "details_format", limit: 10, default: "md", null: false
    t.jsonb "attachments", default: [], null: false
    t.boolean "anyone_can_participate", default: false, null: false
    t.boolean "hide_results_until_closed", default: false, null: false
    t.boolean "stances_in_discussion", default: true, null: false
    t.datetime "discarded_at"
    t.integer "discarded_by"
    t.string "secret_token", default: -> { "public.gen_random_uuid()" }
    t.boolean "specified_voters_only", default: false, null: false
    t.integer "notify_on_closing_soon", default: 0, null: false
    t.string "content_locale"
    t.jsonb "link_previews", default: [], null: false
    t.boolean "shuffle_options", default: false, null: false
    t.boolean "allow_long_reason", default: false, null: false
    t.index ["author_id"], name: "index_polls_on_author_id"
    t.index ["closed_at", "closing_at"], name: "index_polls_on_closed_at_and_closing_at"
    t.index ["closed_at", "discussion_id"], name: "index_polls_on_closed_at_and_discussion_id"
    t.index ["discussion_id"], name: "index_polls_on_discussion_id"
    t.index ["group_id"], name: "index_polls_on_group_id"
    t.index ["guest_group_id"], name: "index_polls_on_guest_group_id", unique: true
    t.index ["key"], name: "index_polls_on_key", unique: true
  end

  create_table "reactions", id: :serial, force: :cascade do |t|
    t.integer "reactable_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "reaction", default: "+1", null: false
    t.string "reactable_type", default: "Comment", null: false
    t.index ["created_at"], name: "index_reactions_on_created_at"
    t.index ["reactable_id", "reactable_type"], name: "index_reactions_on_reactable_id_and_reactable_type"
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "saml_providers", force: :cascade do |t|
    t.integer "group_id", null: false
    t.string "idp_metadata_url", null: false
    t.integer "authentication_duration", default: 24, null: false
    t.index ["group_id"], name: "index_saml_providers_on_group_id"
  end

  create_table "stance_choices", id: :serial, force: :cascade do |t|
    t.integer "stance_id"
    t.integer "poll_option_id"
    t.integer "score", default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["poll_option_id"], name: "index_stance_choices_on_poll_option_id"
    t.index ["stance_id"], name: "index_stance_choices_on_stance_id"
  end

  create_table "stances", id: :serial, force: :cascade do |t|
    t.integer "poll_id", null: false
    t.integer "participant_id"
    t.string "reason"
    t.boolean "latest", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "versions_count", default: 0
    t.string "reason_format", limit: 10, default: "md", null: false
    t.jsonb "attachments", default: [], null: false
    t.datetime "cast_at"
    t.string "token"
    t.datetime "revoked_at"
    t.boolean "admin", default: false, null: false
    t.integer "inviter_id"
    t.integer "volume", default: 2, null: false
    t.datetime "accepted_at"
    t.jsonb "stance_choices_cache", default: []
    t.string "content_locale"
    t.string "secret_token", default: -> { "public.gen_random_uuid()" }
    t.jsonb "link_previews", default: [], null: false
    t.jsonb "option_scores", default: {}, null: false
    t.index ["participant_id"], name: "index_stances_on_participant_id"
    t.index ["poll_id", "cast_at"], name: "index_stances_on_poll_id_and_cast_at", order: "NULLS FIRST"
    t.index ["poll_id"], name: "index_stances_on_poll_id"
    t.index ["token"], name: "index_stances_on_token", unique: true
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.datetime "expires_at"
    t.integer "chargify_subscription_id"
    t.string "plan", default: "free"
    t.string "payment_method", default: "none", null: false
    t.integer "owner_id"
    t.integer "max_threads"
    t.integer "max_members"
    t.integer "max_orgs"
    t.string "state", default: "active", null: false
    t.integer "members_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.jsonb "info"
    t.datetime "canceled_at"
    t.datetime "activated_at"
    t.datetime "renews_at"
    t.datetime "renewed_at"
    t.index ["owner_id"], name: "index_subscriptions_on_owner_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id", null: false
    t.integer "taggable_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "taggable_type", null: false
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.citext "name", null: false
    t.string "color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "taggings_count", default: 0
    t.integer "priority", default: 0, null: false
    t.index ["group_id", "name"], name: "index_tags_on_group_id_and_name", unique: true
    t.index ["name"], name: "index_tags_on_name"
  end

  create_table "translations", id: :serial, force: :cascade do |t|
    t.integer "translatable_id"
    t.string "translatable_type", limit: 255
    t.hstore "fields"
    t.string "language", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["translatable_type", "translatable_id"], name: "index_translations_on_translatable_type_and_translatable_id"
  end

  create_table "usage_reports", id: :serial, force: :cascade do |t|
    t.integer "groups_count"
    t.integer "users_count"
    t.integer "discussions_count"
    t.integer "polls_count"
    t.integer "comments_count"
    t.integer "stances_count"
    t.integer "visits_count"
    t.string "canonical_host"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "version"
  end

  create_table "user_deactivation_responses", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "body"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.citext "email"
    t.string "encrypted_password", limit: 128, default: ""
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 255
    t.datetime "deactivated_at"
    t.boolean "is_admin", default: false
    t.string "avatar_kind", limit: 255, default: "initials", null: false
    t.string "uploaded_avatar_file_name", limit: 255
    t.string "uploaded_avatar_content_type", limit: 255
    t.integer "uploaded_avatar_file_size"
    t.datetime "uploaded_avatar_updated_at"
    t.string "avatar_initials", limit: 255
    t.string "username", limit: 255
    t.boolean "email_when_proposal_closing_soon", default: false, null: false
    t.string "authentication_token", limit: 255
    t.string "unsubscribe_token", limit: 255
    t.integer "memberships_count", default: 0, null: false
    t.boolean "uses_markdown", default: false, null: false
    t.string "selected_locale", limit: 255
    t.string "time_zone", limit: 255
    t.string "key", limit: 255
    t.string "detected_locale", limit: 255
    t.boolean "email_catch_up", default: true, null: false
    t.string "email_api_key", limit: 255
    t.boolean "email_when_mentioned", default: true, null: false
    t.boolean "email_on_participation", default: false, null: false
    t.integer "default_membership_volume", default: 2, null: false
    t.string "country"
    t.string "region"
    t.string "city"
    t.jsonb "experiences", default: {}, null: false
    t.integer "facebook_community_id"
    t.integer "slack_community_id"
    t.string "remember_token"
    t.string "short_bio", default: "", null: false
    t.boolean "email_verified", default: false, null: false
    t.string "location", default: "", null: false
    t.datetime "last_seen_at"
    t.datetime "legal_accepted_at"
    t.boolean "email_newsletter", default: false, null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "short_bio_format", limit: 10, default: "md", null: false
    t.jsonb "attachments", default: [], null: false
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "secret_token", default: -> { "public.gen_random_uuid()" }
    t.string "content_locale"
    t.boolean "bot", default: false, null: false
    t.jsonb "link_previews", default: [], null: false
    t.integer "email_catch_up_day"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email_verified"], name: "index_users_on_email_verified"
    t.index ["key"], name: "index_users_on_key", unique: true
    t.index ["remember_token"], name: "users_remember_token_idx"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["unsubscribe_token"], name: "index_users_on_unsubscribe_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "event", limit: 255, null: false
    t.integer "whodunnit"
    t.datetime "created_at"
    t.jsonb "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "webhooks", force: :cascade do |t|
    t.integer "group_id", null: false
    t.string "name", null: false
    t.string "url"
    t.jsonb "event_kinds", default: [], null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "format", default: "markdown"
    t.boolean "include_body", default: false
    t.boolean "include_subgroups", default: false, null: false
    t.boolean "is_broken", default: false, null: false
    t.string "token"
    t.integer "author_id"
    t.integer "actor_id"
    t.string "permissions", default: [], null: false, array: true
    t.index ["group_id"], name: "index_webhooks_on_group_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
