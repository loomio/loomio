# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171111234938) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"
  enable_extension "hstore"
  enable_extension "pg_stat_statements"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "resource_id",   limit: 255, null: false
    t.string   "resource_type", limit: 255, null: false
    t.integer  "author_id"
    t.string   "author_type",   limit: 255
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace",     limit: 255
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_admin_notes_on_resource_type_and_resource_id", using: :btree

  create_table "ahoy_events", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid     "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.jsonb    "properties"
    t.datetime "time"
  end

  add_index "ahoy_events", ["properties"], name: "ahoy_events_properties", using: :gin
  add_index "ahoy_events", ["time"], name: "index_ahoy_events_on_time", using: :btree
  add_index "ahoy_events", ["user_id"], name: "index_ahoy_events_on_user_id", using: :btree
  add_index "ahoy_events", ["visit_id"], name: "index_ahoy_events_on_visit_id", using: :btree

  create_table "ahoy_messages", force: :cascade do |t|
    t.string   "token"
    t.text     "to"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "mailer"
    t.datetime "sent_at"
    t.datetime "opened_at"
    t.datetime "clicked_at"
  end

  add_index "ahoy_messages", ["sent_at"], name: "index_ahoy_messages_on_sent_at", using: :btree
  add_index "ahoy_messages", ["to"], name: "index_ahoy_messages_on_to", using: :btree
  add_index "ahoy_messages", ["token"], name: "index_ahoy_messages_on_token", using: :btree
  add_index "ahoy_messages", ["user_id", "user_type"], name: "index_ahoy_messages_on_user_id_and_user_type", using: :btree

  create_table "attachments", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "filename",          limit: 255
    t.text     "location"
    t.integer  "comment_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "filesize"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "attachable_id"
    t.string   "attachable_type"
  end

  add_index "attachments", ["attachable_id", "attachable_type"], name: "index_attachments_on_attachable_id_and_attachable_type", using: :btree
  add_index "attachments", ["comment_id"], name: "index_attachments_on_comment_id", using: :btree

  create_table "blacklisted_passwords", force: :cascade do |t|
    t.string   "string",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blacklisted_passwords", ["string"], name: "index_blacklisted_passwords_on_string", using: :hash

  create_table "cohorts", force: :cascade do |t|
    t.date "start_on"
    t.date "end_on"
  end

  create_table "comment_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

  add_index "comment_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "tag_anc_desc_udx", unique: true, using: :btree
  add_index "comment_hierarchies", ["descendant_id"], name: "tag_desc_idx", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "discussion_id",       default: 0
    t.text     "body",                default: ""
    t.integer  "user_id",             default: 0,     null: false
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "uses_markdown",       default: false, null: false
    t.integer  "comment_votes_count", default: 0,     null: false
    t.integer  "attachments_count",   default: 0,     null: false
    t.text     "liker_ids_and_names"
    t.datetime "edited_at"
    t.integer  "versions_count",      default: 0
  end

  add_index "comments", ["created_at"], name: "index_comments_on_created_at", using: :btree
  add_index "comments", ["discussion_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["discussion_id"], name: "index_comments_on_discussion_id", using: :btree
  add_index "comments", ["parent_id"], name: "index_comments_on_parent_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "contact_messages", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "user_id"
    t.string   "email",       limit: 255
    t.text     "message"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "destination", limit: 255, default: "contact@loomio.org"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",       limit: 255
    t.string   "email",      limit: 255
    t.string   "source",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "contacts", ["user_id"], name: "index_contacts_on_user_id", using: :btree

  create_table "default_group_covers", force: :cascade do |t|
    t.string   "cover_photo_file_name"
    t.string   "cover_photo_content_type"
    t.integer  "cover_photo_file_size"
    t.datetime "cover_photo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0
    t.integer  "attempts",               default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  add_index "delayed_jobs", ["priority"], name: "index_delayed_jobs_on_priority", using: :btree
  add_index "delayed_jobs", ["run_at", "locked_at", "locked_by", "failed_at"], name: "index_delayed_jobs_on_ready", using: :btree

  create_table "discussion_readers", force: :cascade do |t|
    t.integer  "user_id",                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "discussion_id",                      null: false
    t.datetime "last_read_at"
    t.integer  "read_items_count",   default: 0,     null: false
    t.integer  "volume"
    t.boolean  "participating",      default: false, null: false
    t.datetime "dismissed_at"
    t.string   "read_ranges_string"
  end

  add_index "discussion_readers", ["discussion_id"], name: "index_motion_read_logs_on_discussion_id", using: :btree
  add_index "discussion_readers", ["last_read_at"], name: "index_discussion_readers_on_last_read_at", using: :btree
  add_index "discussion_readers", ["participating"], name: "index_discussion_readers_on_participating", using: :btree
  add_index "discussion_readers", ["user_id", "discussion_id"], name: "index_discussion_readers_on_user_id_and_discussion_id", unique: true, using: :btree
  add_index "discussion_readers", ["user_id", "volume"], name: "index_discussion_readers_on_user_id_and_volume", using: :btree
  add_index "discussion_readers", ["user_id"], name: "index_motion_read_logs_on_user_id", using: :btree
  add_index "discussion_readers", ["volume"], name: "index_discussion_readers_on_volume", using: :btree

  create_table "discussion_search_vectors", force: :cascade do |t|
    t.integer  "discussion_id"
    t.tsvector "search_vector"
  end

  add_index "discussion_search_vectors", ["discussion_id"], name: "index_discussion_search_vectors_on_discussion_id", using: :btree
  add_index "discussion_search_vectors", ["search_vector"], name: "discussion_search_vector_index", using: :gin

  create_table "discussion_tags", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "discussion_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discussions", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",              limit: 255
    t.datetime "last_comment_at"
    t.text     "description"
    t.boolean  "uses_markdown",                  default: false, null: false
    t.boolean  "is_deleted",                     default: false, null: false
    t.integer  "items_count",                    default: 0,     null: false
    t.datetime "archived_at"
    t.boolean  "private"
    t.string   "key",                limit: 255
    t.string   "iframe_src",         limit: 255
    t.datetime "last_activity_at"
    t.integer  "last_sequence_id",               default: 0,     null: false
    t.integer  "first_sequence_id",              default: 0,     null: false
    t.integer  "versions_count",                 default: 0
    t.integer  "closed_polls_count",             default: 0,     null: false
    t.boolean  "pinned",                         default: false, null: false
    t.integer  "importance",                     default: 0,     null: false
    t.integer  "seen_by_count",                  default: 0,     null: false
    t.string   "ranges_string"
  end

  add_index "discussions", ["author_id"], name: "index_discussions_on_author_id", using: :btree
  add_index "discussions", ["created_at"], name: "index_discussions_on_created_at", using: :btree
  add_index "discussions", ["group_id"], name: "index_discussions_on_group_id", using: :btree
  add_index "discussions", ["is_deleted", "archived_at", "private"], name: "index_discussions_visible", using: :btree
  add_index "discussions", ["is_deleted", "archived_at"], name: "index_discussions_on_is_deleted_and_archived_at", using: :btree
  add_index "discussions", ["is_deleted"], name: "index_discussions_on_is_deleted", using: :btree
  add_index "discussions", ["key"], name: "index_discussions_on_key", unique: true, using: :btree
  add_index "discussions", ["last_activity_at"], name: "index_discussions_on_last_activity_at", order: {"last_activity_at"=>:desc}, using: :btree
  add_index "discussions", ["private"], name: "index_discussions_on_private", using: :btree

  create_table "drafts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "draftable_id"
    t.string  "draftable_type"
    t.json    "payload",        default: {}, null: false
  end

  add_index "drafts", ["user_id", "draftable_type", "draftable_id"], name: "index_drafts_on_user_id_and_draftable_type_and_draftable_id", unique: true, using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "kind",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "eventable_id"
    t.string   "eventable_type", limit: 255
    t.integer  "user_id"
    t.integer  "discussion_id"
    t.integer  "sequence_id"
    t.boolean  "announcement",               default: false, null: false
    t.jsonb    "custom_fields",              default: {},    null: false
    t.integer  "parent_id"
    t.integer  "position",                   default: 0,     null: false
    t.integer  "child_count",                default: 0,     null: false
    t.integer  "depth",                      default: 0,     null: false
  end

  add_index "events", ["created_at"], name: "index_events_on_created_at", using: :btree
  add_index "events", ["discussion_id", "sequence_id"], name: "index_events_on_discussion_id_and_sequence_id", unique: true, using: :btree
  add_index "events", ["discussion_id"], name: "index_events_on_discussion_id", using: :btree
  add_index "events", ["eventable_type", "eventable_id"], name: "index_events_on_eventable_type_and_eventable_id", using: :btree
  add_index "events", ["parent_id", "position"], name: "index_events_on_parent_id_and_position", where: "(parent_id IS NOT NULL)", using: :btree
  add_index "events", ["parent_id"], name: "index_events_on_parent_id", where: "(parent_id IS NOT NULL)", using: :btree

  create_table "group_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

  add_index "group_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "group_anc_desc_udx", unique: true, using: :btree
  add_index "group_hierarchies", ["descendant_id"], name: "group_desc_idx", using: :btree

  create_table "group_identities", force: :cascade do |t|
    t.integer  "group_id",                   null: false
    t.integer  "identity_id",                null: false
    t.jsonb    "custom_fields", default: {}, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "group_identities", ["group_id"], name: "index_group_identities_on_group_id", using: :btree
  add_index "group_identities", ["identity_id"], name: "index_group_identities_on_identity_id", using: :btree

  create_table "group_visits", force: :cascade do |t|
    t.uuid     "visit_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "member",     default: false, null: false
  end

  add_index "group_visits", ["created_at"], name: "index_group_visits_on_created_at", using: :btree
  add_index "group_visits", ["group_id"], name: "index_group_visits_on_group_id", using: :btree
  add_index "group_visits", ["member"], name: "index_group_visits_on_member", using: :btree
  add_index "group_visits", ["visit_id", "group_id"], name: "index_group_visits_on_visit_id_and_group_id", unique: true, using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",                               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.text     "description"
    t.integer  "memberships_count",                              default: 0,              null: false
    t.datetime "archived_at"
    t.integer  "discussions_count",                              default: 0,              null: false
    t.string   "full_name",                          limit: 255
    t.boolean  "parent_members_can_see_discussions",             default: false,          null: false
    t.string   "key",                                limit: 255
    t.integer  "category_id"
    t.citext   "subdomain"
    t.integer  "theme_id"
    t.boolean  "is_visible_to_public",                           default: true,           null: false
    t.boolean  "is_visible_to_parent_members",                   default: false,          null: false
    t.string   "discussion_privacy_options",                     default: "private_only", null: false
    t.boolean  "members_can_add_members",                        default: true,           null: false
    t.string   "membership_granted_upon",                        default: "approval",     null: false
    t.boolean  "members_can_edit_discussions",                   default: true,           null: false
    t.boolean  "motions_can_be_edited",                          default: false,          null: false
    t.string   "cover_photo_file_name",              limit: 255
    t.string   "cover_photo_content_type",           limit: 255
    t.integer  "cover_photo_file_size"
    t.datetime "cover_photo_updated_at"
    t.string   "logo_file_name",                     limit: 255
    t.string   "logo_content_type",                  limit: 255
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.boolean  "members_can_edit_comments",                      default: true
    t.boolean  "members_can_raise_motions",                      default: true,           null: false
    t.boolean  "members_can_vote",                               default: true,           null: false
    t.boolean  "members_can_start_discussions",                  default: true,           null: false
    t.boolean  "members_can_create_subgroups",                   default: false,          null: false
    t.integer  "creator_id"
    t.boolean  "is_referral",                                    default: false,          null: false
    t.integer  "cohort_id"
    t.integer  "default_group_cover_id"
    t.integer  "subscription_id"
    t.integer  "invitations_count",                              default: 0,              null: false
    t.integer  "admin_memberships_count",                        default: 0,              null: false
    t.integer  "public_discussions_count",                       default: 0,              null: false
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.integer  "closed_motions_count",                           default: 0,              null: false
    t.boolean  "enable_experiments",                             default: false
    t.boolean  "analytics_enabled",                              default: false,          null: false
    t.integer  "proposal_outcomes_count",                        default: 0,              null: false
    t.jsonb    "experiences",                                    default: {},             null: false
    t.integer  "pending_invitations_count",                      default: 0,              null: false
    t.jsonb    "features",                                       default: {},             null: false
    t.integer  "recent_activity_count",                          default: 0,              null: false
    t.integer  "closed_polls_count",                             default: 0,              null: false
    t.integer  "announcement_recipients_count",                  default: 0,              null: false
    t.integer  "polls_count",                                    default: 0,              null: false
    t.integer  "subgroups_count",                                default: 0,              null: false
    t.string   "type",                                           default: "FormalGroup",  null: false
  end

  add_index "groups", ["archived_at"], name: "index_groups_on_archived_at", using: :btree
  add_index "groups", ["category_id"], name: "index_groups_on_category_id", using: :btree
  add_index "groups", ["cohort_id"], name: "index_groups_on_cohort_id", using: :btree
  add_index "groups", ["created_at"], name: "index_groups_on_created_at", using: :btree
  add_index "groups", ["default_group_cover_id"], name: "index_groups_on_default_group_cover_id", using: :btree
  add_index "groups", ["full_name"], name: "index_groups_on_full_name", using: :btree
  add_index "groups", ["is_visible_to_public"], name: "index_groups_on_is_visible_to_public", using: :btree
  add_index "groups", ["key"], name: "index_groups_on_key", unique: true, using: :btree
  add_index "groups", ["name"], name: "index_groups_on_name", using: :btree
  add_index "groups", ["parent_id"], name: "index_groups_on_parent_id", using: :btree
  add_index "groups", ["parent_members_can_see_discussions"], name: "index_groups_on_parent_members_can_see_discussions", using: :btree
  add_index "groups", ["recent_activity_count"], name: "index_groups_on_recent_activity_count", using: :btree
  add_index "groups", ["subdomain"], name: "index_groups_on_subdomain", unique: true, using: :btree

  create_table "invitations", force: :cascade do |t|
    t.string   "recipient_email", limit: 255
    t.integer  "inviter_id"
    t.boolean  "to_be_admin",                 default: false,        null: false
    t.string   "token",           limit: 255,                        null: false
    t.datetime "accepted_at"
    t.string   "intent",                      default: "join_group", null: false
    t.integer  "canceller_id"
    t.datetime "cancelled_at"
    t.string   "recipient_name",  limit: 255
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "single_use",                  default: true,         null: false
    t.text     "message"
    t.integer  "send_count",                  default: 0,            null: false
  end

  add_index "invitations", ["accepted_at"], name: "index_invitations_on_accepted_at", where: "(accepted_at IS NULL)", using: :btree
  add_index "invitations", ["cancelled_at"], name: "index_invitations_on_cancelled_at", using: :btree
  add_index "invitations", ["created_at"], name: "index_invitations_on_created_at", using: :btree
  add_index "invitations", ["recipient_email"], name: "index_invitations_on_recipient_email", using: :btree
  add_index "invitations", ["single_use"], name: "index_invitations_on_single_use", using: :btree
  add_index "invitations", ["token"], name: "index_invitations_on_token", using: :btree

  create_table "login_tokens", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token"
    t.boolean  "used",       default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "redirect"
  end

  create_table "membership_requests", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "email",        limit: 255
    t.text     "introduction"
    t.integer  "group_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "requestor_id"
    t.integer  "responder_id"
    t.string   "response",     limit: 255
    t.datetime "responded_at"
  end

  add_index "membership_requests", ["email"], name: "index_membership_requests_on_email", using: :btree
  add_index "membership_requests", ["group_id", "response"], name: "index_membership_requests_on_group_id_and_response", using: :btree
  add_index "membership_requests", ["group_id"], name: "index_membership_requests_on_group_id", using: :btree
  add_index "membership_requests", ["name"], name: "index_membership_requests_on_name", using: :btree
  add_index "membership_requests", ["requestor_id"], name: "index_membership_requests_on_requestor_id", using: :btree
  add_index "membership_requests", ["responder_id"], name: "index_membership_requests_on_responder_id", using: :btree
  add_index "membership_requests", ["response"], name: "index_membership_requests_on_response", using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "inviter_id"
    t.datetime "archived_at"
    t.integer  "inbox_position", default: 0
    t.boolean  "admin",          default: false, null: false
    t.boolean  "is_suspended",   default: false, null: false
    t.integer  "volume",         default: 2,     null: false
    t.jsonb    "experiences",    default: {},    null: false
    t.integer  "invitation_id"
  end

  add_index "memberships", ["created_at"], name: "index_memberships_on_created_at", using: :btree
  add_index "memberships", ["group_id", "user_id", "is_suspended", "archived_at"], name: "active_memberships", using: :btree
  add_index "memberships", ["group_id", "user_id"], name: "index_memberships_on_group_id_and_user_id", unique: true, using: :btree
  add_index "memberships", ["group_id"], name: "index_memberships_on_group_id", using: :btree
  add_index "memberships", ["inviter_id"], name: "index_memberships_on_inviter_id", using: :btree
  add_index "memberships", ["user_id", "volume"], name: "index_memberships_on_user_id_and_volume", using: :btree
  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree
  add_index "memberships", ["volume"], name: "index_memberships_on_volume", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
    t.boolean  "viewed",             default: false, null: false
    t.jsonb    "translation_values", default: {},    null: false
    t.string   "url"
    t.integer  "actor_id"
  end

  add_index "notifications", ["actor_id"], name: "index_notifications_on_actor_id", using: :btree
  add_index "notifications", ["created_at"], name: "index_notifications_on_created_at", order: {"created_at"=>:desc}, using: :btree
  add_index "notifications", ["event_id"], name: "index_notifications_on_event_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree
  add_index "notifications", ["viewed"], name: "index_notifications_on_viewed", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                           null: false
    t.string   "uid",                            null: false
    t.string   "secret",                         null: false
    t.text     "redirect_uri",                   null: false
    t.string   "scopes",            default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "omniauth_identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "email",         limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "identity_type", limit: 255
    t.string   "uid",           limit: 255
    t.string   "name",          limit: 255
    t.string   "access_token",              default: ""
    t.string   "logo"
    t.jsonb    "custom_fields",             default: {}, null: false
  end

  add_index "omniauth_identities", ["email"], name: "index_personas_on_email", using: :btree
  add_index "omniauth_identities", ["identity_type", "uid"], name: "index_omniauth_identities_on_identity_type_and_uid", using: :btree
  add_index "omniauth_identities", ["user_id"], name: "index_personas_on_user_id", using: :btree

  create_table "organisation_visits", force: :cascade do |t|
    t.uuid     "visit_id"
    t.integer  "organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "member",          default: false, null: false
  end

  add_index "organisation_visits", ["created_at"], name: "index_organisation_visits_on_created_at", using: :btree
  add_index "organisation_visits", ["member"], name: "index_organisation_visits_on_member", using: :btree
  add_index "organisation_visits", ["organisation_id"], name: "index_organisation_visits_on_organisation_id", using: :btree
  add_index "organisation_visits", ["visit_id", "organisation_id"], name: "index_organisation_visits_on_visit_id_and_organisation_id", unique: true, using: :btree

  create_table "outcomes", force: :cascade do |t|
    t.integer  "poll_id"
    t.text     "statement",                     null: false
    t.integer  "author_id",                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "latest",         default: true, null: false
    t.integer  "poll_option_id"
    t.jsonb    "custom_fields",  default: {},   null: false
  end

  add_index "outcomes", ["poll_id"], name: "index_outcomes_on_poll_id", using: :btree

  create_table "poll_communities", force: :cascade do |t|
    t.integer "poll_id",      null: false
    t.integer "community_id", null: false
  end

  add_index "poll_communities", ["community_id"], name: "index_poll_communities_on_community_id", using: :btree
  add_index "poll_communities", ["poll_id"], name: "index_poll_communities_on_poll_id", using: :btree

  create_table "poll_did_not_votes", force: :cascade do |t|
    t.integer "poll_id"
    t.integer "user_id"
  end

  add_index "poll_did_not_votes", ["poll_id"], name: "index_poll_did_not_votes_on_poll_id", using: :btree
  add_index "poll_did_not_votes", ["user_id"], name: "index_poll_did_not_votes_on_user_id", using: :btree

  create_table "poll_options", force: :cascade do |t|
    t.string  "name",                 null: false
    t.integer "poll_id"
    t.integer "priority", default: 0, null: false
  end

  add_index "poll_options", ["poll_id", "name"], name: "index_poll_options_on_poll_id_and_name", using: :btree
  add_index "poll_options", ["poll_id", "priority"], name: "index_poll_options_on_poll_id_and_priority", using: :btree
  add_index "poll_options", ["poll_id"], name: "index_poll_options_on_poll_id", using: :btree
  add_index "poll_options", ["priority"], name: "index_poll_options_on_priority", using: :btree

  create_table "poll_references", force: :cascade do |t|
    t.integer "reference_id",   null: false
    t.string  "reference_type", null: false
    t.integer "poll_id",        null: false
  end

  add_index "poll_references", ["poll_id"], name: "index_poll_references_on_poll_id", using: :btree

  create_table "poll_unsubscriptions", force: :cascade do |t|
    t.integer  "poll_id",    null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "poll_unsubscriptions", ["poll_id", "user_id"], name: "index_poll_unsubscriptions_on_poll_id_and_user_id", unique: true, using: :btree
  add_index "poll_unsubscriptions", ["poll_id"], name: "index_poll_unsubscriptions_on_poll_id", using: :btree
  add_index "poll_unsubscriptions", ["user_id"], name: "index_poll_unsubscriptions_on_user_id", using: :btree

  create_table "polls", force: :cascade do |t|
    t.integer  "author_id",                             null: false
    t.string   "title",                                 null: false
    t.text     "details"
    t.datetime "closing_at"
    t.datetime "closed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "discussion_id"
    t.string   "key",                                   null: false
    t.string   "poll_type",                             null: false
    t.jsonb    "stance_data",           default: {}
    t.integer  "stances_count",         default: 0,     null: false
    t.boolean  "multiple_choice",       default: false, null: false
    t.jsonb    "custom_fields",         default: {},    null: false
    t.jsonb    "stance_counts",         default: [],    null: false
    t.integer  "group_id"
    t.jsonb    "matrix_counts",         default: [],    null: false
    t.boolean  "notify_on_participate", default: false, null: false
    t.boolean  "example",               default: false, null: false
    t.integer  "undecided_user_count",  default: 0,     null: false
    t.boolean  "voter_can_add_options", default: false, null: false
    t.integer  "guest_group_id"
  end

  add_index "polls", ["author_id"], name: "index_polls_on_author_id", using: :btree
  add_index "polls", ["discussion_id"], name: "index_polls_on_discussion_id", using: :btree
  add_index "polls", ["group_id"], name: "index_polls_on_group_id", using: :btree
  add_index "polls", ["guest_group_id"], name: "index_polls_on_guest_group_id", unique: true, using: :btree

  create_table "reactions", force: :cascade do |t|
    t.integer  "reactable_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reaction",       default: "+1",      null: false
    t.string   "reactable_type", default: "Comment", null: false
  end

  add_index "reactions", ["created_at"], name: "index_reactions_on_created_at", using: :btree
  add_index "reactions", ["reactable_id", "reactable_type"], name: "index_reactions_on_reactable_id_and_reactable_type", using: :btree
  add_index "reactions", ["user_id"], name: "index_reactions_on_user_id", using: :btree

  create_table "stance_choices", force: :cascade do |t|
    t.integer  "stance_id"
    t.integer  "poll_option_id"
    t.integer  "score",          default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stance_choices", ["poll_option_id"], name: "index_stance_choices_on_poll_option_id", using: :btree
  add_index "stance_choices", ["stance_id"], name: "index_stance_choices_on_stance_id", using: :btree

  create_table "stances", force: :cascade do |t|
    t.integer  "poll_id",                       null: false
    t.integer  "participant_id",                null: false
    t.string   "reason"
    t.boolean  "latest",         default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stances", ["participant_id"], name: "index_stances_on_participant_id", using: :btree
  add_index "stances", ["poll_id"], name: "index_stances_on_poll_id", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.string  "kind"
    t.date    "expires_at"
    t.date    "trial_ended_at"
    t.date    "activated_at"
    t.integer "chargify_subscription_id"
    t.string  "plan"
    t.string  "payment_method",           default: "chargify", null: false
  end

  add_index "subscriptions", ["kind"], name: "index_subscriptions_on_kind", using: :btree

  create_table "tags", force: :cascade do |t|
    t.integer  "group_id"
    t.string   "name"
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "discussion_tags_count", default: 0
  end

  create_table "themes", force: :cascade do |t|
    t.text     "style"
    t.string   "name",                    limit: 255
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "pages_logo_file_name",    limit: 255
    t.string   "pages_logo_content_type", limit: 255
    t.integer  "pages_logo_file_size"
    t.datetime "pages_logo_updated_at"
    t.string   "app_logo_file_name",      limit: 255
    t.string   "app_logo_content_type",   limit: 255
    t.integer  "app_logo_file_size"
    t.datetime "app_logo_updated_at"
    t.text     "javascript"
  end

  create_table "translations", force: :cascade do |t|
    t.integer  "translatable_id"
    t.string   "translatable_type", limit: 255
    t.hstore   "fields"
    t.string   "language",          limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "translations", ["translatable_type", "translatable_id"], name: "index_translations_on_translatable_type_and_translatable_id", using: :btree

  create_table "usage_reports", force: :cascade do |t|
    t.integer  "groups_count"
    t.integer  "users_count"
    t.integer  "discussions_count"
    t.integer  "polls_count"
    t.integer  "comments_count"
    t.integer  "stances_count"
    t.integer  "visits_count"
    t.string   "canonical_host"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version"
  end

  add_index "usage_reports", ["canonical_host"], name: "index_usage_reports_on_canonical_host", using: :btree

  create_table "user_deactivation_responses", force: :cascade do |t|
    t.integer "user_id"
    t.text    "body"
  end

  add_index "user_deactivation_responses", ["user_id"], name: "index_user_deactivation_responses_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.citext   "email",                                        default: "",                    null: false
    t.string   "encrypted_password",               limit: 128, default: ""
    t.string   "reset_password_token",             limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",               limit: 255
    t.string   "last_sign_in_ip",                  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                             limit: 255
    t.datetime "deactivated_at"
    t.boolean  "is_admin",                                     default: false
    t.string   "avatar_kind",                      limit: 255, default: "initials",            null: false
    t.string   "uploaded_avatar_file_name",        limit: 255
    t.string   "uploaded_avatar_content_type",     limit: 255
    t.integer  "uploaded_avatar_file_size"
    t.datetime "uploaded_avatar_updated_at"
    t.string   "avatar_initials",                  limit: 255
    t.string   "username",                         limit: 255
    t.boolean  "email_when_proposal_closing_soon",             default: false,                 null: false
    t.string   "authentication_token",             limit: 255
    t.string   "unsubscribe_token",                limit: 255
    t.integer  "memberships_count",                            default: 0,                     null: false
    t.boolean  "uses_markdown",                                default: false,                 null: false
    t.string   "selected_locale",                  limit: 255
    t.string   "time_zone",                        limit: 255
    t.string   "key",                              limit: 255
    t.string   "detected_locale",                  limit: 255
    t.boolean  "email_missed_yesterday",                       default: true,                  null: false
    t.string   "email_api_key",                    limit: 255
    t.boolean  "email_when_mentioned",                         default: true,                  null: false
    t.boolean  "angular_ui_enabled",                           default: true,                  null: false
    t.boolean  "email_on_participation",                       default: true,                  null: false
    t.integer  "default_membership_volume",                    default: 2,                     null: false
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.jsonb    "experiences",                                  default: {},                    null: false
    t.integer  "facebook_community_id"
    t.integer  "slack_community_id"
    t.string   "remember_token"
    t.string   "short_bio",                                    default: "",                    null: false
    t.boolean  "email_verified",                               default: false,                 null: false
    t.string   "location",                                     default: "",                    null: false
    t.datetime "last_seen_at",                                 default: '2017-10-18 21:05:12', null: false
  end

  add_index "users", ["deactivated_at"], name: "index_users_on_deactivated_at", using: :btree
  add_index "users", ["email"], name: "email_verified_and_unique", unique: true, where: "(email_verified IS TRUE)", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["key"], name: "index_users_on_key", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unsubscribe_token"], name: "index_users_on_unsubscribe_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255, null: false
    t.integer  "item_id",                    null: false
    t.string   "event",          limit: 255, null: false
    t.integer  "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.jsonb    "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  add_index "versions", ["whodunnit"], name: "index_versions_on_whodunnit", using: :btree

  create_table "visits", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid     "visitor_id"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "landing_page"
    t.integer  "user_id"
    t.string   "referring_domain"
    t.string   "search_keyword"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.integer  "screen_height"
    t.integer  "screen_width"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "started_at"
  end

  add_index "visits", ["user_id"], name: "index_visits_on_user_id", using: :btree

  create_table "webhooks", force: :cascade do |t|
    t.integer "hookable_id"
    t.string  "hookable_type"
    t.string  "kind",                       null: false
    t.string  "uri",                        null: false
    t.text    "event_types",   default: [],              array: true
  end

  add_index "webhooks", ["hookable_type", "hookable_id"], name: "index_webhooks_on_hookable_type_and_hookable_id", using: :btree

end
