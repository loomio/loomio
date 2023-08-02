class DiscussionTemplate < ApplicationRecord
  include Discard::Model
  include HasRichText
  include CustomCounterCache::Model

  is_rich_text on: :description

  belongs_to :author, class_name: "User"
  belongs_to :group, class_name: "Group"

  update_counter_cache :group, :discussion_templates_count

  validates :description, length: { maximum: Rails.application.secrets.max_message_length }
  validates :process_name, presence: true
  validates :process_subtitle, presence: true

  has_paper_trail only: [
    :title,
    :process_name,
    :process_subtitle,
    :process_introduction,
    :process_introduction_format,
    :details,
    :details_format,
    :group_id,
    :tags,
    :discarded_at
  ]
end
