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

ActiveRecord::Schema.define(:version => 20120821031839) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "comment_votes", :force => true do |t|
    t.integer  "comment_id"
    t.integer  "user_id"
    t.boolean  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comment_votes", ["comment_id"], :name => "index_comment_votes_on_comment_id"
  add_index "comment_votes", ["user_id"], :name => "index_comment_votes_on_user_id"

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id",   :default => 0
    t.string   "commentable_type", :default => ""
    t.string   "title",            :default => ""
    t.text     "body"
    t.string   "subject",          :default => ""
    t.integer  "user_id",          :default => 0,  :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["parent_id"], :name => "index_comments_on_parent_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "did_not_votes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "motion_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "did_not_votes", ["motion_id"], :name => "index_did_not_votes_on_motion_id"
  add_index "did_not_votes", ["user_id"], :name => "index_did_not_votes_on_user_id"

  create_table "discussion_read_logs", :force => true do |t|
    t.integer  "discussion_activity_when_last_read"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "discussion_id"
  end

  add_index "discussion_read_logs", ["discussion_id"], :name => "index_motion_read_logs_on_discussion_id"
  add_index "discussion_read_logs", ["user_id"], :name => "index_motion_read_logs_on_user_id"

  create_table "discussions", :force => true do |t|
    t.integer  "group_id"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.integer  "activity",        :default => 0, :null => false
    t.datetime "last_comment_at"
  end

  add_index "discussions", ["author_id"], :name => "index_discussions_on_author_id"
  add_index "discussions", ["group_id"], :name => "index_discussions_on_group_id"

  create_table "events", :force => true do |t|
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "eventable_id"
    t.string   "eventable_type"
  end

  add_index "events", ["eventable_id"], :name => "index_events_on_eventable_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "viewable_by"
    t.string   "members_invitable_by"
    t.integer  "parent_id"
    t.boolean  "email_new_motion",     :default => true
    t.boolean  "hide_members",         :default => false
    t.boolean  "beta_features",        :default => false
    t.string   "description"
    t.integer  "creator_id",                              :null => false
    t.integer  "memberships_count",    :default => 0,     :null => false
    t.datetime "archived_at"
  end

  add_index "groups", ["parent_id"], :name => "index_groups_on_parent_id"

  create_table "memberships", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "access_level"
    t.integer  "inviter_id"
  end

  add_index "memberships", ["group_id"], :name => "index_memberships_on_group_id"
  add_index "memberships", ["inviter_id"], :name => "index_memberships_on_inviter_id"
  add_index "memberships", ["user_id"], :name => "index_memberships_on_user_id"

  create_table "motions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phase",          :default => "voting", :null => false
    t.string   "discussion_url", :default => "",       :null => false
    t.datetime "close_date"
    t.integer  "discussion_id"
  end

  add_index "motions", ["author_id"], :name => "index_motions_on_author_id"
  add_index "motions", ["discussion_id"], :name => "index_motions_on_discussion_id"

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
    t.datetime "viewed_at"
  end

  add_index "notifications", ["event_id"], :name => "index_notifications_on_event_id"
  add_index "notifications", ["user_id"], :name => "index_notifications_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                      :default => "",    :null => false
    t.string   "encrypted_password",                         :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                              :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                                      :default => false
    t.string   "name"
    t.string   "unconfirmed_email"
    t.string   "invitation_token",             :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.datetime "deleted_at"
    t.boolean  "has_read_system_notice",                     :default => false, :null => false
    t.boolean  "is_admin",                                   :default => false
    t.string   "avatar_kind"
    t.string   "uploaded_avatar_file_name"
    t.string   "uploaded_avatar_content_type"
    t.integer  "uploaded_avatar_file_size"
    t.datetime "uploaded_avatar_updated_at"
    t.string   "avatar_initials"
    t.boolean  "has_read_dashboard_notice",                  :default => false, :null => false
    t.boolean  "has_read_group_notice",                      :default => false, :null => false
    t.boolean  "has_read_discussion_notice",                 :default => false, :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"
  add_index "users", ["invited_by_id"], :name => "index_users_on_invited_by_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "votes", :force => true do |t|
    t.integer  "motion_id"
    t.integer  "user_id"
    t.string   "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "statement"
  end

  add_index "votes", ["motion_id"], :name => "index_votes_on_motion_id"
  add_index "votes", ["user_id"], :name => "index_votes_on_user_id"

end
