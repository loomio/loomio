require "test_helper"

class PollTemplateServiceTest < ActiveSupport::TestCase
  test "built-in templates with disagreement options require reasons when disagreeing" do
    templates = PollTemplateService.default_templates + PollTemplateService.example_templates
    templates_with_disagreement = templates.select do |template|
      template.poll_type == "proposal" &&
        template.poll_options.any? { |option| %w[disagree block].include?(option["icon"] || option[:icon]) }
    end

    assert_not_empty templates_with_disagreement
    templates_with_disagreement.each do |template|
      assert_equal "required_when_disagreeing", template.stance_reason_required, template.key
    end

    assert_equal "optional", templates.find { |template| template.key == "count" }.stance_reason_required
  end
end
