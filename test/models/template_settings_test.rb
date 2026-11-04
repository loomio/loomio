require "test_helper"

class TemplateSettingsTest < ActiveSupport::TestCase
  test "every template setting is a template attribute" do
    { PollTemplate => PollTemplate::SETTINGS, DiscussionTemplate => DiscussionTemplate::SETTINGS }.each do |model, settings|
      record = model.new
      settings.each { |setting| assert record.respond_to?(setting), "#{model} has no #{setting}" }
    end
  end

  test "the poll template serializer sends every setting" do
    template = PollTemplate.new(poll_type: "meeting", meeting_duration: 60, can_respond_maybe: false)

    json = PollTemplateSerializer.new(template, scope: { exclude_types: [] }).as_json.fetch(:poll_template)

    assert_empty PollTemplate::SETTINGS.map(&:to_sym) - json.keys
    assert_equal 60, json[:meeting_duration]
    assert_equal false, json[:can_respond_maybe]
  end
end
