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

ActiveRecord::Schema.define(version: 20160919091714) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
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
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
    t.index ["resource_type", "resource_id"], name: "index_admin_notes_on_resource_type_and_resource_id", using: :btree
  end

  create_table "ahoy_events", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid     "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.jsonb    "properties"
    t.datetime "time"
    t.index ["properties"], name: "ahoy_events_properties", using: :gin
    t.index ["time"], name: "index_ahoy_events_on_time", using: :btree
    t.index ["user_id"], name: "index_ahoy_events_on_user_id", using: :btree
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id", using: :btree
  end

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
    t.index ["token"], name: "index_ahoy_messages_on_token", using: :btree
    t.index ["user_id", "user_type"], name: "index_ahoy_messages_on_user_id_and_user_type", using: :btree
  end

  create_table "announcement_dismissals", force: :cascade do |t|
    t.integer  "announcement_id"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["announcement_id"], name: "index_announcement_dismissals_on_announcement_id", using: :btree
    t.index ["user_id"], name: "index_announcement_dismissals_on_user_id", using: :btree
  end

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
    t.index ["comment_id"], name: "index_attachments_on_comment_id", using: :btree
  end

  create_table "blacklisted_passwords", force: :cascade do |t|
    t.string   "string",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["string"], name: "index_blacklisted_passwords_on_string", using: :hash
  end

  create_table "blog_stories", force: :cascade do |t|
    t.string   "title"
    t.string   "url"
    t.string   "image_url"
    t.datetime "published_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

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

  create_table "cohorts", force: :cascade do |t|
    t.date "start_on"
    t.date "end_on"
  end

  create_table "comment_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "tag_anc_desc_udx", unique: true, using: :btree
    t.index ["descendant_id"], name: "tag_desc_idx", using: :btree
  end

  create_table "comment_votes", force: :cascade do |t|
    t.integer  "comment_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["comment_id"], name: "index_comment_votes_on_comment_id", using: :btree
    t.index ["created_at"], name: "index_comment_votes_on_created_at", using: :btree
    t.index ["user_id"], name: "index_comment_votes_on_user_id", using: :btree
  end

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
    t.integer  "versions_count",                  default: 0
    t.index ["created_at"], name: "index_comments_on_created_at", using: :btree
    t.index ["discussion_id"], name: "index_comments_on_commentable_id", using: :btree
    t.index ["discussion_id"], name: "index_comments_on_discussion_id", using: :btree
    t.index ["parent_id"], name: "index_comments_on_parent_id", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

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
    t.index ["user_id"], name: "index_contacts_on_user_id", using: :btree
  end

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
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "did_not_votes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "motion_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["motion_id"], name: "index_did_not_votes_on_motion_id", using: :btree
    t.index ["user_id"], name: "index_did_not_votes_on_user_id", using: :btree
  end

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
    t.index ["discussion_id"], name: "index_motion_read_logs_on_discussion_id", using: :btree
    t.index ["participating"], name: "index_discussion_readers_on_participating", using: :btree
    t.index ["starred"], name: "index_discussion_readers_on_starred", using: :btree
    t.index ["user_id", "discussion_id"], name: "index_discussion_readers_on_user_id_and_discussion_id", unique: true, using: :btree
    t.index ["user_id", "volume"], name: "index_discussion_readers_on_user_id_and_volume", using: :btree
    t.index ["user_id"], name: "index_motion_read_logs_on_user_id", using: :btree
    t.index ["volume"], name: "index_discussion_readers_on_volume", using: :btree
  end

  create_table "discussion_search_vectors", force: :cascade do |t|
    t.integer  "discussion_id"
    t.tsvector "search_vector"
    t.index ["discussion_id"], name: "index_discussion_search_vectors_on_discussion_id", using: :btree
    t.index ["search_vector"], name: "discussion_search_vector_index", using: :gin
  end

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
    t.string   "title",                limit: 255
    t.datetime "last_comment_at"
    t.text     "description"
    t.boolean  "uses_markdown",                    default: false, null: false
    t.boolean  "is_deleted",                       default: false, null: false
    t.integer  "items_count",                      default: 0,     null: false
    t.datetime "archived_at"
    t.boolean  "private"
    t.string   "key",                  limit: 255
    t.string   "iframe_src",           limit: 255
    t.datetime "last_activity_at"
    t.integer  "motions_count",                    default: 0
    t.integer  "last_sequence_id",                 default: 0,     null: false
    t.integer  "first_sequence_id",                default: 0,     null: false
    t.integer  "salient_items_count",              default: 0,     null: false
    t.integer  "versions_count",                   default: 0
    t.integer  "closed_motions_count",             default: 0,     null: false
    t.index ["author_id"], name: "index_discussions_on_author_id", using: :btree
    t.index ["created_at"], name: "index_discussions_on_created_at", using: :btree
    t.index ["group_id"], name: "index_discussions_on_group_id", using: :btree
    t.index ["is_deleted", "archived_at"], name: "index_discussions_on_is_deleted_and_archived_at", using: :btree
    t.index ["is_deleted"], name: "index_discussions_on_is_deleted", using: :btree
    t.index ["key"], name: "index_discussions_on_key", unique: true, using: :btree
    t.index ["last_activity_at"], name: "index_discussions_on_last_activity_at", order: {"last_activity_at"=>:desc}, using: :btree
    t.index ["private"], name: "index_discussions_on_private", using: :btree
  end

  create_table "drafts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "draftable_id"
    t.string  "draftable_type"
    t.json    "payload",        default: {}, null: false
  end

  create_table "events", force: :cascade do |t|
    t.string   "kind",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "eventable_id"
    t.string   "eventable_type", limit: 255
    t.integer  "user_id"
    t.integer  "discussion_id"
    t.integer  "sequence_id"
    t.index ["created_at"], name: "index_events_on_created_at", using: :btree
    t.index ["discussion_id", "sequence_id"], name: "index_events_on_discussion_id_and_sequence_id", unique: true, using: :btree
    t.index ["discussion_id"], name: "index_events_on_discussion_id", using: :btree
    t.index ["eventable_type", "eventable_id"], name: "index_events_on_eventable_type_and_eventable_id", using: :btree
    t.index ["sequence_id"], name: "index_events_on_sequence_id", using: :btree
  end

  create_table "group_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "group_anc_desc_udx", unique: true, using: :btree
    t.index ["descendant_id"], name: "group_desc_idx", using: :btree
  end

  create_table "group_measurements", force: :cascade do |t|
    t.integer "group_id"
    t.date    "period_end_on"
    t.integer "members_count"
    t.integer "admins_count"
    t.integer "subgroups_count"
    t.integer "invitations_count"
    t.integer "discussions_count"
    t.integer "proposals_count"
    t.integer "comments_count"
    t.integer "likes_count"
    t.integer "group_visits_count"
    t.integer "group_member_visits_count"
    t.integer "organisation_visits_count"
    t.integer "organisation_member_visits_count"
    t.integer "age",                              null: false
    t.index ["group_id", "period_end_on"], name: "index_group_measurements_on_group_id_and_period_end_on", unique: true, using: :btree
    t.index ["group_id"], name: "index_group_measurements_on_group_id", using: :btree
    t.index ["period_end_on"], name: "index_group_measurements_on_period_end_on", using: :btree
  end

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
    t.index ["group_id"], name: "index_group_requests_on_group_id", using: :btree
  end

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

  create_table "group_visits", force: :cascade do |t|
    t.uuid     "visit_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "member",     default: false, null: false
    t.index ["created_at"], name: "index_group_visits_on_created_at", using: :btree
    t.index ["group_id"], name: "index_group_visits_on_group_id", using: :btree
    t.index ["member"], name: "index_group_visits_on_member", using: :btree
    t.index ["visit_id", "group_id"], name: "index_group_visits_on_visit_id_and_group_id", unique: true, using: :btree
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name",                               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.boolean  "is_visible_to_public",                           default: true,           null: false
    t.boolean  "is_visible_to_parent_members",                   default: false,          null: false
    t.string   "discussion_privacy_options",         limit: 255,                          null: false
    t.boolean  "members_can_add_members",                        default: true,           null: false
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
    t.boolean  "members_can_create_subgroups",                   default: false,          null: false
    t.integer  "creator_id"
    t.boolean  "is_commercial"
    t.boolean  "is_referral",                                    default: false,          null: false
    t.integer  "cohort_id"
    t.integer  "default_group_cover_id"
    t.integer  "subscription_id"
    t.integer  "motions_count",                                  default: 0,              null: false
    t.integer  "admin_memberships_count",                        default: 0,              null: false
    t.integer  "invitations_count",                              default: 0,              null: false
    t.integer  "public_discussions_count",                       default: 0,              null: false
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.integer  "closed_motions_count",                           default: 0,              null: false
    t.boolean  "enable_experiments",                             default: false
    t.boolean  "analytics_enabled",                              default: false,          null: false
    t.integer  "proposal_outcomes_count",                        default: 0,              null: false
    t.jsonb    "experiences",                                    default: {},             null: false
    t.index ["category_id"], name: "index_groups_on_category_id", using: :btree
    t.index ["cohort_id"], name: "index_groups_on_cohort_id", using: :btree
    t.index ["created_at"], name: "index_groups_on_created_at", using: :btree
    t.index ["default_group_cover_id"], name: "index_groups_on_default_group_cover_id", using: :btree
    t.index ["full_name"], name: "index_groups_on_full_name", using: :btree
    t.index ["is_visible_to_public"], name: "index_groups_on_is_visible_to_public", using: :btree
    t.index ["key"], name: "index_groups_on_key", unique: true, using: :btree
    t.index ["name"], name: "index_groups_on_name", using: :btree
    t.index ["parent_id"], name: "index_groups_on_parent_id", using: :btree
    t.index ["parent_members_can_see_discussions"], name: "index_groups_on_parent_members_can_see_discussions", using: :btree
  end

  create_table "invitations", force: :cascade do |t|
    t.string   "recipient_email"
    t.integer  "inviter_id"
    t.boolean  "to_be_admin",                 default: false, null: false
    t.string   "token",           limit: 255,                 null: false
    t.datetime "accepted_at"
    t.string   "intent",          limit: 255
    t.integer  "canceller_id"
    t.datetime "cancelled_at"
    t.string   "recipient_name",  limit: 255
    t.integer  "invitable_id"
    t.string   "invitable_type",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "single_use",                  default: true,  null: false
    t.text     "message"
    t.integer  "send_count",                  default: 0,     null: false
    t.index ["accepted_at"], name: "index_invitations_on_accepted_at", where: "(accepted_at IS NULL)", using: :btree
    t.index ["created_at"], name: "index_invitations_on_created_at", using: :btree
    t.index ["invitable_type", "invitable_id"], name: "index_invitations_on_invitable_type_and_invitable_id", using: :btree
    t.index ["token"], name: "index_invitations_on_token", using: :btree
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
    t.index ["email"], name: "index_membership_requests_on_email", using: :btree
    t.index ["group_id", "response"], name: "index_membership_requests_on_group_id_and_response", using: :btree
    t.index ["group_id"], name: "index_membership_requests_on_group_id", using: :btree
    t.index ["name"], name: "index_membership_requests_on_name", using: :btree
    t.index ["requestor_id"], name: "index_membership_requests_on_requestor_id", using: :btree
    t.index ["responder_id"], name: "index_membership_requests_on_responder_id", using: :btree
    t.index ["response"], name: "index_membership_requests_on_response", using: :btree
  end

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
    t.index ["created_at"], name: "index_memberships_on_created_at", using: :btree
    t.index ["group_id", "user_id", "is_suspended", "archived_at"], name: "active_memberships", using: :btree
    t.index ["group_id"], name: "index_memberships_on_group_id", using: :btree
    t.index ["inviter_id"], name: "index_memberships_on_inviter_id", using: :btree
    t.index ["user_id", "volume"], name: "index_memberships_on_user_id_and_volume", using: :btree
    t.index ["user_id"], name: "index_memberships_on_user_id", using: :btree
    t.index ["volume"], name: "index_memberships_on_volume", using: :btree
  end

  create_table "motion_readers", force: :cascade do |t|
    t.integer  "motion_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_read_at"
    t.integer  "read_votes_count",    default: 0, null: false
    t.integer  "read_activity_count", default: 0, null: false
    t.index ["user_id", "motion_id"], name: "index_motion_readers_on_user_id_and_motion_id", using: :btree
  end

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
    t.integer  "votes_count",                     default: 0,    null: false
    t.integer  "outcome_author_id"
    t.string   "key",                 limit: 255
    t.integer  "members_count",                   default: 0,    null: false
    t.integer  "voters_count",                    default: 0,    null: false
    t.index ["author_id"], name: "index_motions_on_author_id", using: :btree
    t.index ["closed_at"], name: "index_motions_on_closed_at", using: :btree
    t.index ["closing_at"], name: "index_motions_on_closing_at", using: :btree
    t.index ["created_at"], name: "index_motions_on_created_at", using: :btree
    t.index ["discussion_id", "closed_at"], name: "index_motions_on_discussion_id_and_closed_at", order: {"closed_at"=>:desc}, using: :btree
    t.index ["discussion_id"], name: "index_motions_on_discussion_id", using: :btree
    t.index ["key"], name: "index_motions_on_key", unique: true, using: :btree
  end

  create_table "network_coordinators", force: :cascade do |t|
    t.integer  "coordinator_id", null: false
    t.integer  "network_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["coordinator_id", "network_id"], name: "index_network_coordinators_on_coordinator_id_and_network_id", unique: true, using: :btree
  end

  create_table "network_membership_requests", force: :cascade do |t|
    t.integer  "requestor_id", null: false
    t.integer  "responder_id"
    t.integer  "group_id",     null: false
    t.integer  "network_id",   null: false
    t.boolean  "approved"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_id"], name: "index_network_membership_requests_on_group_id", using: :btree
    t.index ["network_id"], name: "index_network_membership_requests_on_network_id", using: :btree
  end

  create_table "network_memberships", force: :cascade do |t|
    t.integer  "group_id",   null: false
    t.integer  "network_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_id", "network_id"], name: "index_network_memberships_on_group_id_and_network_id", unique: true, using: :btree
  end

  create_table "networks", force: :cascade do |t|
    t.string   "name",             null: false
    t.string   "slug",             null: false
    t.text     "description"
    t.text     "joining_criteria"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_networks_on_name", unique: true, using: :btree
    t.index ["slug"], name: "index_networks_on_slug", unique: true, using: :btree
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
    t.boolean  "viewed",     default: false, null: false
    t.index ["created_at"], name: "index_notifications_on_created_at", order: {"created_at"=>:desc}, using: :btree
    t.index ["event_id"], name: "index_notifications_on_event_id", using: :btree
    t.index ["user_id"], name: "index_notifications_on_user_id", using: :btree
    t.index ["viewed"], name: "index_notifications_on_viewed", using: :btree
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree
  end

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
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree
  end

  create_table "omniauth_identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "email",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.string   "name",       limit: 255
    t.index ["email"], name: "index_personas_on_email", using: :btree
    t.index ["provider", "uid"], name: "index_omniauth_identities_on_provider_and_uid", using: :btree
    t.index ["user_id"], name: "index_personas_on_user_id", using: :btree
  end

  create_table "organisation_visits", force: :cascade do |t|
    t.uuid     "visit_id"
    t.integer  "organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "member",          default: false, null: false
    t.index ["created_at"], name: "index_organisation_visits_on_created_at", using: :btree
    t.index ["member"], name: "index_organisation_visits_on_member", using: :btree
    t.index ["organisation_id"], name: "index_organisation_visits_on_organisation_id", using: :btree
    t.index ["visit_id", "organisation_id"], name: "index_organisation_visits_on_visit_id_and_organisation_id", unique: true, using: :btree
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string  "kind"
    t.date    "expires_at"
    t.date    "trial_ended_at"
    t.date    "activated_at"
    t.integer "chargify_subscription_id"
    t.string  "plan"
    t.string  "payment_method",           default: "chargify", null: false
    t.index ["kind"], name: "index_subscriptions_on_kind", using: :btree
  end

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
    t.index ["translatable_type", "translatable_id"], name: "index_translations_on_translatable_type_and_translatable_id", using: :btree
  end

  create_table "user_deactivation_responses", force: :cascade do |t|
    t.integer "user_id"
    t.text    "body"
    t.index ["user_id"], name: "index_user_deactivation_responses_on_user_id", using: :btree
  end

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
    t.boolean  "angular_ui_enabled",                           default: true,       null: false
    t.boolean  "email_on_participation",                       default: false,      null: false
    t.integer  "default_membership_volume",                    default: 2,          null: false
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.jsonb    "experiences",                                  default: {},         null: false
    t.index ["deactivated_at"], name: "index_users_on_deactivated_at", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["key"], name: "index_users_on_key", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["unsubscribe_token"], name: "index_users_on_unsubscribe_token", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255, null: false
    t.integer  "item_id",                    null: false
    t.string   "event",          limit: 255, null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.jsonb    "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
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
    t.index ["user_id"], name: "index_visits_on_user_id", using: :btree
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "motion_id"
    t.integer  "user_id"
    t.string   "position",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "statement",        limit: 255
    t.integer  "age",                          default: 0, null: false
    t.integer  "previous_vote_id"
    t.index ["created_at"], name: "index_votes_on_created_at", using: :btree
    t.index ["motion_id", "user_id", "age"], name: "vote_age_per_user_per_motion", unique: true, using: :btree
    t.index ["motion_id", "user_id"], name: "index_votes_on_motion_id_and_user_id", using: :btree
    t.index ["motion_id"], name: "index_votes_on_motion_id", using: :btree
  end

  create_table "webhooks", force: :cascade do |t|
    t.integer "hookable_id"
    t.string  "hookable_type"
    t.string  "kind",                       null: false
    t.string  "uri",                        null: false
    t.text    "event_types",   default: [],              array: true
    t.index ["hookable_type", "hookable_id"], name: "index_webhooks_on_hookable_type_and_hookable_id", using: :btree
  end

end
