class TemplateFileService
  VERSION = 1

  ATTRIBUTES = {
    "discussion_template" => %w[
      title
      title_placeholder
      description
      description_format
      process_name
      process_subtitle
      process_introduction
      process_introduction_format
      recipient_audience
      newest_first
      max_depth
      allow_concurrent_polls
      allow_comments
      allow_reactions
      comment_length_max
      public
      default_to_direct_discussion
      poll_template_keys_or_ids
      tags
      content_locale
    ],
    "poll_template" => %w[
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
    ]
  }.freeze

  POLL_OPTION_ATTRIBUTES = %w[
    name
    icon
    meaning
    prompt
    priority
    test_operator
    test_percent
    test_against
  ].freeze

  def self.export(template:)
    type = template.model_name.singular
    attributes = template.attributes.slice(*ATTRIBUTES.fetch(type))

    if type == "discussion_template"
      attributes["poll_template_keys_or_ids"] = portable_poll_template_keys(attributes["poll_template_keys_or_ids"])
    else
      attributes["poll_options"] = portable_poll_options(attributes["poll_options"])
    end

    {
      "loomio_template" => {
        "version" => VERSION,
        "type" => type,
        "template" => attributes
      }
    }
  end

  def self.portable_poll_template_keys(values)
    Array(values).grep(String).reject { |value| value.match?(/\A\d+\z/) }
  end
  private_class_method :portable_poll_template_keys

  def self.portable_poll_options(values)
    Array(values).filter_map do |value|
      value.to_h.slice(*POLL_OPTION_ATTRIBUTES) if value.respond_to?(:to_h)
    end
  end
  private_class_method :portable_poll_options
end
