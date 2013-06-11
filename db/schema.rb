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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130610051804) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "announcement_dismissals", :force => true do |t|
    t.integer  "announcement_id"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "announcement_dismissals", ["announcement_id"], :name => "index_announcement_dismissals_on_announcement_id"
  add_index "announcement_dismissals", ["user_id"], :name => "index_announcement_dismissals_on_user_id"

  create_table "announcements", :force => true do |t|
    t.text     "message",                      :null => false
    t.string   "locale",     :default => "en", :null => false
    t.datetime "starts_at",                    :null => false
    t.datetime "ends_at",                      :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "campaign_signups", :force => true do |t|
    t.integer  "campaign_id"
    t.string   "name"
    t.string   "email"
    t.boolean  "spam"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "campaign_signups", ["campaign_id"], :name => "index_campaign_signups_on_campaign_id"

  create_table "campaigns", :force => true do |t|
    t.string   "showcase_url"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "name",          :null => false
    t.string   "manager_email", :null => false
  end

  create_table "comment_votes", :force => true do |t|
    t.integer  "comment_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "comment_votes", ["comment_id"], :name => "index_comment_votes_on_comment_id"
  add_index "comment_votes", ["user_id"], :name => "index_comment_votes_on_user_id"

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id",      :default => 0
    t.string   "commentable_type",    :default => ""
    t.string   "title",               :default => ""
    t.text     "body",                :default => ""
    t.string   "subject",             :default => ""
    t.integer  "user_id",             :default => 0,     :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "uses_markdown",       :default => false, :null => false
    t.integer  "comment_votes_count", :default => 0,     :null => false
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["parent_id"], :name => "index_comments_on_parent_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "did_not_votes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "motion_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "did_not_votes", ["motion_id"], :name => "index_did_not_votes_on_motion_id"
  add_index "did_not_votes", ["user_id"], :name => "index_did_not_votes_on_user_id"

  create_table "discussion_read_logs", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "discussion_id"
    t.datetime "discussion_last_viewed_at"
  end

  add_index "discussion_read_logs", ["discussion_id"], :name => "index_motion_read_logs_on_discussion_id"
  add_index "discussion_read_logs", ["user_id", "discussion_id"], :name => "index_discussion_read_logs_on_user_id_and_discussion_id"
  add_index "discussion_read_logs", ["user_id"], :name => "index_motion_read_logs_on_user_id"

  create_table "discussions", :force => true do |t|
    t.integer  "group_id"
    t.integer  "author_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "title"
    t.datetime "last_comment_at"
    t.text     "description"
    t.boolean  "uses_markdown",   :default => true, :null => false
    t.integer  "total_views",     :default => 0,    :null => false
  end

  add_index "discussions", ["author_id"], :name => "index_discussions_on_author_id"
  add_index "discussions", ["group_id"], :name => "index_discussions_on_group_id"

  create_table "events", :force => true do |t|
    t.string   "kind"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "eventable_id"
    t.string   "eventable_type"
    t.integer  "user_id"
    t.integer  "discussion_id"
  end

  add_index "events", ["discussion_id"], :name => "index_events_on_discussion_id"
  add_index "events", ["eventable_id"], :name => "index_events_on_eventable_id"
  add_index "events", ["user_id"], :name => "index_events_on_user_id"

  create_table "group_requests", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "admin_email"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "status"
    t.integer  "group_id"
    t.boolean  "cannot_contribute"
    t.string   "expected_size"
    t.integer  "max_size",            :default => 50
    t.string   "robot_trap"
    t.integer  "distribution_metric"
    t.string   "sectors"
    t.string   "other_sector"
    t.string   "token"
    t.string   "admin_name"
    t.string   "country_name"
    t.boolean  "high_touch",          :default => false, :null => false
    t.datetime "approved_at"
    t.datetime "defered_until"
    t.integer  "approved_by_id"
    t.text     "why_do_you_want"
    t.text     "group_core_purpose"
    t.text     "admin_notes"
  end

  add_index "group_requests", ["group_id"], :name => "index_group_requests_on_group_id"

  create_table "group_setups", :force => true do |t|
    t.integer  "group_id"
    t.string   "group_name"
    t.text     "group_description"
    t.string   "viewable_by",            :default => "members"
    t.string   "members_invitable_by",   :default => "admins"
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
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "viewable_by"
    t.string   "members_invitable_by"
    t.integer  "parent_id"
    t.boolean  "email_new_motion",     :default => true
    t.boolean  "hide_members",         :default => false
    t.boolean  "beta_features",        :default => false
    t.text     "description"
    t.datetime "archived_at"
    t.integer  "memberships_count",    :default => 0,     :null => false
    t.integer  "max_size"
    t.boolean  "cannot_contribute",    :default => false
    t.integer  "distribution_metric"
    t.string   "sectors"
    t.string   "other_sector"
    t.integer  "discussions_count",    :default => 0,     :null => false
    t.integer  "motions_count",        :default => 0,     :null => false
    t.string   "country_name"
    t.datetime "setup_completed_at"
    t.boolean  "next_steps_completed", :default => false, :null => false
  end

  add_index "groups", ["parent_id"], :name => "index_groups_on_parent_id"

  create_table "invitations", :force => true do |t|
    t.string   "recipient_email",                    :null => false
    t.integer  "inviter_id",                         :null => false
    t.integer  "group_id",                           :null => false
    t.boolean  "to_be_admin",     :default => false, :null => false
    t.string   "token",                              :null => false
    t.integer  "accepted_by_id"
    t.datetime "accepted_at"
    t.string   "intent"
    t.integer  "canceller_id"
    t.datetime "cancelled_at"
  end

  add_index "invitations", ["group_id"], :name => "index_invitations_on_group_id"
  add_index "invitations", ["token"], :name => "index_invitations_on_token"

  create_table "membership_requests", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "introduction"
    t.integer  "group_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "requestor_id"
    t.integer  "responder_id"
    t.string   "response"
    t.datetime "responded_at"
  end

  add_index "membership_requests", ["email"], :name => "index_membership_requests_on_email"
  add_index "membership_requests", ["group_id"], :name => "index_membership_requests_on_group_id"
  add_index "membership_requests", ["name"], :name => "index_membership_requests_on_name"
  add_index "membership_requests", ["requestor_id"], :name => "index_membership_requests_on_requestor_id"
  add_index "membership_requests", ["responder_id"], :name => "index_membership_requests_on_responder_id"
  add_index "membership_requests", ["response"], :name => "index_membership_requests_on_response"

  create_table "memberships", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "access_level"
    t.integer  "inviter_id"
    t.datetime "group_last_viewed_at",                                :null => false
    t.boolean  "subscribed_to_notification_emails", :default => true
  end

  add_index "memberships", ["group_id"], :name => "index_memberships_on_group_id"
  add_index "memberships", ["inviter_id"], :name => "index_memberships_on_inviter_id"
  add_index "memberships", ["user_id"], :name => "index_memberships_on_user_id"

  create_table "motion_read_logs", :force => true do |t|
    t.integer  "motion_id"
    t.integer  "user_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.datetime "motion_last_viewed_at"
  end

  create_table "motions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "author_id"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "phase",              :default => "voting", :null => false
    t.string   "discussion_url",     :default => "",       :null => false
    t.datetime "close_at"
    t.integer  "discussion_id"
    t.string   "outcome"
    t.datetime "last_vote_at"
    t.boolean  "uses_markdown",      :default => true,     :null => false
    t.date     "close_at_date"
    t.string   "close_at_time"
    t.string   "close_at_time_zone"
  end

  add_index "motions", ["author_id"], :name => "index_motions_on_author_id"
  add_index "motions", ["discussion_id"], :name => "index_motions_on_discussion_id"

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "event_id"
    t.datetime "viewed_at"
  end

  add_index "notifications", ["event_id"], :name => "index_notifications_on_event_id"
  add_index "notifications", ["user_id"], :name => "index_notifications_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                                      :default => "",         :null => false
    t.string   "encrypted_password",                                         :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                              :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
    t.string   "name"
    t.string   "unconfirmed_email"
    t.string   "invitation_token",                             :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.datetime "deleted_at"
    t.string   "avatar_kind",                                                :default => "initials", :null => false
    t.string   "uploaded_avatar_file_name"
    t.string   "uploaded_avatar_content_type"
    t.integer  "uploaded_avatar_file_size"
    t.datetime "uploaded_avatar_updated_at"
    t.boolean  "has_read_system_notice",                                     :default => false,      :null => false
    t.boolean  "is_admin",                                                   :default => false
    t.string   "avatar_initials"
    t.string   "username"
    t.boolean  "subscribed_to_daily_activity_email",                         :default => true,       :null => false
    t.boolean  "subscribed_to_mention_notifications",                        :default => true,       :null => false
    t.boolean  "subscribed_to_proposal_closure_notifications",               :default => true,       :null => false
    t.string   "authentication_token"
    t.string   "unsubscribe_token"
    t.integer  "memberships_count",                                          :default => 0,          :null => false
    t.boolean  "uses_markdown",                                              :default => false
    t.string   "language_preference"
    t.string   "time_zone"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"
  add_index "users", ["invited_by_id"], :name => "index_users_on_invited_by_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unsubscribe_token"], :name => "index_users_on_unsubscribe_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "votes", :force => true do |t|
    t.integer  "motion_id"
    t.integer  "user_id"
    t.string   "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "statement"
  end

  add_index "votes", ["motion_id"], :name => "index_votes_on_motion_id"
  add_index "votes", ["user_id"], :name => "index_votes_on_user_id"

end
