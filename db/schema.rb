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

ActiveRecord::Schema.define(version: 20150204230136) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false, index: {name: "index_admin_notes_on_resource_type_and_resource_id", with: ["resource_id"]}
    t.integer  "author_id"
    t.string   "author_type",   index: {name: "index_active_admin_comments_on_author_type_and_author_id", with: ["author_id"]}
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace",     index: {name: "index_active_admin_comments_on_namespace"}
  end

  create_table "announcement_dismissals", force: :cascade do |t|
    t.integer  "announcement_id", index: {name: "index_announcement_dismissals_on_announcement_id"}
    t.integer  "user_id",         index: {name: "index_announcement_dismissals_on_user_id"}
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "announcements", force: :cascade do |t|
    t.text     "message",    null: false
    t.string   "locale",     default: "en", null: false
    t.datetime "starts_at",  null: false
    t.datetime "ends_at",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attachments", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "filename"
    t.text     "location"
    t.integer  "comment_id", index: {name: "index_attachments_on_comment_id"}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "filesize"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string   "showcase_url"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "name",          null: false
    t.string   "manager_email", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "position",   default: 0, null: false
  end

  create_table "comment_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false, index: {name: "tag_anc_desc_udx", with: ["descendant_id", "generations"], unique: true}
    t.integer "descendant_id", null: false, index: {name: "tag_desc_idx"}
    t.integer "generations",   null: false
  end

  create_table "comment_search_vectors", force: :cascade do |t|
    t.integer  "comment_id"
    t.tsvector "search_vector", index: {name: "comment_search_vector_index", using: :gin}
  end

  create_table "comment_votes", force: :cascade do |t|
    t.integer  "comment_id", index: {name: "index_comment_votes_on_comment_id"}
    t.integer  "user_id",    index: {name: "index_comment_votes_on_user_id"}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "discussion_id",       default: 0, index: {name: "index_comments_on_commentable_id"}
    t.text     "body",                default: ""
    t.string   "subject",             default: ""
    t.integer  "user_id",             default: 0,     null: false, index: {name: "index_comments_on_user_id"}
    t.integer  "parent_id",           index: {name: "index_comments_on_parent_id"}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "uses_markdown",       default: false, null: false
    t.integer  "comment_votes_count", default: 0,     null: false
    t.integer  "attachments_count",   default: 0,     null: false
    t.text     "liker_ids_and_names"
    t.datetime "edited_at"
  end
  add_index "comments", ["discussion_id"], name: "index_comments_on_discussion_id"

  create_table "contact_messages", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.string   "email"
    t.text     "message"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "destination", default: "contact@loomio.org"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer  "user_id",    index: {name: "index_contacts_on_user_id"}
    t.string   "name"
    t.string   "email"
    t.string   "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, index: {name: "delayed_jobs_priority", with: ["run_at"]}
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "did_not_votes", force: :cascade do |t|
    t.integer  "user_id",    index: {name: "index_did_not_votes_on_user_id"}
    t.integer  "motion_id",  index: {name: "index_did_not_votes_on_motion_id"}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discussion_readers", force: :cascade do |t|
    t.integer  "user_id",             index: {name: "index_motion_read_logs_on_user_id"}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "discussion_id",       index: {name: "index_motion_read_logs_on_discussion_id"}
    t.datetime "last_read_at"
    t.integer  "read_comments_count"
    t.integer  "read_items_count",    default: 0, null: false
    t.boolean  "following"
  end
  add_index "discussion_readers", ["user_id", "discussion_id"], name: "index_discussion_read_logs_on_user_id_and_discussion_id"

  create_table "discussion_search_vectors", force: :cascade do |t|
    t.integer  "discussion_id"
    t.tsvector "search_vector", index: {name: "discussion_search_vector_index", using: :gin}
  end

  create_table "discussions", force: :cascade do |t|
    t.integer  "group_id",         index: {name: "index_discussions_on_group_id"}
    t.integer  "author_id",        index: {name: "index_discussions_on_author_id"}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.datetime "last_comment_at"
    t.text     "description"
    t.boolean  "uses_markdown",    default: false, null: false
    t.integer  "total_views",      default: 0,     null: false
    t.boolean  "is_deleted",       default: false, null: false, index: {name: "index_discussions_on_is_deleted"}
    t.integer  "comments_count",   default: 0,     null: false
    t.integer  "items_count",      default: 0,     null: false
    t.datetime "archived_at"
    t.boolean  "private"
    t.string   "key",              index: {name: "index_discussions_on_key", unique: true}
    t.string   "iframe_src"
    t.datetime "last_activity_at"
    t.integer  "motions_count",    default: 0
  end
  add_index "discussions", ["is_deleted", "group_id"], name: "index_discussions_on_is_deleted_and_group_id"
  add_index "discussions", ["is_deleted", "id"], name: "index_discussions_on_is_deleted_and_id"

  create_table "events", force: :cascade do |t|
    t.string   "kind"
    t.datetime "created_at",     index: {name: "index_events_on_created_at"}
    t.datetime "updated_at"
    t.integer  "eventable_id"
    t.string   "eventable_type", index: {name: "index_events_on_eventable_type_and_eventable_id", with: ["eventable_id"]}
    t.integer  "user_id"
    t.integer  "discussion_id",  index: {name: "index_events_on_discussion_id"}
    t.integer  "sequence_id"
  end
  add_index "events", ["discussion_id", "sequence_id"], name: "index_events_on_discussion_id_and_sequence_id", unique: true

  create_table "group_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false, index: {name: "group_anc_desc_udx", with: ["descendant_id", "generations"], unique: true}
    t.integer "descendant_id", null: false, index: {name: "group_desc_idx"}
    t.integer "generations",   null: false
  end

  create_table "group_requests", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "admin_email"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "status"
    t.integer  "group_id",            index: {name: "index_group_requests_on_group_id"}
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

  create_table "group_setups", force: :cascade do |t|
    t.integer  "group_id"
    t.string   "group_name"
    t.text     "group_description"
    t.string   "viewable_by",            default: "members"
    t.string   "members_invitable_by",   default: "admins"
    t.string   "discussion_title"
    t.text     "discussion_description"
    t.string   "motion_title"
    t.text     "motion_description"
    t.date     "close_at_date"
    t.string   "close_at_time_zone"
    t.string   "close_at_time"
    t.string   "admin_email"
    t.text     "recipients"
    t.string   "message_subject"
    t.text     "message_body"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name",                               index: {name: "index_groups_on_name"}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "privacy",                            default: "private"
    t.string   "members_invitable_by"
    t.integer  "parent_id",                          index: {name: "index_groups_on_parent_id"}
    t.boolean  "hide_members",                       default: false
    t.text     "description"
    t.integer  "memberships_count",                  default: 0,              null: false
    t.datetime "archived_at",                        index: {name: "index_groups_on_archived_at_and_id", with: ["id"]}
    t.integer  "max_size",                           default: 1000,           null: false
    t.boolean  "cannot_contribute",                  default: false
    t.integer  "distribution_metric"
    t.string   "sectors"
    t.string   "other_sector"
    t.integer  "discussions_count",                  default: 0,              null: false
    t.string   "country_name"
    t.datetime "setup_completed_at"
    t.boolean  "next_steps_completed",               default: false,          null: false
    t.string   "full_name",                          index: {name: "index_groups_on_full_name"}
    t.string   "payment_plan",                       default: "undetermined"
    t.boolean  "parent_members_can_see_discussions", default: false,          null: false
    t.string   "key",                                index: {name: "index_groups_on_key", unique: true}
    t.boolean  "can_start_group",                    default: true
    t.integer  "category_id",                        index: {name: "index_groups_on_category_id"}
    t.text     "enabled_beta_features"
    t.string   "subdomain"
    t.integer  "theme_id"
    t.boolean  "is_visible_to_public",               default: false,          null: false, index: {name: "index_groups_on_is_visible_to_public"}
    t.boolean  "is_visible_to_parent_members",       default: false,          null: false
    t.string   "discussion_privacy_options",         null: false
    t.boolean  "members_can_add_members",            default: false,          null: false
    t.string   "membership_granted_upon",            null: false
    t.boolean  "members_can_edit_discussions",       default: true,           null: false
    t.boolean  "motions_can_be_edited",              default: false,          null: false
    t.string   "cover_photo_file_name"
    t.string   "cover_photo_content_type"
    t.integer  "cover_photo_file_size"
    t.datetime "cover_photo_updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.boolean  "members_can_edit_comments",          default: true
    t.boolean  "members_can_raise_motions",          default: true,           null: false
    t.boolean  "members_can_vote",                   default: true,           null: false
    t.boolean  "members_can_start_discussions",      default: true,           null: false
    t.boolean  "members_can_create_subgroups",       default: true,           null: false
    t.integer  "creator_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.string   "recipient_email", null: false
    t.integer  "inviter_id",      null: false
    t.boolean  "to_be_admin",     default: false, null: false
    t.string   "token",           null: false, index: {name: "index_invitations_on_token"}
    t.integer  "accepted_by_id"
    t.datetime "accepted_at"
    t.string   "intent"
    t.integer  "canceller_id"
    t.datetime "cancelled_at"
    t.string   "recipient_name"
    t.integer  "invitable_id"
    t.string   "invitable_type"
  end

  create_table "membership_requests", force: :cascade do |t|
    t.string   "name",         index: {name: "index_membership_requests_on_name"}
    t.string   "email",        index: {name: "index_membership_requests_on_email"}
    t.text     "introduction"
    t.integer  "group_id",     index: {name: "index_membership_requests_on_group_id"}
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "requestor_id", index: {name: "index_membership_requests_on_requestor_id"}
    t.integer  "responder_id", index: {name: "index_membership_requests_on_responder_id"}
    t.string   "response",     index: {name: "index_membership_requests_on_response"}
    t.datetime "responded_at"
  end
  add_index "membership_requests", ["group_id", "response"], name: "index_membership_requests_on_group_id_and_response"

  create_table "memberships", force: :cascade do |t|
    t.integer  "group_id",                            index: {name: "index_memberships_on_group_id"}
    t.integer  "user_id",                             index: {name: "index_memberships_on_user_id"}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "inviter_id",                          index: {name: "index_memberships_on_inviter_id"}
    t.boolean  "email_new_discussions_and_proposals", default: true
    t.datetime "archived_at"
    t.integer  "inbox_position",                      default: 0
    t.boolean  "admin",                               default: false, null: false
    t.boolean  "is_suspended",                        default: false, null: false
    t.boolean  "following_by_default",                default: false, null: false
  end

  create_table "motion_readers", force: :cascade do |t|
    t.integer  "motion_id"
    t.integer  "user_id",             index: {name: "index_motion_readers_on_user_id_and_motion_id", with: ["motion_id"]}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_read_at"
    t.integer  "read_votes_count",    default: 0, null: false
    t.integer  "read_activity_count", default: 0, null: false
  end

  create_table "motion_search_vectors", force: :cascade do |t|
    t.integer  "motion_id"
    t.tsvector "search_vector", index: {name: "motion_search_vector_index", using: :gin}
  end

  create_table "motions", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "author_id",           index: {name: "index_motions_on_author_id"}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "closed_at"
    t.integer  "discussion_id",       index: {name: "index_motions_on_discussion_id"}
    t.text     "outcome"
    t.datetime "last_vote_at"
    t.boolean  "uses_markdown",       default: true, null: false
    t.integer  "yes_votes_count",     default: 0,    null: false
    t.integer  "no_votes_count",      default: 0,    null: false
    t.integer  "abstain_votes_count", default: 0,    null: false
    t.integer  "block_votes_count",   default: 0,    null: false
    t.datetime "closing_at"
    t.integer  "did_not_votes_count"
    t.integer  "votes_count",         default: 0,    null: false
    t.integer  "outcome_author_id"
    t.string   "key",                 index: {name: "index_motions_on_key", unique: true}
  end
  add_index "motions", ["discussion_id", "closed_at"], name: "index_motions_on_discussion_id_and_closed_at", order: {"discussion_id"=>:asc, "closed_at"=>:desc}

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id",    index: {name: "index_notifications_on_user_id"}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id",   index: {name: "index_notifications_on_event_id"}
    t.datetime "viewed_at",  index: {name: "index_notifications_on_viewed_at"}
  end
  add_index "notifications", ["event_id", "user_id"], name: "index_notifications_on_event_id_and_user_id"

  create_table "omniauth_identities", force: :cascade do |t|
    t.integer  "user_id",    index: {name: "index_personas_on_user_id"}
    t.string   "email",      index: {name: "index_personas_on_email"}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "provider",   index: {name: "index_omniauth_identities_on_provider_and_uid", with: ["uid"]}
    t.string   "uid"
    t.string   "name"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "group_id",   index: {name: "index_subscriptions_on_group_id"}
    t.decimal  "amount",     precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "profile_id"
  end

  create_table "themes", force: :cascade do |t|
    t.text     "style"
    t.string   "name"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
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
    t.hstore   "fields",            index: {name: "translations_gin_fields", using: :gin}
    t.string   "language"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "user_deactivation_responses", force: :cascade do |t|
    t.integer "user_id", index: {name: "index_user_deactivation_responses_on_user_id"}
    t.text    "body"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                               default: "",         null: false, index: {name: "index_users_on_email", unique: true}
    t.string   "encrypted_password",                  limit: 128, default: ""
    t.string   "reset_password_token",                index: {name: "index_users_on_reset_password_token", unique: true}
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.datetime "deactivated_at"
    t.boolean  "is_admin",                            default: false
    t.string   "avatar_kind",                         default: "initials", null: false
    t.string   "uploaded_avatar_file_name"
    t.string   "uploaded_avatar_content_type"
    t.integer  "uploaded_avatar_file_size"
    t.datetime "uploaded_avatar_updated_at"
    t.string   "avatar_initials"
    t.string   "username"
    t.boolean  "email_followed_threads",              default: true,       null: false
    t.boolean  "email_when_proposal_closing_soon",    default: true,       null: false
    t.string   "authentication_token"
    t.string   "unsubscribe_token",                   index: {name: "index_users_on_unsubscribe_token", unique: true}
    t.integer  "memberships_count",                   default: 0,          null: false
    t.boolean  "uses_markdown",                       default: false,      null: false
    t.string   "selected_locale"
    t.string   "time_zone"
    t.string   "key",                                 index: {name: "index_users_on_key", unique: true}
    t.string   "detected_locale"
    t.boolean  "email_missed_yesterday",              default: true,       null: false
    t.string   "email_api_key"
    t.boolean  "email_new_discussions_and_proposals", default: true,       null: false
    t.boolean  "email_when_mentioned",                default: true,       null: false
    t.boolean  "angular_ui_enabled",                  default: false,      null: false
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false, index: {name: "index_versions_on_item_type_and_item_id", with: ["item_id"]}
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "motion_id",        index: {name: "index_votes_on_motion_id"}
    t.integer  "user_id"
    t.string   "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "statement"
    t.integer  "age",              default: 0, null: false
    t.integer  "previous_vote_id"
  end
  add_index "votes", ["motion_id", "user_id", "age"], name: "vote_age_per_user_per_motion", unique: true, deferrable: :initially_immediate
  add_index "votes", ["motion_id", "user_id"], name: "index_votes_on_motion_id_and_user_id"

end
