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

ActiveRecord::Schema.define(version: 20150512034525) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

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

  create_table "announcement_dismissals", force: :cascade do |t|
    t.integer  "announcement_id"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "announcement_dismissals", ["announcement_id"], name: "index_announcement_dismissals_on_announcement_id", using: :btree
  add_index "announcement_dismissals", ["user_id"], name: "index_announcement_dismissals_on_user_id", using: :btree

  create_table "announcements", force: :cascade do |t|
    t.text     "message",                               null: false
    t.string   "locale",     limit: 255, default: "en", null: false
    t.datetime "starts_at",                             null: false
    t.datetime "ends_at",                               null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "attachments", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "filename",   limit: 255
    t.text     "location"
    t.integer  "comment_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "filesize"
  end

  add_index "attachments", ["comment_id"], name: "index_attachments_on_comment_id", using: :btree

  create_table "blacklisted_passwords", force: :cascade do |t|
    t.string   "string",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blacklisted_passwords", ["string"], name: "index_blacklisted_passwords_on_string", using: :hash

  create_table "campaigns", force: :cascade do |t|
    t.string   "showcase_url",  limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "name",          limit: 255, null: false
    t.string   "manager_email", limit: 255, null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "position",               default: 0, null: false
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
  add_index "comment_votes", ["user_id"], name: "index_comment_votes_on_user_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "discussion_id",                   default: 0
    t.text     "body",                            default: ""
    t.string   "subject",             limit: 255, default: ""
    t.integer  "user_id",                         default: 0,     null: false
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "uses_markdown",                   default: false, null: false
    t.integer  "comment_votes_count",             default: 0,     null: false
    t.integer  "attachments_count",               default: 0,     null: false
    t.text     "liker_ids_and_names"
    t.datetime "edited_at"
  end

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
    t.integer  "read_comments_count",      default: 0,     null: false
    t.integer  "read_items_count",         default: 0,     null: false
    t.integer  "last_read_sequence_id",    default: 0,     null: false
    t.integer  "read_salient_items_count", default: 0,     null: false
    t.integer  "volume"
    t.boolean  "participating",            default: false, null: false
  end

  add_index "discussion_readers", ["discussion_id"], name: "index_motion_read_logs_on_discussion_id", using: :btree
  add_index "discussion_readers", ["user_id", "discussion_id"], name: "index_discussion_readers_on_user_id_and_discussion_id", unique: true, using: :btree
  add_index "discussion_readers", ["user_id"], name: "index_motion_read_logs_on_user_id", using: :btree

  create_table "discussion_search_vectors", force: :cascade do |t|
    t.integer  "discussion_id"
    t.tsvector "search_vector"
  end

  add_index "discussion_search_vectors", ["search_vector"], name: "discussion_search_vector_index", using: :gin

  create_table "discussions", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",               limit: 255
    t.datetime "last_comment_at"
    t.text     "description"
    t.boolean  "uses_markdown",                   default: false, null: false
    t.boolean  "is_deleted",                      default: false, null: false
    t.integer  "comments_count",                  default: 0,     null: false
    t.integer  "items_count",                     default: 0,     null: false
    t.datetime "archived_at"
    t.boolean  "private"
    t.string   "key",                 limit: 255
    t.string   "iframe_src",          limit: 255
    t.datetime "last_activity_at"
    t.integer  "motions_count",                   default: 0
    t.integer  "last_sequence_id",                default: 0,     null: false
    t.integer  "first_sequence_id",               default: 0,     null: false
    t.datetime "last_item_at"
    t.integer  "salient_items_count",             default: 0,     null: false
  end

  add_index "discussions", ["author_id"], name: "index_discussions_on_author_id", using: :btree
  add_index "discussions", ["group_id"], name: "index_discussions_on_group_id", using: :btree
  add_index "discussions", ["is_deleted", "group_id"], name: "index_discussions_on_is_deleted_and_group_id", using: :btree
  add_index "discussions", ["is_deleted", "id"], name: "index_discussions_on_is_deleted_and_id", using: :btree
  add_index "discussions", ["is_deleted"], name: "index_discussions_on_is_deleted", using: :btree
  add_index "discussions", ["key"], name: "index_discussions_on_key", unique: true, using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "kind",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "eventable_id"
    t.string   "eventable_type", limit: 255
    t.integer  "user_id"
    t.integer  "discussion_id"
    t.integer  "sequence_id"
  end

  add_index "events", ["created_at"], name: "index_events_on_created_at", using: :btree
  add_index "events", ["discussion_id", "sequence_id"], name: "index_events_on_discussion_id_and_sequence_id", unique: true, using: :btree
  add_index "events", ["discussion_id"], name: "index_events_on_discussion_id", using: :btree
  add_index "events", ["eventable_type", "eventable_id"], name: "index_events_on_eventable_type_and_eventable_id", using: :btree

  create_table "group_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

  add_index "group_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "group_anc_desc_udx", unique: true, using: :btree
  add_index "group_hierarchies", ["descendant_id"], name: "group_desc_idx", using: :btree

  create_table "group_requests", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.text     "description"
    t.string   "admin_email",         limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "status",              limit: 255
    t.integer  "group_id"
    t.boolean  "cannot_contribute"
    t.string   "expected_size",       limit: 255
    t.integer  "max_size",                        default: 300
    t.string   "robot_trap",          limit: 255
    t.integer  "distribution_metric"
    t.string   "sectors",             limit: 255
    t.string   "other_sector",        limit: 255
    t.string   "token",               limit: 255
    t.string   "admin_name",          limit: 255
    t.string   "country_name",        limit: 255
    t.boolean  "high_touch",                      default: false, null: false
    t.datetime "approved_at"
    t.datetime "defered_until"
    t.integer  "approved_by_id"
    t.text     "why_do_you_want"
    t.text     "group_core_purpose"
    t.text     "admin_notes"
    t.boolean  "is_commercial"
  end

  add_index "group_requests", ["group_id"], name: "index_group_requests_on_group_id", using: :btree

  create_table "group_setups", force: :cascade do |t|
    t.integer  "group_id"
    t.string   "group_name",             limit: 255
    t.text     "group_description"
    t.string   "viewable_by",            limit: 255, default: "members"
    t.string   "members_invitable_by",   limit: 255, default: "admins"
    t.string   "discussion_title",       limit: 255
    t.text     "discussion_description"
    t.string   "motion_title",           limit: 255
    t.text     "motion_description"
    t.date     "close_at_date"
    t.string   "close_at_time_zone",     limit: 255
    t.string   "close_at_time",          limit: 255
    t.string   "admin_email",            limit: 255
    t.text     "recipients"
    t.string   "message_subject",        limit: 255
    t.text     "message_body"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name",                               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "members_invitable_by",               limit: 255
    t.integer  "parent_id"
    t.boolean  "hide_members",                                   default: false
    t.text     "description"
    t.integer  "memberships_count",                              default: 0,              null: false
    t.datetime "archived_at"
    t.integer  "max_size",                                       default: 100,            null: false
    t.boolean  "cannot_contribute",                              default: false
    t.integer  "distribution_metric"
    t.string   "sectors",                            limit: 255
    t.string   "other_sector",                       limit: 255
    t.integer  "discussions_count",                              default: 0,              null: false
    t.string   "country_name",                       limit: 255
    t.datetime "setup_completed_at"
    t.boolean  "next_steps_completed",                           default: false,          null: false
    t.string   "full_name",                          limit: 255
    t.string   "payment_plan",                       limit: 255, default: "undetermined"
    t.boolean  "parent_members_can_see_discussions",             default: false,          null: false
    t.string   "key",                                limit: 255
    t.boolean  "can_start_group",                                default: true
    t.integer  "category_id"
    t.text     "enabled_beta_features"
    t.string   "subdomain",                          limit: 255
    t.integer  "theme_id"
    t.boolean  "is_visible_to_public",                           default: false,          null: false
    t.boolean  "is_visible_to_parent_members",                   default: false,          null: false
    t.string   "discussion_privacy_options",         limit: 255,                          null: false
    t.boolean  "members_can_add_members",                        default: false,          null: false
    t.string   "membership_granted_upon",            limit: 255,                          null: false
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
    t.boolean  "members_can_create_subgroups",                   default: true,           null: false
    t.integer  "creator_id"
    t.boolean  "is_commercial"
    t.boolean  "is_referral",                                    default: false,          null: false
  end

  add_index "groups", ["archived_at", "id"], name: "index_groups_on_archived_at_and_id", using: :btree
  add_index "groups", ["category_id"], name: "index_groups_on_category_id", using: :btree
  add_index "groups", ["full_name"], name: "index_groups_on_full_name", using: :btree
  add_index "groups", ["is_visible_to_public"], name: "index_groups_on_is_visible_to_public", using: :btree
  add_index "groups", ["key"], name: "index_groups_on_key", unique: true, using: :btree
  add_index "groups", ["name"], name: "index_groups_on_name", using: :btree
  add_index "groups", ["parent_id"], name: "index_groups_on_parent_id", using: :btree

  create_table "invitations", force: :cascade do |t|
    t.string   "recipient_email", limit: 255,                 null: false
    t.integer  "inviter_id",                                  null: false
    t.boolean  "to_be_admin",                 default: false, null: false
    t.string   "token",           limit: 255,                 null: false
    t.integer  "accepted_by_id"
    t.datetime "accepted_at"
    t.string   "intent",          limit: 255
    t.integer  "canceller_id"
    t.datetime "cancelled_at"
    t.string   "recipient_name",  limit: 255
    t.integer  "invitable_id"
    t.string   "invitable_type",  limit: 255
  end

  add_index "invitations", ["token"], name: "index_invitations_on_token", using: :btree

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
  end

  add_index "memberships", ["group_id"], name: "index_memberships_on_group_id", using: :btree
  add_index "memberships", ["inviter_id"], name: "index_memberships_on_inviter_id", using: :btree
  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree

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
    t.string   "name",                limit: 255
    t.text     "description"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "closed_at"
    t.integer  "discussion_id"
    t.text     "outcome"
    t.datetime "last_vote_at"
    t.boolean  "uses_markdown",                   default: true, null: false
    t.integer  "yes_votes_count",                 default: 0,    null: false
    t.integer  "no_votes_count",                  default: 0,    null: false
    t.integer  "abstain_votes_count",             default: 0,    null: false
    t.integer  "block_votes_count",               default: 0,    null: false
    t.datetime "closing_at"
    t.integer  "did_not_votes_count"
    t.integer  "votes_count",                     default: 0,    null: false
    t.integer  "outcome_author_id"
    t.string   "key",                 limit: 255
  end

  add_index "motions", ["author_id"], name: "index_motions_on_author_id", using: :btree
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
    t.boolean  "viewed",     default: false, null: false
  end

  add_index "notifications", ["event_id", "user_id"], name: "index_notifications_on_event_id_and_user_id", using: :btree
  add_index "notifications", ["event_id"], name: "index_notifications_on_event_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree
  add_index "notifications", ["viewed"], name: "index_notifications_on_viewed", using: :btree

  create_table "omniauth_identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "email",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.string   "name",       limit: 255
  end

  add_index "omniauth_identities", ["email"], name: "index_personas_on_email", using: :btree
  add_index "omniauth_identities", ["provider", "uid"], name: "index_omniauth_identities_on_provider_and_uid", using: :btree
  add_index "omniauth_identities", ["user_id"], name: "index_personas_on_user_id", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "group_id"
    t.decimal  "amount",                 precision: 8, scale: 2
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "profile_id", limit: 255
  end

  add_index "subscriptions", ["group_id"], name: "index_subscriptions_on_group_id", using: :btree

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

  create_table "user_deactivation_responses", force: :cascade do |t|
    t.integer "user_id"
    t.text    "body"
  end

  add_index "user_deactivation_responses", ["user_id"], name: "index_user_deactivation_responses_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                            limit: 255, default: "",         null: false
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
    t.string   "avatar_kind",                      limit: 255, default: "initials", null: false
    t.string   "uploaded_avatar_file_name",        limit: 255
    t.string   "uploaded_avatar_content_type",     limit: 255
    t.integer  "uploaded_avatar_file_size"
    t.datetime "uploaded_avatar_updated_at"
    t.string   "avatar_initials",                  limit: 255
    t.string   "username",                         limit: 255
    t.boolean  "email_when_proposal_closing_soon",             default: false,      null: false
    t.string   "authentication_token",             limit: 255
    t.string   "unsubscribe_token",                limit: 255
    t.integer  "memberships_count",                            default: 0,          null: false
    t.boolean  "uses_markdown",                                default: false,      null: false
    t.string   "selected_locale",                  limit: 255
    t.string   "time_zone",                        limit: 255
    t.string   "key",                              limit: 255
    t.string   "detected_locale",                  limit: 255
    t.boolean  "email_missed_yesterday",                       default: true,       null: false
    t.string   "email_api_key",                    limit: 255
    t.boolean  "email_when_mentioned",                         default: true,       null: false
    t.boolean  "angular_ui_enabled",                           default: false,      null: false
    t.boolean  "email_on_participation",                       default: true,       null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["key"], name: "index_users_on_key", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unsubscribe_token"], name: "index_users_on_unsubscribe_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255, null: false
    t.integer  "item_id",                null: false
    t.string   "event",      limit: 255, null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "motion_id"
    t.integer  "user_id"
    t.string   "position",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "statement",        limit: 255
    t.integer  "age",                          default: 0, null: false
    t.integer  "previous_vote_id"
  end

  add_index "votes", ["motion_id", "user_id", "age"], name: "vote_age_per_user_per_motion", unique: true, using: :btree
  add_index "votes", ["motion_id", "user_id"], name: "index_votes_on_motion_id_and_user_id", using: :btree
  add_index "votes", ["motion_id"], name: "index_votes_on_motion_id", using: :btree

end
