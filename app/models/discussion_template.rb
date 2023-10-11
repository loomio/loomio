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
  # validates :process_subtitle, presence: true

  has_paper_trail only: [
    :public,
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

  def dump_i18n
    out = {}
    [
    :title,
    :title_placeholder,
    :process_name,
    :process_subtitle,
    :process_introduction,
    :description,
    ].map(&:to_s).each do |key|
      value = self[key]
      next unless value
      value.strip! if value.respond_to? :strip!
      out[key] = value
    end

    tags.each do |tag|
      out[tag.underscore.gsub(" ", "_")] = tag
    end

    {process_name.strip.underscore.gsub(" ", "_") => out}
  end

  def poll_templates
    PollTemplate.where(id: poll_template_ids)
  end

  def poll_template_ids
    self.poll_template_keys_or_ids.filter do |key_or_id| 
      key_or_id.is_a? Integer
    end
  end
end
