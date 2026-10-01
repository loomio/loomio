class PollTemplate < ApplicationRecord
  include Hideable
  include DiscardableBy
  include HasRichText
  include CustomCounterCache::Model

  is_rich_text on: :details

  # Settings a template carries to the polls started from it. This single list
  # drives template files, permitted params, the serializer and the client.
  SETTINGS = %w[
    poll_type
    process_name
    process_subtitle
    process_introduction
    process_introduction_format
    title
    title_placeholder
    details
    details_format
    anonymous
    weighted_voting
    specified_voters_only
    notify_on_closing_soon
    notify_on_open
    content_locale
    shuffle_options
    show_none_of_the_above
    hide_results
    chart_type
    min_score
    max_score
    minimum_stance_choices
    maximum_stance_choices
    dots_per_person
    reason_prompt
    tags
    poll_options
    stance_reason_required
    limit_reason_length
    default_duration_in_days
    agree_target
    meeting_duration
    can_respond_maybe
    poll_option_name_format
    outcome_statement
    outcome_statement_format
    outcome_review_due_in_days
    quorum_pct
    allow_comments
    allow_reactions
    comment_length_max
  ].freeze

  POLL_OPTION_SETTINGS = %w[
    name
    icon
    meaning
    prompt
    priority
    test_operator
    test_percent
    test_against
  ].freeze

  attribute :example, :boolean, default: false

  belongs_to :author, class_name: "User"
  belongs_to :group, class_name: "Group"

  enum :notify_on_closing_soon, {nobody: 0, author: 1, undecided_voters: 2, voters: 3}
  enum :hide_results, {off: 0, until_vote: 1, until_closed: 2}
  enum :stance_reason_required, {
    disabled: 0,
    optional: 1,
    required: 2,
    required_for_disagree_or_block: 3,
    required_for_block: 4
  }

  update_counter_cache :group, :poll_templates_count

  validates :poll_type, inclusion: { in: AppConfig.poll_types.keys }
  validates :details, length: { maximum: AppConfig.app_features[:max_message_length] }
  validates :process_name, presence: true
  validates :process_subtitle, presence: true
  validates :default_duration_in_days, presence: true
  normalizes :quorum_pct, with: ->(v) { v.nil? ? nil : [ [ v, 0 ].max, 100 ].min }
  normalizes :comment_length_max, with: ->(v) { v.presence&.to_i }
  validate :weighted_voting_available

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
    :weighted_voting,
    :shuffle_options,
    :show_none_of_the_above,
    :chart_type,
    :specified_voters_only,
    :stance_reason_required,
    :notify_on_closing_soon,
    :notify_on_open,
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
    :comment_length_max,
    :hidden_at,
    :discarded_at,
    :attachments
  ]

  def dump_i18n
    out = {}
    [
    :title,
    :title_placeholder,
    :process_name,
    :process_subtitle,
    :process_introduction,
    :details,
    :reason_prompt,
    :outcome_statement
    ].map(&:to_s).each do |key|
      unless self.send(key) == AppConfig.poll_types.dig(self.poll_type, 'defaults', key)
        out[key] = self[key]
      end
    end

    tags.each do |tag|
      out[tag.underscore.gsub(" ", "_")] = tag
    end

    self.poll_options.each do |poll_option|
      option_name = poll_option.slice('name').values[0].parameterize(separator: '_').gsub('-', '_')
      poll_option.slice('name', 'meaning', 'prompt').each_pair do |key, value|
        if key == 'name'
          out[option_name] = value
        else
          out[option_name+"_"+key] = value
        end
      end
    end

    {process_name.underscore.gsub(" ", "_") => out}
  end

  private

  # Use the poll rule, so a template cannot save a combination that polls
  # started from it would reject.
  def weighted_voting_available
    return unless weighted_voting?
    return if Poll.weighted_voting_available?(poll_type: poll_type, anonymous: anonymous?)

    errors.add(:weighted_voting, :invalid)
  end
end
