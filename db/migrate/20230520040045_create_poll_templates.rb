class CreatePollTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :poll_templates do |t|
      t.string :handle
      t.integer :group_id, null: false
      t.integer :position, default: 0, null: false
      t.integer "author_id", null: false
      t.string "poll_type", null: false
      t.string "process_name"
      t.string "process_subtitle"
      t.string "process_url"
      t.string "title", null: false
      t.text   "details"
      t.string "details_format", limit: 10, default: "md", null: false
      t.boolean "notify_on_participate", default: false, null: false
      t.boolean "anonymous", default: false, null: false
      t.boolean "specified_voters_only", default: false, null: false
      t.integer "notify_on_closing_soon", default: 0, null: false
      t.string "content_locale"
      t.boolean "shuffle_options", default: false, null: false
      t.boolean "allow_long_reason", default: false, null: false
      t.integer "hide_results", default: 0, null: false
      t.string "chart_type"
      t.integer "min_score"
      t.integer "max_score"
      t.integer "minimum_stance_choices"
      t.integer "maximum_stance_choices"
      t.integer "dots_per_person"
      t.string "reason_prompt"
      t.jsonb "poll_options", default: [], null: false
      t.integer "stance_reason_required", default: 1, null: false
      t.boolean "limit_reason_length", default: true, null: false
      t.integer "default_duration_in_days"
      t.integer "agree_target"
      t.timestamps
    end
  end
end
