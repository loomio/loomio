class PollTemplate < ApplicationRecord
  include Discard::Model
  include HasRichText
  include CustomCounterCache::Model

  is_rich_text on: :details

  belongs_to :author, class_name: "User"
  belongs_to :group, class_name: "Group"

  enum notify_on_closing_soon: {nobody: 0, author: 1, undecided_voters: 2, voters: 3}
  enum hide_results: {off: 0, until_vote: 1, until_closed: 2}
  enum stance_reason_required: {disabled: 0, optional: 1, required: 2}

  update_counter_cache :group, :poll_templates_count

  validates :poll_type, inclusion: { in: AppConfig.poll_types.keys }
  validates :details, length: { maximum: Rails.application.secrets.max_message_length }
  validates :process_name, presence: true
  validates :process_subtitle, presence: true
  validates :default_duration_in_days, presence: true

  has_paper_trail only: [
    :poll_type,
    :process_name,
    :process_subtitle,
    :process_introduction,
    :process_introduction_format,
    :title,
    :details,
    :details_format,
    :group_id,
    :anonymous,
    :shuffle_options,
    :chart_type,
    :allow_long_reason,
    :specified_voters_only,
    :stance_reason_required,
    :notify_on_closing_soon,
    :hide_results,
    :min_score,
    :max_score,
    :minimum_stance_choices,
    :maximum_stance_choices,
    :dots_per_person,
    :reason_prompt,
    :poll_options,
    :limit_reason_length,
    :default_duration_in_days,
    :meeting_duration,
    :can_respond_maybe,
    :tags,
    :discarded_at
  ]

end
