class TemplateFileService
  VERSION = 1

  ATTRIBUTES = {
    "discussion_template" => DiscussionTemplate::SETTINGS,
    "poll_template" => PollTemplate::SETTINGS
  }.freeze


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
      value.to_h.slice(*PollTemplate::POLL_OPTION_SETTINGS) if value.respond_to?(:to_h)
    end
  end
  private_class_method :portable_poll_options
end
