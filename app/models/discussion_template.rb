class DiscussionTemplate < ApplicationRecord
  include Discard::Model
  include HasRichText
  include CustomCounterCache::Model

  is_rich_text on: :description

  belongs_to :author, class_name: "User"
  belongs_to :group, class_name: "Group"

  update_counter_cache :group, :discussion_templates_count

  validates :description, length: { maximum: Rails.application.secrets.max_message_length }
  # validates :process_name, presence: true
  # validates :process_subtitle, presence: true
  validates :title, presence: true

  has_paper_trail only: [
    :title,
    :process_name,
    :process_subtitle,
    :process_introduction,
    :process_introduction_format,
    :description,
    :description_format,
    :group_id,
    :tags,
    :discarded_at
  ]

  def members
    User.none
  end

  def dump_i18n_yaml
    out = {}
    [
    :title,
    :process_name,
    :process_subtitle,
    :process_introduction,
    :process_introduction_format,
    :description,
    :description_format,
    :group_id,
    :tags,
    :newest_first,
    :max_depth
    ].map(&:to_s).each do |key|
      out[key] = self[key]
    end

    {process_name.underscore.gsub(" ", "_") => out}.to_yaml
  end
end
