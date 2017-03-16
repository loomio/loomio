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

ActiveRecord::Schema.define(version: 20170314040259) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

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
    t.text     "subject"
    t.text     "content"
    t.datetime "sent_at"
    t.datetime "opened_at"
    t.datetime "clicked_at"
  end

  add_index "ahoy_messages", ["token"], name: "index_ahoy_messages_on_token", using: :btree
  add_index "ahoy_messages", ["user_id", "user_type"], name: "index_ahoy_messages_on_user_id_and_user_type", using: :btree

  create_table "attachments", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "filename"
    t.text     "location"
    t.integer  "comment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "filesize"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "attachable_id"
    t.string   "attachable_type"
  end

  add_index "attachments", ["comment_id"], name: "index_attachments_on_comment_id", using: :btree

  create_table "blacklisted_passwords", force: :cascade do |t|
    t.string   "string"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blacklisted_passwords", ["string"], name: "index_blacklisted_passwords_on_string", using: :hash

  create_table "blog_stories", force: :cascade do |t|
    t.string   "title"
    t.string   "url"
    t.string   "image_url"
    t.datetime "published_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",   default: 0, null: false
  end

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

  create_table "comment_votes", force: :cascade do |t|
    t.integer  "comment_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comment_votes", ["comment_id"], name: "index_comment_votes_on_comment_id", using: :btree
  add_index "comment_votes", ["created_at"], name: "index_comment_votes_on_created_at", using: :btree
  add_index "comment_votes", ["user_id"], name: "index_comment_votes_on_user_id", using: :btree

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
  add_index "comments", ["discussion_id"], name: "index_comments_on_discussion_id", using: :btree
  add_index "comments", ["parent_id"], name: "index_comments_on_parent_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "communities", force: :cascade do |t|
    t.string   "community_type",              null: false
    t.jsonb    "custom_fields",  default: {}, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contact_messages", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.string   "email"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "destination", default: "contact@loomio.org"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "email"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "did_not_votes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "motion_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "did_not_votes", ["motion_id"], name: "index_did_not_votes_on_motion_id", using: :btree
  add_index "did_not_votes", ["user_id"], name: "index_did_not_votes_on_user_id", using: :btree

  create_table "discussion_readers", force: :cascade do |t|
    t.integer  "user_id",                                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "discussion_id",                            null: false
    t.datetime "last_read_at"
    t.integer  "read_items_count",         default: 0,     null: false
    t.integer  "last_read_sequence_id",    default: 0,     null: false
    t.integer  "read_salient_items_count", default: 0,     null: false
    t.integer  "volume"
    t.boolean  "participating",            default: false, null: false
    t.boolean  "starred",                  default: false, null: false
    t.datetime "dismissed_at"
  end

  add_index "discussion_readers", ["discussion_id"], name: "index_discussion_readers_on_discussion_id", using: :btree
  add_index "discussion_readers", ["participating"], name: "index_discussion_readers_on_participating", using: :btree
  add_index "discussion_readers", ["starred"], name: "index_discussion_readers_on_starred", using: :btree
  add_index "discussion_readers", ["user_id", "discussion_id"], name: "index_discussion_readers_on_user_id_and_discussion_id", using: :btree
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
    t.string   "title"
    t.datetime "last_comment_at"
    t.text     "description"
    t.boolean  "uses_markdown",        default: false, null: false
    t.boolean  "is_deleted",           default: false, null: false
    t.integer  "items_count",          default: 0,     null: false
    t.boolean  "private"
    t.string   "key"
    t.datetime "archived_at"
    t.string   "iframe_src"
    t.integer  "motions_count",        default: 0
    t.datetime "last_activity_at"
    t.integer  "last_sequence_id",     default: 0,     null: false
    t.integer  "first_sequence_id",    default: 0,     null: false
    t.integer  "salient_items_count",  default: 0,     null: false
    t.integer  "versions_count",       default: 0
    t.integer  "closed_motions_count", default: 0,     null: false
    t.integer  "closed_polls_count",   default: 0,     null: false
  end

  add_index "discussions", ["author_id"], name: "index_discussions_on_author_id", using: :btree
  add_index "discussions", ["created_at"], name: "index_discussions_on_created_at", using: :btree
  add_index "discussions", ["group_id"], name: "index_discussions_on_group_id", using: :btree
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
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "eventable_id"
    t.string   "eventable_type"
    t.integer  "user_id"
    t.integer  "discussion_id"
    t.integer  "sequence_id"
    t.boolean  "announcement",   default: false, null: false
    t.jsonb    "custom_fields",  default: {},    null: false
  end

  add_index "events", ["created_at"], name: "index_events_on_created_at", using: :btree
  add_index "events", ["discussion_id", "sequence_id"], name: "index_events_on_discussion_id_and_sequence_id", unique: true, using: :btree
  add_index "events", ["discussion_id"], name: "index_events_on_discussion_id", using: :btree
  add_index "events", ["eventable_type", "eventable_id"], name: "index_events_on_eventable_type_and_eventable_id", using: :btree
  add_index "events", ["sequence_id"], name: "index_events_on_sequence_id", using: :btree

  create_table "group_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

  add_index "group_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "group_anc_desc_udx", unique: true, using: :btree
  add_index "group_hierarchies", ["descendant_id"], name: "group_desc_idx", using: :btree

  create_table "group_requests", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "admin_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.integer  "group_id"
    t.boolean  "cannot_contribute"
    t.string   "expected_size"
    t.integer  "max_size",            default: 300
    t.string   "robot_trap"
    t.integer  "distribution_metric"
    t.string   "sectors"
    t.string   "other_sector"
    t.string   "token"
    t.string   "admin_name"
    t.string   "country_name"
    t.boolean  "high_touch",          default: false, null: false
    t.datetime "approved_at"
    t.datetime "defered_until"
    t.integer  "approved_by_id"
    t.text     "why_do_you_want"
    t.text     "group_core_purpose"
    t.text     "admin_notes"
    t.boolean  "is_commercial"
  end

  add_index "group_requests", ["group_id"], name: "index_group_requests_on_group_id", using: :btree

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
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.text     "description"
    t.datetime "archived_at"
    t.integer  "memberships_count",                  default: 0,     null: false
    t.integer  "discussions_count",                  default: 0,     null: false
    t.string   "full_name"
    t.boolean  "parent_members_can_see_discussions", default: false, null: false
    t.string   "key"
    t.integer  "category_id"
    t.boolean  "is_visible_to_public",               default: true,  null: false
    t.boolean  "is_visible_to_parent_members",       default: false, null: false
    t.string   "discussion_privacy_options",                         null: false
    t.boolean  "members_can_add_members",            default: true,  null: false
    t.string   "membership_granted_upon",                            null: false
    t.string   "subdomain"
    t.integer  "theme_id"
    t.string   "cover_photo_file_name"
    t.string   "cover_photo_content_type"
    t.integer  "cover_photo_file_size"
    t.datetime "cover_photo_updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.boolean  "members_can_edit_discussions",       default: true,  null: false
    t.boolean  "motions_can_be_edited",              default: false, null: false
    t.boolean  "members_can_edit_comments",          default: true
    t.boolean  "members_can_raise_motions",          default: true,  null: false
    t.boolean  "members_can_vote",                   default: true,  null: false
    t.boolean  "members_can_start_discussions",      default: true,  null: false
    t.boolean  "members_can_create_subgroups",       default: false, null: false
    t.integer  "creator_id"
    t.boolean  "is_referral",                        default: false, null: false
    t.integer  "cohort_id"
    t.integer  "default_group_cover_id"
    t.integer  "subscription_id"
    t.integer  "motions_count",                      default: 0,     null: false
    t.integer  "admin_memberships_count",            default: 0,     null: false
    t.integer  "invitations_count",                  default: 0,     null: false
    t.integer  "public_discussions_count",           default: 0,     null: false
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.integer  "closed_motions_count",               default: 0,     null: false
    t.boolean  "enable_experiments",                 default: false
    t.boolean  "analytics_enabled",                  default: false, null: false
    t.integer  "proposal_outcomes_count",            default: 0,     null: false
    t.jsonb    "experiences",                        default: {},    null: false
    t.integer  "pending_invitations_count",          default: 0,     null: false
    t.jsonb    "features",                           default: {},    null: false
    t.integer  "recent_activity_count",              default: 0,     null: false
    t.integer  "community_id"
    t.integer  "closed_polls_count",                 default: 0,     null: false
    t.integer  "announcement_recipients_count",      default: 0,     null: false
  end

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

  create_table "invitations", force: :cascade do |t|
    t.string   "recipient_email"
    t.integer  "inviter_id"
    t.boolean  "to_be_admin",     default: false, null: false
    t.string   "token",                           null: false
    t.datetime "accepted_at"
    t.string   "intent"
    t.integer  "canceller_id"
    t.datetime "cancelled_at"
    t.string   "recipient_name"
    t.integer  "invitable_id"
    t.string   "invitable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "single_use",      default: true,  null: false
    t.text     "message"
    t.integer  "send_count",      default: 0,     null: false
  end

  add_index "invitations", ["accepted_at"], name: "index_invitations_on_accepted_at", where: "(accepted_at IS NULL)", using: :btree
  add_index "invitations", ["created_at"], name: "index_invitations_on_created_at", using: :btree
  add_index "invitations", ["invitable_type", "invitable_id"], name: "index_invitations_on_invitable_type_and_invitable_id", using: :btree
  add_index "invitations", ["token"], name: "index_invitations_on_token", using: :btree

  create_table "membership_requests", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.text     "introduction"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "requestor_id"
    t.integer  "responder_id"
    t.string   "response"
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
    t.integer  "inbox_position", default: 0
    t.datetime "archived_at"
    t.boolean  "admin",          default: false, null: false
    t.boolean  "is_suspended",   default: false, null: false
    t.integer  "volume",         default: 2,     null: false
    t.jsonb    "experiences",    default: {},    null: false
  end

  add_index "memberships", ["created_at"], name: "index_memberships_on_created_at", using: :btree
  add_index "memberships", ["group_id", "user_id", "is_suspended", "archived_at"], name: "active_memberships", using: :btree
  add_index "memberships", ["group_id"], name: "index_memberships_on_group_id", using: :btree
  add_index "memberships", ["inviter_id"], name: "index_memberships_on_inviter_id", using: :btree
  add_index "memberships", ["user_id", "volume"], name: "index_memberships_on_user_id_and_volume", using: :btree
  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree
  add_index "memberships", ["volume"], name: "index_memberships_on_volume", using: :btree

  create_table "motion_readers", force: :cascade do |t|
    t.integer  "motion_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_read_at"
    t.integer  "read_votes_count",    default: 0, null: false
    t.integer  "read_activity_count", default: 0, null: false
  end

  add_index "motion_readers", ["user_id", "motion_id"], name: "index_motion_readers_on_user_id_and_motion_id", using: :btree

  create_table "motions", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "closed_at"
    t.integer  "discussion_id"
    t.text     "outcome"
    t.datetime "last_vote_at"
    t.integer  "yes_votes_count",     default: 0, null: false
    t.integer  "no_votes_count",      default: 0, null: false
    t.integer  "abstain_votes_count", default: 0, null: false
    t.integer  "block_votes_count",   default: 0, null: false
    t.datetime "closing_at"
    t.integer  "votes_count",         default: 0, null: false
    t.integer  "outcome_author_id"
    t.string   "key"
    t.integer  "members_count",       default: 0, null: false
    t.integer  "voters_count",        default: 0, null: false
  end

  add_index "motions", ["author_id"], name: "index_motions_on_author_id", using: :btree
  add_index "motions", ["closed_at"], name: "index_motions_on_closed_at", using: :btree
  add_index "motions", ["closing_at"], name: "index_motions_on_closing_at", using: :btree
  add_index "motions", ["created_at"], name: "index_motions_on_created_at", using: :btree
  add_index "motions", ["discussion_id", "closed_at"], name: "index_motions_on_discussion_id_and_closed_at", order: {"closed_at"=>:desc}, using: :btree
  add_index "motions", ["discussion_id"], name: "index_motions_on_discussion_id", using: :btree
  add_index "motions", ["key"], name: "index_motions_on_key", unique: true, using: :btree

  create_table "network_coordinators", force: :cascade do |t|
    t.integer  "coordinator_id", null: false
    t.integer  "network_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "network_coordinators", ["coordinator_id", "network_id"], name: "index_network_coordinators_on_coordinator_id_and_network_id", unique: true, using: :btree

  create_table "network_membership_requests", force: :cascade do |t|
    t.integer  "requestor_id", null: false
    t.integer  "responder_id"
    t.integer  "group_id",     null: false
    t.integer  "network_id",   null: false
    t.boolean  "approved"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "network_membership_requests", ["group_id"], name: "index_network_membership_requests_on_group_id", using: :btree
  add_index "network_membership_requests", ["network_id"], name: "index_network_membership_requests_on_network_id", using: :btree

  create_table "network_memberships", force: :cascade do |t|
    t.integer  "group_id",   null: false
    t.integer  "network_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "network_memberships", ["group_id", "network_id"], name: "index_network_memberships_on_group_id_and_network_id", unique: true, using: :btree

  create_table "networks", force: :cascade do |t|
    t.string   "name",             null: false
    t.string   "slug",             null: false
    t.text     "description"
    t.text     "joining_criteria"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "networks", ["name"], name: "index_networks_on_name", unique: true, using: :btree
  add_index "networks", ["slug"], name: "index_networks_on_slug", unique: true, using: :btree

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
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
  end

  add_index "omniauth_identities", ["email"], name: "index_omniauth_identities_on_email", using: :btree
  add_index "omniauth_identities", ["provider", "uid"], name: "index_omniauth_identities_on_provider_and_uid", using: :btree
  add_index "omniauth_identities", ["user_id"], name: "index_omniauth_identities_on_user_id", using: :btree

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
    t.text     "statement",                 null: false
    t.integer  "author_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "latest",     default: true, null: false
  end

  create_table "poll_communities", force: :cascade do |t|
    t.integer "poll_id",      null: false
    t.integer "community_id", null: false
  end

  create_table "poll_did_not_votes", force: :cascade do |t|
    t.integer "poll_id"
    t.integer "user_id"
  end

  create_table "poll_options", force: :cascade do |t|
    t.string  "name",                 null: false
    t.integer "poll_id"
    t.integer "priority", default: 0, null: false
  end

  add_index "poll_options", ["priority"], name: "index_poll_options_on_priority", using: :btree

  create_table "poll_references", force: :cascade do |t|
    t.integer "reference_id",   null: false
    t.string  "reference_type", null: false
    t.integer "poll_id",        null: false
  end

  create_table "polls", force: :cascade do |t|
    t.integer  "author_id",                           null: false
    t.string   "title",                               null: false
    t.text     "details"
    t.datetime "closing_at"
    t.datetime "closed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "discussion_id"
    t.string   "key",                                 null: false
    t.string   "poll_type",                           null: false
    t.integer  "motion_id"
    t.jsonb    "stance_data",         default: {}
    t.integer  "stances_count",       default: 0,     null: false
    t.boolean  "multiple_choice",     default: false, null: false
    t.jsonb    "custom_fields",       default: {},    null: false
    t.jsonb    "stance_counts",       default: [],    null: false
    t.integer  "did_not_votes_count", default: 0,     null: false
    t.integer  "group_id"
    t.jsonb    "matrix_counts",       default: [],    null: false
  end

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
    t.integer  "poll_id",                         null: false
    t.integer  "participant_id",                  null: false
    t.string   "participant_type",                null: false
    t.string   "reason"
    t.boolean  "latest",           default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.integer  "discussion_tags_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "themes", force: :cascade do |t|
    t.text     "style"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pages_logo_file_name"
    t.string   "pages_logo_content_type"
    t.integer  "pages_logo_file_size"
    t.datetime "pages_logo_updated_at"
    t.string   "app_logo_file_name"
    t.string   "app_logo_content_type"
    t.integer  "app_logo_file_size"
    t.datetime "app_logo_updated_at"
    t.text     "javascript"
  end

  create_table "translations", force: :cascade do |t|
    t.integer  "translatable_id"
    t.string   "translatable_type"
    t.hstore   "fields"
    t.string   "language"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "translations", ["translatable_type", "translatable_id"], name: "index_translations_on_translatable_type_and_translatable_id", using: :btree

  create_table "user_deactivation_responses", force: :cascade do |t|
    t.integer "user_id"
    t.text    "body"
  end

  add_index "user_deactivation_responses", ["user_id"], name: "index_user_deactivation_responses_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                            default: "",         null: false
    t.string   "encrypted_password",               default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.datetime "deactivated_at"
    t.string   "avatar_kind",                      default: "initials", null: false
    t.string   "uploaded_avatar_file_name"
    t.string   "uploaded_avatar_content_type"
    t.integer  "uploaded_avatar_file_size"
    t.datetime "uploaded_avatar_updated_at"
    t.boolean  "is_admin",                         default: false
    t.string   "avatar_initials"
    t.string   "username"
    t.boolean  "email_when_proposal_closing_soon", default: false,      null: false
    t.string   "authentication_token"
    t.string   "unsubscribe_token"
    t.integer  "memberships_count",                default: 0,          null: false
    t.boolean  "uses_markdown",                    default: false,      null: false
    t.string   "selected_locale"
    t.string   "time_zone"
    t.string   "key"
    t.string   "detected_locale"
    t.boolean  "email_missed_yesterday",           default: true,       null: false
    t.string   "email_api_key"
    t.boolean  "email_when_mentioned",             default: true,       null: false
    t.boolean  "angular_ui_enabled",               default: true,       null: false
    t.boolean  "email_on_participation",           default: false,      null: false
    t.integer  "default_membership_volume",        default: 2,          null: false
    t.jsonb    "experiences",                      default: {},         null: false
    t.string   "country"
    t.string   "region"
    t.string   "city"
  end

  add_index "users", ["deactivated_at"], name: "index_users_on_deactivated_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["key"], name: "index_users_on_key", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unsubscribe_token"], name: "index_users_on_unsubscribe_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.jsonb    "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "visitors", force: :cascade do |t|
    t.string   "participation_token"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_kind",         default: "initials", null: false
    t.string   "avatar_initials"
    t.integer  "community_id",                             null: false
    t.boolean  "revoked",             default: false,      null: false
  end

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

  create_table "votes", force: :cascade do |t|
    t.integer  "motion_id"
    t.integer  "user_id"
    t.string   "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "statement"
    t.integer  "age",              default: 0, null: false
    t.integer  "previous_vote_id"
  end

  add_index "votes", ["created_at"], name: "index_votes_on_created_at", using: :btree
  add_index "votes", ["motion_id", "user_id", "age"], name: "vote_age_per_user_per_motion", unique: true, using: :btree
  add_index "votes", ["motion_id", "user_id"], name: "index_votes_on_motion_id_and_user_id", using: :btree
  add_index "votes", ["motion_id"], name: "index_votes_on_motion_id", using: :btree

  create_table "webhooks", force: :cascade do |t|
    t.integer "hookable_id"
    t.string  "hookable_type"
    t.string  "kind",                       null: false
    t.string  "uri",                        null: false
    t.text    "event_types",   default: [],              array: true
  end

  add_index "webhooks", ["hookable_type", "hookable_id"], name: "index_webhooks_on_hookable_type_and_hookable_id", using: :btree

end
