class PollTemplate < ApplicationRecord
  include HasRichText

  is_rich_text on: :details

  belongs_to :author, class_name: "User"
  belongs_to :group, class_name: "Group"

  enum notify_on_closing_soon: {nobody: 0, author: 1, undecided_voters: 2, voters: 3}
  enum hide_results: {off: 0, until_vote: 1, until_closed: 2}
  enum stance_reason_required: {disabled: 0, optional: 1, required: 2}

  validates :poll_type, inclusion: { in: AppConfig.poll_types.keys }
  validates :details, length: {maximum: Rails.application.secrets.max_message_length }
  validates :process_name, presence: true
  validates :process_subtitle, presence: true
  validates :title, presence: true
  validates :details, presence: true

  # has_paper_trail only: [
  #   :author_id,
  #   :process_name,
  #   :process_subtitle,
  #   :process_url,
  #   :title,
  #   :details,
  #   :details_format,
  #   :group_id,
  #   :anonymous,
  #   :stances_in_discussion,
  #   :voter_can_add_options,
  #   :anyone_can_participate,
  #   :specified_voters_only,
  #   :stance_reason_required,
  #   :notify_on_closing_soon,
  #   :hide_results]
end
